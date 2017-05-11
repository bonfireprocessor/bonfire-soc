.section .init
.global _start


.extern main

.extern _edata
.extern _end
.extern __libc_fini_array
.extern __libc_init_array
.extern atexit
.extern memset



_start:

  la gp, _gp

  //li a0,0x0fffffff8
  //and sp,sp,a0 // Align stack modulo 8, to make *printf of doubles working ..

// From riscv-gnu-toolchain/riscv-newlib/libgloss/riscv
 # Clear the bss segment
  la      a0, _edata
  la      a2, _end
  sub     a2, a2, a0
  li      a1, 0
  call    memset

  //la      a0, __libc_fini_array   # Register global termination functions
  //call    atexit                  #  to be called upon exit
  //call    __libc_init_array       # Run global initialization functions


   call main

endless:
j endless



