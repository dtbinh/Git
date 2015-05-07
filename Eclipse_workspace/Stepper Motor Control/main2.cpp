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

#define PORT_EN1		22
#define PORT_STP1		4
#define PORT_DIR1		17
#define PORT_DIR1N		27
#define PORT_FL			26
#define PORT_BL			19

void *mainThread(void *arg)
{
  double startSpeed = 9;
  double maxSpeed = 4;
  double totalRevolutions = 8;

  int stepsPerRev = 400;
  double acceleration = 220.0;

	  StepperMotor motor1 = StepperMotor(4, stepsPerRev, acceleration);
	  gpioSetMode(PORT_DIR1, PI_OUTPUT);
	  gpioSetMode(PORT_DIR1N, PI_OUTPUT);

	  int max_steps_per_wave = gpioWaveGetMaxPulses()/4;

	  motor1.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);

	  printf("MainThread: Moving the motor FORWARD\n");
	  gpioWrite(PORT_DIR1, 0);
	  gpioWrite(PORT_DIR1N, 1);
	  motor1.startMotion();
	  sleep(1);

	  printf("MainThread: Moving the motor BACKWARD\n");
	  gpioWrite(PORT_DIR1, 1);
	  gpioWrite(PORT_DIR1N, 0);
	  motor1.startMotion();
	  sleep(1);

	  printf("MainThread: Moving the motor FORWARD\n");
	  gpioWrite(PORT_DIR1, 0);
	  gpioWrite(PORT_DIR1N, 1);
	  motor1.startMotion();

	  // End program
	  gpioWaveClear();
}

void *sensorThread(void *arg)
{
	bool sensor_fl = false;
	bool sensor_bl = false;
	while(1)
	{
		if(sensor_fl)
		{
			if(gpioRead(PORT_FL) == 1)
			{
				sensor_fl = false;
			}
		}
		else
		{
			if(gpioRead(PORT_FL) == 0)
			{
				sensor_fl = true;
				printf("SensorThread: FRONT switch hit!\n");
			}
		}


		if(sensor_bl)
		{
			if(gpioRead(PORT_BL) == 1)
			{
				sensor_bl = false;
			}
		}
		else
		{
			if(gpioRead(PORT_BL) == 0)
			{
				sensor_bl = true;
				printf("SensorThread: BACK switch hit!\n");
			}
		}

		gpioSleep(PI_TIME_RELATIVE, 0, 100000);
	}
}


int main(int argc, char *argv[])
{
	if(gpioInitialise() < 0) return 1;

	gpioSetMode(PORT_EN1, PI_OUTPUT);
	gpioSetMode(PORT_STP1, PI_OUTPUT);
	gpioSetMode(PORT_DIR1, PI_OUTPUT);
	gpioSetMode(PORT_DIR1N, PI_OUTPUT);
	gpioSetMode(PORT_FL, PI_INPUT);
	gpioSetMode(PORT_BL, PI_INPUT);
	gpioSetPullUpDown(PORT_FL, PI_PUD_UP);
	gpioSetPullUpDown(PORT_BL, PI_PUD_UP);

	printf("Disabling motor\n");
	gpioWrite(PORT_EN1, 0);
	sleep(3);
	printf("Enabling motor\n");
	gpioWrite(PORT_EN1, 1);
	sleep(3);
	printf("Disabling motor\n");
	gpioWrite(PORT_EN1, 0);
	sleep(3);
	printf("Enabling motor\n");
	gpioWrite(PORT_EN1, 1);

	pthread_t *p1, *p2;
	p1 = gpioStartThread(mainThread, (void*)"abc");
	p2 = gpioStartThread(sensorThread, (void*)"abc");
	sleep(10);
	gpioStopThread(p1);
	gpioStopThread(p2);
    gpioTerminate();
	return 0;
}
