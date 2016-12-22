#include "wildfire.h"


int main()
{

volatile uint32_t *pmem = DRAM_BASE;
int I;
void (*pfunc)() = DRAM_BASE;

   for(I=0;I<16;I++) {
        pmem[I] = 0x013; // RISCV NOP instruction 
   }     
   pmem[16] =  0x000008067; // RET instruction
   
   while(1) {
    pfunc(); 
   }
   
  



}
