#include <stdio.h>
#include "bonfire.h"
#include <math.h>

volatile uint32_t *mtime=(void*)MTIME_BASE;

void l_ftoa(double n, char *res, int afterpoint);


void main()
{
char buff[256];

uint32_t itime=mtime[0];
double time=0.0;

  printf("fptest\n");
  while(1) {

    l_ftoa(time,buff,3);
    printf( "%s %8.2f \n %ld\n\n",buff,time,itime);
    time+=0.1;
    if (time>1.0) printf("!!\n");
    while ((mtime[0]-itime) < SYSCLK); // WAIT ONE SECOND
    itime=mtime[0];

  }




}
