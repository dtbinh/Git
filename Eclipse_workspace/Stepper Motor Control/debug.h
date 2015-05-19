/*
 * debug.h
 *
 *  Created on: May 18, 2015
 *      Author: andre
 */

#ifndef DEBUG_H_
#define DEBUG_H_

// Enable/Disable debug prints
#define DEBUG_PRINT_ENABLED 1

// Debug printf function
#include <stdio.h>
#if DEBUG_PRINT_ENABLED
#define Debug printf
#else
#define Debug(format, args...) ((void)0)
#endif

// Error codes
#define ERR_MALLOC                  -1
#define ERR_MOTOR_NOT_CONFIGURED    -11
#define ERR_DEVICE_NOT_INITIALIZED  -12
#define ERR_GPIO_INIT_FAIL          -101
#define ERR_GPIO_WAVE_CREATE_FAIL   -102

#endif /* DEBUG_H_ */
