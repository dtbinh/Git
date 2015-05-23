/*
 * debug.h
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#ifndef DEBUG_H_
#define DEBUG_H_

// Includes
#include <stdio.h>

// Enable/Disable debug prints
#define DEBUG_PRINT_ENABLED 1
#define ERROR_PRINT_ENABLED 1

// Debug print function
#if DEBUG_PRINT_ENABLED
#define Debug printf
#else
#define Debug(format, args...) ((void)0)
#endif

// Debug print function
#if ERROR_PRINT_ENABLED
#define Error printf
#else
#define Error(format, args...) ((void)0)
#endif

// Error codes
#define ERR_MALLOC                  -1
#define ERR_MOTOR_NOT_CONFIGURED    -11
#define ERR_DEVICE_NOT_INITIALIZED  -12
#define ERR_TIME_CALC_INVALID       -13
#define ERR_INVALID_MOTOR_SPEED     -21
#define ERR_INSERT_SPEED_TOO_SMALL  -22
#define ERR_INSERT_SPEED_TOO_HIGH   -23
#define ERR_ROT_SPEED_TOO_SMALL     -24
#define ERR_ROT_SPEED_TOO_HIGH      -25
#define ERR_INVALID_ROTATION_RAMP   -14
#define ERR_GPIO_INIT_FAIL          -101
#define ERR_GPIO_WAVE_CREATE_FAIL   -102
#define ERR_WAVES_NOT_PRESENT       -103

#endif /* DEBUG_H_ */
