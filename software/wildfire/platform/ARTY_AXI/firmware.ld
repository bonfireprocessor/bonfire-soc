MEMORY
{
    RAM (rwx)    : ORIGIN = 0xC0000000, LENGTH = 32768
}


ENTRY(_start)


SECTIONS
{
  _rombase = 0xC0000000;

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
     *(.sbss)
     *(.sbss.*)
     *(.gnu.linkonce.sb.*)
     *(.bss)
     *(.bss.*)
     *(.gnu.linkonce.b.*)
     *(COMMON)

      end = .; _end = .; __end = .;

 } > RAM
  _stacktop = 0xC0007ff0;

}

