#
# C Runtime for Pito.
#


# Read-only C strings.
#    Allocatable, Mergeable, String.
.section .rodata.str1.1, "aMS", @progbits, 1
_boot0msg:
    .asciz "boot0: text@%d data@%d stack@%d (%d bytes free)\n"



# Program code
.section .init

.globl _start
.balign 4
_start:
    #
    # SET STACK POINTER AND GLOBAL POINTER
    # sp = __stack + 512*(hartid+1)
    # gp = __global_pointer$
    #
    # The stack and global pointers must be loaded before any (pseudo-)
    # instruction or C code attempts to refer to data with those registers as a
    # base. For the initialization of the global pointer we must block all
    # relaxations, otherwise you end up with a relaxation to oneself:
    #
    #       mv     gp, gp                               # ***BAD!***
    #
    # rather than
    #
    #       auipc  gp,     %pcrel_hi(__global_pointer$) # GOOD!
    #       addi   gp, gp, %pcrel_lo(__global_pointer$) # GOOD!
    #
    # [1] https://sourceware.org/binutils/docs/as/RISC_002dV_002dDirectives.html
    #
.option push
.option norelax
    la     gp,   __global_pointer$
.option pop
    jal    get_pito_hart_id
    slli   a0,   a0,    9
    la     sp,   __stack_top
    sub    sp,   sp,    a0
    
    
    # CLEAR ALL OTHER REGISTERS
    li x1,  0;            li x4,  0; li x5,  0; li x6,  0; li x7,  0;
    li x8,  0; li x9,  0; li x10, 0; li x11, 0; li x12, 0; li x13, 0;
    li x14, 0; li x15, 0; li x16, 0; li x17, 0; li x18, 0; li x19, 0;
    li x20, 0; li x21, 0; li x22, 0; li x23, 0; li x24, 0; li x25, 0;
    li x26, 0; li x27, 0; li x28, 0; li x29, 0; li x30, 0; li x31, 0;
    
    
    # PREINIT ARRAY
    la     s0,   __preinit_array_start
    la     s1,   __preinit_array_end
0:  bge    s0,   s1,   1f
    lw     t0,   0(s0)     # Load function pointer
    addi   s0,   s0,   4   # Increment iterator through function pointers by one word
    jal    get_pito_hart_id# Set up mhartid argument to function.
    la     ra,   0b        # Prepare "return" address, actually a backward label
    jr     t0              # Call function. Return will be to backward label.
1:  
    
    # INIT ARRAY
    la     s0,   __init_array_start
    la     s1,   __init_array_end
2:  bge    s0,   s1,   3f
    lw     t0,   0(s0)     # Load function pointer
    addi   s0,   s0,   4   # Increment iterator through function pointers by one word
    jal    get_pito_hart_id# Set up mhartid argument to function.
    la     ra,   2b        # Prepare "return" address, actually a backward label
    jr     t0              # Call function. Return will be to backward label.
3:  li     s0,   0
    li     s1,   0
    li     t0,   0
    
    
    # ************* CALL MAIN *************
    jal    get_pito_hart_id# Set up mhartid argument to main().
    jal    main            # MAIN USER PROGRAM CALL
    mv     s2,   a0        # Save integer exit code
    
    
    # FINI ARRAY
    la     s0,   __fini_array_start
    la     s1,   __fini_array_end
4:  bge    s0,   s1,   5f
    lw     t0,   0(s0)     # Load function pointer
    addi   s0,   s0,   4   # Increment iterator through function pointers by one word
    jal    get_pito_hart_id# Set up mhartid argument to function.
    la     ra,   4b        # Prepare "return" address, actually a backward label
    jr     t0              # Call function. Return will be to backward label.
5:  
    
    # EXIT
    mv     a0,   s2
    jal    exit
    ebreak

# 
# Utility functions:
# wait_for_mvu_irq: Loops infinitely until an IRQ is received. 
# enable_mvu_irq:   First, enables the global interrupt by setting mstatus.mie. 
#                   It will then enables mvu IRQ by setting mie[16].
# get_pito_hart_id: A utility funciton to get the process hart id.

.weak  wait_for_mvu_irq
.globl wait_for_mvu_irq
wait_for_mvu_irq:
    addi sp, sp, -24
    sw ra, 4(sp)
    sw s0, 8(sp)
    sw s1, 12(sp)
    sw s2, 16(sp)
    sw s3, 20(sp)
    sw s4, 24(sp)
wait_for_mvu_irq_loop:
    csrr t0, mcause
    srli t0, t0, 31
    addi t1, x0, 1
    # wait for mcause[31] interrupt to go high
    bne t0, t1, wait_for_mvu_irq_loop
    # Clear interrup cause
    csrw mcause, x0
    lw ra, 4(sp)
    lw s0, 8(sp)
    lw s1, 12(sp)
    lw s2, 16(sp)
    lw s3, 20(sp)
    lw s4, 24(sp)
    addi sp, sp, 24
    ret


.weak  enable_mvu_irq
.globl enable_mvu_irq
enable_mvu_irq:
    addi sp, sp, -4
    sw ra, 4(sp)
    # make sure global interrupt is enabled
    csrwi mstatus, 0x8
    # # set MVU specific MIE bit aka mie[16]
    addi t0, x0, 1
    slli t0, t0, 16
    csrw mie, t0
    addi ra, sp, 0
    lw ra, 4(sp)
    addi sp, sp, 4
    ret

.weak  get_pito_hart_id
.globl get_pito_hart_id
get_pito_hart_id:
    csrr a0, mhartid
    ret

#
# Compiler runtime support for no-M extension
#
#     int          __mulsi3  (int          a, int          b)    *
#     unsigned int __udivsi3 (unsigned int a, unsigned int b)    /
#     unsigned int __umodsi3 (unsigned int a, unsigned int b)    %
#
.section .text.math
.weak  __mulsi3, __udivsi3, __umodsi3
.globl __mulsi3, __udivsi3, __umodsi3

.balign 16
__mulsi3:             # P = a*b
    beqz   a0, 1f     # Return 0 if first operand is 0
    mv     a3, a0     # Save a3=a0.
    mv     a0, zero   # Initialize return value to 0.
    beqz   a1, 1f     # Return 0 if second operand is 0
0:  andi   a2, a1, 1
    neg    a2, a2     # bitmask = (a1&1) ? 0xFFFFFFFF : 0
    and    a2, a2, a3
    add    a0, a0, a2 # P   += (a3 & bitmask)
    slli   a3, a3, 1  # a3 <<= 1
    srli   a1, a1, 1  # a1 >>= 1
    bnez   a1, 0b
1:  ret

.balign 16
__udivsi3:            # Q,M = D/d
0:  mv     a3, a1     # Save a3=a1 (d)
    li     a2, 1      # Load constant 1
    li     a1, 0      # Load constant 0
    beq    a3, a2, 1f # If d == 1, return {D, 0}
    beqz   a3,     3f # If d == 0, return {UINT_MAX, 0} (divide-by-zero)
    beq    a3, a0, 4f # If d == D, return {1, 0}
    mv     a1, a0     # Prepare a1=D and possible fast return
    bltu   a0, a3, 2f # If D <  d, return {0, D}
    
    #
    # The easy cases are inapplicable. Begin long division process.
    #
    ### PRECOND:  D>d && d>1
    ### RETURN:  {Q, M}
    ### REGISTER ASSIGNMENTS
    ###         BEGINNING  ENDING
    ###          a0 = 1    Q=D/d
    ###          a1 = D    M=D%d
    ###          a2 = q      0
    ###          a3 = d      -
    #
    # The precondition is D>d && d>1. Therefore, the quotient is always
    # at least one. Initialize Q=1 and execute one subtraction D -= d.
    # Afterwards, two possibilities:
    #
    #   1. d >= 0x80000000. In this case, D is now guaranteed < d. Division complete!
    #   2. d <  0x80000000. In this case it is safe to enter the q/d-alignment loop.
    #
    mv     a0, a2     # Q   = 1
    sub    a1, a1, a3 # D  -= d
5:                    # do{                            (Ascent  begins)
    bltu   a1, a3, 6f #     if(D<d) break;
    slli   a2, a2, 1  #     q <<= 1
    slli   a3, a3, 1  #     d <<= 1
    bgez   a3,     5b # }while(no overflow on d+d)
6:                    # do{                            (Descent begins)
    bltu   a1, a3, 7f #     if D>=d:
    add    a0, a0, a2 #         Q  += q
    sub    a1, a1, a3 #         D  -= d
7:  srli   a2, a2, 1  #     q >>= 1
    srli   a3, a3, 1  #     d >>= 1
    bnez   a2,     6b # }while(q)
1:  ret               # Return {a0,a1} = {Q,M} = {D/d,D%d}
2:  li     a2, 0      # (If entered directly) Return  0U
3:  neg    a2, a2     # (If entered directly) Return -1U (Divide-by-zero)
4:  mv     a0, a2     # (If entered directly) Return  1U
    ret

.balign 16
__umodsi3:
    mv     a4, ra
    jal    0b         # We do *not* reference __udivsi3 by name since that
    mv     a0, a1     # generates an interposable relocation to a __udivsi3
    mv     ra, a4     # that may not be "ours" (and thus doesn't return in a1)
    ret


#
# "Weak" putchar() function, used if no other implementation exists.
#
.section .text.io
.weak  putchar
.globl putchar
.balign 16
putchar:
    la     a1, io
0:  lbu    a2, 1(a1)
    andi   a2, a2, 1
    #fence
    bnez   a2, 0b
    sb     a0, 0(a1)
    ret


#
# "Weak" exit() function, used if no other implementation exists.
#
.section .text.exit
.weak  exit
.globl exit
exit:
    #
    # Under Linux, only the lower 8 bits of the exit code are taken
    #
    andi   a0, a0, 0xFF
    #
    # Exit Code
    #     0 == EXIT_SUCCESS. Other codes, including
    #     1 == EXIT_FAILURE, indicate failure.
    #
    bnez   a0, 0f
    lui    a0, 0x10000000>>12
    addi   a1, zero, 'O'
    addi   a2, zero, 'K'
    addi   a3, zero, '\n'
    sw     a1, 0(a0)
    sw     a2, 0(a0)
    sw     a3, 0(a0)
    j      1f
0:  lui    a0, 0x10000000>>12
    addi   a1, zero, 'N'
    addi   a2, zero, 'O'
    addi   a3, zero, 'K'
    addi   a4, zero, '\n'
    sw     a1, 0(a0)
    sw     a2, 0(a0)
    sw     a3, 0(a0)
    sw     a4, 0(a0)
1:  ebreak



#
# "Weak" main() function, used if no main() in any object file. Returns -1.
#
.section .text.main
.weak  main
.globl main
main:
    li     a0, -1
    ret
