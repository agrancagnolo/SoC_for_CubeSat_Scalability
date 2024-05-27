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

#include <defs.h>
#include <stub.c>

// --------------------------------------------------------
#define UART_EV_TX	0x1
#define UART_EV_RX	0x2

void UART_enableTX(bool is_enable);
void UART_enableRX(bool is_enable);
char UART_readChar();
void UART_popChar();
char* UART_readLine();
void UART_sendChar(char c);
void UART_sendInt(int data);
void putchar2(char c);
void print2(const char *p);

void main()
{

    int j;

    // Configure I/O:  High 16 bits of user area used for a 16-bit
    // word to write and be detected by the testbench verilog.
    // Only serial Tx line is used in this testbench.  It connects
    // to mprj_io[6].  Since all lines of the chip are input or
    // high impedence on startup, the I/O has to be configured
    // for output

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;

    // Set clock to 64 kbaud and enable the UART.  It is important to do this
    // before applying the configuration, or else the Tx line initializes as
    // zero, which indicates the start of a byte to the receiver.

//    reg_uart_clkdiv = 625;
    //reg_uart_enable = 1;
    UART_enableRX(1);
    // Now, apply the configuration
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // Start test
    reg_mprj_datal = 0xA0000000;
    //reg_mprj_datal = 0xb0000000;
    //reg_mprj_datal = 0xa0000000;

    //reg_uart_data = 0xab;

    // This should appear at the output, received by the testbench UART.
    // (Makes simulation time long.)
    // print("test msg\n");
    //print("Monitor: Test UART (RTL) passed\n");
    //print2("\n");
    //print2("C\n");
    UART_sendInt(2);
    UART_sendInt(1);
    //print2("\n");
    //UART_sendChar('C');
    //UART_sendChar('\n');
    // Allow transmission to complete before signalling that the program
    // has ended.
    for (j = 0; j < 5000; j++);
    reg_mprj_datal = 0xAE000000;//fin
    //reg_mprj_datal = 0xab000000;
}


void UART_enableTX(bool is_enable){
    if (is_enable){
        reg_uart_enable = 1;
    }else{
        reg_uart_enable = 0;
    }

} 
// UART 
/**
 * Enable or disable RX of UART
 * 
 *  
 * @param is_enable when 1(true) UART RX enable, 0 (false) UART RX disable
 * 
 * \note
 * Some caravel CPU enable and disable UART TX and RX together
 * 
 */
void UART_enableRX(bool is_enable){
    if (is_enable){
        reg_uart_enable = 1;
    }else{
        reg_uart_enable = 0;

    }
}
/**
 * Wait receiving ASCII symbol and return it. 
 * 
 * Return the first ASCII symbol of the UART received queue
 * 
 * RX mode have to be enabled
 * 
 */
char UART_readChar(){
    while (uart_rxempty_read() == 1);
    return reg_uart_data;
}
/**
 * Pop the first ASCII symbol of the UART received queue
 * 
 * UART_readChar() function would keeping reading the same symbol unless this function is called
 */
void UART_popChar(){
    uart_ev_pending_write(UART_EV_RX);
    return;
}

/**
 * read full line msg and return it
 * 
 */

char* UART_readLine(){
    char* received_array =0;
    char received_char;
    int count = 0;
    while ((received_char = UART_readChar()) != '\n'){
        received_array[count++] = received_char;
        UART_popChar();
    }
    received_array[count++] = received_char;
    UART_popChar();
    return received_array;
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


void putchar2(char c)
{
	if (c == '\n')
		putchar2('\r');
    while (reg_uart_txfull == 1);
	reg_uart_data = c;
}

void print2(const char *p)
{
	while (*p)
		putchar2(*(p++));
}