#include "wildfire.h"

#include "mempattern.h"

int main()
{
   while(1) {
    
     writepattern(DRAM_BASE,8);
     writepattern((void*)DRAM_BASE+512,8); // force bank switch
     verifypattern(DRAM_BASE,8);  
     verifypattern((void*)DRAM_BASE+512,8);   // force bank switch
    
   } 
    
}
