/* Writes Data to GPIO Port */

lc r0, 0x10000000 // Address of GPIO Port 
lc r1, 0x9 // Data 
sb r0,r1

/// Test write to memory
lc r2, 0x03FF0 // shortly before end of our 16K memory 
lc r3,0x0FFFFFFFF
sw r2,r3 // init with FFFFFFF
sb r2,r1 // store  test pattern two lowes byte 

lc r101, halt

halt:
	hlt
	jmp r101