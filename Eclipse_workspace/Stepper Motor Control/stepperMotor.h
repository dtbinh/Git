/*
 * stepperMotor.h
 *
 *  Created on: Apr 30, 2015
 *      Author: andre
 */

#ifndef STEPPERMOTOR_H_
#define STEPPERMOTOR_H_

class StepperMotor
{
	private:
		int wave_ramp_up_;
		int wave_ramp_down_;
		int wave_constant_;

		bool has_wave_ramp_up_;
		bool has_wave_ramp_down_;
		bool has_wave_constant_;

		unsigned steps_ramp_up_;
		unsigned steps_ramp_down_;
		unsigned steps_constant_;

		unsigned seconds_ramp_up_;
		unsigned seconds_ramp_down_;
		unsigned seconds_constant_;

		unsigned micros_ramp_up_;
		unsigned micros_ramp_down_;
		unsigned micros_constant_;

		unsigned steps_per_revolution_;
		unsigned port_step_;

		double max_acceleration_;

		int checkExistingWaves(void);
		int createWaveRampUpDown(double lower_frequency, double higher_frequency, unsigned max_steps);
		int createWaveConstant(double frequency, unsigned num_steps);

	public:
		StepperMotor(unsigned port_step, unsigned steps_per_revolution, double max_acceleration);

		void startMotion();
		int moveRamp(double lower_frequency, double higher_frequency, double total_revolutions,  unsigned max_steps_per_wave);

};




#endif /* STEPPERMOTOR_H_ */
