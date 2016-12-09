.section .init
.global _start
.global get_impid
.extern main
.extern stacktop

_start:
la sp,stacktop // set SP to end of RAM
jal main


get_impid:
csrr a0,mimpid
ret

