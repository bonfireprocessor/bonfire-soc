#ifndef __MONITOR_H
#define __MONITOR_H

#define LOAD_BASE ((void*)0x010000)


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

void start_user(uint32_t pc,uint32_t sp);


#endif
