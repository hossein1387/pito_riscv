OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY {
  PITO_INSTR (rx) : ORIGIN = 0x00200000, LENGTH = 0x2000
  PITO_DATA (rwx) : ORIGIN = 0x00202000, LENGTH = 0x2000
  IO  (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x10
}

SECTIONS
{
  .text : 
  {
    *(.text.init)
    *(.text)
  } > PITO_INSTR
  .data : 
  {
    *(.rodata*)
    *(.data)
    _global = . + 0x800;
    *(.sbss)    
    *(.bss)
   } > PITO_DATA

   PROVIDE ( _stack_top = ORIGIN(PITO_DATA) + LENGTH(PITO_DATA));
   PROVIDE ( _stack_base = ORIGIN(PITO_DATA) + LENGTH(PITO_DATA) - 0x200 );

  .io : 
  {  
    PROVIDE (io = ORIGIN(IO)); 
  } > IO

}

