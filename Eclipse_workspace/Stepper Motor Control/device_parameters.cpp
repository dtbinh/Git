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
   // These are the Raspberry Pi ports that I have connected to each one of the
   // motor signals. These should only be modified, if the interface board changes
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
   // These values must ALWAYS match the DIP switches of the STR2 drivers
#define STEP_SIZE_INSERTION     5000
#define STEP_SIZE_ROTATION      400
#define STEP_SIZE_BACK_GRIPPER  400

// Gear ratio - conversion constant between the motors and the end effectors
   // These values must be verified with the rotation transmissions in the device
#define INSERTION_MOTOR_REVS_PER_MM               (35.0/29)
#define ROTATION_MOTOR_REVS_PER_NEEDLE_REVS       (20.0/7)
#define BACK_GRIPPER_MOTOR_REVS_PER_GEAR_REVS     (20.0/7)

// Speed and acceleration parameters of the motors
   // These values are all given in motor revolutions (not end effector)
#define MIN_SPEED            0.25
#define MAX_SPEED            4.0
#define MAX_FINAL_SPEED     30.0
#define ACC                200.0

// Gripper default speed and displacements
// These values are given in end effector perspective (not actual motor speeds)

   // The default speed the 'Engrenagem Guia's will spin - about 0.5 rev/s
#define GRIPPER_SPEED         0.5

   // The default angle the front gripper must spin to firmly grasp the needle - about 90 degrees (0.25 revolutions)
#define FRONT_GRIPPER_DISP    0.25

   // The default angle the back gripper must spin to firmly grasp the needle - about 90 degrees (0.25 revolutions)
#define BACK_GRIPPER_DISP     0.25

// Insertion length position limits in millimeters
#define MAX_INSERT_POS    140.0
#define MIN_INSERT_POS      1.0

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
  insertion_parameters.gear_ratio = INSERTION_MOTOR_REVS_PER_MM;

  // Motor 2 : controls the back gripper
  back_gripper_parameters.port_enable = PORT_EN2;
  back_gripper_parameters.port_direction = PORT_DIR2;
  back_gripper_parameters.port_step = PORT_STP2;
  back_gripper_parameters.steps_per_revolution = STEP_SIZE_BACK_GRIPPER;
  back_gripper_parameters.gear_ratio = BACK_GRIPPER_MOTOR_REVS_PER_GEAR_REVS;

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
  rotation_parameters.gear_ratio = ROTATION_MOTOR_REVS_PER_NEEDLE_REVS;

  // Motor 4 : controls the front gripper
  // The resolution and gear ratio of this motor must be the same of the rotation,
  // because motors 3 and 4 must be driven by the same step signal and rotate at
  // the same speed.
  front_gripper_parameters.port_enable = PORT_EN4;
  front_gripper_parameters.port_direction = PORT_DIR4;
  front_gripper_parameters.port_step = PORT_STP4;
  front_gripper_parameters.steps_per_revolution = STEP_SIZE_ROTATION;
  front_gripper_parameters.gear_ratio = ROTATION_MOTOR_REVS_PER_NEEDLE_REVS;
}
