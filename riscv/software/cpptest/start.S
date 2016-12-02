.section .init
.global _start
.global get_impid
.extern main

_start:
li sp,0x03FF0 // set SP to end of RAM
jal main


get_impid:
csrr a0,mimpid
ret

