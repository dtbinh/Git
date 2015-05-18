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

#define PORT_EN1		27
#define PORT_DIR1		4
#define PORT_STP1		17

#define PORT_EN2		24
#define PORT_DIR2		23
#define PORT_STP2		18

#define PORT_EN3		7
#define PORT_DIR3		8
#define PORT_STP3		25

#define PORT_EN4		26
#define PORT_DIR4		20
#define PORT_STP4		16

#define PORT_STP3_4		12

#define PORT_EM			19
#define PORT_FS			5
#define PORT_BS			6

void *mainThread(void *arg)
{
	  double startSpeed = 4;
	  double maxSpeed = 8;
	  double totalRevolutions = 20;

	  int stepsPerRev = 400;
	  double acceleration = 180.0;

	  StepperMotor motor1 = StepperMotor(PORT_STP1, stepsPerRev, acceleration);
	  StepperMotor motor2 = StepperMotor(PORT_STP2, stepsPerRev, acceleration);
	  StepperMotor motor3 = StepperMotor(PORT_STP3, stepsPerRev, acceleration);
	  StepperMotor motor4 = StepperMotor(PORT_STP4, stepsPerRev, acceleration);
	  StepperMotor motor34 = StepperMotor(PORT_STP3_4, stepsPerRev, acceleration);

	  int max_steps_per_wave = gpioWaveGetMaxPulses()/4;

	  motor1.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
	  motor2.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
	  motor3.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
	  motor4.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);
	  motor34.moveRamp(startSpeed, maxSpeed, totalRevolutions,  max_steps_per_wave);


	  // ENABLE TEST - 7s
	  printf("Disabling all motors\n");
	  gpioWrite(PORT_EN1, 1);
	  gpioWrite(PORT_EN2, 1);
	  gpioWrite(PORT_EN3, 1);
	  gpioWrite(PORT_EN4, 1);

	  sleep(5);
	  printf("Enabling all motors\n");
	  gpioWrite(PORT_EN1, 0);
	  gpioWrite(PORT_EN2, 0);
	  gpioWrite(PORT_EN3, 0);
	  gpioWrite(PORT_EN4, 0);

	  sleep(5);
	  printf("Disabling all motors\n");
	  gpioWrite(PORT_EN1, 1);
	  gpioWrite(PORT_EN2, 1);
	  gpioWrite(PORT_EN3, 1);
	  gpioWrite(PORT_EN4, 1);

	  sleep(4);
	  gpioWrite(PORT_EN1, 0);
	  gpioWrite(PORT_EN2, 0);
	  gpioWrite(PORT_EN3, 0);
	  gpioWrite(PORT_EN4, 0);



	  /*
	  // TEST MOTORS 3 AND 4 - 22s
	  printf("MOVING FORWARD\n");
	  printf("MainThread: Moving the motor 4\n");
	  motor4.startMotion();
	  sleep(1);
	  printf("MainThread: Moving the motor 3\n");
	  motor3.startMotion();
	  sleep(1);
	  printf("MainThread: Moving both motors simultaneously\n");
	  motor34.startMotion();
	  sleep(1);

	  gpioWrite(PORT_DIR4, 1);
	  gpioWrite(PORT_DIR3, 1);
	  printf("MOVING BACKWARD\n");
	  printf("MainThread: Moving the motor 4\n");
	  motor4.startMotion();
	  sleep(1);
	  printf("MainThread: Moving the motor 3\n");
	  motor3.startMotion();
	  sleep(1);
	  printf("MainThread: Moving both motors simultaneously\n");
	  motor34.startMotion();
	  sleep(1);
	  */



	  /*
	  // TEST MOTORS 2 - 7s
	  printf("MOVING FORWARD\n");
	  motor2.startMotion();
	  sleep(1);

	  gpioWrite(PORT_DIR2, 1);
	  printf("MOVING BACKWARD\n");
	  motor2.startMotion();
	  sleep(1);
	  */




	  /*
	  // TEST MOTOR 1 - 11s
	  printf("MOVING MOTOR 1 FORWARD\n");
	  motor1.startMotion();
	  sleep(1);
	  printf("MOVING MOTOR 1 BACKWARD\n");
	  gpioWrite(PORT_DIR1, 1);
	  motor1.startMotion();
	  sleep(1);
	  printf("MOVING MOTOR 1 FORWARD\n");
	  gpioWrite(PORT_DIR1, 0);
	  motor1.startMotion();
	  sleep(1);
	  */






	  // End program
	  gpioWaveClear();
}

void *sensorThread(void *arg)
{
	bool sensor_fl = false;
	bool sensor_bl = false;

	unsigned sensor_em;
	unsigned sensor_fs;
	unsigned sensor_bs;

	unsigned current_sensor;
	unsigned past_sensor = 0;

	while(1)
	{
		sensor_em = gpioRead(PORT_EM);
		sensor_fs = gpioRead(PORT_FS);
		sensor_bs = gpioRead(PORT_BS);

		current_sensor = 4*sensor_em + 2*sensor_fs + sensor_bs;

		if(current_sensor != past_sensor)
		{
			printf("EM = %d, BS = %d, FS = %d\n", sensor_em, sensor_bs, sensor_fs);
		}

		past_sensor = current_sensor;
		gpioSleep(PI_TIME_RELATIVE, 0, 100000);
	}
}

void initGPIO()
{
	gpioSetMode(PORT_EN1, PI_OUTPUT);
	gpioSetMode(PORT_DIR1, PI_OUTPUT);
	gpioSetMode(PORT_STP1, PI_OUTPUT);

	gpioSetMode(PORT_EN2, PI_OUTPUT);
	gpioSetMode(PORT_DIR2, PI_OUTPUT);
	gpioSetMode(PORT_STP2, PI_OUTPUT);

	gpioSetMode(PORT_EN3, PI_OUTPUT);
	gpioSetMode(PORT_DIR3, PI_OUTPUT);
	gpioSetMode(PORT_STP3, PI_OUTPUT);

	gpioSetMode(PORT_EN4, PI_OUTPUT);
	gpioSetMode(PORT_DIR4, PI_OUTPUT);
	gpioSetMode(PORT_STP4, PI_OUTPUT);

	gpioSetMode(PORT_STP3_4, PI_OUTPUT);

	gpioSetMode(PORT_EM, PI_INPUT);
	gpioSetMode(PORT_FS, PI_INPUT);
	gpioSetMode(PORT_BS, PI_INPUT);

	gpioSetPullUpDown(PORT_EM, PI_PUD_OFF);
	gpioSetPullUpDown(PORT_FS, PI_PUD_DOWN);
	gpioSetPullUpDown(PORT_BS, PI_PUD_DOWN);

	gpioWrite(PORT_EN1, 0);
	gpioWrite(PORT_DIR1, 0);
	gpioWrite(PORT_STP1, 0);

	gpioWrite(PORT_EN2, 0);
	gpioWrite(PORT_DIR2, 0);
	gpioWrite(PORT_STP2, 0);

	gpioWrite(PORT_EN3, 0);
	gpioWrite(PORT_DIR3, 0);
	gpioWrite(PORT_STP3, 0);

	gpioWrite(PORT_EN4, 0);
	gpioWrite(PORT_DIR4, 0);
	gpioWrite(PORT_STP4, 0);

	gpioWrite(PORT_STP3_4, 0);
}

int main(int argc, char *argv[])
{
	if(gpioInitialise() < 0) return 1;
	initGPIO();

	pthread_t *p1, *p2;
	p1 = gpioStartThread(mainThread, (void*)"abc");
	p2 = gpioStartThread(sensorThread, (void*)"abc");

	sleep(15);
	gpioStopThread(p1);
	gpioStopThread(p2);
    gpioTerminate();
	return 0;
}
