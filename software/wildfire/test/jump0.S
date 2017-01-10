.section .init
.global _start

_start:

la a1,trap
csrw mtvec, a1

// Jump to address 0x0
li a0,0x0
csrw mepc,a0
sret


trap:
j trap
