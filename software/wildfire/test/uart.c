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

#include "platform.h"

#define UART_TX 0x0
#define UART_RECV 0x04
#define UART_STATUS 0x08
#define UART_DIVISOR 0x0c
#define UART_INTE 0x10


volatile uint8_t *uartadr=(uint8_t *)UART_BASE;




void writechar(char c)
{
  while (uartadr[UART_STATUS] & 0x08); // Wait while transmit buffer full
  uartadr[UART_TX]=(uint8_t)c;

}

char readchar()
{
  while (uartadr[UART_STATUS] & 0x01); // Wait while receive buffer empty
  return uartadr[UART_RECV];
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
}


void wait()
{
static volatile int c;

  c=0;
  while (c++ < 1000000);
}

void setDivisor(uint32_t divisor)
{
    uartadr[UART_DIVISOR]=divisor; // Set Baudrate divisor
    wait();
}

