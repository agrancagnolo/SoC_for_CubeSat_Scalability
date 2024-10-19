/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	IO Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Observes counter value through the MPRJ lower 8 IO pins (in the testbench)
*/

#define ENABLE_ADDRESS   	(*(volatile uint32_t*)0x30000000)
#define FREQUENCY_ADDRESS   (*(volatile uint32_t*)0x30000004)
#define PHI_P_ADDRESS    	(*(volatile uint32_t*)0x30000008)
#define PHI_L1_ADDRESS    	(*(volatile uint32_t*)0x3000000C)
#define PHI_L2_ADDRESS    	(*(volatile uint32_t*)0x30000010)
#define PHI_R_ADDRESS    	(*(volatile uint32_t*)0x30000014)
#define CLOCK_ADDRESS 		(*(volatile uint32_t*)0x30000018)
#define	RETURN_ADDRESS		(*(volatile uint32_t*)0x3000001C)

void delay(volatile uint32_t time) {
    while (time > 0) time--;
}

void main()
{
	int contador;
	int return_value;
	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// Configure lower 8-IOs as user output
	// Observe counter value in the testbench
	// 5 - 6 uart
	reg_mprj_io_10 =  GPIO_MODE_USER_STD_OUTPUT; 		// phi P
	reg_mprj_io_13 =  GPIO_MODE_USER_STD_OUTPUT; 		// phi R
	reg_mprj_io_11 =  GPIO_MODE_USER_STD_OUTPUT; 		// phi L1
	reg_mprj_io_12 =  GPIO_MODE_USER_STD_OUTPUT; 		// phi L2
	reg_mprj_io_9  =  GPIO_MODE_USER_STD_OUTPUT; 		// test_out[2]
	reg_mprj_io_8  =  GPIO_MODE_USER_STD_OUTPUT; 		// test_out[1]
	reg_mprj_io_7  =  GPIO_MODE_USER_STD_OUTPUT; 		// test_out[0]

	// Set UART clock to 64 kbaud (enable before I/O configuration)
	// reg_uart_clkdiv = 625;

	
	reg_wb_enable=1;
	reg_mprj_xfer = 1;

	/* Apply configuration */
	while (reg_mprj_xfer == 1);

	contador = 0;
	return_value = 0x00;

	RETURN_ADDRESS = 0;
	ENABLE_ADDRESS = 0;
	FREQUENCY_ADDRESS = 0x0;
	CLOCK_ADDRESS = 0x00;
	ENABLE_ADDRESS = 1;
	
	while(1)
	{
		while(contador < 2){ // 500ns 
			CLOCK_ADDRESS = 0xFF;
			delay(10);
			CLOCK_ADDRESS = 0x00;
			delay(10);
			contador = contador + 1; 
		}
		if (PHI_P_ADDRESS == 1 && PHI_R_ADDRESS == 1 && PHI_L2_ADDRESS == 1 && PHI_L1_ADDRESS == 0) {
			return_value = return_value + 0x01;
			RETURN_ADDRESS = return_value;
		}
		while(contador < 6){ //1.5us
			CLOCK_ADDRESS = 0xFF;
			delay(10);
			CLOCK_ADDRESS = 0x00;
			delay(10);
			contador = contador + 1; 
		}
		if (PHI_P_ADDRESS == 0 && PHI_R_ADDRESS == 0 && PHI_L2_ADDRESS == 0 && PHI_L1_ADDRESS == 1) {
			return_value = return_value + 0x01;
			RETURN_ADDRESS = return_value;
		}
		while(contador < 9){ //2.25us
			CLOCK_ADDRESS = 0xFF;
			delay(10);
			CLOCK_ADDRESS = 0x00;
			delay(10);
			if (PHI_P_ADDRESS == 0 && PHI_R_ADDRESS == 1 && PHI_L2_ADDRESS == 1 && PHI_L1_ADDRESS == 0) {
			return_value = return_value + 0x01;
			RETURN_ADDRESS = return_value;
			}
			contador = contador + 1; 
		}
		while(contador < 11){ //2.75us
			CLOCK_ADDRESS = 0xFF;
			delay(10);
			CLOCK_ADDRESS = 0x00;
			if (PHI_P_ADDRESS == 0 && PHI_R_ADDRESS == 0 && PHI_L2_ADDRESS == 1 && PHI_L1_ADDRESS == 0) {
			return_value = return_value + 0x01;
			RETURN_ADDRESS = return_value;
			}
			delay(10);
			contador = contador + 1; 
		}
		while(contador < 15){ //3.75us
			CLOCK_ADDRESS = 0xFF;
			delay(10);
			CLOCK_ADDRESS = 0x00;
			delay(10);
			contador = contador + 1; 
		}
		ENABLE_ADDRESS = 0;
	}
}

