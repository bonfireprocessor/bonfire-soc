#include "uart.h"


char *Welcome = "Hello World \r\n";


int main() {
uint32_t counter=0;   

    setDivisor(16);
    
    writestr(Welcome);
    while(1) {
	  writeHex(counter++); 
	  writestr("\r\n");		  
	}	
};

	
