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
// !  | 0x14               | Revision Code                              |
//--! |--------------------|--------------------------------------------|

//--! The status register contains the following bits:
//--! - Bit 0: receive buffer empty
//--! - Bit 1: transmit buffer empty
//--! - Bit 2: receive buffer full
//--! - Bit 3: transmit buffer full

#include <stdint.h>
#include <stdbool.h>


#include "platform.h"

#define UART_TX 0x0
#define UART_RECV 0x04
#define UART_STATUS 0x08
#define UART_DIVISOR 0x0c
#define UART_INTE 0x10
#define UART_REVISION 0x14

#define ENABLE_SEND_DELAY 0


volatile uint8_t *uartadr=(uint8_t *)UART_BASE;

volatile uint8_t *gpioadr=(uint8_t *)GPIO_BASE;


void wait(long nWait)
{
static volatile int c;

  c=0;
  while (c++ < nWait);
}



void writechar(char c)
{

#ifdef  ENABLE_SEND_DELAY
   wait(1000);     
#endif
  while (uartadr[UART_STATUS] & 0x08); // Wait while transmit buffer full
  uartadr[UART_TX]=(uint8_t)c;

}

char readchar()
{
  while (uartadr[UART_STATUS] & 0x01); // Wait while receive buffer empty
  return uartadr[UART_RECV];
}


int wait_receive(long timeout)
{
uint8_t status;
bool forever = timeout < 0;
    
  do {
    status=uartadr[UART_STATUS];
  //  *gpioadr = status & 0x0f; // show status on LEDs
    if ((status & 0x01)==0) { // receive buffer not empty?
   //    *gpioadr=0; // clear LEDs  
      return uartadr[UART_RECV];
    } else
      timeout--;  
      
  }while(forever ||  timeout>=0 );
  *gpioadr=0; // clear LEDs
  return -1;    

}



void writestr(char *p)
{
  while (*p) {
    writechar(*p);
    p++;
  }
}


// Like Writestr but expands \n to \n\r
void write_console(char *p)
{
   while (*p) {
    if (*p=='\n') writechar('\r');   
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
}




void _setDivisor(uint32_t divisor){
    
   uartadr[UART_DIVISOR]=divisor; // Set Baudrate divisor  
}

void setDivisor(uint32_t divisor)
{
    _setDivisor(divisor);   
    wait(1000000);
}

uint32_t getDivisor()
{
  return uartadr[UART_DIVISOR];    
}

void setBaudRate(int baudrate) {
// sample_clk = (f_clk / (baudrate * 16)) - 1
// (96.000.000 / (115200*16))-1 = 51,08    
    
   setDivisor(SYSCLK / (baudrate*16) -1); 
}

uint8_t getUartRevision()
{
   return uartadr[UART_REVISION];   
     
}
