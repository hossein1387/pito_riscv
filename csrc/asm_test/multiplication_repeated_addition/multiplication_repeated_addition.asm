_START_:
    addi a1, zero, 10
    nop
    nop
    nop
    nop
    nop
    addi a2, zero, -10
    nop
    nop
    nop
    nop
    nop
    addi a3, zero, 0
    nop
    nop
    nop
    nop
    nop
    addi a5, zero, 0
    nop
    nop
    nop
    nop
    nop
    blt  zero, a1, LOOP
    nop
    nop
    nop
    nop
    nop
    addi a3, zero, 1
    nop
    nop
    nop
    nop
    nop
    addi a4, zero, -1
    nop
    nop
    nop
    nop
    nop
    xor  a1, a1, a4
    nop
    nop
    nop
    nop
    nop
    addi a1, a1, 1
    nop
    nop
    nop
    nop
    nop
LOOP:
    beq zero, a1, DONE
    nop
    nop
    nop
    nop
    nop
    add a5, a5, a2
    nop
    nop
    nop
    nop
    nop
    addi a1, a1, -1
    nop
    nop
    nop
    nop
    nop
    jal zero, LOOP
    nop
    nop
    nop
    nop
    nop
DONE: 
    beq zero, a3, RET
    nop
    nop
    nop
    nop
    nop
    addi a4, zero, -1
    nop
    nop
    nop
    nop
    nop
    xor  a5, a5, a4
    nop
    nop
    nop
    nop
    nop
    addi a5, a5, 1
    nop
    nop
    nop
    nop
    nop
RET: 
    jal zero, RET
    nop
    nop
    nop
    nop
    nop
