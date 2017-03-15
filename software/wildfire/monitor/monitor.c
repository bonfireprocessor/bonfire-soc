#include "bonfire.h"

#include "uart.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

#include "encoding.h"
#include "monitor.h"
#include "mempattern.h"
#include "console.h"
#include "xmodem.h"
#include "syscall.h"

#include "spi_driver.h"



extern uint8_t *gpioadr;



#define LOAD_SIZE  (DRAM_SIZE-(long)LOAD_BASE)
#define HEADER_BASE ((void*)(LOAD_BASE-4096)) // Place Flash Header 4KB below LOAD_BASE

typedef struct {
  uint32_t magic;
  uint32_t nPages;
  uint32_t brkAddress;

} t_flash_header;

#define  FLASH_HEADER ((t_flash_header*)HEADER_BASE)

#define C_MAGIC 0x55aaddbb

#define BAUDRATE 500000L

// Offset of mtime for 1ms 
#define TIME_OFFS (SYSCLK / 1000 ) 

int uptime = 0; // Uptime in ms
volatile uint32_t *pmtime = (uint32_t*)MTIME_BASE;


// XModem and spi Flash Variables

int nPages=0;
long recv_bytes=0;




static void handle_syscall(trapframe_t* tf)
{
  tf->gpr[10] = do_syscall(tf->gpr[10], tf->gpr[11], tf->gpr[12], tf->gpr[13],
                           tf->gpr[14], tf->gpr[15], tf->gpr[17]);
  tf->epc += 4;
}


trapframe_t* trap_handler(trapframe_t *ptf)
{
char c;


    //*gpioadr = (ptf->cause & 0x0f); // Show trap cause on LEDs

    if (ptf->cause==11 || ptf->cause==8) // ecall
        handle_syscall(ptf);
    else {

        printk("\nTrap cause: %lx\n",ptf->cause);
        dump_tf(ptf);
        c=readchar();
        if (c=='r' || c=='R')
          ptf->epc=SRAM_BASE; // will cause reset
        else
          if (((long)ptf->cause)>0) ptf->epc+=4;
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


  printk("\nBonfire Boot Monitor 0.2b\n");
  printk("MIMPID: %lx\nMISA: %lx\nUART Divisor: %d\nUART Revision %x\n",
         read_csr(mimpid),read_csr(misa),
         getDivisor(),getUartRevision());
}

void error(int n)
{
  printk("Error %d\n",n);
}




void writeBootImage(spiflash_t *spi)
{


uint32_t nFlashBytes;
uint32_t flashAddress;
int err;
   if (!nPages)
     printk("First load Image !");
   else {
     flashAddress=FLASH_IMAGEBASE;
     nFlashBytes = nPages << 12;
     if ((nFlashBytes+4096) >MAX_FLASH_IMAGESIZE) {
       printk("Image size %d > %d, abort\n",nFlashBytes+4096,MAX_FLASH_IMAGESIZE);
       return;
     }
     printk("Saving Image to Flash Address %x (%d bytes) \n",flashAddress,nFlashBytes);
     memset(HEADER_BASE,0,4096);
     FLASH_HEADER->magic=C_MAGIC;
     FLASH_HEADER->nPages=nPages;
     FLASH_HEADER->brkAddress=brk_address;
     err=flash_Overwrite(spi,FLASH_IMAGEBASE,4096,HEADER_BASE);
     if (err!=SPIFLASH_OK) return;
     flashAddress=FLASH_IMAGEBASE+4096;


     err=flash_Overwrite(spi,flashAddress,nFlashBytes,LOAD_BASE);

   }

}


int readBootImage(spiflash_t *spi)
{
int err;

  printk("Reading Header\n");
  err=SPIFLASH_read(spi,FLASH_IMAGEBASE,4096,HEADER_BASE);
  if (flash_print_spiresult(err)!=SPIFLASH_OK) return err;
  // Check Header
  if (FLASH_HEADER->magic == C_MAGIC) {
    uint32_t nFlashBytes = FLASH_HEADER->nPages << 12;
    printk("Boot Image found, length %d Bytes, Break Address: %x\n",nFlashBytes,FLASH_HEADER->brkAddress);
    err=SPIFLASH_read(spi,FLASH_IMAGEBASE+4096,nFlashBytes,LOAD_BASE);
    if (flash_print_spiresult(err)!=SPIFLASH_OK) return err;
    nPages=FLASH_HEADER->nPages;
    brk_address= FLASH_HEADER->brkAddress;
    return SPIFLASH_OK;

  } else {

    printk("Invalid Boot Image header\n");
    return -1;
  }
}


int main()
{

char cmd[64];
char *p;
char xcmd;
uint32_t *dumpaddress=LOAD_BASE;



void (*pfunc)();

uint32_t args[3];
int nArgs;


spiflash_t *spi;

uint32_t nFlashbytes;
uint32_t flashAddress;
int err;

   setBaudRate(BAUDRATE);
  
   printInfo();
   spi=flash_init();

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
         if (recv_bytes % 4096) nPages+=1; // Round up..
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
         clear_csr(mstatus,MSTATUS_MIE);
         start_user((uint32_t)pfunc,DRAM_TOP & 0x0fffffffc );
         break;

       case 'F': // flash read
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

       case 'R': // Load Boot Image from Flash and run
         if (readBootImage(spi)==SPIFLASH_OK) {
            clear_csr(mstatus,MSTATUS_MIE); 
            start_user((uint32_t)LOAD_BASE,DRAM_TOP & 0x0fffffffc );
         }     
         break;

       case 'W': // flash write
         writeBootImage(spi);

       default:
         writechar('\a'); // beep...
      }

   }
}
