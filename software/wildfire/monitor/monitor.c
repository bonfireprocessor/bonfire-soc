#include "bonfire.h"

#include "uart.h"
#include <stdlib.h>
#include <stdio.h>
#include "encoding.h"
#include "monitor.h"




trapframe_t* trap_handler(trapframe_t *ptf)
{
char buff[128];


    snprintf(buff,sizeof(buff),
             "\r\nTrap cause: %lx\r\nTrap pc: %lx\r\nTrap opcode: %lx\r\n",
             ptf->cause,ptf->epc,*((uint32_t*)ptf->epc));

    writestr(buff);
    dump_tf(ptf);
    ptf->epc+=4; 
    return ptf;
}

int main()
{
char buff[128];
    
   setBaudRate(115200);
  
   writestr("\r\nBonfire Boot Monitor 0.1b\r\n");
 
   
   snprintf(buff,sizeof(buff),"Processor ID: %lx \r\n",get_impid());
   writestr(buff);
   
   writestr("\r\nUART Divisor: ");
   itoa(getDivisor(),buff,10);
   writestr(buff);
   writestr("\r\n");
   
   // Test trap Handler
   do_break((uint32_t)buff,1,2,3);
   writestr("\r\nReturn from break");
   do_break(sizeof(trapframe_t),5,6);
   
   while(1); 
    
    
}
