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

// RAM independant delay loop which takes 6 clocks/count 
void delay_loop(uint32_t count); 

#define LOOP_TIME (CLK_PERIOD * 6)

#endif
