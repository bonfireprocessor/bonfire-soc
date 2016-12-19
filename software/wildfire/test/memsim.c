#include "wildfire.h"

#include "mempattern.h"

int main()
{
   while(1) {
    
     writepattern(DRAM_BASE,8);
     verifypattern(DRAM_BASE,8);    
    
   } 
    
}
