/*
 * UStepDevice.cpp
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

// Includes
#include "UStepDevice.h"
#include "debug.h"
#include <iostream>
#include <stdlib.h>
#include <pigpio.h>
#include <math.h>

// File containing all the parameters for configuring the UStepDevice.
#include "device_parameters.cpp"

// Time unit conversions
#define S_TO_US   1000000
#define US_TO_S   0.000001

// Possible return values for the function 'checkExistingWaves()'
#define WAVES_ALL                     1
#define WAVES_INSERT_ROT              2
#define WAVES_ROT_REMAIN              3
#define WAVES_ROT                     4
#define WAVES_INSERT                  5
#define WAVES_NONE                    -1

// Numeric code for referring to each of the motors
#define MOTOR_INSERTION               1
#define MOTOR_ROTATION                2
#define MOTOR_FRONT_GRIPPER           3
#define MOTOR_BACK_GRIPPER            4

// Directions that must be set to the motors for moving the end effector correctly
#define DIRECTION_FORWARD             0
#define DIRECTION_BACKWARD            1
#define DIRECTION_CLOCKWISE           0
#define DIRECTION_COUNTER_CLOCKWISE   1
#define DIRECTION_OPENING             1
#define DIRECTION_CLOSING             0

UStepDevice::UStepDevice()
{
  emergency_button_ = 0;
  front_switch_ = 0;
  back_switch_ = 0;

  min_base_speed_ = 1.0;
  max_base_speed_ = 1.0;
  max_final_speed_ = 1.0;
  max_acceleration_ = 1.0;

  gripper_default_speed_ = 1.0;
  front_gripper_default_displacement_ = 1.0;
  back_gripper_default_displacement_ = 1.0;
  max_insertion_position_ = 0.0;
  min_insertion_position_ = 0.0;

  dc_max_threshold_ = 1.0;
  dc_min_threshold_ = 0.0;

  front_gripper_closed_ = false;
  back_gripper_closed_ = false;
  insertion_position_ = 0.0;

  configured_ = false;
  initialized_ = false;
  calibrated_ = false;

  clearWaves();
}

void UStepDevice::configureMotorParameters()
{
  // Run a function in an external source file that fills the MotorParameters
  // structures with all the configuration parameters of the device
  // OBS: Ideally this information should be read from a configuration file
  declareDeviceParameters();

  // Set the parameters for each one of the motors
  insertion_.configureParameters(insertion_parameters);
  rotation_.configureParameters(rotation_parameters);
  front_gripper_.configureParameters(front_gripper_parameters);
  back_gripper_.configureParameters(back_gripper_parameters);

  // Assign the port number of the inputs to the member variables
  emergency_button_ = PORT_EM;
  front_switch_ = PORT_FS;
  back_switch_ = PORT_BS;

  // Physical parameters of the motors
  min_base_speed_ = MIN_SPEED;
  max_base_speed_ = MAX_SPEED;
  max_final_speed_ = MAX_FINAL_SPEED;
  max_acceleration_ = ACC;

  gripper_default_speed_ = GRIPPER_SPEED;
  front_gripper_default_displacement_ = FRONT_GRIPPER_DISP;
  back_gripper_default_displacement_ = BACK_GRIPPER_DISP;
  max_insertion_position_ = MAX_INSERT_POS;
  min_insertion_position_ = MIN_INSERT_POS;

  // Duty cycle parameters
  dc_max_threshold_ = MAX_DC;
  dc_min_threshold_ = MIN_DC;

  displayParameters();

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
      Error("ERROR UStepDevice::initGPIO - Unable to call gpioInitialise() \n");
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
  }

  // If the motor parameters have not been set, return an error code
  else
  {
    Error("ERROR UStepDevice::initGPIO - Motor parameters not configured. You must call configureMotorParameters() before \n");
    return ERR_MOTOR_NOT_CONFIGURED;
  }

  return 0;
}

void UStepDevice::terminateGPIO()
{
  if(initialized_)
  {
    gpioTerminate();
    initialized_ = false;
  }

  else
  {
    Warn("WARNING UStepDevice::terminateGPIO - Device not initialized. \n");
  }
}

int UStepDevice::calibrateMotorsStartingPosition()
{
  if(initialized_)
  {
    // TODO - Insert calibration routine here

    // all motors are enabled by default
    // print something like "STARTING CALIBRATION"
    printf("\n\n\n\n\n");
    printf(" ----------------------------------------------------- \n");
    printf(" -           Starting calibration function           - \n");
    printf(" ----------------------------------------------------- \n");
    printf("\n");

    printf("STEP 1 - Calibrating the initial position of Motor 1:\n");
    printf("   - Please wait for the front gripper to hit the front limit switch\n");
    moveGripperToFrontSwitch(max_base_speed_*0.7);
    //moveMotorConstantSpeed(MOTOR_INSERTION, max_insertion_position_*1.1, max_base_speed_*0.7);
    printf("   - Moving motor 1 to its initial position: %.2f mm\n", min_insertion_position_);
    setDirection(MOTOR_INSERTION, DIRECTION_BACKWARD);
    moveMotorConstantSpeed(MOTOR_INSERTION, min_insertion_position_, max_base_speed_*0.7);
    printf("   - Motor 1 calibrated \n");

    // disable back gripper
    // ask user to move it to completely open position and hit enter
    // enable back gripper

    // disable front gripper
    // ask user to move it to completely open position and hit enter
    // enable front gripper

    // move the insertion motor for 200 mm forward (it will surely hit the limit switch)





    // move the insertion motor to min_insertion_position
    // update the insertion_position_variable

    calibrated_ = true;
  }

  else
  {
    Error("ERROR UStepDevice::calibrateMotorsStartingPosition - Device not initialized. You must call initGPIO() before \n");
    return ERR_DEVICE_NOT_INITIALIZED;
  }

  return 0;
}

int UStepDevice::setInsertionWithDutyCycle(double needle_insertion_depth,  double needle_insertion_speed, double needle_rotation_speed, double duty_cycle)
{
  // Input units
  //   - insert_depth : The requested insertion distance in millimeters
  //   - insert_speed : The requested insertion speed in millimeters/second
  //   - rot_speed    : The requested rotation speed in revolutions/second
  //   - duty_cycle   : The requested duty cycle

  if(calibrated_)
  {
    // Convert the insertion quantities from millimeters to revolutions
    double insertion_motor_distance = needle_insertion_depth * insertion_.gear_ratio();
    double insertion_motor_speed = needle_insertion_speed * insertion_.gear_ratio();
    double rotation_motor_speed = needle_rotation_speed * rotation_.gear_ratio();

    int result;

    // Verify if the requested speeds are inside the allowed range
    result = verifyMotorSpeedLimits(insertion_motor_speed, 0);
    if(result)
    {
      Error("ERROR UStepDevice::setInsertionWithDutyCycle - Requested insertion motor speeds is invalid \n");
      return result;
    }
    result = verifyMotorSpeedLimits(rotation_motor_speed, 1);
    if(result)
    {
      Error("ERROR UStepDevice::setInsertionWithDutyCycle - Requested rotation motor speeds is invalid \n");
      return result;
    }

    // Before generating new waves, clear all wave variables
    clearWaves();

    // Calculate all necessary parameters for generating the duty cycle motion
    if((result = calculateDutyCycleMotionParameters(insertion_motor_distance, insertion_motor_speed, rotation_motor_speed, duty_cycle)))
    {
      Error("ERROR UStepDevice::setInsertionWithDutyCycle - Bad parameters \n");
      return result;
    }

    // If the duty cycle is smaller than 1 or there are remaining steps to be
    // performed after all duty cycle periods, generate a wave with insertion only
    if(micros_pure_insertion_ > 0 || micros_remaining_ > 0)
    {
      if((result = generateWavePureInsertion()))
      {
        Error("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave pure insertion \n");
        return result;
      }
    }

    // If the duty cycle is greater than 0 generate a wave containing insertion and rotation
    if(micros_rotation_ > 0)
    {
      if((result = generateWaveInsertionWithRotation()))
      {
        Error("ERROR UStepDevice::setInsertionWithDutyCycle - Unable to create wave insertion with rotation \n");
        return result;
      }
    }

    calculateFeedbackInformation();
  }

  else
  {
    Error("ERROR UStepDevice::setInsertionWithDutyCycle - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::startInsertionWithDutyCycle()
{
  if(calibrated_)
  {
    Debug("\nDEBUG 0\n");
    Debug("Wave rot = %d, during %u(s) and %u(us)\n", wave_insertion_with_rotation_, seconds_rotation_, micros_rotation_);
    Debug("Wave insert = %d, during %u(s) and %u(us)\n", wave_pure_insertion_, seconds_pure_insertion_, micros_pure_insertion_);
    Debug("Number of DC periods = %u, remaining micros = %u\n", num_dc_periods_, micros_remaining_);
    switch (checkExistingWaves())
    {
      case WAVES_ALL:
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

      case WAVES_INSERT_ROT:
        for(unsigned n = 0; n < num_dc_periods_; n++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
          gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
          gpioSleep(PI_TIME_RELATIVE, seconds_pure_insertion_, micros_pure_insertion_);
        }
        gpioWaveTxStop();
        break;

      case WAVES_ROT_REMAIN:
        for(unsigned n = 0; n < num_dc_periods_; n++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
        }
        gpioSleep(PI_TIME_RELATIVE, 0, micros_remaining_);
        gpioWaveTxStop();
        break;

      case WAVES_ROT:
        for(unsigned n = 0; n < num_dc_periods_; n++)
        {
          gpioWaveTxSend(wave_insertion_with_rotation_, PI_WAVE_MODE_ONE_SHOT);
          gpioSleep(PI_TIME_RELATIVE, seconds_rotation_, micros_rotation_);
        }
        gpioWaveTxStop();
        break;

      case WAVES_INSERT:
        gpioWaveTxSend(wave_pure_insertion_, PI_WAVE_MODE_REPEAT);
        gpioSleep(PI_TIME_RELATIVE, seconds_pure_insertion_, micros_pure_insertion_);
        gpioWaveTxStop();
        break;

      // Error: the waves have not been set
      case WAVES_NONE:
        Error("ERROR UStepDevice::startInsertion - Waves not set \n");
        return ERR_WAVES_NOT_PRESENT;

      default:
        break;
    }
  }

  else
  {
    Error("ERROR UStepDevice::startInsertionWithDutyCycle - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  gpioWrite(insertion_.port_step(), 0);
  gpioWrite(rotation_.port_step(), 0);

  return 0;
}

int UStepDevice::performFullDutyCyleStep(double needle_insertion_depth,  double needle_insertion_speed, double needle_rotation_speed, double duty_cycle)
{
  if(calibrated_)
  {
    int result;

    // PART 3 - RELEASE THE NEEDLE
    if((result = closeBackGripper()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to close the back gripper\n"); return result; }

    if((result = openFrontGripper()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to open the front gripper\n"); return result; }

    // PART 4 - RETREAT THE MOVING GRIPPER BOX
    if(insertion_position_ + needle_insertion_depth > max_insertion_position_)
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Insertion position upper limit reached. Try choosing a smaller step size\n");
        return ERR_INSERT_POS_TOO_HIGH; }

    if((result = setInsertionWithDutyCycle(needle_insertion_depth, needle_insertion_speed, needle_rotation_speed, 0.0)))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to set the retreat parameters\n"); return result; }

    result = setDirection(MOTOR_INSERTION, DIRECTION_BACKWARD);

    if((result = startInsertionWithDutyCycle()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to retreat the device\n"); return result; }
    insertion_position_ += calculated_insertion_depth_;


    // PART 1 - GRASP THE NEEDLE
    if((result = closeFrontGripper()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to close the front gripper\n"); return result; }

    if((result = openBackGripper()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to open the back gripper\n"); return result; }

    // PART 2 - INSERT THE NEEDLE
    if(insertion_position_ - needle_insertion_depth < min_insertion_position_)
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Insertion position lower limit reached. There may be an error in your insertion step cycle\n");
      return ERR_INSERT_POS_TOO_LOW; }

    if((result = setInsertionWithDutyCycle(needle_insertion_depth, needle_insertion_speed, needle_rotation_speed, duty_cycle)))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to set the insertion parameters\n"); return result; }

    setDirection(MOTOR_INSERTION, DIRECTION_FORWARD);

    if((result = startInsertionWithDutyCycle()))
      { Error("ERROR UStepDevice::performFullDutyCyleStep - Unable to insert the needle\n"); return result; }
    insertion_position_ -= calculated_insertion_depth_;
  }

  else
  {
    Error("ERROR UStepDevice::startInsertionWithDutyCycle - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::openFrontGripper()
{
  if(calibrated_)
  {
    if(front_gripper_closed_)
    {
      setDirection(MOTOR_FRONT_GRIPPER, DIRECTION_OPENING);
      int result = moveMotorConstantSpeed(MOTOR_FRONT_GRIPPER, front_gripper_default_displacement_, gripper_default_speed_);
      if(result)
      {
        Error("ERROR UStepDevice::openFrontGripper - Could not move the front gripper correctly \n");
        return result;
      }

      front_gripper_closed_ = false;
    }

    else
    {
      Warn("WARNING UStepDevice::openFrontGripper - Front Gripper is already open. \n");
    }

  }

  else
  {
    Error("ERROR UStepDevice::openFrontGripper - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::closeFrontGripper()
{
  if(calibrated_)
  {
    if(!front_gripper_closed_)
    {
      setDirection(MOTOR_FRONT_GRIPPER, DIRECTION_CLOSING);
      int result = moveMotorConstantSpeed(MOTOR_FRONT_GRIPPER, front_gripper_default_displacement_, gripper_default_speed_);
      if(result)
      {
        Error("ERROR UStepDevice::closeFrontGripper - Could not move the front gripper correctly \n");
        return result;
      }

      front_gripper_closed_ = true;
    }

    else
    {
      Warn("WARNING UStepDevice::closeFrontGripper - Front Gripper is already closed. \n");
    }
  }

  else
  {
    Error("ERROR UStepDevice::closeFrontGripper - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::openBackGripper()
{
  if(calibrated_)
  {
    if(back_gripper_closed_)
    {
      setDirection(MOTOR_BACK_GRIPPER, DIRECTION_OPENING);
      int result = moveMotorConstantSpeed(MOTOR_BACK_GRIPPER, back_gripper_default_displacement_, gripper_default_speed_);
      if(result)
      {
        Error("ERROR UStepDevice::openBackGripper - Could not move the back gripper correctly \n");
        return result;
      }

      back_gripper_closed_ = false;
    }

    else
    {
      Warn("WARNING UStepDevice::openBackGripper - Back Gripper is already open. \n");
    }
  }

  else
  {
    Error("ERROR UStepDevice::openBackGripper - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::closeBackGripper()
{
  if(calibrated_)
  {
    if(!back_gripper_closed_)
    {
      setDirection(MOTOR_BACK_GRIPPER, DIRECTION_CLOSING);
      int result = moveMotorConstantSpeed(MOTOR_BACK_GRIPPER, back_gripper_default_displacement_, gripper_default_speed_);
      if(result)
      {
        Error("ERROR UStepDevice::closeBackGripper - Could not move the front gripper correctly \n");
        return result;
      }

      back_gripper_closed_ = true;
    }

    else
    {
      Warn("WARNING UStepDevice::closeBackGripper - Back Gripper is already closed. \n");
    }
  }

  else
  {
    Error("ERROR UStepDevice::closeBackGripper - Device not calibrated. You must call calibrateMotorsStartingPosition() before \n");
    return ERR_DEVICE_NOT_CALIBRATED;
  }

  return 0;
}

int UStepDevice::moveMotorConstantSpeed(unsigned motor, double displacement, double speed)
{
  // Input units
  //   - motor        : The code specifying the motor to move
  //   - displacement : The requested displacement of the end effector in revs
  //   - speed        : The requested speed of the end effector in rev/s

  double motor_displacement;
  double motor_speed;

  unsigned motor_port_step;
  unsigned motor_displacement_step;

  unsigned step_half_period;
  unsigned duration_seconds;
  unsigned duration_micros;

  switch(motor)
  {
    case MOTOR_INSERTION:
      motor_displacement = displacement * insertion_.gear_ratio();
      motor_speed = speed * insertion_.gear_ratio();
      motor_port_step = insertion_.port_step();
      motor_displacement_step = round(motor_displacement * insertion_.steps_per_revolution());
      break;

    case MOTOR_ROTATION:
      motor_displacement = displacement * rotation_.gear_ratio();
      motor_speed = speed * rotation_.gear_ratio();
      motor_port_step = rotation_.port_step();
      motor_displacement_step = round(motor_displacement * rotation_.steps_per_revolution());
      break;

    case MOTOR_FRONT_GRIPPER:
      motor_displacement = displacement * front_gripper_.gear_ratio();
      motor_speed = speed * front_gripper_.gear_ratio();
      motor_port_step = front_gripper_.port_step();
      motor_displacement_step = round(motor_displacement * front_gripper_.steps_per_revolution());
      break;

    case MOTOR_BACK_GRIPPER:
      motor_displacement = displacement * back_gripper_.gear_ratio();
      motor_speed = speed * back_gripper_.gear_ratio();
      motor_port_step = back_gripper_.port_step();
      motor_displacement_step = round(motor_displacement * back_gripper_.steps_per_revolution());
      break;

    default:
      Error("ERROR UStepDevice::moveMotor - Invalid motor code \n");
      return ERR_INVALID_MOTOR_CODE;
  }

  if(verifyMotorSpeedLimits(motor_speed, 0))
  {
    Error("ERROR UStepDevice::moveMotor - Requested motor speeds is invalid \n");
    return ERR_INVALID_MOTOR_SPEED;
  }

  double exp_total_insert_time_us = (motor_displacement / motor_speed) * S_TO_US;
  step_half_period = round((exp_total_insert_time_us / motor_displacement_step) / 2);
  duration_micros = motor_displacement_step * 2*step_half_period;
  duration_seconds = floor(duration_micros*US_TO_S);
  duration_micros = duration_micros - S_TO_US*duration_seconds;

  gpioPulse_t *pulses = generatePulsesConstantSpeed(motor_port_step, step_half_period, 1, 2*step_half_period);

  if(pulses >= 0)
  {
    gpioWaveClear();
    gpioWaveAddGeneric(2, pulses);
    int wave_id = gpioWaveCreate();

    free(pulses);

    if (wave_id >= 0)
    {
      gpioWaveTxSend(wave_id, PI_WAVE_MODE_REPEAT);
      gpioSleep(PI_TIME_RELATIVE, duration_seconds, duration_micros);
      gpioWaveTxStop();
      gpioWrite(motor_port_step, 0);
    }

    else
    {
      Error("ERROR UStepDevice::moveMotorConstantSpeed - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Error("ERROR UStepDevice::moveMotorConstantSpeed - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

int UStepDevice::setDirection(unsigned motor, unsigned direction)
{
  if(initialized_)
  {
    switch(motor)
    {
      case MOTOR_INSERTION:
        gpioWrite(insertion_.port_direction(), direction);
        break;

      case MOTOR_ROTATION:
        gpioWrite(rotation_.port_direction(), direction);
        gpioWrite(front_gripper_.port_direction(), direction);
        break;

      case MOTOR_FRONT_GRIPPER:
        gpioWrite(front_gripper_.port_direction(), direction);
        break;

      case MOTOR_BACK_GRIPPER:
        gpioWrite(back_gripper_.port_direction(), direction);
        break;

      default:
        Error("ERROR UStepDevice::setDirection - Invalid motor code \n");
        return ERR_INVALID_MOTOR_CODE;
      }
    }

    else
    {
      Error("ERROR UStepDevice::setDirection - Device not initialized. You must call initGPIO() before \n");
      return ERR_DEVICE_NOT_INITIALIZED;
    }

    return 0;
}

int UStepDevice::moveGripperToFrontSwitch(double speed)
{
  setDirection(MOTOR_INSERTION, DIRECTION_FORWARD);

  //double motor_displacement;
  double motor_speed;

  unsigned motor_port_step;
  //unsigned motor_displacement_step;

  unsigned step_half_period;
  //unsigned duration_seconds;
  //unsigned duration_micros;



      //motor_displacement = displacement * insertion_.gear_ratio();
      motor_speed = speed * insertion_.gear_ratio();
      motor_port_step = insertion_.port_step();
      //motor_displacement_step = round();



  if(verifyMotorSpeedLimits(motor_speed, 0))
  {
    Error("ERROR UStepDevice::moveMotor - Requested motor speeds is invalid \n");
    return ERR_INVALID_MOTOR_SPEED;
  }

  //double exp_total_insert_time_us = () *;
  //step_half_period = round((   (S_TO_US * / motor_speed) / (insertion_.steps_per_revolution())     ) / 2);

  step_half_period = round((S_TO_US / (motor_speed * insertion_.steps_per_revolution())) / 2);


  //duration_micros = motor_displacement_step * 2*step_half_period;
  //duration_seconds = floor(duration_micros*US_TO_S);
  //duration_micros = duration_micros - S_TO_US*duration_seconds;

  gpioPulse_t *pulses = generatePulsesConstantSpeed(motor_port_step, step_half_period, 1, 2*step_half_period);

  if(pulses >= 0)
  {
    gpioWaveClear();
    gpioWaveAddGeneric(2, pulses);
    int wave_id = gpioWaveCreate();

    free(pulses);

    if (wave_id >= 0)
    {
      gpioWaveTxSend(wave_id, PI_WAVE_MODE_REPEAT);
      while(gpioRead(front_switch_) == 0)
        gpioSleep(PI_TIME_RELATIVE, 0, 100000);
      gpioWaveTxStop();
      gpioWrite(motor_port_step, 0);
    }

    else
    {
      Error("ERROR UStepDevice::moveMotorConstantSpeed - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Error("ERROR UStepDevice::moveMotorConstantSpeed - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

void UStepDevice::displayParameters()
{
  // Display the software name and version
  printf("\n\n");
  printf(" ##################################################### \n");
  printf(" #    uStep Device Control Software - version 1.0    # \n");
  printf(" #        - written by Andre A. Geraldes -           # \n");
  printf(" ##################################################### \n");
  printf("\n\n");

  // Display the motor model information
  printf("Using the following motors \n");
  printf("-------------------------------------------- \n");
  printf(" - Motor 1 - needle insertion : KTC-HT23-397 \n");
  printf(" - Motor 2 - back gripper     : KTC-HT23-397 \n");
  printf(" - Motor 3 - needle rotation  : KTC-HT23-397 \n");
  printf(" - Motor 4 - front griper     : KTC-HT23-397 \n");
  printf("\n\n");

  // Display the speed and acceleration parameters
  printf("Speed and acceleration parameters (applied to all motors) \n");
  printf("-------------------------------------------- \n");
  printf(" - Minimum speed                             : %.2f RPS   \n", min_base_speed_);
  printf(" - Maximum constant speed (without ramping)  : %.2f RPS   \n", max_base_speed_);
  printf(" - Maximum speed (only reached with ramping) : %.2f RPS   \n", max_final_speed_);
  printf(" - Standard acceleration                     : %.2f RPS/s \n", max_acceleration_);
  printf("\n\n");

  // Display the position parameters
  printf("Device parameters \n");
  printf("-------------------------------------------- \n");
  printf(" - Insertion positions range      : %.2f mm - %.2f mm (measured from the front support) \n", min_insertion_position_, max_insertion_position_);
  printf(" - Front gripper closing position : %.1f\xB0 \n", front_gripper_default_displacement_*360);
  printf(" - Back gripper closing position  : %.1f\xB0 \n", back_gripper_default_displacement_*360);
  printf(" - Grippers standard speed        : %.2f RPS \n", gripper_default_speed_);
  printf(" - Allowed Duty cycle values      : %.1f%% - %.1f%% \n", 100*dc_min_threshold_, 100*dc_max_threshold_);
  printf("\n\n");

  // Gear rations
  printf("Gear ratios (from motor to end effector) \n");
  printf("-------------------------------------------- \n");
  printf(" - Motor 1 - %.2f revolutions per 1 mm of insertion \n", insertion_.gear_ratio());
  printf(" - Motor 2 - %.2f\xB0 of motor turning per 1\xB0 of gripper closing \n", back_gripper_.gear_ratio());
  printf(" - Motor 3 - %.2f revolutions per 1 needle revolution \n", rotation_.gear_ratio());
  printf(" - Motor 4 - %.2f\xB0 of motor turning per 1\xB0 of gripper closing \n", front_gripper_.gear_ratio());
  printf("\n\n");

  // Motor resolutions
  printf("Motor resolution (steps per revolution) \n");
  printf("-------------------------------------------- \n");
  printf(" - Motor 1 : %u \n", insertion_.steps_per_revolution());
  printf(" - Motor 2 : %u \n", back_gripper_.steps_per_revolution());
  printf(" - Motor 3 : %u \n", rotation_.steps_per_revolution());
  printf(" - Motor 4 : %u \n", front_gripper_.steps_per_revolution());
  printf("\n!!! ATTENTION: Please verify if the DIP switches of all STR2 Drivers match this configuration !!! \n");

  printf("\n---- Press any key to start running the program ----\n");
  getchar();
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

  num_dc_periods_ = 0;
  insertion_step_half_period_ = 0;
  rotation_step_half_period_ = 0;
  micros_rotation_ = 0;
  micros_pure_insertion_ = 0;
  micros_remaining_ = 0;
  seconds_rotation_ = 0;
  seconds_pure_insertion_ = 0;

  micros_real_rotation_duration_ = 0;
  calculated_insertion_speed_ = 0;
  calculated_rotation_speed_ = 0;
  calculated_duty_cycle_ = 0;
  rotation_ramp_step_percentage_ = 0;
}

int UStepDevice::checkExistingWaves()
{
  if(has_wave_insertion_with_rotation_)
  {
    if(has_wave_pure_insertion_)
    {
      if(has_wave_remaining_)
        return WAVES_ALL;
      else
        return WAVES_INSERT_ROT;
    }
    else
    {
      if(has_wave_remaining_)
        return WAVES_ROT_REMAIN;
      else
        return WAVES_ROT;
    }
  }
  else
  {
    if(has_wave_pure_insertion_)
      return WAVES_INSERT;
    else
      return WAVES_NONE;
  }
}

int UStepDevice::verifyMotorSpeedLimits(double motor_speed, bool allow_ramp)
{
  // Verify if the motor speed is lower than the minimum speed
  if(motor_speed < min_base_speed_)
  {
    Error("ERROR UStepDevice::verifyMotorSpeedLimits - Motor speed is too slow \n");
    return ERR_SPEED_TOO_SMALL;
  }

  if(allow_ramp)
  {
    // Verify if the motor speed is greater than the maximum speed
    if(motor_speed > max_final_speed_)
    {
      Error("ERROR UStepDevice::verifyMotorSpeedLimits - Motor speed is too high \n");
      return ERR_SPEED_TOO_HIGH;
    }
  }
  else
  {
    // Verify if the insertion motor speed is greater than the base speed
    if(motor_speed > max_base_speed_)
    {
      Error("ERROR UStepDevice::verifyMotorSpeedLimits - Motor speed is too high \n");
      return ERR_SPEED_TOO_HIGH;
    }
  }

  return 0;
}

int UStepDevice::calculateDutyCycleMotionParameters(double insert_motor_distance,  double insert_motor_speed, double rot_motor_speed, double duty_cycle)
{
  // Input units
  //   - insert_motor_distance : The requested displacement of the insertion motor in rev
  //   - insert_motor_speed    : The requested speed of the insertion motor in rev/s
  //   - rot_motor_speed       : The requested speed of the rotation motor in rev/s
  //   - duty_cycle            : The requested duty cycle

  // Expected continuous time quantities
  double rot_motor_distance_rev;              // The total rotation distance of one rotation period in revolutions
  double exp_single_rot_time_s;               // The expected time of a single rotation period in s
  double exp_single_dc_time_s;                // The expected time of a single duty cycle period in s
  double exp_total_insert_time_s;             // The expected time of the insertion in s

  // Discrete time quantities
  unsigned total_insert_time_us;              // The total time of the insertion in us
  unsigned single_dc_time_us;                 // The time of a single duty cycle period in us
  unsigned rot_insert_time_us;                // The rotation part of the duty cycle period in us
  unsigned pure_insert_time_us;               // The pure insertion part of the duty cycle period in us
  unsigned remaining_insert_time_us;          // The remaining insertion type, to be performed after all duty cycle periods

  // Discrete parameters
  unsigned total_insert_distance_step;        // The requested insertion distance in steps
  unsigned half_step_insert_time_us;          // The time of half of an insertion step in us
  unsigned step_insert_time_us;               // The time of an insertion step in us
  unsigned half_step_rot_time_us;             // The time of half of a rotation step in us
  unsigned num_dc;                            // The total number of duty cycle periods in the insertion

  // Duty cycle = 0 : pure insertion
  if(duty_cycle <= dc_min_threshold_)
  {
    // Convert the insertion distance from revolutions to steps
    total_insert_distance_step = round(insert_motor_distance * insertion_.steps_per_revolution());

    // Estimate the total duration of the insertion based on the requested distance and speed
    exp_total_insert_time_s = insert_motor_distance / insert_motor_speed;

    // Calculate the period of a single insertion step
    half_step_insert_time_us = round(((exp_total_insert_time_s * S_TO_US) / total_insert_distance_step) / 2);

    // Calculate the total duration of the insertion as a multiple of the step period
    total_insert_time_us = total_insert_distance_step * 2*half_step_insert_time_us;

    // Export the relevant calculated values to member variables
    insertion_step_half_period_ = half_step_insert_time_us;
    micros_pure_insertion_ = total_insert_time_us;

    num_dc_periods_ = 0;
    rotation_step_half_period_ = 0;
    micros_rotation_ = 0;
    micros_remaining_ = 0;
  }

  // Duty cycle > 0 : insertion with rotation
  else
  {
    if(duty_cycle >= dc_max_threshold_)
      duty_cycle = 1.0;

    // Calculate in how many duty cycles, the insertion will be divided
    rot_motor_distance_rev = 1.0 * rotation_.gear_ratio();
    exp_single_rot_time_s = rot_motor_distance_rev / rot_motor_speed;
    exp_single_dc_time_s = exp_single_rot_time_s / duty_cycle;
    exp_total_insert_time_s = insert_motor_distance / insert_motor_speed;
    num_dc = round(exp_total_insert_time_s / exp_single_dc_time_s);

    // Calculate the period of a single insertion step (this will be our time unit)
    total_insert_distance_step = round(insert_motor_distance * insertion_.steps_per_revolution());
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
      Error("ERROR UStepDevice::calculateDutyCycleMotionParameters - Can't perform a full rotation ramp in the requested time \n");
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
  }

  // Calculate part of the feedback information
  double total_insert_distance_rev = ((double)(total_insert_distance_step)) / insertion_.steps_per_revolution();
  double real_insertion_speed_rev = S_TO_US * (total_insert_distance_rev / total_insert_time_us);
  calculated_insertion_depth_ = total_insert_distance_rev / insertion_.gear_ratio();
  calculated_insertion_speed_ = real_insertion_speed_rev / insertion_.gear_ratio();

  return 0;
}

int UStepDevice::calculateRotationSpeed(unsigned max_rotation_time)
{
  double rot_motor_distance_rev;          // The total rotation distance of one rotation period in revolutions
  unsigned rot_motor_distance_step;       // The total rotation distance of one rotation period in steps
  double average_speed;                   // The average rotation speed for the entire rotation period in RPS
  double final_speed;                     // The maximum rotation speed for the entire rotation period in RPS
  unsigned us_delay;                      // The time of half of a rotation step in us, for the maximum achieved rotation speed

  // Calculate the average rotation speed for the entire rotation period
  rot_motor_distance_rev = 1.0 * rotation_.gear_ratio();
  average_speed = (rot_motor_distance_rev / max_rotation_time) * S_TO_US;

  // DEBUG
  Debug("CALCULATING ROTATION SPEED - Tmax = %u(us) \n\n", max_rotation_time);
  Debug("I have %u micros for one complete rotation period \n", max_rotation_time);
  Debug("If I go at constant speed, I would need to go at %f RPS\n", average_speed);
  // END DEBUG

  if(average_speed <= max_base_speed_)
  {
    // If the average speed is below the base speed, move the motor at constant speed
    rot_motor_distance_step = rot_motor_distance_rev * rotation_.steps_per_revolution();
    us_delay = floor((max_rotation_time / rot_motor_distance_step) / 2);

    Debug("This is ok. I'm going at %f RPS\n", average_speed);
    Debug("Since one rotation period has %u steps, each step will take %u micros \n\n", rotation_.steps_per_revolution(), 2*us_delay);

    return us_delay;
  }

  else
  {
    // If the average speed is above the base speed, move the motor with a ramp profile
    // Start the motor at the base speed, accelerate until a target speed and decelerate
    // back again to the base speed.
    // The target speed can be found as the smaller solution of the second degree equation:
    //     Wt² - Wt*(2*W0 + a*Tmax) + (W0² + a*Nrot)
    double B = -(2*max_base_speed_ + max_acceleration_ * (max_rotation_time * US_TO_S));
    double C = pow(max_base_speed_, 2) + max_acceleration_ * rot_motor_distance_rev;
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
      Error("ERROR UStepDevice::calculateRotationSpeed - Can't perform a full rotation ramp in the requested time \n");
      return ERR_INVALID_ROTATION_RAMP;
    }

    final_speed = (-B -pow(D, 0.5))/2;
    us_delay = floor(((S_TO_US / final_speed) / rotation_.steps_per_revolution()) / 2);

    // DEBUG
    unsigned us_delay_initial = floor(((S_TO_US / max_base_speed_) / rotation_.steps_per_revolution()) / 2);
    final_speed = ((double)(S_TO_US)) / (rotation_.steps_per_revolution() * 2 * us_delay);
    //Debug("B=%f, C=%f, D=%f\n", B, C, D);
    Debug("That is too fast. I will start at %f RPS and ramp up until %f RPS\n", max_base_speed_, final_speed);
    Debug("The half step will vary from %u micros to %u micros\n", us_delay_initial, us_delay);
    // END DEBUG

    return us_delay;
  }
}

int UStepDevice::calculateFeedbackInformation()
{
  // micros_real_rotation_duration_;
     // Already measured inside functions 'generatePulsesConstantSpeed' or 'generatePulsesRampUpDown'

  // calculated_insertion_speed_;
     // Already calculated inside function 'calculateDutyCycleMotionParameters'

  // rotation_ramp_step_percentage_;
     // Already measured inside function 'generatePulsesRampUpDown'

  /*double rot_motor_distance_rev = 1.0 * motor_per_needle_revolutions_;
  double real_rotation_motor_speed_ = S_TO_US * (rot_motor_distance_rev / micros_real_rotation_duration_);
  calculated_rotation_speed_ = real_rotation_motor_speed_ / motor_per_needle_revolutions_;*/

  if(micros_real_rotation_duration_ > 0)
  {
    calculated_rotation_speed_ = ((double)(S_TO_US)) / micros_real_rotation_duration_;

    unsigned rotation_time = (seconds_rotation_ * S_TO_US) + micros_rotation_;
    unsigned insertion_time = (seconds_pure_insertion_ * S_TO_US) + micros_pure_insertion_;

    unsigned total_insert_time_us = (num_dc_periods_ * (rotation_time + insertion_time)) + micros_remaining_;
    calculated_duty_cycle_ = ((double)(micros_real_rotation_duration_ * num_dc_periods_)) / total_insert_time_us;
  }

  Debug("\nFEEDBACK: Real insert speed = %f, Real rot speed = %f\n", calculated_insertion_speed_, calculated_rotation_speed_);
  Debug("FEEDBACK: Real DC = %f%%, Ramp percentage = %f%%\n", 100*calculated_duty_cycle_, 100*rotation_ramp_step_percentage_);

  return 0;
}

int UStepDevice::generateWaveInsertionWithRotation()
{
  unsigned num_insertion_steps;       // The number of insertion steps that will fit in 'micros_rotation_' micros
  unsigned num_rotation_steps;        // The number of rotation steps that will fit in 'micros_rotation_' micros

  unsigned rot_single_rev_time_us;    // The time of a single revolution of the rotation motor
  double rot_motor_speed_final;       // The maximum speed of the rotation motor

  // Declare the pointers for storing the pulses used to create the insertion
  // and the rotation steps
  gpioPulse_t *insertion_pulses;
  gpioPulse_t *rotation_pulses;

  // Calculate the amount of insertion steps that fit within 'micros_rotation_' micros
  num_insertion_steps = micros_rotation_/(2*insertion_step_half_period_);

  // Calculate the amount of rotation steps that fit within 'micros_rotation_' micros
  // This value should always correspond to one complete rotation of the needle,
  // because this condition was assumed inside the 'calculateDutyCycleMotionParameters' function
  num_rotation_steps = 1.0 * rotation_.gear_ratio() * rotation_.steps_per_revolution();

  // Calculate the final speed of the rotation motor, based on the previously calculated rotation_step_half_period_
  rot_single_rev_time_us = rotation_.steps_per_revolution() * 2 * rotation_step_half_period_;
  rot_motor_speed_final = ((double)(S_TO_US)) / rot_single_rev_time_us;

  // Generate enough insertion pulses (constant speed) to fit in 'micros_rotation_' us
  insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, num_insertion_steps, micros_rotation_);

  // Check if the rotation motor final speed is greater than the maximum base speed
  if(rot_motor_speed_final <= max_base_speed_)
  {
    // If not, generate the rotation pulses as constant speed
    rotation_pulses = generatePulsesConstantSpeed(rotation_.port_step(), rotation_step_half_period_, num_rotation_steps, micros_rotation_);
  }
  else
  {
    // If yes, generate the rotation pulses as a ramp profile,starting at the maximum base speed and accelerating until the final speed
    double frequency_initial = max_base_speed_ * rotation_.steps_per_revolution();
    double frequency_final = rot_motor_speed_final * rotation_.steps_per_revolution();
    double step_acceleration = max_acceleration_ * rotation_.steps_per_revolution();
    rotation_pulses = generatePulsesRampUpDown(rotation_.port_step(), frequency_initial, frequency_final, step_acceleration, num_rotation_steps, micros_rotation_);
  }

  // If both sequences of pulses have been successfully generated, create the wave
  if(insertion_pulses >= 0 && rotation_pulses >= 0)
  {
    gpioWaveAddGeneric(2*num_insertion_steps, insertion_pulses);
    gpioWaveAddGeneric(2*num_rotation_steps, rotation_pulses);

    Debug("\nDEBUG: Creating wave insertion with rotation\n");
    Debug("Vstep_hT = %u, NV = %u, TotalV = %u\n", insertion_step_half_period_, num_insertion_steps, num_insertion_steps*2*insertion_step_half_period_);
    Debug("Wstep_hT = %u, NW = %u, TotalW = %u\n", rotation_step_half_period_, num_rotation_steps, num_rotation_steps*2*rotation_step_half_period_);
    Debug("Last insertion step: port on = %u, port off = %f, usdelay = %u\n", insertion_pulses[2*num_insertion_steps-1].gpioOn, log2((double)insertion_pulses[2*num_insertion_steps-1].gpioOff), insertion_pulses[2*num_insertion_steps-1].usDelay);
    Debug("Last rotation step: port on = %u, port off = %f, usdelay = %u\n", rotation_pulses[2*num_rotation_steps-1].gpioOn, log2((double)rotation_pulses[2*num_rotation_steps-1].gpioOff), rotation_pulses[2*num_rotation_steps-1].usDelay);

    //Debug("WAVE LIMITS: maxMicros = %d, maxPulses = %d, maxCbs = %d\n", gpioWaveGetMaxMicros(), gpioWaveGetMaxPulses(), gpioWaveGetMaxCbs());
    //Debug("WAVE CURRENT STUFF: micros = %d, pulses = %d, cbs = %d \n", gpioWaveGetMicros(), gpioWaveGetPulses(), gpioWaveGetCbs());

    wave_insertion_with_rotation_ = gpioWaveCreate();

    // Free the memory allocated for the pulse sequences
    free(insertion_pulses);
    free(rotation_pulses);

    if (wave_insertion_with_rotation_ >= 0)
    {
      // If the wave has been successfully created, set the flag and parse its
      // duration into the seconds and micros components
      has_wave_insertion_with_rotation_ = true;
      seconds_rotation_ = (unsigned)(micros_rotation_*US_TO_S);
      micros_rotation_ = micros_rotation_ - S_TO_US*seconds_rotation_;
    }

    else
    {
      has_wave_insertion_with_rotation_ = false;
      Error("ERROR UStepDevice::generateWaveInsertionWithRotation - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Error("ERROR UStepDevice::generateWaveInsertionWithRotation - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

int UStepDevice::generateWavePureInsertion()
{
  // Generate one pair of insertion pulses with constant speed
  gpioPulse_t *insertion_pulses = generatePulsesConstantSpeed(insertion_.port_step(), insertion_step_half_period_, 1, 2*insertion_step_half_period_);

  // If the pulses have been successfully generated, create the wave
  if(insertion_pulses >= 0)
  {
    gpioWaveAddGeneric(2, insertion_pulses);
    wave_pure_insertion_ = gpioWaveCreate();

    // Free the memory allocated for the pulses
    free(insertion_pulses);

    if (wave_pure_insertion_ >= 0)
    {
      // If the wave has been successfully created, check if it will be used as
      // pure_insertion wave, remaining wave or both
      if(micros_pure_insertion_ > 0)
      {
        // If there is a pure_insertion wave, set the flag and parse its
        // duration into the seconds and micros components
        has_wave_pure_insertion_ = true;
        seconds_pure_insertion_ = (unsigned)(micros_pure_insertion_*US_TO_S);
        micros_pure_insertion_ = micros_pure_insertion_ - S_TO_US*seconds_pure_insertion_;
      }
      if(micros_remaining_ > 0)
      {
        // If there is a remaining wave, set the flag (no need to parse its
        // duration, as the remaining wave will never exceed 1s)
        has_wave_remaining_ = true;
      }
    }

    else
    {
      has_wave_pure_insertion_ = false;
      has_wave_remaining_ = false;

      Error("ERROR UStepDevice::generateWavePureInsertion - Unable to call gpioWaveCreate() \n");
      return ERR_GPIO_WAVE_CREATE_FAIL;
    }
  }

  else
  {
    Error("ERROR UStepDevice::generateWavePureInsertion - Malloc error \n");
    return ERR_MALLOC;
  }

  return 0;
}

gpioPulse_t* UStepDevice::generatePulsesConstantSpeed(unsigned port_number, unsigned half_period, unsigned num_steps, unsigned total_time)
{
  // Allocate memory for creating the step sequence
  gpioPulse_t *pulses = (gpioPulse_t*) malloc(2*num_steps*sizeof(gpioPulse_t));

  if (pulses)
  {
    // Generate all steps with the same half_period
    for(unsigned i_step = 0; i_step < num_steps; i_step++)
    {
      pulses[2*i_step].gpioOn = (1<<port_number);
      pulses[2*i_step].gpioOff = 0;
      pulses[2*i_step].usDelay = half_period;
      pulses[2*i_step+1].gpioOn = 0;
      pulses[2*i_step+1].gpioOff = (1<<port_number);
      pulses[2*i_step+1].usDelay = half_period;
    }

    // Calculate the accumulated time of the generated steps
    unsigned accumulated_time = num_steps * 2 * half_period;

    // If the accumulated time is greater than the total time, something went wrong
    if(accumulated_time > total_time)
    {
      Error("ERROR UStepDevice::generatePulsesConstantSpeed - Invalid calculated time \n");
      return (gpioPulse_t*)ERR_TIME_CALC_INVALID;
    }

    // Pad the last step of the sequence so that the accumulated time of the sequence
    // matches the total time exactly
    unsigned remaining_time = total_time - accumulated_time;
    if(remaining_time > 0)
    {
      pulses[2*num_steps-1].usDelay += remaining_time;
    }

    // Save the original wave duration to the member variable (this is used for feedback purposes)
    // This 'if' is just a work around for not measuring the insertion time
    if(num_steps > 1)
      micros_real_rotation_duration_ = accumulated_time;

    return pulses;
  }

  else
  {
    Error("ERROR UStepDevice::generatePulsesConstantSpeed - Malloc error \n");
    return (gpioPulse_t*)ERR_MALLOC;
  }
}

gpioPulse_t* UStepDevice::generatePulsesRampUpDown(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, unsigned num_steps, unsigned total_time)
{
  // Calculate the maximum number of steps that can be spent in the ramps
  unsigned max_steps = floor(num_steps/2);

  // Allocate memory for creating the ramp up
  gpioPulse_t *pulses_ramp = (gpioPulse_t*) malloc(2*max_steps*sizeof(gpioPulse_t));

  if(pulses_ramp)
  {
    // Generate the ramp up sequence and measure the total number of steps it contains
    unsigned num_steps_ramp = generatePulsesRampUp(port_number, frequency_initial, frequency_final, step_acceleration, pulses_ramp, max_steps);

    // Calculate the number of steps that should be created with constant speed
    unsigned num_steps_constant = num_steps - 2*num_steps_ramp;

    // Save the ramp step percentage to the member variable (this is used for feedback purposes)
    rotation_ramp_step_percentage_ = ((double)2*num_steps_ramp)/num_steps;

    // Allocate memory for the entire motion profile
    gpioPulse_t *pulses = (gpioPulse_t*) malloc(2*num_steps*sizeof(gpioPulse_t));

    if(pulses)
    {
      unsigned current_delay;
      unsigned accumulated_time = 0;

      // Start filling the motion profile with the ramp up and ramp down
      // Ramp down should be exactly symmetrical to the ramp up
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

        accumulated_time += 4*current_delay;
      }

      // Free the memory used for the ramp steps
      free(pulses_ramp);


      // DEBUG
      Debug("\nRAMP UP: Initial ht = %u, final ht = %u \n", pulses[0].usDelay,  pulses[2*num_steps_ramp-1].usDelay);
      Debug("Each ramp has %u steps, so both ramps have %u steps and take %u micros\n", num_steps_ramp, 2*num_steps_ramp, accumulated_time);
      Debug("There are %u steps and %u micros left for the constant speed\n", num_steps-2*num_steps_ramp, total_time-accumulated_time);
      // END DEBUG


      // If there are remaining steps to be generated
      if(num_steps_constant > 0)
      {
        // Complete the motion profile by filling the remaining steps with constant speed
        current_delay = floor(((double)(total_time-accumulated_time))/(2*num_steps_constant));
        for(unsigned i_step = num_steps_ramp; i_step < num_steps_ramp+num_steps_constant; i_step++)
        {
          pulses[2*i_step].gpioOn = (1<<port_number);
          pulses[2*i_step].gpioOff = 0;
          pulses[2*i_step].usDelay = current_delay;
          pulses[2*i_step+1].gpioOn = 0;
          pulses[2*i_step+1].gpioOff = (1<<port_number);
          pulses[2*i_step+1].usDelay = current_delay;

          accumulated_time += 2*current_delay;
        }
      }

      // If the accumulated time is greater than the total time, something went wrong
      if(accumulated_time > total_time)
      {
        Debug("T_ACC = %u, T_TOT = %u\n", accumulated_time, total_time);
        Error("ERROR UStepDevice::generatePulsesRampUpDown - Invalid calculated time \n");
        return (gpioPulse_t*)ERR_TIME_CALC_INVALID;
      }

      // Pad the last step of the sequence so that the accumulated time of the sequence
      // matches the total time exactly
      unsigned remaining_time = total_time - accumulated_time;
      if(remaining_time > 0)
      {
        pulses[2*num_steps-1].usDelay += remaining_time;
      }

      // Save the original wave duration to the member variable (this is used for feedback purposes)
      micros_real_rotation_duration_ = accumulated_time;

      return pulses;
    }

    else
    {
      Error("ERROR UStepDevice::generatePulsesRampUpDown - Malloc error \n");
      return (gpioPulse_t*)ERR_MALLOC;
    }
  }

  else
  {
    Error("ERROR UStepDevice::generatePulsesRampUpDown - Malloc error \n");
    return (gpioPulse_t*)ERR_MALLOC;
  }
}

unsigned UStepDevice::generatePulsesRampUp(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, gpioPulse_t* pulses, unsigned max_steps)
{
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
