#ifndef __MONITOR_H
#define __MONITOR_H

typedef struct
{
  long gpr[32];
  long status;
  long epc;
  long badvaddr;
  long cause;
  long insn;
} trapframe_t;


void do_break(uint32_t arg0,...);
void printk(const char* s, ...);
void dump_tf(trapframe_t* tf);
void do_panic(const char* s, ...);
void kassert_fail(const char* s);

#endif
