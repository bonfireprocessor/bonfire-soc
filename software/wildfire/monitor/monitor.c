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
#include "syscall.h"

#include "spi_driver.h"



extern uint8_t *gpioadr;



#define LOAD_SIZE  (DRAM_SIZE-(long)LOAD_BASE)
#define BAUDRATE 500000L

#define FLASHSIZE (8192*1024)


static void handle_syscall(trapframe_t* tf)
{
  tf->gpr[10] = do_syscall(tf->gpr[10], tf->gpr[11], tf->gpr[12], tf->gpr[13],
                           tf->gpr[14], tf->gpr[15], tf->gpr[17]);
  tf->epc += 4;
}


trapframe_t* trap_handler(trapframe_t *ptf)
{
char c;


    *gpioadr = (ptf->cause & 0x0f); // Show trap cause on LEDs
    
    if (ptf->cause==11 || ptf->cause==8) // ecall
        handle_syscall(ptf);
    else {

        printk("\nTrap cause: %lx\n",ptf->cause);
        dump_tf(ptf);
        c=readchar();
        if (c=='r' || c=='R')
          ptf->epc=SRAM_BASE; // will cause reset
        else      
          ptf->epc+=4;
    }  
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


  printk("\nBonfire Boot Monitor 0.1l\n");
  printk("MIMPID: %lx\nMISA: %lx\nUART Divisor: %d\nUART Revision %x\n",
         read_csr(mimpid),read_csr(misa),
         getDivisor(),getUartRevision());
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
spiflash_t *spi=NULL;

int nPages=0;
uint32_t nFlashbytes;
uint32_t flashAddress;
int err;




   setBaudRate(BAUDRATE);
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
         nPages= recv_bytes >> 12; // Number of 4096 Byte pages
         if (nPages % 4096) nPages+=1; // Round up..         
         brk_address= ((uint32_t)LOAD_BASE + recv_bytes + 4096) & 0x0fffffffc;
         break;
       case 'E':
         if (recv_bytes>=0)
           printk("\n%ld Bytes received\n%d(%x) Pages\nBreak Address %x\n",recv_bytes,nPages,nPages,brk_address);
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
             
         start_user((uint32_t)pfunc,DRAM_TOP & 0x0fffffffc );
         break;
       case 'F':
         spiflash_test();
         break;  
       case 'R': // flash read
         if (!spi) spi=flash_init();
        
         // Usage ftarget_adr,flash_page(4K),len (pages)
         switch(nArgs) {
           case 0: // No Arugments default...
             args[0]=(uint32_t)LOAD_BASE;
             // fall through
           case 1:  // Only Load Base specified
             args[1]=0x80; // Start at 512KB in Flash
             // fall through    
           case 2:   
             args[2]=0x80; // Load 512KB
           
         }
        
         nPages=args[2];
         flashAddress=args[1] << 12;
         nFlashbytes=args[2] << 12;
         if (flashAddress>=FLASHSIZE || (flashAddress+nFlashbytes) >=FLASHSIZE  || nFlashbytes==0) {
            printk("Invalid args");
            continue;
          }   
       
         printk("Flash read to %x from Page %p (%d Bytes)...\n",args[0],args[1],nFlashbytes); 
         err=SPIFLASH_read(spi,flashAddress,nFlashbytes,(uint8_t*)args[0]);
         if (err!=0) 
            error(err);
         else
           printk("OK");   
         break; 
        
       default:
         writechar('\a'); // beep...
      }

   }
}
