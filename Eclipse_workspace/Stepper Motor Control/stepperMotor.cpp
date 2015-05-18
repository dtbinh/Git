/*
 * stepperMotor.cpp
 *
 *  Created on: Apr 30, 2015
 *      Author: andre
 */

#include "stepperMotor.h"

#include <stdio.h>
#include <stdlib.h>
#include <pigpio.h>

#define SECONDS_TO_MICROS	1000000
#define MICROS_TO_SECONDS	0.000001

#define WAVES_PRESENT_ALL         1
#define WAVES_PRESENT_RAMP        2
#define WAVES_PRESENT_CONSTANT    3
#define WAVES_PRESENT_NONE        -1

StepperMotor::StepperMotor(unsigned port_step, unsigned steps_per_revolution, double max_acceleration)
{
	gpioSetMode(port_step, PI_OUTPUT);
	gpioWrite(port_step, 0);

	has_wave_ramp_up_ = false;
	has_wave_ramp_down_ = false;
	has_wave_constant_ = false;

	wave_ramp_up_ = -1; wave_ramp_down_ = -1; wave_constant_ = -1;
	steps_ramp_up_ = 0; steps_ramp_down_ = 0; steps_constant_ = 0;
	seconds_ramp_up_ = 0; seconds_ramp_down_ = 0; seconds_constant_ = 0;
	micros_ramp_up_ = 0; micros_ramp_down_ = 0; micros_constant_ = 0;

	steps_per_revolution_ = steps_per_revolution;
	port_step_ = port_step;

  max_acceleration_ = max_acceleration;
}

/*
 * IMPLEMENTATION COMMENTS
 *   - Simply combines all the has_wave flags into one code
 *   - If any of the ramps is absent, both ramps are considered absent
*/
int StepperMotor::checkExistingWaves(void)
{
  if(has_wave_ramp_up_ && has_wave_ramp_up_)
  {
    if(has_wave_constant_)
      return WAVES_PRESENT_ALL;
    else
      return WAVES_PRESENT_RAMP;
  }
  else
  {
    if(has_wave_constant_)
      return WAVES_PRESENT_CONSTANT;
    else
      return WAVES_PRESENT_NONE;
  }
}

/*
 * IMPLEMENTATION COMMENTS
 *   - Generates a varying frequency square wave
 *   - The lower frequency may be higher than requested due to truncation
 *   - The higher frequency may be higher than requested due to truncation
 *   - The wave starts and ends at the same frequency
 *	 - If the necessary steps to achieve the higher frequency is higher than max_steps, the obtained higher frequency
 *	   is lower than the requested one
 *	 - In case of success, the wave is stored, the wave length is recorded and the wave flag is set
 *	 - In case of failure, the wave id is set to a negative value. The other wave parameters remain unchanged
*/
int StepperMotor::createWaveRampUpDown(double lower_frequency, double higher_frequency, unsigned max_steps)
{
	// Convert frequency variables from RPS to steps/second
	double lower_step_frequency = lower_frequency * steps_per_revolution_;
	double higher_step_frequency = higher_frequency * steps_per_revolution_;
	double step_acceleration = max_acceleration_ * steps_per_revolution_;

	// Allocate the memory for the ramp up pulses
	gpioPulse_t *pulses_up = (gpioPulse_t*) malloc(2*max_steps*sizeof(gpioPulse_t));

	if (pulses_up)
	{
		double current_step_frequency;
		unsigned current_half_period;
		unsigned total_micros = 0;
		unsigned i_step;

		// Generate ramp up pulses
		for(i_step = 0; i_step < max_steps; i_step++)
		{
			// Calculate the current frequency W(t) = W0 + a*t
			current_step_frequency = lower_step_frequency + step_acceleration*total_micros*MICROS_TO_SECONDS;

			// Calculate the corresponding half period in micros
			current_half_period = SECONDS_TO_MICROS/(2*current_step_frequency);

      // If the higher_frequency has been reached, stop generating pulses
      if (current_step_frequency >= higher_step_frequency)
      {
        break;
      }

			// Generate one step with the calculated period
			pulses_up[2*i_step].gpioOn = (1<<port_step_);
			pulses_up[2*i_step].gpioOff = 0;
			pulses_up[2*i_step].usDelay = current_half_period;
			pulses_up[2*i_step+1].gpioOn = 0;
			pulses_up[2*i_step+1].gpioOff = (1<<port_step_);
			pulses_up[2*i_step+1].usDelay = current_half_period;

			// Update the elapsed time counter
			total_micros += 2*current_half_period;
		}

		// Store the total number of steps used for the ramp up
		unsigned num_steps = i_step;

		// Allocate the memory for the ramp down pulses
		gpioPulse_t *pulses_down = (gpioPulse_t*) malloc(2*num_steps*sizeof(gpioPulse_t));

		if (pulses_down)
		{
			// Generate ramp down pulses by reversing the order of the ramp up
			for(i_step = 0; i_step < num_steps; i_step++)
			{
				current_half_period = pulses_up[2*i_step].usDelay;

				pulses_down[2*(num_steps-1-i_step)].gpioOn = (1<<port_step_);
				pulses_down[2*(num_steps-1-i_step)].gpioOff = 0;
				pulses_down[2*(num_steps-1-i_step)].usDelay = current_half_period;

				pulses_down[2*(num_steps-1-i_step)+1].gpioOn = 0;
				pulses_down[2*(num_steps-1-i_step)+1].gpioOff = (1<<port_step_);
				pulses_down[2*(num_steps-1-i_step)+1].usDelay = current_half_period;
			}

			// Create the wave ramp up
			gpioWaveAddGeneric(2*num_steps, pulses_up);
			steps_ramp_up_ = gpioWaveGetPulses()/2;
			micros_ramp_up_ = gpioWaveGetMicros();
      wave_ramp_up_ = gpioWaveCreate();

      // Create the wave ramp down
			gpioWaveAddGeneric(2*num_steps, pulses_down);
			steps_ramp_down_ = gpioWaveGetPulses()/2;
			micros_ramp_down_ = gpioWaveGetMicros();
      wave_ramp_down_ = gpioWaveCreate();

      // Free the memory allocated for storing the pulses
      free(pulses_up);
      free(pulses_down);

	    if (wave_ramp_up_ >= 0)
	    {
	      has_wave_ramp_up_ = true;
		    seconds_ramp_up_ = (unsigned)(micros_ramp_up_*MICROS_TO_SECONDS);
	      micros_ramp_up_ = micros_ramp_up_ - SECONDS_TO_MICROS*seconds_ramp_up_;
	    }
	    else
	    {
	      has_wave_ramp_up_ = false;
	      micros_ramp_up_ = -1;

	    	// [Error] wave not generated
	    	return -2;
	    }

	    if (wave_ramp_down_ >= 0)
	    {
	      has_wave_ramp_down_ = true;
	      seconds_ramp_down_ = (unsigned)(micros_ramp_down_*MICROS_TO_SECONDS);
	      micros_ramp_down_ = micros_ramp_down_ - SECONDS_TO_MICROS*seconds_ramp_down_;
	    }
	    else
	    {
	      has_wave_ramp_down_ = false;
	      micros_ramp_down_ = -1;

	      // [Error] wave not generated
		    return -2;
	    }
		}
		else
		{
			// [Error] error calling malloc
			return -1;
		}
	}
	else
	{
		// [Error] error calling malloc
		return -1;
	}

	return 0;
}

int StepperMotor::createWaveConstant(double frequency, unsigned num_steps)
{
  // Calculate the wave half period, based on the requested frequency
  uint32_t usHalfPeriod = SECONDS_TO_MICROS / (2*frequency*steps_per_revolution_);

  // Allocate the memory for the ramp up pulses
  gpioPulse_t *pulses = (gpioPulse_t*) malloc(2*sizeof(gpioPulse_t));

  if (pulses)
  {
    // Generate one pair of pulses for creating the wave
    pulses[0].gpioOn = (1<<port_step_);
    pulses[0].gpioOff = 0;
    pulses[0].usDelay = usHalfPeriod;
    pulses[1].gpioOn = 0;
    pulses[1].gpioOff = (1<<port_step_);
    pulses[1].usDelay = usHalfPeriod;

    // Create the wave with constant frequency
    gpioWaveAddGeneric(2, pulses);
    micros_constant_ = gpioWaveGetMicros();
    wave_constant_ = gpioWaveCreate();

    // Free the memory allocated for storing the pulses
    free(pulses);

    if (wave_constant_ >= 0)
    {
      has_wave_constant_ = true;
      steps_constant_ = num_steps;
      micros_constant_ = steps_constant_*micros_constant_;
      seconds_constant_ = (unsigned)(micros_constant_*MICROS_TO_SECONDS);
      micros_constant_ = micros_constant_ - SECONDS_TO_MICROS*seconds_constant_;
    }
    else
    {
      has_wave_constant_ = false;
      micros_constant_ = -1;

      // [Error] wave not generated
      return -2;
    }
  }
  else
  {
    // [Error] error calling malloc
    return -1;
  }

  return 0;
}

void StepperMotor::startMotion()
{
  switch (checkExistingWaves())
  {
    case WAVES_PRESENT_ALL:
      gpioWaveTxSend(wave_ramp_up_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, seconds_ramp_up_, micros_ramp_up_);
      gpioWaveTxSend(wave_constant_, PI_WAVE_MODE_REPEAT);
      gpioSleep(PI_TIME_RELATIVE, seconds_constant_, micros_constant_);
      gpioWaveTxSend(wave_ramp_down_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, seconds_ramp_down_, micros_ramp_down_);
      break;

    case WAVES_PRESENT_RAMP:
      gpioWaveTxSend(wave_ramp_up_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, seconds_ramp_up_, micros_ramp_up_);
      gpioWaveTxSend(wave_ramp_down_, PI_WAVE_MODE_ONE_SHOT);
      gpioSleep(PI_TIME_RELATIVE, seconds_ramp_down_, micros_ramp_down_);
      break;

    case WAVES_PRESENT_CONSTANT:
      gpioWaveTxSend(wave_constant_, PI_WAVE_MODE_REPEAT);
      gpioSleep(PI_TIME_RELATIVE, seconds_constant_, micros_constant_);
      gpioWaveTxStop();
      gpioWrite(port_step_, 0);

    default:
        break;
   }
}

int StepperMotor::moveRamp(double lower_frequency, double higher_frequency, double total_revolutions, unsigned max_steps_per_wave)
{
	unsigned ramp_max_steps;
	unsigned total_steps = total_revolutions * steps_per_revolution_;

	if(higher_frequency > lower_frequency)
	{
	  if (total_steps > 2*max_steps_per_wave) ramp_max_steps = max_steps_per_wave;
	  else ramp_max_steps = total_steps/2;
	  createWaveRampUpDown(lower_frequency, higher_frequency, ramp_max_steps);
	  printf("Generated ramp up and down with %d steps each \n", steps_ramp_up_);
	}

	unsigned remaining_steps = total_steps - steps_ramp_up_ - steps_ramp_down_;
	if(remaining_steps > 0)
	{
	  createWaveConstant(higher_frequency, remaining_steps);
	  printf("Generated constant speed wave with %d steps \n", steps_constant_);
	}

	return 0;

}
