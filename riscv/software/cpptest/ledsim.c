#include <stdint.h>

// GPIO Test Program intented for use with the simulator

volatile uint8_t *gpioadr=(uint8_t *)0x10000000;

int main(int argc,char ** argv) {

volatile int counter =0;

    while(1) {
	
        *gpioadr= counter++ & 0x0f;
   }

};
