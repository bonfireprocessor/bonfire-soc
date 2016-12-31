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

extern void do_break();

#endif
