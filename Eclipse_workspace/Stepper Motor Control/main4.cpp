/*
 * main2.cpp
 *
 *  Created on: Apr 30, 2015
 *      Author: andre
 */

#include "UStepDevice.h"
#include "debug.h"
#include <pigpio.h>
#include <math.h>



int main(int argc, char *argv[])
{
  UStepDevice device;
  device.configureMotorParameters();
  device.initGPIO();

  // Move motors to the home position
  //device.calibrate

  device.setInsertionWithDutyCycle(10.0, 1.0, 4.0, 0.5);
  device.startInsertionWithDutyCycle();



  device.terminateGPIO();
  return 0;
}
