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

#define WAVES_PRESENT_DC_ALWAYS               1
#define WAVES_PRESENT_DC_AND_REMAINING        2
#define WAVES_PRESENT_ROTATION_ALWAYS         3
#define WAVES_PRESENT_ROTATION_AND_REMAINING  4
#define WAVES_PRESENT_INSERTION_ONLY          5
#define WAVES_PRESENT_NONE                    -1

UStepDevice::UStepDevice()
{
  emergency_button_ = 0;
  front_switch_ = 0;
  back_switch_ = 0;

  dc_max_threshold_ = 1.0;
  dc_min_threshold_ = 0.0;

  configured_ = false;
  initialized_ = false;

  clearWaves();
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

  // Duty cycle parameters
  dc_max_threshold_ = MAX_DC;
  dc_min_threshold_ = MIN_DC;

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

int UStepDevice::setInsertionWithDutyCycle(double insertion_depth_rev,  double insertion_speed, double rotation_speed, double duty_cycle)
{
  if(initialized_)
  {

    // VERIFY IF THE REQUESTED VALUES ARE WITHIN THE SECURITY LIMITS
    // Values to be verified: insertion_speed and rotation_speed (min and max limits)
    // insertion_depth is not important, because of the limit switches
    // DC is not important, because I already check for boundary conditions latter on

    clearWaves();
    calculateDutyCycleMotionParameters(insertion_depth_rev, insertion_speed, rotation_speed, duty_cycle);

    if(rotation_step_half_period_ > 0)
    {
      if(int result = generateWaveInsertionWithRotation())
      {
        Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave insertion with rotation \n");
        return result;
      }
    }

    if(micros_pure_insertion_ > 0 || micros_remaining_ > 0)
    {
      if(int result = generateWavePureInsertion())
      {
        Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave pure insertion \n");
        return result;
      }
    }

    /*
    // SET SOME FLAGS TO SAY EVERYTHING WAS OK
    Debug("Vht = %u, Wht = %u\n", insertion_step_half_period_, rotation_step_half_period_);
    //Debug("TDC = %u, Trot = %u, Tins = %u\n", micros_duty_cycle_period_, micros_rotation_, micros_pure_insertion_);
    Debug("N = %u, TR = %u\n", num_dc_periods_, micros_remaining_);
    Debug("Rotation Port = %u\n", rotation_.port_step());*/

  }

  else
  {
    Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Device not initialized. You must call initGPIO() before \n");
    return ERR_DEVICE_NOT_INITIALIZED;
  }

  return 0;
}

int UStepDevice::startInsertion()
{
  if(initialized_)
  {
    Debug("DEBUG 0\n");
    Debug("Wave rot = %d, during %u(s) and %u(us)\n", wave_insertion_with_rotation_, seconds_rotation_, micros_rotation_);
    Debug("Wave insert = %d, during %u(s) and %u(us)\n", wave_pure_insertion_, seconds_pure_insertion_, micros_pure_insertion_);
    Debug("Number of DC periods = %u, remaining micros = %u\n", num_dc_periods_, micros_remaining_);
    switch (checkExistingWaves())
    {
      // Duty-cycle = 0: No rotation
      case WAVES_PRESENT_INSERTION_ONLY:
        Debug("DEBUG 1\n");
        gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
        gpioSleep(PI_TIME_RELATIVE, seconds_pure_insertion_, micros_pure_insertion_);
        gpioWaveTxStop();
        break;

      // Duty-cycle = 1: Insert always with rotation
      case WAVES_PRESENT_ROTATION_ALWAYS:
        Debug("DEBUG 2\n");
        for(unsigned i_dc_period = 0; i_dc_period < num_dc_periods_; i_dc_period++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_REPEAT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
        }
        gpioWaveTxStop();
        break;

      // Duty-cycle = 1: Insert with rotation and perform remaining insertion in the end
      case WAVES_PRESENT_ROTATION_AND_REMAINING:
        Debug("DEBUG 3\n");
        for(unsigned i_dc_period = 0; i_dc_period < num_dc_periods_; i_dc_period++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_REPEAT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
        }
        gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
        gpioSleep(PI_TIME_RELATIVE, 0, micros_remaining_);
        gpioWaveTxStop();
        break;

      // Duty-cycle between 0 and 1: Perform duty-cycle periods
      case WAVES_PRESENT_DC_ALWAYS:
        Debug("DEBUG 4\n");
        for(unsigned i_dc_period = 0; i_dc_period < num_dc_periods_; i_dc_period++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
          gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
          gpioSleep(PI_TIME_RELATIVE, seconds_pure_insertion_, micros_pure_insertion_);
        }
        gpioWaveTxStop();
        break;

      // Duty-cycle between 0 and 1: Perform duty-cycle periods and perform remaining insertion in the end
      case WAVES_PRESENT_DC_AND_REMAINING:
        Debug("DEBUG 5\n");
        for(unsigned n = 0; n < num_dc_periods_; n++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
          gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
          gpioSleep(PI_TIME_RELATIVE, seconds_pure_insertion_, micros_pure_insertion_);
        }
        gpioSleep(PI_TIME_RELATIVE, 0, micros_remaining_);
        gpioWaveTxStop();
        break;


      // Error: the waves have not been set
      case WAVES_PRESENT_NONE:
        Debug("ERROR UStepDevice::startInsertion - Waves not set \n");
        return ERR_DEVICE_NOT_INITIALIZED;

      default:
          break;
    }
  }

  else
  {
    Debug("ERROR UStepDevice::startInsertion - Device not initialized. You must call initGPIO() before \n");
    return ERR_DEVICE_NOT_INITIALIZED;
  }

  return 0;
}

void UStepDevice::clearWaves()
{
  if(initialized_)
  {
    gpioWaveClear();
  }

  wave_insertion_with_rotation_ = -1;
  wave_pure_insertion_ = -1;

  has_wave_pure_insertion_ = false;
  has_wave_insertion_with_rotation_ = false;
  has_wave_remaining_ = false;

  seconds_rotation_ = 0;
  seconds_pure_insertion_ = 0;
  micros_rotation_ = 0;
  micros_pure_insertion_ = 0;
  micros_remaining_ = 0;
  insertion_step_half_period_ = 0;
  rotation_step_half_period_ = 0;
  num_dc_periods_ = 0;
}

int UStepDevice::checkExistingWaves()
{
  if(has_wave_insertion_with_rotation_)
  {
    if(has_wave_pure_insertion_)
    {
      if(has_wave_remaining_)
        return WAVES_PRESENT_DC_AND_REMAINING;
      else
        return WAVES_PRESENT_DC_ALWAYS;
    }
    else
    {
      if(has_wave_remaining_)
        return WAVES_PRESENT_ROTATION_AND_REMAINING;
      else
        return WAVES_PRESENT_ROTATION_ALWAYS;
    }
  }
  else
  {
    if(has_wave_pure_insertion_)
      return WAVES_PRESENT_INSERTION_ONLY;
    else
      return WAVES_PRESENT_NONE;
  }
}

void UStepDevice::calculateDutyCycleMotionParameters(double insertion_depth_rev,  double insertion_speed_rev, double rotation_speed, double duty_cycle)
{
  if(duty_cycle <= dc_min_threshold_)
  {
    unsigned insertion_steps_per_revolution = insertion_.steps_per_revolution();
    double insertion_revolution_period = (1/insertion_speed_rev) * S_TO_US;
    insertion_step_half_period_ = round(insertion_revolution_period/(2*insertion_steps_per_revolution));

    unsigned total_insertion_steps = round(insertion_depth_rev*insertion_steps_per_revolution);
    micros_pure_insertion_ = total_insertion_steps*2*insertion_step_half_period_;

    rotation_step_half_period_ = 0;
    micros_rotation_ = 0;
    num_dc_periods_ = 0;
    micros_remaining_ = 0;
  }
  else
  {
    if(duty_cycle >= dc_max_threshold_)
      duty_cycle = 1.0;

    // Get the step resolution of the insertion and rotation motors
    unsigned insertion_steps_per_revolution = insertion_.steps_per_revolution();
    unsigned rotation_steps_per_revolution = rotation_.steps_per_revolution();

    // Calculate the half period (in micros) of each step of the insertion wave
    double insertion_revolution_period = (1/insertion_speed_rev) * S_TO_US;
    insertion_step_half_period_ = round(insertion_revolution_period/(2*insertion_steps_per_revolution));

    // Calculate the duty cycle period (it must be a multiple of the insertion_step_half_period_)
    double requested_rotation_period = (1/rotation_speed) * S_TO_US;
    double requested_duty_cycle_period = requested_rotation_period/duty_cycle;
    unsigned duty_cycle_period = floor(requested_duty_cycle_period/(2*insertion_step_half_period_))*2*insertion_step_half_period_;

    // Calculate the half period (in micros) of each step of the rotation wave
    unsigned expected_rotation_period = round(duty_cycle_period*duty_cycle);
    rotation_step_half_period_ = round(((double)(expected_rotation_period))/(2*rotation_steps_per_revolution));

    // Calculate the real period (after truncation) of the rotation and the pure insertion parts
    unsigned single_rotation_period = rotation_.steps_per_revolution()*2*rotation_step_half_period_;
    micros_rotation_ = ceil(((double)(single_rotation_period))/(2*insertion_step_half_period_))*2*insertion_step_half_period_;
    micros_pure_insertion_ = duty_cycle_period - micros_rotation_;

    // Calculate the total number of entire duty cycle periods that fit in the insertion depth
    // and the amount of remaining steps
    unsigned total_insertion_steps = round(insertion_depth_rev*insertion_steps_per_revolution);
    unsigned total_insertion_time = total_insertion_steps*2*insertion_step_half_period_;
    num_dc_periods_ = floor(((double)(total_insertion_time))/duty_cycle_period);
    micros_remaining_ = total_insertion_time - num_dc_periods_*duty_cycle_period;
  }
}

int UStepDevice::generateWaveInsertionWithRotation()
{
  unsigned num_insertion_steps = micros_rotation_/(2*insertion_step_half_period_);
  unsigned num_rotation_steps = rotation_.steps_per_revolution();

  gpioPulse_t *insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, num_insertion_steps);
  gpioPulse_t *rotation_pulses = generatePulsesConstantSpeed(rotation_.port_step(), rotation_step_half_period_, num_rotation_steps);

  unsigned total_pulse_difference = num_insertion_steps*2*insertion_step_half_period_ - num_rotation_steps*2*rotation_step_half_period_;
  rotation_pulses[2*num_rotation_steps-1].usDelay = rotation_step_half_period_ + total_pulse_difference;

  if(insertion_pulses >= 0 && rotation_pulses >= 0)
  {
    gpioWaveAddGeneric(2*num_insertion_steps, insertion_pulses);
    gpioWaveAddGeneric(2*num_rotation_steps, rotation_pulses);

    Debug("DEBUG: Creating wave insertion with rotation\n");
    Debug("Vstep_hT = %u, NV = %u, TotalV = %u\n", insertion_step_half_period_, num_insertion_steps, num_insertion_steps*2*insertion_step_half_period_);
    Debug("Wstep_hT = %u, NW = %u, TotalW = %u\n", rotation_step_half_period_, num_rotation_steps, num_rotation_steps*2*rotation_step_half_period_);

    wave_insertion_with_rotation_ = gpioWaveCreate();
    free(insertion_pulses);
    free(rotation_pulses);

    if (wave_insertion_with_rotation_ >= 0)
    {
      has_wave_insertion_with_rotation_ = true;
      seconds_rotation_ = (unsigned)(micros_rotation_*US_TO_S);
      micros_rotation_ = micros_rotation_ - S_TO_US*seconds_rotation_;
    }

    else
    {
      has_wave_insertion_with_rotation_ = false;
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
      if(micros_pure_insertion_ > 0)
      {
        has_wave_pure_insertion_ = true;
        seconds_pure_insertion_ = (unsigned)(micros_pure_insertion_*US_TO_S);
        micros_pure_insertion_ = micros_pure_insertion_ - S_TO_US*seconds_pure_insertion_;
      }
      if(micros_remaining_ > 0)
      {
        has_wave_remaining_ = true;
      }
    }

    else
    {
      has_wave_pure_insertion_ = false;
      has_wave_remaining_ = false;

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
