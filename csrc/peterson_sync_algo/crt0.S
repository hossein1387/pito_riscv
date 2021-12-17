.globl _start
.globl get_pito_hart_id
.globl _fail
.section .text;
.section .text.init;

#include "pito_def.h"

// For the riscv-tests environment
.weak mtvec_handler

_start:
    /* reset vector */
    j reset_vector
reset_vector:
    li      x1, 0
    li      x4, 0
    li      x5, 0
    li      x6, 0
    li      x7, 0
    li      x8, 0
    li      x9, 0
    li      x10, 0
    li      x11, 0
    li      x12, 0
    li      x13, 0
    li      x14, 0
    li      x15, 0
    li      x16, 0
    li      x17, 0
    li      x18, 0
    li      x19, 0
    li      x20, 0
    li      x10, 0
    li      x21, 0
    li      x22, 0
    li      x23, 0
    li      x24, 0
    li      x25, 0
    li      x26, 0
    li      x27, 0
    li      x28, 0
    li      x29, 0
    li      x30, 0
    li      x31, 0
    # set sp to the end of the memory
    li      sp, 0x00003fc 
    csrw mtvec, a0
    // Set up a PMP to permit all accesses
    // Delegate no traps
    csrwi   mie, 0
    la      t0, trap_vector
    csrw    mtvec, t0
    // Call main
    la      t0, main
    csrw    mepc, t0
    mret

enable_mvu_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    # make sure global interrupt is enabled
    csrwi mstatus, 0x8
    # set MVU specific MIE bit aka mie[16]
    addi t0, x0, 1
    slli t0, t0, 16
    csrw mie, t0
    addi ra, sp, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

disable_mvu_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    # clear MVU specific MIE bit
    addi t0, x0, 1
    slli t0, t0, 16
    not t0, t0
    csrw mie, t0
    addi ra, sp, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

get_pito_hart_id:
    csrr a0, mhartid
    ret

clear_mvu_pending_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    csrrci x0, mip, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

trap_vector:
    // Jump to the mtvec_handler, if it exists
    la t5, mtvec_handler
    beqz t5, 1f
    jr t5
1:  csrr a0, mcause
    j _fail

# Done with our awesome program!
_prog_end:
    lui a0,0x10000000>>12
    addi  a1,zero,'O'
    addi  a2,zero,'K'
    addi  a3,zero,'\n'
    sw  a1,0(a0)
    sw  a2,0(a0)
    sw  a3,0(a0)
    ebreak

_fail:
    lui a0,0x10000000>>12
    addi  a1,zero,'N'
    addi  a2,zero,'O'
    addi  a3,zero,'K'
    addi  a4,zero,'\n'
    sw  a1,0(a0)
    sw  a2,0(a0)
    sw  a3,0(a0)
    sw  a4,0(a0)
    ebreak

.section .data