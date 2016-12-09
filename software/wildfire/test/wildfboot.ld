MEMORY
{
    RAM (rwx)    : ORIGIN = 0x0C000000, LENGTH = 16384
}


ENTRY(_start)

SECTIONS
{
  
  . = 0x0;
  rombase = .;
  .text : {
    *(.init)
    . = 0x100;
    *(.text.*)

   } > RAM

  .data  ALIGN(4) : {
     *(.rodata.*)
     *(.sdata)
     *(.data)
     *(.bss)
     end = .; _end = .; __end = .;
      
 } > RAM
  stacktop = 0x0C003ff0; 

}
