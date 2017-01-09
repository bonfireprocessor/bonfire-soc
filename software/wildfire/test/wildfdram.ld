MEMORY
{
    RAM (rwx)    : ORIGIN = 0x00010000, LENGTH = 8384512
}


ENTRY(_start)


SECTIONS
{
  
  
  . = 0x0;
  
  .text : {
    *(.init)
    *(.text.*)

   } > RAM

  .data  ALIGN(4) : {
     *(.rodata.*)
     *(.sdata)
     *(.data)
     *(.bss)
     end = .; _end = .; __end = .;
   
 } > RAM
   _stacktop = 0x07ffff0; 
 
}
