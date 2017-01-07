#include <stdint.h>



#include "monitor.h"
#include "uart.h"
#include "xmodem.h"
#include "console.h"



// This global function receives a x-modem transmission consisting of
// (potentially) several blocks.  Returns the number of bytes received or
// an error code 
// dest: Pointer to memory buffer 
// maxsize: Length of memory buffer

#define XM_PACKSIZE 128

// Line control codes
#define XM_SOH  0x01
#define XM_ACK  0x06
#define XM_NAK  0x15
#define XM_CAN  0x18
#define XM_EOT  0x04


extern uint8_t *gpioadr;

uint8_t h1,h2,chksum,recv_chksum;
enum txm_state {s_idle,s_h1,s_h2,s_pack,s_chk,s_recover } xm_state;



inline char hex_nibble(u8 nibble)
{
   nibble=nibble & 0x0f; 
   return (nibble<=9)?(char)(nibble + '0'):(char)(nibble-10+'A');   
}    

void dumpByte(u8 v)
{
     writechar(hex_nibble(v>>4));
     writechar(hex_nibble(v));
}


char* nack_block; 


void xmmodem_errrorDump()
{ 
int i;
char c;
       
  printk("H1: %x H2: %x ~H2: %x chksum: %x recv chksum: %x state: %d\n",h1,h2,~h2 & 0x0ff,chksum,recv_chksum,xm_state);    
  
  for(i=0;i<128;i++) {
     printk(!(i % 8)?"\n %d =>  ":" ",i);
     dumpByte(nack_block[i+2]);      
  } 
   for(i=0;i<128;i++) {
     if (!(i % 8) ) printk("\n %d =>  ",i);
     c=nack_block[i+2];
     writechar(c>=32?c:'.');      
  }  
        
}


long xmodem_receive( char *dest,long maxsize)
{
    
//enum txm_state {s_idle,s_h1,s_h2,s_pack,s_chk,s_recover } xm_state;

long recv;
int retry=XMODEM_RETRY_LIMIT;
long nBytes=0;
//uint8_t h1,chksum;
int indx=0;


   nack_block=dest;
   do {
     writechar(XM_NAK);
     recv=wait_receive(XMODEM_TIMEOUT);
     *gpioadr=(uint8_t)retry;
        
   }while(recv<0 && retry--);
    *gpioadr=0;
    xm_state=s_idle;
    h1=h2=chksum=0;
  
    do {
      *gpioadr=(uint8_t)xm_state;
      switch(xm_state) {
          
         case s_idle:
         case s_recover:
           switch(recv) {
             case XM_EOT:
               writechar(XM_ACK);
               return nBytes;
               break;
             case XM_CAN:
               writechar(XM_ACK);  
               return XMODEM_ERROR_REMOTECANCEL;
               break;   
             case XM_SOH:
               xm_state=s_h1;
               break;  
             //default:
           }    
           break;
         case s_h1:
           h1=(uint8_t)recv;  
           xm_state=s_h2;
           break;
         case s_h2:
           indx=0;
           chksum=0;
           h2=(uint8_t)recv;
           if (h1 == (~h2 & 0x0ff) ) {
             xm_state=s_pack;        
           } else {
            // Abort immedatly on error for debugging purposes
            writechar(XM_CAN);   
            //xm_state=s_recover;
            return XMODEM_ERROR_HEADER;
               
           }
           break;
         case s_pack:
           dest[indx++]=(char)recv;
           chksum+=(uint8_t)recv;
           
           if (indx==XM_PACKSIZE) {
             xm_state=s_chk;   
           }
           break;
         case s_chk:
           recv_chksum=(uint8_t)recv;
           if (recv_chksum==chksum) {
              dest+=XM_PACKSIZE;
              nack_block=dest;
              nBytes+=XM_PACKSIZE;
              if (nBytes > maxsize) {
                writechar(XM_CAN);     
                return XMODEM_ERROR_OUTOFMEM;
              } else          
                writechar(XM_ACK);                 
           } else {      
             // Abort immedatly on error for debugging purposes   
             writechar(XM_CAN);   
             //xm_state=s_recover;      
             return XMODEM_ERROR_CRC;         
           }  
           xm_state=s_idle;                            
          
      }
      
      //recv=wait_receive(XMODEM_TIMEOUT);
      recv=readchar();
      if (recv<0) return XMODEM_ERROR_RETRYEXCEED;      
        
    }while(1);           

    
}
