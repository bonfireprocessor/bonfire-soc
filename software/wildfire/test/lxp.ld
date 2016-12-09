MEMORY
{
    RAM (rwx)    : ORIGIN = 0x00000000, LENGTH = 0x10000000
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
 } > RAM

end = .; _end = .; __end = .;
}
