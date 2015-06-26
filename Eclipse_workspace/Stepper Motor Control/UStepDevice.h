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

  /*
   * DEVICE PARAMETERS
   */

  // Actuators
  StepperMotor insertion_;
  StepperMotor rotation_;
  StepperMotor front_gripper_;
  StepperMotor back_gripper_;

  // Sensors
  unsigned emergency_button_;
  unsigned front_switch_;
  unsigned back_switch_;

  // Speed and acceleration parameters of the motors
  double min_base_speed_;
  double max_base_speed_;
  double max_final_speed_;
  double max_acceleration_;

  // Standard speed for opening/closing the gripper
  double gripper_default_speed_;

  // The default displacement of the front gripper (in revolutions) necessary to
  // move the gripper from the open position to the firmly grasping position
  double front_gripper_default_displacement_;

  // The default displacement of the back gripper (in revolutions) necessary to
  // move the gripper from the open position to the firmly grasping position
  double back_gripper_default_displacement_;

  // Insertion length position limits in millimeters
  // These positions correspond to the distance from the gripper box to the front limit switch
  double max_insertion_position_;
  double min_insertion_position_;

  // Duty cycle threshold parameters
  double dc_max_threshold_;
  double dc_min_threshold_;

//  double insertion_motor_revolutions_per_mm_;   // (6/5)*(1/1) motor revolutions / displacement mm
//  double rotation_motor_per_needle_revolutions_;   // (32/28)*(5/2) motor revolutions / needle revolution

  /*
   * INTERNAL VARIABLES
   */

  // State variables
  bool configured_;
  bool initialized_;
  bool calibrated_;

  // Internal position estimation
  bool front_gripper_closed_;
  bool back_gripper_closed_;
  double insertion_position_;

  // Waves
  int wave_insertion_with_rotation_;
  int wave_pure_insertion_;

  // Wave flags
  bool has_wave_pure_insertion_;
  bool has_wave_insertion_with_rotation_;
  bool has_wave_remaining_;

  // Duty cycle wave parameters
  unsigned num_dc_periods_;
  unsigned insertion_step_half_period_;
  unsigned rotation_step_half_period_;
  unsigned micros_rotation_;
  unsigned micros_pure_insertion_;
  unsigned micros_remaining_;
  unsigned seconds_rotation_;
  unsigned seconds_pure_insertion_;

  // Feed back variables
  double calculated_insertion_depth_;
  double calculated_insertion_speed_;
  double calculated_rotation_speed_;
  double calculated_duty_cycle_;
  unsigned micros_real_rotation_duration_;
  double rotation_ramp_step_percentage_;

  /*
   * AUXILIARY FUNCTIONS
   */

  // DESCRIPTION PENDING
  void displayParameters();

  // Clear the wave variables, clear the wave flags and clear all the duty cycle parameters
  void clearWaves();

  // Combine all the wave flags in a single variable
  int checkExistingWaves();

  // Safety check
  int verifyMotorSpeedLimits(double motor_speed, bool allow_ramp);

  // Calculate all the duty cycle parameters, based on the requested speeds and duty cycle
  // OBS: The actual speeds and duty cycle may differ from the requested due to
  // truncation and the need of ramping the rotation motor. The performed
  // speeds and duty cycle are then saved to feedback variables.
  int calculateDutyCycleMotionParameters(double insert_motor_distance,  double insert_motor_speed, double rot_motor_speed, double duty_cycle);

  // Calculate the maximum rotation speed, if a frequency ramp is necessary.
  // Motor is considered to start at a base speed, ramp up until a 'maximum speed'
  // with constant acceleration and ramp down to base speed again, performing
  // one full rotation.
  // The 'maximum speed' is calculated as the lowest speed so that the motor can
  // perform an entire rotation within 'rot_insert_time_us' microseconds.
  int calculateRotationSpeed(unsigned max_rotation_time);

  // DESCRIPTION PENDING
  int calculateFeedbackInformation();

  // Generate a wave containing pulses for both the insertion and the rotation motor
  // In case of success the wave is saved to the member variable and the
  // corresponding flag is set.
  // In case of failure, the wave is not created and this functions return an error result
  int generateWaveInsertionWithRotation();

  // Generate a wave containing one step of the insertion motor
  int generateWavePureInsertion();

  // Build an array of pulses with constant speed
  // This function is called from the 'generateWavePureInsertion()' function
  gpioPulse_t* generatePulsesConstantSpeed(unsigned port_number, unsigned half_period, unsigned num_steps, unsigned total_time);

  // Build an array of pulses forming a motion profile that starts at a 'frequency_initial'
  // ramps up until 'frequency_final', maintain 'frequency_final' for some time and
  // decelerate back to 'frequency_initial'. Both ramps use the same 'step_acceleration'.
  // The final sequence of pulses contains 'num_steps' steps and lasts 'total_time' microseconds.
  // This function is called from the 'generateWaveInsertionWithRotation()' function
  gpioPulse_t* generatePulsesRampUpDown(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, unsigned num_steps, unsigned total_time);

  // Build an array of pulses for ramping from 'frequency_initial' to 'frequency_final'
  // The pointer for the pulses must be provided and must have previously allocated enough
  // memory for storing  'max_steps' steps.
  // This function returns the number of pulses used in the ramp
  unsigned generatePulsesRampUp(unsigned port_number, double frequency_initial, double frequency_final, double step_acceleration, gpioPulse_t* pulses, unsigned max_steps);

 public:

  // Empty constructor
  UStepDevice();

  // Read device parameters from file and set the member variables
  void configureMotorParameters();

  // Initialize the Raspberry Pi GPIO
  int initGPIO();

  // Terminate the Raspberry Pi GPIO
  void terminateGPIO();

  // DESCRIPTION PENDING
  int calibrateMotorsStartingPosition();

  // Calculate the duty cycle motion parameters and create the motion waves
  int setInsertionWithDutyCycle(double needle_insertion_depth,  double needle_insertion_speed, double needle_rotation_speed, double duty_cycle);

  // Send the duty cycle motion waves
  int startInsertionWithDutyCycle();

  // DESCRIPTION PENDING
  int performFullDutyCyleStep(double needle_insertion_depth,  double needle_insertion_speed, double needle_rotation_speed, double duty_cycle);

  // DESCRIPTION PENDING
  int openFrontGripper();

  // DESCRIPTION PENDING
  int closeFrontGripper();

  // DESCRIPTION PENDING
  int openBackGripper();

  // DESCRIPTION PENDING
  int closeBackGripper();

  // DESCRIPTION PENDING
  // OBS: This should be a private function, but I will leave it public for debugging purposes
  int moveMotorConstantSpeed(unsigned motor, double displacement, double speed);

  // DESCRIPTION PENDING
  int setDirection(unsigned motor, unsigned direction);

};

#endif /* USTEPDEVICE_H_ */
