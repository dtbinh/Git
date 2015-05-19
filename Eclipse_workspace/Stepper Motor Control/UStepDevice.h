/*
 * UStepDevice.h
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#ifndef USTEPDEVICE_H_
#define USTEPDEVICE_H_

#include "StepperMotor.h"
#include <pigpio.h>

class UStepDevice
{
 private:

  // Sensors
  unsigned emergency_button_;
  unsigned front_switch_;
  unsigned back_switch_;

  // Actuators
  StepperMotor insertion_;
  StepperMotor rotation_;
  StepperMotor front_gripper_;
  StepperMotor back_gripper_;

  // State variables
  bool configured_;
  bool initialized_;

  // Duty cycle wave parameters
  unsigned micros_rotation_;
  unsigned micros_pure_insertion_;
  unsigned micros_duty_cycle_period_;
  unsigned micros_remaining_;
  unsigned insertion_step_half_period_;
  unsigned rotation_step_half_period_;
  unsigned number_of_duty_cycle_periods_;

  // Waves
  int wave_insertion_with_rotation_;
  int wave_pure_insertion_;

  //
  void calculateDutyCycleMotionParameters(double insertion_depth_rev,  double insertion_speed, double rotation_speed, double duty_cycle);
  int generateWaveInsertionWithRotation();
  int generateWavePureInsertion();
  gpioPulse_t* generatePulsesConstantSpeed(unsigned port_number, unsigned half_period, unsigned num_steps);

 public:

  // Empty constructor
  UStepDevice();

  // Configuration functions
  void configureMotorParameters();
  int initGPIO();
  void terminateGPIO();

  // Motion functions
  void openFrontGripper();
  void closeFrontGripper();
  void openBackGripper();
  void closeBackGripper();
  void insert();
  void retreat();
  void spin();

  int setInsertionWithDutyCycle(double insertion_depth_rev,  double insertion_speed, double rotation_speed, double duty_cycle);
  int startInsertionWithDutyCycle();

};

#endif /* USTEPDEVICE_H_ */
