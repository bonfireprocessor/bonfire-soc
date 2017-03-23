#include "wildfire.h"
#include "uart.h"
#include <stdlib.h>

#include "mempattern.h"



extern uint32_t _rombase;

//#define MEMSIZE 4096*4; // Mem Size in Bytes

#define MEMSIZE 8192*1024 / 4 // 8 Megabytes 

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


void doTest()
{
int errors;
char buff[32];
   
   itoa(MEMSIZE,buff,10);
   writestr(buff);
   writestr("\r\nWriting test pattern...\r\n"); 
   writepattern(DRAM_BASE,MEMSIZE);
   writestr("Verifying test pattern...\r\n");
   errors=verifypattern(DRAM_BASE,MEMSIZE);
   itoa(errors,buff,10);
   writestr("Number of errors: ");writestr(buff); writestr("\r\n");
    
}

int main()
{
uint32_t *memptr=  DRAM_BASE;
char c;
const int blocksz = 64;
//int errors;
char buff[32];

   //setDivisor(16);
   setBaudRate(500000);
   writestr("Memory test program 3.0\r\nProcessor ID: ");
   writeHex(get_impid());
   writestr("\r\nUART Divisor: ");
   itoa(getDivisor(),buff,10);
   writestr(buff);
   writestr("\r\n");
   
   doTest();
   
   while(1) {
       
        
           
     HexDump(memptr,blocksz);
     writestr("\r\npress r to restart test, any other key to continue dump\r\n");
     c=readchar();
     if ( (c=='r') || (c=='R')) {
       doTest();  
       memptr= DRAM_BASE;
     } else
       memptr+=blocksz;
   }
}
