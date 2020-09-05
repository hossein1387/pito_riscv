# See LICENSE for license details.

# ############################################################################
# irq.S
# ############################################################################
#
# Test csr instruction.
#

#include "pito_def.h"

jal   sp, enable_mvu_irq
jal   sp, wait_for_mvu_irq
jal   sp, mvu_irq_handler
jal   sp, prog_end

wait_for_mvu_irq:
    csrr t0, mcause
    srli t0, t0, 31
    addi t1, x0, 1
    # wait for mcause[31] interrupt to go high
    bne t0, t1, wait_for_mvu_irq
    addi ra, sp, 0
    ret

mvu_irq_handler:
    # first things first, disable mvu intterupts while processing current irq.
    jal ra, disable_mvu_irq
    # do whatever to make MVU happy 
    addi x0, x0, 0
    # we can now start processing incoming interrupts
    jal ra, enable_mvu_irq
    addi ra, sp, 0
    ret

enable_mvu_irq:
    # make sure global interrupt is enabled
    csrwi mstatus, 0x8
    # set MVU specific MIE bit aka mie[16]
    addi t0, x0, 1
    slli t0, t0, 16
    csrw mie, t0
    addi ra, sp, 0
    ret

disable_mvu_irq:
    # clear MVU specific MIE bit
    addi t0, x0, 1
    slli t0, t0, 16
    not t0, t0
    csrw mie, t0
    addi ra, sp, 0
    ret

# Done with our awesome program!
prog_end:
    nop
    nop
    nop
    ebreak
