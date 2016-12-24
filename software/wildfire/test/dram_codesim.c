#include "wildfire.h"


volatile uint32_t *pmem = DRAM_BASE;

int main()
{


int I;
void (*pfunc)() = DRAM_BASE;

   for(I=0;I<8;I++) {
        pmem[I] = (uint32_t) (I << 20) |  0x013;  // various RISCV NOP instructions 
   }     
   pmem[8] =  0x000008067; // RET instruction
   
   while(1) {
    pfunc(); 
   }
   
  



}
