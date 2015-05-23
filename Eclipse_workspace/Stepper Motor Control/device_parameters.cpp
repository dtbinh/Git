/*
 * device_parameters.cpp
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#include "StepperMotor.h"

/*
 * This file contains all the parameters for configuring the UStepDevice.
 * Ideally this parameters should be read from an external text file, to
 * avoid the need of recompiling, but this implementation will be left to the
 * future.
 *
 * IMPORTANT: Since this file is exclude from the project build list, whenever
 * a parameter is modified, it is necessary to clean and rebuild the entire
 * project.
 */


// Pinout of the interface board
#define PORT_EN1    27
#define PORT_DIR1   4
#define PORT_STP1   17

#define PORT_EN2    24
#define PORT_DIR2   23
#define PORT_STP2   18

#define PORT_EN3    7
#define PORT_DIR3   8
#define PORT_STP3   25

#define PORT_EN4    26
#define PORT_DIR4   20
#define PORT_STP4   16

#define PORT_STP3_4 12

#define PORT_EM     19
#define PORT_FS     5
#define PORT_BS     6

// Step size of the motors, configured through the DIP Switch of each STR2 driver
#define STEP_SIZE_INSERTION     5000
#define STEP_SIZE_ROTATION      2000
#define STEP_SIZE_BACK_GRIPPER  2000

// Physical parameters of the motors
#define MIN_SPEED 0.25
#define MAX_SPEED 5.0
#define MAX_FINAL_SPEED 30.0
#define ACC 300.0

#define INS_REVS_PER_MM               1.0
#define NEEDLE_TO_MOTOR_GEAR_RATIO    1.5
//#define NEEDLE_TO_MOTOR_GEAR_RATIO    ((32.0/28)*(5.0/2))

// Threshold values for the duty cycle
#define MAX_DC  0.95
#define MIN_DC  0.10

// Empty structs to be filled with the motor parameters
MotorParameters insertion_parameters;
MotorParameters rotation_parameters;
MotorParameters front_gripper_parameters;
MotorParameters back_gripper_parameters;

void declareDeviceParameters()
{
  // Motor 1 : controls the needle insertion
  insertion_parameters.port_enable = PORT_EN1;
  insertion_parameters.port_direction = PORT_DIR1;
  insertion_parameters.port_step = PORT_STP1;
  insertion_parameters.steps_per_revolution = STEP_SIZE_INSERTION;

  // Motor 2 : controls the back gripper
  back_gripper_parameters.port_enable = PORT_EN2;
  back_gripper_parameters.port_direction = PORT_DIR2;
  back_gripper_parameters.port_step = PORT_STP2;
  back_gripper_parameters.steps_per_revolution = STEP_SIZE_BACK_GRIPPER;

  // Motor 3 : controls the needle rotation
  // The step port is set as PORT_STP3_4 instead of PORT_STP3, because in order
  // to rotate the needle, motors 3 and 4 must be commanded simultaneously
  //
  // OBS: This also happens for the direction ports. When changing the rotation
  // direction it is necessary to write to PORT_DIR3 and PORT_DIR4 at the same
  // time, as there is no PORT_DIR3_4
  rotation_parameters.port_enable = PORT_EN3;
  rotation_parameters.port_direction = PORT_DIR3;
  rotation_parameters.port_step = PORT_STP3_4;
  rotation_parameters.steps_per_revolution = STEP_SIZE_ROTATION;

  // Motor 4 : controls the front gripper
  // The resolution of this motor must be the same of the rotation, because
  // motors 3 and 4 must be driven by the same step signal.
  front_gripper_parameters.port_enable = PORT_EN4;
  front_gripper_parameters.port_direction = PORT_DIR4;
  front_gripper_parameters.port_step = PORT_STP4;
  front_gripper_parameters.steps_per_revolution = STEP_SIZE_ROTATION;
}
