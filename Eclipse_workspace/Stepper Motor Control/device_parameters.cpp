/*
 * device_parameters.cpp
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#include "StepperMotor.h"

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

#define STEP_SIZE_ROTATION   5000
#define STEP_SIZE_INSERTION  5000

#define MAX_DC  0.95
#define MIN_DC  0.10

MotorParameters translation_parameters;
MotorParameters rotation_parameters;
MotorParameters front_gripper_parameters;
MotorParameters back_gripper_parameters;

void declareDeviceParameters()
{
  translation_parameters.port_enable = PORT_EN1;
  translation_parameters.port_direction = PORT_DIR1;
  translation_parameters.port_step = PORT_STP1;
  translation_parameters.steps_per_revolution = STEP_SIZE_INSERTION;

  rotation_parameters.port_enable = PORT_EN3;
  rotation_parameters.port_direction = PORT_DIR3;
  rotation_parameters.port_step = PORT_STP3_4;
  rotation_parameters.steps_per_revolution = STEP_SIZE_ROTATION;

  front_gripper_parameters.port_enable = PORT_EN4;
  front_gripper_parameters.port_direction = PORT_DIR4;
  front_gripper_parameters.port_step = PORT_STP4;
  front_gripper_parameters.steps_per_revolution = STEP_SIZE_ROTATION;

  back_gripper_parameters.port_enable = PORT_EN2;
  back_gripper_parameters.port_direction = PORT_DIR2;
  back_gripper_parameters.port_step = PORT_STP2;
  back_gripper_parameters.steps_per_revolution = STEP_SIZE_ROTATION;
}
