// "Borrowed" from RISC-V proxy kernel
// See LICENSE for license details.



#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include "uart.h"



static void vprintk(const char* s, va_list vl)
{
  static char out[256]; // make buffer so that it works also when low on stack space
  vsnprintf(out, sizeof(out), s, vl);
  write_console(out);
}

void printk(const char* s, ...)
{
  va_list vl;
  va_start(vl, s);
  vprintk(s, vl);

  va_end(vl);
}

