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

int stepsPerRev = 400;
double acceleration = 220.0;
StepperMotor motor1 = StepperMotor(4, stepsPerRev, acceleration);
StepperMotor motor2 = StepperMotor(17, stepsPerRev, acceleration);

void *myfunc1(void *arg)
{
	printf("STARTING THREAD1\n");
	sleep(2);
	printf("Sending data to motor1\n");
	motor1.startMotion();
	//gpioSleep(PI_TIME_RELATIVE, 3, 0);
	printf("Finished moving motor1\n");
	return (void*)0;
}

void *myfunc2(void *arg)
{
	printf("STARTING THREAD2\n");
	sleep(2);
	printf("Sending data to motor2\n");
	motor2.startMotion();
	//gpioSleep(PI_TIME_RELATIVE, 3, 0);
	printf("Finished moving motor2\n");
	return (void*)0;
}


int main(int argc, char *argv[])
{
  double startSpeed = 9;
  double maxSpeed = 4;
  double totalRevolutions = 10;

  if (gpioInitialise() < 0) return 1;

  motor1 = StepperMotor(4, stepsPerRev, acceleration);
  motor2 = StepperMotor(17, stepsPerRev, acceleration);

  int max_steps_per_wave = gpioWaveGetMaxPulses()/4;

  motor1.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
  //motor2.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);

  //motor1.startMotion();
  //motor2.startMotion();

  /*pthread_t *p1, *p2;
  p1 = gpioStartThread(myfunc1, (void*)"abc");
  sleep(1);
  p2 = gpioStartThread(myfunc2, (void*)"abc");
  sleep(6);
  //gpioStopThread(p1);
  //sleep(3);*/

  // End program
  gpioWaveClear();
  gpioTerminate();

  return 0;
}
