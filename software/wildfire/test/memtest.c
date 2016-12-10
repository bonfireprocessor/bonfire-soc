#include "wildfire.h"
#include "uart.h"

//char *pRAM = (char*)0x30000000; // Memory address

extern void* _rombase;

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
uint32_t *memptr= &_rombase;
char c;

   setDivisor(16);
   writestr("Memory dump program 1.0\r\nProcessor ID: ");
   writeHex(get_impid());
   writestr("\r\n");
   while(1) {

     HexDump(memptr,64);
     writestr("\r\npress r to restart with address 0, any other key to continue\r\n");
     c=readchar();
     if ( (c=='r') || (c=='R'))
       memptr= &_rombase;
     else
       memptr+=64;
   }
}
