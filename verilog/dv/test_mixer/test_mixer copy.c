
#include <defs.h>
#include <stub.c>
#define reg_set_value    (*(volatile uint32_t*)0x30000000)
#define reg_get_value    (*(volatile uint32_t*)0x30000004)

void UART_enableRX(bool is_enable);
void UART_enableTX(bool is_enable);
void UART_sendChar(char c);
void UART_sendInt(int data);
void delay(volatile uint32_t time);

void main()
{
	uint32_t value;
	int time;
	reg_spimaster_control = SPI_MASTER_ENABLE | (2 & SPI_MASTER_DIV_MASK);
	reg_spimaster_control |= SPI_HOUSEKEEPING_CONN;
	reg_mprj_io_35 =  GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;
	UART_enableTX(1);
	reg_wb_enable=1;
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);
	time = 50; // 1000 
	reg_get_value = 0;
	
	while(1)
	{
		reg_set_value = 0x07;
		
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

void delay(volatile uint32_t time) {
    while (time > 0) time--;
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

void UART_sendChar(char c){
    while (reg_uart_txfull == 1);
	reg_uart_data = c;
}

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
            ch = '0' + chunk;
        } else {
            ch = 'A' + (chunk - 10);
        }
        UART_sendChar(ch);
    }
    UART_sendChar('\n');
}
