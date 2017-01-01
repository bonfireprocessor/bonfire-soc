#include "bonfire.h"

#include "uart.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "encoding.h"
#include "monitor.h"
#include "mempattern.h"
#include "console.h"




trapframe_t* trap_handler(trapframe_t *ptf)
{

    printk("\nTrap cause: %lx\n",ptf->cause);
    dump_tf(ptf);
    ptf->epc+=4; 
    return ptf;
}






int main()
{
char cmd;
char buff[8];
uint32_t dumpaddress=DRAM_BASE;
uint32_t arg1;
    
   setBaudRate(115200);
  
   printk("\nBonfire Boot Monitor 0.1b\n");
 
   printk("Processor ID: %lx \nUART Divisor: %d\n",get_impid(),getDivisor());
   printk("Testing %d Kilobytes of DRAM...\n",DRAM_SIZE/1024);
   writepattern((void*)DRAM_BASE,DRAM_SIZE/4);
   printk("Verifying...\n");
   printk("Found %d errors\n",verifypattern((void*)DRAM_BASE,DRAM_SIZE/4));
   
   
   
   
   // Test trap Handler
   //do_break((uint32_t)buff,1,2,3);
   //writestr("\r\nReturn from break");
   //do_break(sizeof(trapframe_t),5,6);
   
   while(1) {
     write_console("\n>");  
     cmd=toupper(readchar());
     writechar(cmd); 
     switch(cmd) {
       case 'D': // Dump command
        
         buff[0]='\0';
         printk("\nEnter address(%lx):  ",dumpaddress);read_hex_str(buff,sizeof(buff));
         if (strlen(buff) && (arg1=strtol(buff,NULL,16))) {
           dumpaddress=arg1 & 0x0fffffffc; // mask lower two bits to avoid misalignment
         }  
         hex_dump((void*)dumpaddress,64);
         dumpaddress+=64;  
         break;
       default:
         writechar('\a'); // beep...  
      }     
       
   }; 
    
    
}
