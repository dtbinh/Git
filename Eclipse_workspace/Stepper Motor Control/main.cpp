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

#define GPIO 4

#define S_TO_US   1000000
#define US_TO_S   0.000001

int main(int argc, char *argv[])
{

  int stepsPerRev = 400;

  double startSpeed = 1;
  double maxSpeed = 40;
  double totalRevolutions = 100;

  double acceleration = 220.0;

  if (gpioInitialise() < 0) return 1;

  StepperMotor motor = StepperMotor(GPIO, stepsPerRev, acceleration);

  int max_steps_per_wave = gpioWaveGetMaxPulses()/4;

  motor.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);

  //sleep(3);
  motor.startMotion();
  sleep(1);
  motor.startMotion();

  // End program
  gpioWaveClear();
  gpioTerminate();

  return 0;
}
