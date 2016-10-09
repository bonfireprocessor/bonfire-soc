/* Test UART */
// sample_clk = (f_clk / (baudrate * 16)) - 1
// (32.000.000 / (115200*16))-1 = 16,36 ...
// UART Base: 0x20000000
//    |--------------------|--------------------------------------------|
//--! | Address            | Description                                |
//--! |--------------------|--------------------------------------------|
//--! | 0x00               | Transmit register (write-only)             |
//--! | 0x04               | Receive register (read-only)               |
//--! | 0x08               | Status register (read-only)                |
//--! | 0x0c               | Sample clock divisor register (read/write) |
//--! | 0x10               | Interrupt enable register (read/write)     |
//--! |--------------------|--------------------------------------------|

#include <stdint.h>

#define UART_BASE 0x20000000

#define UART_TX 0x0
#define UART_RECV 0x04
#define UART_STATUS 0x08
#define UART_DIVISOR 0x0c
#define UART_INTE 0x10


volatile uint8_t *uartadr=(uint8_t *)UART_BASE;

char *Welcome = "Hello World \r\n";


void writechar(char c)
{
  while ((uartadr[UART_STATUS] & 0x08)==0x08); // Wait for transmit buffer free
  uartadr[UART_TX]=(uint8_t)c; 
	
}	


void writestr(char *p)
{
  while (*p) {
	writechar(*p); 
	p++;  	
  }		
	
	
}	

void writeHex(uint32_t v)
{
int i;
uint8_t nibble;
char c;


   for(i=7;i>=0;i--) {
	 nibble = (v >> (i*4)) & 0x0f;
	 if (nibble<=9) 
	   c=(char)(nibble + '0');
	 else
	   c=(char)(nibble-10+'A');
	       
     writechar(c); 	   
   }
   writestr("\r\n");	   	
}	


int main() {
uint32_t counter=0;   

    uartadr[UART_DIVISOR]=16; // Set Baudrate divisor
    
    writestr(Welcome);
    while(1) {
	  writeHex(counter++); 	  
	}	
};

	
