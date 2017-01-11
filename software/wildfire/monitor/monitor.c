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
#include "xmodem.h"


extern uint8_t *gpioadr;

#define LOAD_SIZE  DRAM_SIZE-(long)LOAD_BASE


trapframe_t* trap_handler(trapframe_t *ptf)
{
char c;


    *gpioadr = (ptf->cause & 0x0f); // Show trap cause on LEDs

    printk("\nTrap cause: %lx\n",ptf->cause);
    dump_tf(ptf);
    c=readchar();
    if (c=='r' || c=='R')
      ptf->epc=SRAM_BASE; // will cause reset
    else      
      ptf->epc+=4;
      
    return ptf;
}


void xm_send(u8 c)
{
  writechar((char)c);
}


void test_dram()
{
   printk("\nTesting %d Kilobytes of DRAM...\n",DRAM_SIZE/1024);
   writepattern((void*)DRAM_BASE,DRAM_SIZE/4);
   printk("Verifying...\n");
   printk("Found %d errors\n",verifypattern((void*)DRAM_BASE,DRAM_SIZE/4));
}


void changeBaudRate()
{
char strbuff[7];
long newBaud;

   printk("\nEnter new baudrate: ");
   read_num_str(strbuff,sizeof(strbuff));
   if (strbuff[0]) {
     newBaud=atol(strbuff);
     if (newBaud>=300L && newBaud<=500000L) {
        printk("\nChangine baudratew now....\n");
        setBaudRate(newBaud);
     } else {
       printk("\nInvalid, enter 300-500000\n",newBaud);
     }
   }
}

void printInfo()
{

  printk("\nBonfire Boot Monitor 0.1g\n");
  printk("Processor ID: %lx \nUART Divisor: %d\nUART Revision %x\n",get_impid(),getDivisor(),getUartRevision());

}

void error(int n)
{
  printk("Error %d\n",n);    
}

int main()
{

char cmd[64];
char *p;
char xcmd;
uint32_t *dumpaddress=LOAD_BASE;

long recv_bytes=0;

void (*pfunc)();

uint32_t args[3];
int nArgs;


   setBaudRate(38400);
   printInfo();

   // Test trap Handler
   //do_break((uint32_t)buff,1,2,3);
   //writestr("\r\nReturn from break");
   //do_break(sizeof(trapframe_t),5,6);

   while(1) {
     restart:  
     write_console("\n>");
     if (readBuffer(cmd,sizeof(cmd))) {
        p=cmd;
        skipWhiteSpace(&p);
        if (*p!='\0' && isalpha(*p)) {
          xcmd=toupper(*p++);
          skipWhiteSpace(&p);    
        }  else {
          error(1);  
          continue;
        }
        nArgs=0;
        while(nArgs<3 && *p!='\0' ) {
          if (parseNext(p,&p,&args[nArgs])) {
            nArgs++;
            skipWhiteSpace(&p);
          } else {
            error(2);
            goto restart;
          }    
        };
     } else continue;           
         
     switch(xcmd) {
       case 'D': // Dump command

         if (nArgs>=1)
             dumpaddress=(uint32_t*) (args[0] & 0x0fffffffc); // mask lower two bits to avoid misalignment
         hex_dump((void*)dumpaddress,64);
         dumpaddress+=64;
         break;
       case 'X': // XModem receive command
         switch(nArgs) {
            case 0:
              args[0]=(uint32_t)LOAD_BASE;
              args[1]=LOAD_SIZE;
              break;
            case 1:
              if (args[0]>=DRAM_TOP) {
                 error(3);
                 continue;   
              }    
              args[1]=DRAM_SIZE-args[0];
              break;
            default:
              error(4);
              continue;       
         };    
       
         write_console("Wait for receive...\n");
         recv_bytes=xmodem_receive((char*)args[0],args[1]);
         break;
       case 'E':
         if (recv_bytes>=0)
           printk("\n%ld Bytes received\n",recv_bytes);
         else {
           printk("\nXmodem Error %ld occured\n",recv_bytes);
           //xmmodem_errrorDump();
         }
         break;
       case 'T':
         test_dram();
         break;
       case 'C':
      case 'B':
        changeBaudRate();
        break;
      case 'I':
        printInfo();
        break;
       case 'G':
         if (nArgs>=1) 
           pfunc=(void*)args[0];
         else
           pfunc=LOAD_BASE;
             
         pfunc();
         break;
        
       default:
         writechar('\a'); // beep...
      }

   }
}
