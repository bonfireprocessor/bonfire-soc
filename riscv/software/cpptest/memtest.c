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
char *line =   "\r\n------------------------------------\r\n";
   	
   setDivisor(16);	
   while(1) {	
	
	 HexDump((void*)0,256); 
	 writestr(line); 
     HexDump(pRAM,256);
     writestr(line);  
   }	
}	
