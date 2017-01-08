/*-
 * Copyright (c) 2006 M. Warner Losh.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * This software is derived from software provide by Kwikbyte who specifically
 * disclaimed copyright on the code.  This version of xmodem has been nearly
 * completely rewritten, but the CRC is from the original.
 *
 * $FreeBSD: src/sys/boot/arm/at91/libat91/xmodem.c,v 1.1 2006/04/19 17:16:49 imp Exp $
 */

// Modified by BogdanM for eLua
// Modified by TH for Bonfire Boot loader

#include <string.h>
#include <stdlib.h>
#include "xmodem.h"

#include "uart.h"
#include "console.h"

#define PXM_ACKET_SIZE    128
static p_xm_send_func xmodem_out_func;
static p_xm_recv_func xmodem_in_func;

// Line control codes
#define XM_SOH  0x01
#define XM_ACK  0x06
#define XM_NAK  0x15
#define XM_CAN  0x18
#define XM_EOT  0x04

// Arguments to xmodem_flush
#define XMODEM_FLUSH_ONLY       0
#define XMODEM_FLUSH_AND_XM_CAN    1

// Delay in "flush packet" mode
//#define XMODEM_PXM_ACKET_DELAY     10000UL
#define XMODEM_PXM_ACKET_DELAY     1L

void xmodem_init( p_xm_send_func send_func, p_xm_recv_func recv_func )
{
  xmodem_out_func = send_func;
  xmodem_in_func = recv_func;
}

// Utility function: flush the receive buffer
static void xmodem_flush( int how )
{
  while( xmodem_in_func( XMODEM_PXM_ACKET_DELAY ) != -1 );
  if( how == XMODEM_FLUSH_AND_XM_CAN )
  {
    xmodem_out_func( XM_CAN );
    xmodem_out_func( XM_CAN );
    xmodem_out_func( XM_CAN );
  }
}

static int rec_error, last_crc;

// This private function receives a x-modem record to the pointer and
// returns 1 on success and 0 on error
// mode 1: CRC
// mode 0: Checksum 
static int xmodem_get_record( unsigned char blocknum, unsigned char *pbuf,int mode )
{
  unsigned chk, j, size;
  int ch;
  int packlen= mode?PXM_ACKET_SIZE + 4:PXM_ACKET_SIZE + 3;
  
  // Read packet
  rec_error=0;
  for( j = 0; j < packlen; j ++ )
  {
    if( ( ch = xmodem_in_func( /*XMODEM_TIMEOUT*/ -1 ) ) == -1 ) {
      rec_error=1; goto err;
    }  
   
    pbuf[ j ] = ( unsigned char )ch;
  }

  // Check block number
  if( pbuf[0] != blocknum )
   { rec_error=2; goto err; }
  if( pbuf[1] != ( unsigned char )~blocknum )
  { rec_error=3;  goto err; }
  // Check CRC
  if (mode) {
      for( size = chk = 0; size < PXM_ACKET_SIZE; size++) 
      {
        chk = chk ^ pbuf[size+2] << 8;
        for( j = 0; j < 8; j ++ ) 
        {
          if( chk & 0x8000 )
            chk = chk << 1 ^ 0x1021;
          else
            chk = chk << 1;
        }
      }
      chk &= 0xFFFF;
      last_crc=chk;
      
      if ( ((pbuf[PXM_ACKET_SIZE+2]<<8) | pbuf[PXM_ACKET_SIZE+3]) !=chk)
      { 
        rec_error=4;  goto err;
      }
  } else { // checksum
      
      uint8_t chksum=0;
      
      for( size = 0; size < PXM_ACKET_SIZE; size++) 
      {
        chksum=( chksum+pbuf[size+2]) & 0x0ff;
      }
      last_crc=chksum;
      if (pbuf[PXM_ACKET_SIZE+2]!=chksum) {
         rec_error=5; goto err;   
      }
      
  }    
  return 1;
  
err:
  
  return 0;
}





static char nack_block[PXM_ACKET_SIZE + 4];

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


void xmmodem_errrorDump()
{
int i;
char c;

  printk("\nerror: %d, last CRC %x \nHeader:\n",rec_error,last_crc);
  dumpByte(nack_block[0]);dumpByte(nack_block[1]);printk("\n");
  for(i=0;i<128;i++) {
     printk(!(i % 8)?"\n %d =>  ":" ",i);
     dumpByte(nack_block[i+2]);      
  } 
   for(i=0;i<128;i++) {
      if (!(i % 8) ) printk("\n %d =>  ",i);
     c=nack_block[i+2];
     writechar(c>=32?c:'.');      
  }        
  //printk("\n packet CRC %x\n",(nack_block[PXM_ACKET_SIZE+2]<<8) | nack_block[PXM_ACKET_SIZE+3]);  
  printk("\n packet checksum %x\n",nack_block[PXM_ACKET_SIZE+2]);
}




// This global function receives a x-modem transmission consisting of
// (potentially) several blocks.  Returns the number of bytes received or
// an error code 
// dest: Pointer to memory buffer 
// maxsize: Length of memory buffer

long xmodem_receive( char *dest,long maxsize)
{
  int starting = 1, ch;
  unsigned char packnum = 1, buf[ PXM_ACKET_SIZE + 4 ];
  unsigned retries = XMODEM_RETRY_LIMIT;
 // u32 limit = XMODEM_INITIAL_BUFFER_SIZE, 
  long size = 0;
  long timeout=XMODEM_TIMEOUT;
 
  
  while( retries-- ) 
  {
    if( starting )
      //xmodem_out_func( 'C' );
      xmodem_out_func(XM_NAK);
    if( ( ( ch = xmodem_in_func(timeout) ) == -1 ) || ( ch != XM_SOH && ch != XM_EOT && ch != XM_CAN ) )
      continue;
    if( ch == XM_EOT ) 
    {
      // End of transmission
      xmodem_out_func( XM_ACK );
      xmodem_flush( XMODEM_FLUSH_ONLY );
      return size;
    }
    else if( ch == XM_CAN )
    {
      // The remote part ended the transmission
      xmodem_out_func( XM_ACK );
      xmodem_flush( XMODEM_FLUSH_ONLY );
      return XMODEM_ERROR_REMOTECANCEL;      
    }
    starting = 0;
    
    
    // Get XMODEM packet
    if( !xmodem_get_record( packnum, buf,0 ) ) { // Checksum mode
      //xmodem_flush( XMODEM_FLUSH_ONLY ); 
      // NACK Debug code
      memcpy(nack_block,buf,sizeof(buf)); // Copy error packet
      xmodem_out_func( XM_NAK );
      xmodem_flush( XMODEM_FLUSH_AND_XM_CAN );
      return -5;    
      continue; // allow for retransmission
    }    

   
    retries = XMODEM_RETRY_LIMIT;
    packnum ++;
      
    // Got a valid packet
    if( size + PXM_ACKET_SIZE > maxsize )
    {      
        // Not enough memory, force cancel and return
        xmodem_flush( XMODEM_FLUSH_AND_XM_CAN );
        return XMODEM_ERROR_OUTOFMEM;      
    }    
    // Acknowledge and consume packet
    memcpy(dest + size, buf + 2, PXM_ACKET_SIZE );
   // xmodem_flush( XMODEM_FLUSH_ONLY );
    xmodem_out_func( XM_ACK );
    size += PXM_ACKET_SIZE;
  }
  
  // Exceeded retry count
  xmodem_flush( XMODEM_FLUSH_AND_XM_CAN );
  return XMODEM_ERROR_RETRYEXCEED;
}



