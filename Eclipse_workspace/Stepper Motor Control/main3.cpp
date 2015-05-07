/*
 * main2.cpp
 *
 *  Created on: Apr 30, 2015
 *      Author: andre
 */

#include <stdio.h>
#include <unistd.h>
#include <pigpio.h>
#include "stepperMotor.h"

#define S_TO_US   1000000
#define US_TO_S   0.000001

#define PORT_STP1		4
#define PORT_STP2		17
#define PORT_STP12		27

int main(int argc, char *argv[])
{
  double startSpeed = 4;
  double maxSpeed = 12;
  double totalRevolutions = 30;

  int stepsPerRev = 400;
  double acceleration = 180.0;

  if(gpioInitialise() < 0) return 1;

  StepperMotor motor1 = StepperMotor(PORT_STP1, stepsPerRev, acceleration);
  StepperMotor motor2 = StepperMotor(PORT_STP2, stepsPerRev, acceleration);
  StepperMotor motor3 = StepperMotor(PORT_STP12, stepsPerRev, acceleration);

  int max_steps_per_wave = gpioWaveGetMaxPulses()/4;

  motor1.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
  motor2.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
  motor3.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);

  sleep(10);
  printf("MainThread: Moving the motor 1\n");
  motor1.startMotion();
  sleep(1);

  printf("MainThread: Moving the motor 2\n");
  motor2.startMotion();
  sleep(1);

  printf("MainThread: Moving both motors simultaneously\n");
  motor3.startMotion();

  // End program
  gpioWaveClear();
  gpioTerminate();
  return 0;
}
