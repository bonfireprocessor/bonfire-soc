// "Borrowed" from RISC-V proxy kernel
// See LICENSE for license details.



#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>
#include <ctype.h>
#include "uart.h"
#include "monitor.h"


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

void dump_tf(trapframe_t* tf)
{
  static const char*  regnames[] = {
    "z ", "ra", "sp", "gp", "tp", "t0",  "t1",  "t2",
    "s0", "s1", "a0", "a1", "a2", "a3",  "a4",  "a5",
    "a6", "a7", "s2", "s3", "s4", "s5",  "s6",  "s7",
    "s8", "s9", "sA", "sB", "t3", "t4",  "t5",  "t6"
  };

  tf->gpr[0] = 0;

  for(int i = 0; i < 32; i+=4)
  {
    for(int j = 0; j < 4; j++)
      printk("%s %lx%c",regnames[i+j],tf->gpr[i+j],j < 3 ? ' ' : '\n');
  }
  printk("pc %lx va %lx op %x sr %lx\n\n\n", tf->epc, tf->badvaddr,
         (uint32_t)tf->insn, tf->status);
}

void do_panic(const char* s, ...)
{
  va_list vl;
  va_start(vl, s);

  vprintk(s, vl);
  while(1); // endless loop

}

void kassert_fail(const char* s)
{
  register uintptr_t ra asm ("ra");
  do_panic("assertion failed @ %p: %s\n", ra, s);
}



void read_hex_str(char *b,int sz) {
char c;
char *p;

   p=b;
   c=toupper(readchar());
   while (c!='\r') {

      if (c==8 && p>b) {// backspace
        p--;
        writestr("\b \b");
      } else if ( ((c>='0' && c<='9') || (c>='A' && c<='F')) && p<(b+sz-1) ) {
          *p++=c;
          writechar(c); // echo
      }
      else
        writechar('\a'); // beep

      c=toupper(readchar());
   }
   *p='\0';

}

void read_num_str(char *b,int sz) {
char c;
char *p;

   p=b;
   c=readchar();
   while (c!='\r') {

      if (c==8 && p>b) {// backspace
        p--;
        writestr("\b \b");
      } else if (((c>='0' && c<='9') || c=='-') && p<(b+sz-1) ) {
          *p++=c;
          writechar(c); // echo
      }
      else
        writechar('\a'); // beep

      c=readchar();
   }
   *p='\0';

}


void hex_dump(void *mem,int numWords)
{
uint32_t *pmem = mem;
int i;

    for(i=0;i<numWords;i++) {
      if ((i % 4)==0) { // Write Memory address for every four words
        printk("\n%lx    ",(uint32_t)&pmem[i]);  
      }
      printk("%lx ",pmem[i]);
      //writeHex(pmem[i]);
    }
}

