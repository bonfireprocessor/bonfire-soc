#include <stdint.h>

// Test program intented for work on real hardware

volatile uint8_t *gpioadr=(uint8_t *)0x10000000;

int main(int argc,char ** argv) {

volatile int counter =0;

    while(1) {
	
        *gpioadr= (counter++ >> 20) & 0x0f;
   }

};
