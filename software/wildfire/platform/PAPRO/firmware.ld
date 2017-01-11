MEMORY
{
    RAM (rwx)    : ORIGIN = 0x0C000000, LENGTH = 16384
}


ENTRY(_start)


SECTIONS
{
  _rombase = 0x0C000000;
  
  . = 0x0;
  
  .text : {
    *(.init)
    *(.text.*)

   } > RAM

  .data  ALIGN(4) : {
     *(.rodata.*)
     *(.rodata)
     *(.eh_frame)
     *(.sdata)
     *(.data)
     *(.bss)
     end = .; _end = .; __end = .;
      
 } > RAM
  _stacktop = 0x0C003ff0; 

}

