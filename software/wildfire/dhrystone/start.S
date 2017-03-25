.section .init
.global _start
.global get_impid
.global do_break
.global start_user
.global delay_loop
.extern main
.extern _stacktop

.extern setBaudRate


#include "bits.h"
#include "platform.h"


_start:
  // init all registers
  li x1, 0
  li x2, 0
  li x3, 0
  li x4, 0
  li x5, 0
  li x6, 0
  li x7, 0
  li x8, 0
  li x9, 0
  li x10, 0
  li x11, 0
  li x12, 0
  li x13, 0
  li x14, 0
  li x15, 0
  li x16, 0
  li x17, 0
  li x18, 0
  li x19, 0
  li x20, 0
  li x21, 0
  li x22, 0
  li x23, 0
  li x24, 0
  li x25, 0
  li x26, 0
  li x27, 0
  li x28, 0
  li x29, 0
  li x30, 0
  li x31, 0


la sp,_stacktop // set SP to end of RAM

li a0,500000
call setBaudRate

call main

endless:
j endless


get_impid:
csrr a0,mimpid
ret

do_break:
sbreak
ret

start_user:
mv sp,a1
jalr a0

delay_loop:
addi a0,a0,-1
bnez a0,delay_loop
ret


