/*
 * MyMotor.h
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#ifndef STEPPERMOTOR_H_
#define STEPPERMOTOR_H_

struct MotorParameters {
  unsigned port_enable;
  unsigned port_direction;
  unsigned port_step;
  unsigned steps_per_revolution;
} ;

const struct MotorParameters empty_parameters = {0,0,0,0};

class StepperMotor
{
 private:

  //
  unsigned port_enable_;
  unsigned port_direction_;
  unsigned port_step_;

  //
  unsigned steps_per_revolution_;

  //
  bool configured_;
  bool initialized_;


 public:

  //
  StepperMotor();

  //
  unsigned port_step();
  unsigned steps_per_revolution();

  //
  void configureParameters(MotorParameters parameters);
  int initGPIO();

};

#endif /* STEPPERMOTOR_H_ */
