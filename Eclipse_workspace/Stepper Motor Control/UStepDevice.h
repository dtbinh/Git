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

  // Sensors
  unsigned emergency_button_;
  unsigned front_switch_;
  unsigned back_switch_;

  // Actuators
  StepperMotor insertion_;
  StepperMotor rotation_;
  StepperMotor front_gripper_;
  StepperMotor back_gripper_;

  // Physical parameters of the rotation motor
  double min_base_speed_;
  double max_base_speed_;
  double max_final_speed_;
  double max_acceleration_;

  // Mechanical parameters
  double insertion_revolutions_per_mm_;   // (6/5)*(1/1) motor revolutions / displacement mm
  double motor_per_needle_revolutions_;   // (32/28)*(5/2) motor revolutions / needle revolution

  // Duty cycle threshold parameters
  double dc_max_threshold_;
  double dc_min_threshold_;

  /*
   * INTERNAL VARIABLES
   */

  // State variables
  bool configured_;
  bool initialized_;

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
  unsigned micros_real_rotation_duration_;
  double calculated_insertion_speed_;
  double calculated_rotation_speed_;
  double calculated_duty_cycle_;
  double rotation_ramp_step_percentage_;

  /*
   * AUXILIARY FUNCTIONS
   */

  // Clear the wave variables, unset the wave flags and clear all the duty cycle parameters
  void clearWaves();

  // Combine all the wave flags in a single variable
  int checkExistingWaves();

  // Safety check
  int verifyMotorSpeedLimits(double insertion_motor_speed, double rotation_motor_speed);

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

  // Calculate the duty cycle motion parameters and create the motion waves
  int setInsertionWithDutyCycle(double needle_insertion_depth,  double needle_insertion_speed, double needle_rotation_speed, double duty_cycle);

  // Send the duty cycle motion waves
  int startInsertion();

  void testFunction();

  /*void openFrontGripper();
  void closeFrontGripper();
  void openBackGripper();
  void closeBackGripper();
  void insert();
  void retreat();
  CALLIBRATE
  DISPLAY PARAMETERS
  void spin();*/

};

#endif /* USTEPDEVICE_H_ */
