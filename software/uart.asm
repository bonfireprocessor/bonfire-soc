/* Test UART */
// sample_clk = (f_clk / (baudrate * 16)) - 1
// (32.000.000 / (115200*16))-1 = 16,36 ...
//    |--------------------|--------------------------------------------|
//--! | Address            | Description                                |
//--! |--------------------|--------------------------------------------|
//--! | 0x00               | Transmit register (write-only)             |
//--! | 0x04               | Receive register (read-only)               |
//--! | 0x08               | Status register (read-only)                |
//--! | 0x0c               | Sample clock divisor register (read/write) |
//--! | 0x10               | Interrupt enable register (read/write)     |
//--! |--------------------|--------------------------------------------|

lc r0, 0x2000000C // Sample Clock Register 
lc r1, 16 // Divisor 
sb r0,r1

lc r100,0x20000000 // Transmit Register
lc r101,0x20000008 // Status register 
lc r102,waitfree // Label
lc r103,mainloop // Label 
lc r104,mainloop1 // Label 
lc r105,0x10000000 // GPIO Register 

mainloop:
lc r1, outstr // Init pointer 
mainloop1:
lub r2,r1 // Read char 
cjmpe r103/*mainloop*/ ,r2,0 // start again when end of string reached 

waitfree:
lub r0,r101 // Load status register
sb r105,r0  // Set GPIO LEDs with UART Status register 
and r0,r0,0x08 // Mask bit 3 (transmit buffer full)
cjmpe r102 /*waitfree*/,r0,0x08 // Wait until bit 3 is cleared

sb r100,r2 // Transmit char in r2 
add r1,r1,1 // increment pointer 
jmp r104 // mainloop1
 

    
outstr: .byte "Hello World\r\n",0     
    