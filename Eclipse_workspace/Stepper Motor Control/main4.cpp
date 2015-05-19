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
#include <unistd.h>



int main(int argc, char *argv[])
{
  UStepDevice device;
  device.configureMotorParameters();
  device.initGPIO();

  // Move motors to the home position
  //device.calibrate

  if(device.setInsertionWithDutyCycle(10.0, 2.0, 5.0, 1.0) == 0)
    device.startInsertion();



  sleep(1);
  device.terminateGPIO();
  return 0;
}
