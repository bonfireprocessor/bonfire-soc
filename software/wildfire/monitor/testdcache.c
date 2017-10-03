#include "bonfire.h"

#include "mempattern.h"
#include "console.h"
#include <string.h>


#define CACHE_WORDS 1024
#define CACHE_BYTELANES 4  // Width of Cache Word in Bytes
#define LINE_SIZE 8 // Width of Cache Line Size in Cache Words
#define CACHE_SIZE (CACHE_WORDS*CACHE_BYTELANES) // Cache Size in Bytes !!
#define CACHE_LINES (CACHE_WORDS/LINE_SIZE)

#define LINE_SIZE_BYTES (LINE_SIZE*CACHE_BYTELANES)


static void _writeinfo(void* adr,uint32_t length,int mode, int errors)
{
    
   printk("%s %lx..%lx (%d )bytes, %d errors\n",mode==1?"write":"verify",adr,adr+length,length,errors );
}    


static inline void dc_writepattern(void *mem,int len) {
   _writeinfo(mem,len,1,0);
   writepattern(mem,len);   
}  

static inline int dc_verifypattern(void *mem,int len) {
   int errors=verifypattern(mem,len);    
   _writeinfo(mem,len,2,errors);
   return errors;
}  

void test_dcache(int n)
{
int errors;
    
   
	  
     //dc_writepattern(DRAM_BASE,LINE_SIZE_BYTES/4);
      
     //dc_writepattern((void*)DRAM_BASE+LINE_SIZE_BYTES,LINE_SIZE_BYTES/4); // force line switch
      
     //errors=dc_verifypattern(DRAM_BASE,LINE_SIZE_BYTES/4);  
     
     //errors+=dc_verifypattern((void*)DRAM_BASE+LINE_SIZE_BYTES,LINE_SIZE_BYTES/4);   // force line switch
     //// Force Cache wrap - and therefore writeback
     //dc_writepattern((void*)DRAM_BASE+CACHE_SIZE,LINE_SIZE_BYTES/4);
      
     //errors+=dc_verifypattern((void*)DRAM_BASE,LINE_SIZE_BYTES/4); // Force another writeback
     
     //errors+=dc_verifypattern((void*)DRAM_BASE+CACHE_SIZE,LINE_SIZE_BYTES/4); 
     
     //memset(DRAM_BASE,0,n);
     //dc_writepattern(DRAM_BASE,n);
     //errors+=dc_verifypattern(DRAM_BASE,n);
     
     printk("Cache size: %d bytes\nLine size: %d bytes\nCache lines: %d\n ",CACHE_SIZE,LINE_SIZE_BYTES,CACHE_LINES);
     
     uint32_t base;
     
     for(base=0;base<CACHE_SIZE;base+=LINE_SIZE_BYTES) {
       printk("\n Test with offset: %lx \n",base);  
       dc_writepattern((void*)base,LINE_SIZE_BYTES/4);
       dc_writepattern((void*)base+CACHE_SIZE,LINE_SIZE_BYTES/4);
       errors=dc_verifypattern((void*)base,LINE_SIZE_BYTES/4);
       if (errors) break;
     }   
     
     //dc_writepattern((void*)0x800,LINE_SIZE_BYTES/4);
     //dc_writepattern((void*)0x4800,LINE_SIZE_BYTES/4);
     //errors+=dc_verifypattern(0x800,LINE_SIZE_BYTES/4);
     
    
     
     printk("Total errors %d\n",errors);
    
    
}
