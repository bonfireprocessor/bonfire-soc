.section .init
.global _start
.extern main

_start:
li sp,0x03FF0 // set SP to end of RAM
jal main
