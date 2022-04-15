OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
    ROM (x!rw) : ORIGIN = 0x00000000, LENGTH = 0x1000
    RAM (rwx) : ORIGIN = 0x00001000, LENGTH = 0x8000
}

SECTIONS
{
    .text :
    {
        *(.boot)
        *(.text)
    } > ROM
    .data :
    {
        *(.rodata*)
        *(.data)
        *(.sbss)
        *(.bss)
    } > RAM
   PROVIDE ( _stack = ORIGIN(RAM) + LENGTH(RAM) );
}