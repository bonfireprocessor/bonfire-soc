#include "wildfire.h"
#include "uart.h"
#include <stdlib.h>

#include "mempattern.h"

//char *pRAM = (char*)0x30000000; // Memory address

extern uint32_t _rombase;

#define MEMSIZE 4096*4; // Mem Size in Bytes

char *Welcome = "Hello World \r\n";

void strcpy(char *t,char *s)
{
   while(*s) {
    *t++ = *s++;
  }
}


void HexDump(void *mem,int numWords)
{
uint32_t *pmem = mem;
int i;

    for(i=0;i<numWords;i++) {
      if ((i % 4)==0) { // Write Memory address for every four words
        writestr("\r\n");
        writeHex((uint32_t)&pmem[i]);
        writestr("    ");
      }
      writeHex(pmem[i]);writechar(' ');
    }
}

int main()
{
uint32_t *memptr=  DRAM_BASE;
char c;
const int blocksz = 64;
int errors;
char buff[32];

   //setDivisor(16);
   setBaudRate(115200);
   writestr("Memory test program 2.0\r\nProcessor ID: ");
   writeHex(get_impid());
   writestr("\r\nUART Divisor: ");
   itoa(getDivisor(),buff,10);
   writestr(buff);
   writestr("\r\n");
   
   
   while(1) {
       
     writepattern(memptr,blocksz);
     errors=verifypattern(memptr,blocksz);
     itoa(errors,buff,10);
     writestr("Number of errors: ");writestr(buff); writestr("\r\n");
      
     HexDump(memptr,64);
     writestr("\r\npress r to restart with address 0, any other key to continue\r\n");
     c=readchar();
     if ( (c=='r') || (c=='R'))
       memptr= DRAM_BASE;
     else
       memptr+=64;
   }
}
