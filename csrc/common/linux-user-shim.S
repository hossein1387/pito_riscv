.section .text
.balign 16


#
# get_pito_hart_id() must be overriden to avoid reading machine CSRs in userland.
#
.globl get_pito_hart_id
get_pito_hart_id:
    mv    a0, zero
    ret

#
# exit() must be overriden to execute the Linux kernel ABI exit syscall.
#
.globl exit
exit:
    li    a7, 94      # __NR_exit_group
    ecall             # Kill the program with exit code in lower 8 bits of a0
    # ret             # UNREACHABLE!

#
# putchar() must be overriden to write to stdout on Linux using kernel ABI write syscall.
#
.globl putchar
putchar:
    addi  sp, sp, -16 # Allocate some stack
    sb    a0, 0(sp)   # *stack = byte in a0
    li    a0, 1       # fd=1=stdout
    mv    a1, sp      # buf
    li    a2, 1       # count
    li    a7, 64      # __NR_write
    ecall             # Execute write
    blez  a0, 0f      # In case of error, return EOF;
    lbu   a0, 0(sp)   # Otherwise return printed character as unsigned char
0:  addi  sp, sp,  16
    ret

#
# Test main() that executes 255/5 == 51 == '3', prints it followed by a newline,
# and then returns it as the exit code.
#
.section .text.main
.weak  main
.globl main
main:
    addi  sp, sp, -16 # Allocate some stack
    sw    ra, 0(sp)
    sw    s0, 4(sp)
    li    a0, 255
    li    a1, 5
    jal   __udivsi3
    mv    s0, a0
    jal   putchar
    li    a0, '\n'
    jal   putchar
    mv    a0, s0
    lw    s0, 4(sp)
    lw    ra, 0(sp)
    addi  sp, sp,  16
    ret
