#ifndef __UART_H

#define __UART_H

#include <stdint.h>

void writechar(char c);

char readchar();

void writestr(char *p);

void writeHex(uint32_t v);

void setDivisor(uint32_t divisor);
void _setDivisor(uint32_t divisor);
uint32_t getDivisor();

void setBaudRate(int baudrate);


#endif
