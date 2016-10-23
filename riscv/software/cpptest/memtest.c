#include "uart.h"

char *pRAM = (char*)0x30000000; // Memory address

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
uint32_t *memptr=0;
char c;

   setDivisor(16);
   writestr("Memory dump program 1.0\r\n");
   while(1) {

     HexDump(memptr,64);
     writestr("\r\npress r to restart with address 0, any other key to continue\r\n");
     c=readchar();
     if ( (c=='r') || (c=='R'))
       memptr=0;
     else
       memptr+=64;
   }
}
