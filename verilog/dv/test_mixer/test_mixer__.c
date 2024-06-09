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

//#define reg_wb_start_tb      (*(volatile uint32_t*)0x30000000)
#define reg_set_value    (*(volatile uint32_t*)0x30000000)
#define reg_get_value    (*(volatile uint32_t*)0x30000004)

void UART_enableRX(bool is_enable);
void UART_enableTX(bool is_enable);
void UART_sendInt(int data);
void UART_sendChar(char c);

void delay(volatile uint32_t time) {
    while (time > 0) time--;
}

void main()
{
	//int j=0;
	uint32_t value;
	int time;
	//uint32_t *p = (uint32_t *) &reg_get_value; 
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
	//reg_mprj_io_4 =  GPIO_MODE_MGMT_STD_OUTPUT;
	
	reg_mprj_io_35 =  GPIO_MODE_USER_STD_OUTPUT; // 8
	//reg_mprj_io_34 =  GPIO_MODE_USER_STD_OUTPUT; // 8
	//reg_mprj_io_33 =  GPIO_MODE_USER_STD_OUTPUT; // 8

	// reg_mprj_io_7 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// reg_mprj_io_8 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	// reg_mprj_io_9 =  GPIO_MODE_USER_STD_INPUT_NOPULL;
	
	
	// reg_mprj_io_25 =  GPIO_MODE_USER_STD_OUTPUT; // 1
	// reg_mprj_io_26 =  GPIO_MODE_USER_STD_OUTPUT; // 2
	// reg_mprj_io_27 =  GPIO_MODE_USER_STD_OUTPUT; // 3
	// reg_mprj_io_28 =  GPIO_MODE_USER_STD_OUTPUT; // 4
	// reg_mprj_io_29 =  GPIO_MODE_USER_STD_OUTPUT; // 5
	// reg_mprj_io_30 =  GPIO_MODE_USER_STD_OUTPUT; // 6
	// reg_mprj_io_31 =  GPIO_MODE_USER_STD_OUTPUT; // 7
	// reg_mprj_io_32 =  GPIO_MODE_USER_STD_OUTPUT; // 8

	reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;
	// Set UART clock to 64 kbaud (enable before I/O configuration)
	// reg_uart_clkdiv = 625;
	UART_enableTX(1);
	
	reg_wb_enable=1;
	
	reg_mprj_xfer = 1;

	/* Apply configuration */
	while (reg_mprj_xfer == 1);


	time = 150; // 1000 
	reg_get_value = 0;
	
	while(1)
	{
		reg_set_value = 0x07; // value of init
		
		delay(time);

		reg_set_value = 0x08; 

		while(reg_get_value > 0 ){
			value = reg_get_value;
			UART_sendInt(value);
			delay(160);
			reg_get_value = 0;
			break;
		};
	}
}


void UART_enableRX(bool is_enable){
    if (is_enable){
        reg_uart_enable = 1;
    }else{
        reg_uart_enable = 0;

    }
}

void UART_enableTX(bool is_enable){
    if (is_enable){
        reg_uart_enable = 1;
    }else{
        reg_uart_enable = 0;
    }
} 

/**
 * Send ASCII char through UART
 * @param c ASCII char to send
 * 
 * TX mode have to be enabled
 */

void UART_sendChar(char c){
    while (reg_uart_txfull == 1);
	reg_uart_data = c;
}
/**
 * Send int through UART 
 * the int would be sent as 8 hex characters
 * @param c int to send
 * 
 * TX mode have to be enabled
 */
void UART_sendInt(int data){
 for (int i = 0; i < 8; i++) {
        // Extract the current 4-bit chunk
        int chunk = (data >> (i * 4)); 
        if (chunk == 0) {
            break;
        }
        chunk = chunk & 0x0F;
        char ch; 
        if (chunk >= 0 && chunk <= 9) {
            ch = '0' + chunk;  // Convert to corresponding decimal digit character
        } else {
            ch = 'A' + (chunk - 10);  // Convert to corresponding hex character A-F
        }
        UART_sendChar(ch);
    }
    UART_sendChar('\n');
}
