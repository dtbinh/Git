/*
 * UStepDevice.cpp
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#include "UStepDevice.h"
#include "debug.h"
#include <stdlib.h>
#include <pigpio.h>
#include <math.h>

#include "device_parameters.cpp"

#define S_TO_US   1000000
#define US_TO_S   0.000001

UStepDevice::UStepDevice()
{
  emergency_button_ = 0;
  front_switch_ = 0;
  back_switch_ = 0;

  configured_ = false;
  initialized_ = false;
}

void UStepDevice::configureMotorParameters()
{
  // Run a function in an external source file that fills the MotorParameters
  // structures with all the configuration parameters of the device
  // OBS: Ideally this information should be read from a configuration file
  declareDeviceParameters();

  // Set the parameters for each one of the motors
  insertion_.configureParameters(translation_parameters);
  rotation_.configureParameters(rotation_parameters);
  front_gripper_.configureParameters(front_gripper_parameters);
  back_gripper_.configureParameters(back_gripper_parameters);

  // Assign the port number of the inputs to the member variables
  emergency_button_ = PORT_EM;
  front_switch_ = PORT_FS;
  back_switch_ = PORT_BS;

  configured_ = true;
}

int UStepDevice::initGPIO()
{
  // Check if all the motor parameters have already been configured
  if(configured_)
  {
    // Attempt to initialize the Raspberry Pi GPIO
    if(gpioInitialise() < 0)
    {
      Debug("ERROR UStepDevice::initGPIO - Unable to call gpioInitialise() \n");
      return ERR_GPIO_INIT_FAIL;
    }

    // Init outputs
    insertion_.initGPIO();
    rotation_.initGPIO();
    front_gripper_.initGPIO();
    back_gripper_.initGPIO();

    // Init inputs
    gpioSetMode(emergency_button_, PI_INPUT);
    gpioSetPullUpDown(emergency_button_, PI_PUD_OFF);

    gpioSetMode(front_switch_, PI_INPUT);
    gpioSetPullUpDown(front_switch_, PI_PUD_DOWN);

    gpioSetMode(back_switch_, PI_INPUT);
    gpioSetPullUpDown(back_switch_, PI_PUD_DOWN);

    initialized_ = true;
    return 0;
  }

  // If the motor parameters have not been set, return an error code
  else
  {
    Debug("ERROR UStepDevice::initGPIO - Motor parameters not configured. You must call configureMotorParameters() before \n");
    return ERR_MOTOR_NOT_CONFIGURED;
  }
}

void UStepDevice::terminateGPIO()
{
  gpioTerminate();
  initialized_ = false;
}

void UStepDevice::openFrontGripper(){}
void UStepDevice::closeFrontGripper(){}
void UStepDevice::openBackGripper(){}
void UStepDevice::closeBackGripper(){}
void UStepDevice::insert(){}
void UStepDevice::retreat(){}
void UStepDevice::spin(){}


int UStepDevice::setInsertionWithDutyCycle(double insertion_depth_rev,  double insertion_speed, double rotation_speed, double duty_cycle)
{
  if(initialized_)
  {

    // VERIFY IF THE REQUESTED VALUES ARE WITHIN THE SECURITY LIMITS

    calculateDutyCycleMotionParameters(insertion_depth_rev, insertion_speed, rotation_speed, duty_cycle);
    gpioWaveClear();

    if(int result = generateWaveInsertionWithRotation())
    {
      Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave insertion with rotation \n");
      return result;
    }

    if(int result = generateWavePureInsertion())
    {
      Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave pure insertion \n");
      return result;
    }

    // SET SOME FLAGS TO SAY EVERYTHING WAS OK
    Debug("Vht = %u, Wht = %u\n", insertion_step_half_period_, rotation_step_half_period_);
    Debug("TDC = %u, Trot = %u, Tins = %u\n", micros_duty_cycle_period_, micros_rotation_, micros_pure_insertion_);
    Debug("N = %u, TR = %u\n", number_of_duty_cycle_periods_, micros_remaining_);
    Debug("Rotation Port = %u\n", rotation_.port_step());

  }

  else
  {
    Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Device not initialized. You must call initGPIO() before \n");
    return ERR_DEVICE_NOT_INITIALIZED;
  }

  return 0;
}

void UStepDevice::calculateDutyCycleMotionParameters(double insertion_depth_rev,  double insertion_speed_rev, double rotation_speed, double duty_cycle)
{
  // Get the step resolution of the insertion and rotation motors
  unsigned insertion_steps_per_revolution = insertion_.steps_per_revolution();
  unsigned rotation_steps_per_revolution = rotation_.steps_per_revolution();

  // Calculate the half period (in micros) of each step of the insertion wave
  double insertion_revolution_period = (1/insertion_speed_rev) * S_TO_US;
  insertion_step_half_period_ = round(insertion_revolution_period/(2*insertion_steps_per_revolution));

  // Calculate the duty cycle period (it must be a multiple of the insertion_step_half_period_)
  double requested_rotation_period = (1/rotation_speed) * S_TO_US;
  double requested_duty_cycle_period = requested_rotation_period/duty_cycle;
  micros_duty_cycle_period_ = floor(requested_duty_cycle_period/(2*insertion_step_half_period_))*2*insertion_step_half_period_;

  // Calculate the half period (in micros) of each step of the rotation wave
  unsigned expected_rotation_period = round(micros_duty_cycle_period_*duty_cycle);
  rotation_step_half_period_ = round(((double)(expected_rotation_period))/(2*rotation_steps_per_revolution));

  // Calculate the real period (after truncation) of the rotation and the pure insertion parts
  micros_rotation_ = rotation_.steps_per_revolution()*2*rotation_step_half_period_;
  micros_pure_insertion_ = micros_duty_cycle_period_ - micros_rotation_;

  // Calculate the total number of entire duty cycle periods that fit in the insertion depth
  // and the amount of remaining steps
  unsigned total_insertion_steps = round(insertion_depth_rev*insertion_steps_per_revolution);
  unsigned total_insertion_time = total_insertion_steps*2*insertion_step_half_period_;
  number_of_duty_cycle_periods_ = floor(((double)(total_insertion_time))/micros_duty_cycle_period_);
  micros_remaining_ = total_insertion_time - number_of_duty_cycle_periods_*micros_duty_cycle_period_;
}

int UStepDevice::generateWaveInsertionWithRotation()
{
  unsigned num_insertion_steps = micros_rotation_/(2*insertion_step_half_period_);
  unsigned num_rotation_steps = rotation_.steps_per_revolution();

  gpioPulse_t *insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, num_insertion_steps);
  gpioPulse_t *rotation_pulses = generatePulsesConstantSpeed(rotation_.port_step(), rotation_step_half_period_, num_rotation_steps);

  if(insertion_pulses >= 0 && rotation_pulses >= 0)
  {
    gpioWaveAddGeneric(2*num_insertion_steps, insertion_pulses);
    gpioWaveAddGeneric(2*num_rotation_steps, rotation_pulses);
    wave_insertion_with_rotation_ = gpioWaveCreate();
    free(insertion_pulses);
    free(rotation_pulses);

    if (wave_insertion_with_rotation_ >= 0)
    {
      // SET A FLAG TO INDICATE THE WAVE HAS BEEN CREATED
    }

    else
    {
      // SET A FLAG TO INDICATE THE WAVE HAS NOT BEEN CREATED

      Debug("ERROR UStepDevice::generateWaveInsertionWithRotation - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Debug("ERROR UStepDevice::generateWaveInsertionWithRotation - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

int UStepDevice::generateWavePureInsertion()
{
  gpioPulse_t *insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, 1);

  if(insertion_pulses >= 0)
  {
    gpioWaveAddGeneric(2, insertion_pulses);
    wave_pure_insertion_ = gpioWaveCreate();
    free(insertion_pulses);

    if (wave_pure_insertion_ >= 0)
    {
      // SET A FLAG TO INDICATE THE WAVE HAS BEEN CREATED
    }

    else
    {
      // SET A FLAG TO INDICATE THE WAVE HAS NOT BEEN CREATED

      Debug("ERROR UStepDevice::generateWavePureInsertion - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Debug("ERROR UStepDevice::generateWavePureInsertion - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

gpioPulse_t* UStepDevice::generatePulsesConstantSpeed(unsigned port_number, unsigned half_period, unsigned num_steps)
{
  gpioPulse_t *pulses = (gpioPulse_t*) malloc(2*num_steps*sizeof(gpioPulse_t));

  if (pulses)
  {
    for(unsigned i_step = 0; i_step < num_steps; i_step++)
    {
      pulses[2*i_step].gpioOn = (1<<port_number);
      pulses[2*i_step].gpioOff = 0;
      pulses[2*i_step].usDelay = half_period;
      pulses[2*i_step+1].gpioOn = 0;
      pulses[2*i_step+1].gpioOff = (1<<port_number);
      pulses[2*i_step+1].usDelay = half_period;
    }
  }

  else
  {
    Debug("ERROR UStepDevice::generatePulsesConstantSpeed - Malloc error \n");
    return (gpioPulse_t*)ERR_MALLOC;
  }

  return pulses;
}


int UStepDevice::startInsertionWithDutyCycle()
{
  if(micros_remaining_ > 0)
  {
    for(unsigned n = 0; n < number_of_duty_cycle_periods_; n++)
    {
      gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, 0, micros_rotation_);
      gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
      gpioSleep(PI_TIME_RELATIVE, 0, micros_pure_insertion_);
    }
    gpioSleep(PI_TIME_RELATIVE, 0, micros_remaining_);
    gpioWaveTxStop();
  }
  else
  {
    for(unsigned n = 0; n < number_of_duty_cycle_periods_; n++)
    {
      gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, 0, micros_rotation_);
      gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
      gpioSleep(PI_TIME_RELATIVE, 0, micros_pure_insertion_);
    }
    gpioWaveTxStop();
  }

  return 0;
}
