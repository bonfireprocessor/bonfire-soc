#include <stdint.h>

#include "platform.h"

// GPIO Test Program intented for use with the simulator

volatile uint8_t *gpioadr=(uint8_t *)GPIO_BASE;

int main(int argc,char ** argv) {

volatile int counter =1;

    while(1) {
	
        *gpioadr= counter++ & 0x0f;
   }

};
