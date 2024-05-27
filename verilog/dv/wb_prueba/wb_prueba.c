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

#define reg_wb_leds      (*(volatile uint32_t*)0x30000000)
#define reg_wb_buttons   (*(volatile uint32_t*)0x30000004)

void main()
{
	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_control = SPI_MASTER_ENABLE | (2 & SPI_MASTER_DIV_MASK);
	reg_spimaster_control |= SPI_HOUSEKEEPING_CONN;
	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

	// Configure lower 8-IOs as user output
	// Observe counter value in the testbench
	// 5 - 6 uart
		reg_mprj_io_7 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_8 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_9 =  GPIO_MODE_USER_STD_INPUT_NOPULL;

		reg_mprj_io_25 =  GPIO_MODE_USER_STD_OUTPUT; // 1
		reg_mprj_io_26 =  GPIO_MODE_USER_STD_OUTPUT; // 2
		reg_mprj_io_27 =  GPIO_MODE_USER_STD_OUTPUT; // 3
		reg_mprj_io_28 =  GPIO_MODE_USER_STD_OUTPUT; // 4
		reg_mprj_io_29 =  GPIO_MODE_USER_STD_OUTPUT; // 5
		reg_mprj_io_30 =  GPIO_MODE_USER_STD_OUTPUT; // 6
		reg_mprj_io_31 =  GPIO_MODE_USER_STD_OUTPUT; // 7
		reg_mprj_io_32 =  GPIO_MODE_USER_STD_OUTPUT; // 8

	reg_wb_enable=1;
	/* Apply configuration */
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);
	
    // Wait for all 3 buttons to get pressed
    while (reg_wb_buttons != 7);

    // Then set all the leds, signalling the end of the test
    reg_wb_leds = 0xFF;

	//while(1){
	//while(delay){espera << }
	// enviar =>
	// datos = recibir
	// print(datos);
	// } 
}

