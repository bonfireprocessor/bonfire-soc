#include "wildfire.h"


volatile uint32_t *pmem = (void*)DRAM_BASE;

int main()
{


int I;
void (*pfunc)() = (void*)DRAM_BASE;

   for(I=0;I<8;I++) {
        pmem[I] = (uint32_t) (I << 20) |  0x013;  // various RISCV NOP instructions 
   }     
   pmem[8] =  0x0440006f; // Jump instruction
   for(I=9;I<9+16;I++) {
        pmem[I] =  0x013;  
   } 
   pmem[9+16] =  0x000008067; // RET instruction
   
   while(1) {
    pfunc(); 
   }
   
  



}
