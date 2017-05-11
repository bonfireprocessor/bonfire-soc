#include <stdio.h>
#include "bonfire.h"
#include "uart.h"

volatile uint32_t *mtime=(void*)MTIME_BASE;



void main()
{


uint32_t itime=mtime[0];
double time=itime;

  printf("fptest");
  while(1) {
    
    printf( "%f %ld\n",time,itime);
    
    while ((mtime[0]-itime) < SYSCLK); // WAIT ONE SECOND
    itime=mtime[0];
    time=itime;
  }    
  



}
