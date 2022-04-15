OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  PITO_RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x2000
  IO  (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x10
}

SECTIONS
{
    .text : {
    *(.text.init)
    *(.text)
  } > PITO_RAM
  .data : {
    . = ALIGN(0x10);
    *(.data)
  } > PITO_RAM

  .data.string : { *(.data.string)}
  .bss : { *(.bss) }

  _end = .;

  .io : {  
    PROVIDE (io = ORIGIN(IO)); 
  } > IO

}

