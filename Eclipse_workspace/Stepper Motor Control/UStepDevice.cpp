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

#define MAX_SPEED 4.0
#define ACC 250.0

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

    int result;

    clearWaves();

    if((result = calculateDutyCycleMotionParameters(insertion_depth_rev, insertion_speed, rotation_speed, duty_cycle)))
    {
      Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Bad parameters \n");
      return result;
    }


    if(rotation_step_half_period_ > 0)
    {
      if((result = generateWaveInsertionWithRotation()))
      {
        Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave insertion with rotation \n");
        return result;
      }
    }

    if(micros_pure_insertion_ > 0 || micros_remaining_ > 0)
    {
      if((result = generateWavePureInsertion()))
      {
        Debug("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave pure insertion \n");
        return result;
      }
    }
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


int UStepDevice::calculateDutyCycleMotionParameters(double insert_depth,  double insert_speed, double rot_speed, double duty_cycle)
{
  // Input units
  //   - insert_depth : The requested insertion distance in millimeters
  //   - insert_speed : The requested insertion speed in millimeters/second
  //   - rot_speed    : The requested rotation speed in revolutions/second
  //   - duty_cycle   : The requested duty cycle

  if(duty_cycle <= dc_min_threshold_)
  {
    // Save motor parameters to local variables
    double insert_revs_per_mm = 1;
    double insert_steps_per_rev = insertion_.steps_per_revolution();

    // Calculate the period of a single insertion step
    unsigned total_insert_distance_step = round(insert_depth * insert_revs_per_mm * insert_steps_per_rev);
    insertion_step_half_period_ = round((((insert_depth / insert_speed) * S_TO_US) / total_insert_distance_step) / 2);

    // Calculate the total time of the insertion
    micros_pure_insertion_ = 2*insertion_step_half_period_ * total_insert_distance_step;
  }

  else
  {
    if(duty_cycle >= dc_max_threshold_)
      duty_cycle = 1.0;

    // Expected continuous time quantities
    double exp_total_insert_time_s;             // The expected time of the insertion in s
    double exp_single_rot_time_s;               // The expected time of a single rotation in s
    double exp_single_dc_time_s;                // The expected time of a single duty cycle period in s

    // Discrete time quantities
    unsigned total_insert_time_us;              // The total time of the insertion in us
    unsigned single_dc_time_us;                 // The time of a single duty cycle period in us
    unsigned rot_insert_time_us;                // The rotation part of the duty cycle period in us
    unsigned pure_insert_time_us;                  // The pure insertion part of the duty cycle period in us
    unsigned remaining_insert_time_us;             // The remaining insertion type, to be performed after all duty cycle periods

    // Discrete parameters
    unsigned total_insert_distance_step;        // The requested insertion distance in steps
    unsigned half_step_insert_time_us;          // The time of half of an insertion step in us
    unsigned step_insert_time_us;               // The time of an insertion step in us
    unsigned half_step_rot_time_us;             // The time of half of a rotation step in us
    unsigned num_dc;                            // The total number of duty cycle periods in the insertion

    // Save motor parameters to local variables
    double insert_revs_per_mm = 1;
    unsigned insert_steps_per_rev = insertion_.steps_per_revolution();

    // Calculate in how many duty cycles, the insertion will be divided
    exp_total_insert_time_s = insert_depth / insert_speed;
    exp_single_rot_time_s = 1 / rot_speed;
    exp_single_dc_time_s = exp_single_rot_time_s / duty_cycle;
    num_dc = round(exp_total_insert_time_s / exp_single_dc_time_s);

    // Calculate the period of a single insertion step (this will be our time unit)
    total_insert_distance_step = round(insert_depth * insert_revs_per_mm * insert_steps_per_rev);
    half_step_insert_time_us = round(((exp_total_insert_time_s * S_TO_US) / total_insert_distance_step) / 2);
    step_insert_time_us = 2*half_step_insert_time_us;

    // Calculate all time windows
    total_insert_time_us = step_insert_time_us * total_insert_distance_step;
    single_dc_time_us = floor(total_insert_time_us / num_dc);
    single_dc_time_us = floor(single_dc_time_us/step_insert_time_us)*step_insert_time_us;
    rot_insert_time_us = floor(single_dc_time_us * duty_cycle);
    rot_insert_time_us = floor(rot_insert_time_us/step_insert_time_us)*step_insert_time_us;
    pure_insert_time_us = single_dc_time_us - rot_insert_time_us;
    remaining_insert_time_us = total_insert_time_us - (num_dc * single_dc_time_us);

    // Calculate the rotation speed profile
    int rot_us_delay = calculateRotationSpeed(rot_insert_time_us);
    if(rot_us_delay < 0)
    {
      Debug("ERROR UStepDevice::calculateDutyCycleMotionParameters - Can't perform a full rotation ramp in the requested time \n");
      return ERR_INVALID_ROTATION_RAMP;
    }

    half_step_rot_time_us = (unsigned)rot_us_delay;

    // Export the relevant calculated values to member variables
    num_dc_periods_ = num_dc;
    insertion_step_half_period_ = half_step_insert_time_us;
    rotation_step_half_period_ = half_step_rot_time_us;
    micros_rotation_ = rot_insert_time_us;
    micros_pure_insertion_ = pure_insert_time_us;
    micros_remaining_ = remaining_insert_time_us;

    return 0;
  }
}

int UStepDevice::calculateRotationSpeed(unsigned rot_insert_time_us)
{
  // Save parameters to local variables
  unsigned rot_steps_per_rev = rotation_.steps_per_revolution();
  double rot_base_speed = MAX_SPEED;
  double rot_acceleration = ACC;

  double constant_speed = ((double)(S_TO_US))/rot_insert_time_us;

  Debug("CALCULATING ROTATION SPEED \n\n");
  Debug("I have %u micros for one complete turn \n", rot_insert_time_us);
  Debug("If I go at constant speed, I would need to go at %f RPS\n", constant_speed);

  if(constant_speed <= rot_base_speed)
  {
    unsigned us_delay = floor((rot_insert_time_us / rot_steps_per_rev) / 2);

    Debug("This is ok. I'm going at %f RPS\n", constant_speed);
    Debug("Since one rev has %u steps, each step will take %u micros \n\n", rot_steps_per_rev, 2*us_delay);

    return us_delay;
  }

  else
  {
    double B = -(2*rot_base_speed + rot_acceleration*rot_insert_time_us*US_TO_S);
    double C = rot_acceleration + pow(rot_base_speed,2);
    double D = pow(B,2) - 4*C;

    if(D < 0)
    {
      // If this condition is achieved, it means the requested ramp is impossible
      // That means, achieving the peak speed would take more than half revolution
      // In standard cases, it should take less than 10% of a revolution
      // There are three ways to solve this problem
      //      Solution 1: Select a smaller rotation speed
      //      Solution 2: Increase the motor acceleration
      //      Solution 3: Change the 'calculateDutyCycleMotionParameters' function to account for acc and decc ramps
      //                  (currently this ramps are being ignored as they are assumed to take always less than 20% of a revolution
      Debug("ERROR UStepDevice::calculateRotationSpeed - Can't perform a full rotation ramp in the requested time \n");
      return ERR_INVALID_ROTATION_RAMP;
    }

    double final_speed = (-B -pow(D, 0.5))/2;
    unsigned us_delay = floor(((S_TO_US / final_speed) / rot_steps_per_rev) / 2);

    Debug("B=%f, C=%f, D=%f\n", B, C, D);
    Debug("That is too fast. I will start at %f and ramp up until %f \n", rot_base_speed, final_speed);
    Debug("Since one rev has %u steps, each step will take %u micros \n\n", rot_steps_per_rev, 2*us_delay);

    return us_delay;
  }
}

/*
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

    // Save the step resolution of the insertion and rotation motors to local variables
    unsigned insertion_steps_per_revolution = insertion_.steps_per_revolution();
    unsigned rotation_steps_per_revolution = rotation_.steps_per_revolution();

    // Calculate the half period (in micros) of each step of the insertion wave
    // This will be the time unit for calculating the other time windows of the duty cycle insertion
    double insertion_revolution_period = (1/insertion_speed_rev) * S_TO_US;
    insertion_step_half_period_ = round(insertion_revolution_period/(2*insertion_steps_per_revolution));

    // Calculate the duty cycle period as a multiple of the period of the insertion wave
    double requested_rotation_period = (1/rotation_speed) * S_TO_US;
    double requested_duty_cycle_period = requested_rotation_period/duty_cycle;
    unsigned duty_cycle_period = floor(requested_duty_cycle_period/(2*insertion_step_half_period_))*2*insertion_step_half_period_;

    // Split the duty_cycle period in the rotation and insertion part
    // Each part should also be a multiple of  the period of the insertion wave
    unsigned expected_rotation_period = round(duty_cycle_period*duty_cycle);
    micros_rotation_ = floor(expected_rotation_period/(2*insertion_step_half_period_))*2*insertion_step_half_period_;
    micros_pure_insertion_ = duty_cycle_period - micros_rotation_;


     * MAKE THE ROTATION WAVE FIT INSIDE MICROS_ROTATION_
     * APPROACH1: Constant speed
     *
     * APPROACH2: Ramp-up - Constant Seed - Ramp-down
     * Parameters for ramping
     *        - us_start (more and less defined)
     *        - us_final  (???)
     *        - acc (more and less defined)
     *        - N step (defined)
     * Condition: cumsum of us <= micros_rotation

    // Calculate the half period (in micros) of each step of the rotation wave
    rotation_step_half_period_ = floor(((double)(micros_rotation_))/(2*rotation_steps_per_revolution));

    // Calculate the total number of entire duty cycle periods that fit in the insertion depth
    // and the amount of remaining steps
    unsigned total_insertion_steps = round(insertion_depth_rev*insertion_steps_per_revolution);
    unsigned total_insertion_time = total_insertion_steps*2*insertion_step_half_period_;
    num_dc_periods_ = floor(((double)(total_insertion_time))/duty_cycle_period);
    micros_remaining_ = total_insertion_time - num_dc_periods_*duty_cycle_period;

    Debug("\n FINISHED CALCULATIONS\n\n");
    Debug("V_us = %u, W_us = %u, N_dc = %u\n", insertion_step_half_period_, rotation_step_half_period_, num_dc_periods_);
    Debug("T_dc = %u(us), T_rot = %u(us), T_ins = %u(us), T_rem = %u(us)\n\n", duty_cycle_period, micros_rotation_, micros_pure_insertion_, micros_remaining_);
  }
}
*/

int UStepDevice::generateWaveInsertionWithRotation()
{
  // Save parameters to local variables
  unsigned rot_steps_per_rev = rotation_.steps_per_revolution();
  double rot_base_speed = MAX_SPEED;
  double rot_acceleration = ACC;

  unsigned num_insertion_steps = micros_rotation_/(2*insertion_step_half_period_);
  unsigned num_rotation_steps = rot_steps_per_rev;

  //unsigned rotation_step_half_period_initial = round((rot_base_speed) / (2*num_rotation_steps));
  unsigned rotation_step_half_period_initial = round(((S_TO_US / rot_base_speed) / num_rotation_steps) / 2);
  double step_acceleration = rot_acceleration * num_rotation_steps;

  gpioPulse_t *insertion_pulses;
  gpioPulse_t *rotation_pulses;

  insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, num_insertion_steps);
  unsigned total_time = num_insertion_steps*2*insertion_step_half_period_;


  Debug("\nPreparing to generate the roation wave\n");

  double rot_frequency_initial = ((double)(S_TO_US))/(2*rotation_step_half_period_initial);
  double rot_frequency_final = ((double)(S_TO_US))/(2*rotation_step_half_period_);

  Debug("Init freq = %f, Final freq = %f\n", rot_frequency_initial, rot_frequency_final);
  if(rot_frequency_initial >= rot_frequency_final)
  {
    Debug("Generating rotation as a constant wave with us_delay = %u\n\n", rotation_step_half_period_);
    rotation_pulses = generatePulsesConstantSpeed(rotation_.port_step(), rotation_step_half_period_, num_rotation_steps);
    rotation_pulses[2*num_rotation_steps-1].usDelay += (total_time - num_rotation_steps*2*rotation_step_half_period_);
  }
  else
  {
    Debug("Generating a ramp profile from %u to %u\n\n", rotation_step_half_period_initial, rotation_step_half_period_);
    rotation_pulses = generatePulsesRampUpDown(rotation_.port_step(), rot_frequency_initial, rot_frequency_final, step_acceleration, num_rotation_steps, total_time);
  }

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

gpioPulse_t* UStepDevice::generatePulsesRampUpDown(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, unsigned num_steps, unsigned total_time)
{
  unsigned max_steps = floor(num_steps/2);
  gpioPulse_t *pulses_ramp = (gpioPulse_t*) malloc(2*max_steps*sizeof(gpioPulse_t));

  if(pulses_ramp)
  {
    unsigned num_steps_ramp = generatePulsesRampUp(port_number, frequency_initial, frequency_final, step_acceleration, pulses_ramp, max_steps);
    unsigned num_steps_constant = num_steps - 2*num_steps_ramp;

    gpioPulse_t *pulses = (gpioPulse_t*) malloc(2*num_steps*sizeof(gpioPulse_t));

    if(pulses)
    {
      unsigned current_delay;
      unsigned cummulated_time = 0;

      for(unsigned i_step = 0; i_step < num_steps_ramp; i_step++)
      {
        current_delay = pulses_ramp[2*i_step].usDelay;

        pulses[2*i_step].gpioOn = (1<<port_number);
        pulses[2*i_step].gpioOff = 0;
        pulses[2*i_step].usDelay = current_delay;
        pulses[2*i_step+1].gpioOn = 0;
        pulses[2*i_step+1].gpioOff = (1<<port_number);
        pulses[2*i_step+1].usDelay = current_delay;

        pulses[2*(num_steps-1-i_step)].gpioOn = (1<<port_number);
        pulses[2*(num_steps-1-i_step)].gpioOff = 0;
        pulses[2*(num_steps-1-i_step)].usDelay = current_delay;
        pulses[2*(num_steps-1-i_step)+1].gpioOn = 0;
        pulses[2*(num_steps-1-i_step)+1].gpioOff = (1<<port_number);
        pulses[2*(num_steps-1-i_step)+1].usDelay = current_delay;

        cummulated_time += 4*current_delay;
      }
      free(pulses_ramp);


      if(num_steps_constant > 0)
      {
        unsigned current_delay = floor(S_TO_US/frequency_final);
        for(unsigned i_step = num_steps_ramp; i_step < num_steps_ramp+num_steps_constant; i_step++)
        {
          pulses[2*i_step].gpioOn = (1<<port_number);
          pulses[2*i_step].gpioOff = 0;
          pulses[2*i_step].usDelay = current_delay;
          pulses[2*i_step+1].gpioOn = 0;
          pulses[2*i_step+1].gpioOff = (1<<port_number);
          pulses[2*i_step+1].usDelay = current_delay;

          cummulated_time += 2*current_delay;
        }
      }

      if(cummulated_time > total_time)
      {
        Debug("ERROR UStepDevice::generatePulsesRampUpDown - Invalid calculated time \n");
        return (gpioPulse_t*)ERR_TIME_CALC_INVALID;
      }

      unsigned remaining_time = total_time - cummulated_time;

      if(remaining_time > 0)
      {
        pulses[2*num_steps-1].usDelay += remaining_time;
      }

      return pulses;
    }

    else
    {
      Debug("ERROR UStepDevice::generatePulsesRampUpDown - Malloc error \n");
      return (gpioPulse_t*)ERR_MALLOC;
    }
  }

  else
  {
    Debug("ERROR UStepDevice::generatePulsesRampUpDown - Malloc error \n");
    return (gpioPulse_t*)ERR_MALLOC;
  }
}

unsigned UStepDevice::generatePulsesRampUp(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, gpioPulse_t* pulses, unsigned max_steps)
{
  // Calculate the min and max frequency based on the given periods variables from RPS to steps/second
  //double lower_step_frequency = ((double)(S_TO_US))/higher_half_period;
  //double higher_step_frequency = ((double)(S_TO_US))/lower_half_period;

  double current_step_frequency;
  unsigned current_half_period;
  unsigned total_micros = 0;
  unsigned i_step;

  // Generate ramp up pulses
  for(i_step = 0; i_step < max_steps; i_step++)
  {
    // Calculate the current frequency W(t) = W0 + a*t
    current_step_frequency = frequency_initial + step_acceleration*(total_micros*US_TO_S);

    // Calculate the corresponding half period in microseconds
    current_half_period = round(((1 / current_step_frequency) / 2) * S_TO_US);

    // If the higher_frequency has been reached, stop generating pulses
    if (current_step_frequency >= frequency_final)
    {
      break;
    }

    // Generate one step with the calculated period
    pulses[2*i_step].gpioOn = (1<<port_number);
    pulses[2*i_step].gpioOff = 0;
    pulses[2*i_step].usDelay = current_half_period;
    pulses[2*i_step+1].gpioOn = 0;
    pulses[2*i_step+1].gpioOff = (1<<port_number);
    pulses[2*i_step+1].usDelay = current_half_period;

    // Update the elapsed time counter
    total_micros += 2*current_half_period;
  }

  return i_step;
}
