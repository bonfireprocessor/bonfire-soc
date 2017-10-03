#include "wildfire.h"

#include "mempattern.h"

#include "encoding.h"

#define CACHE_BYTELANES 4  // Width of Cache Word in Bytes
#define LINE_SIZE 8 // Width of Cache Line Size in Cache Words
#define CACHE_SIZE (1024*CACHE_BYTELANES) // Cache Size in Bytes !!

#define LINE_SIZE_BYTES (LINE_SIZE*CACHE_BYTELANES)


int main()
{
int errors;


   write_csr(mscratch,0x55aa55);
   while(1) {

     //writepattern(DRAM_BASE,8);
     //writepattern((void*)DRAM_BASE+512,8); // force bank switch
     //verifypattern((void*)DRAM_BASE,LINE_SIZE_BYTES/4);
     //verifypattern((void*)DRAM_BASE+512,8);   // force bank switch

     // Fore Cache Wrap
     //writepattern(DRAM_BASE+CACHE_SIZE,8);
     //verifypattern(DRAM_BASE,8);
     //verifypattern(DRAM_BASE+CACHE_SIZE,8);

     uint32_t base;

     for(base=0;base<CACHE_SIZE;base+=0x100) {
       write_csr(mscratch,base);
       writepattern((void*)base,LINE_SIZE_BYTES/4);
       writepattern((void*)base+CACHE_SIZE,LINE_SIZE_BYTES/4);
       errors=verifypattern((void*)base,LINE_SIZE_BYTES/4);
       write_csr(mscratch,errors);
     }

   }

}
