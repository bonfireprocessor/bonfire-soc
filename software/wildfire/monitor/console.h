#ifndef __CONSOLE_H
#define __CONSOLE_H

#include <stdint.h>
#include "monitor.h"

void printk(const char* s, ...);
void dump_tf(trapframe_t* tf);
void do_panic(const char* s, ...);
void kassert_fail(const char* s);
void read_hex_str(char *b,int sz);
void hex_dump(void *mem,int numWords);
void read_num_str(char *b,int sz);


#endif
