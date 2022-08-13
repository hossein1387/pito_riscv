#ifndef _PITO_DEFS_
#define _PITO_DEFS_

// pito DMA macros
#define CSR_DMADSTADDR 0xf00// DMA destination address
#define CSR_DMABLKSIZE 0xf01// DMA block size to copy

// pito mvu macros
#define CSR_MVUWBASEPTR 0xf20//Base address for weight memory
#define CSR_MVUIBASEPTR 0xf21//Base address for input memory
#define CSR_MVUSBASEPTR 0xf22//Base address for scaler memory (6 bits)
#define CSR_MVUBBASEPTR 0xf23//Base address for bias memory (6 bits)
#define CSR_MVUOBASEPTR 0xf24//Output base address
#define CSR_MVUWJUMP_0 0xf25//Weight address jumps in loops 0
#define CSR_MVUWJUMP_1 0xf26//Weight address jumps in loops 1
#define CSR_MVUWJUMP_2 0xf27//Weight address jumps in loops 2
#define CSR_MVUWJUMP_3 0xf28//Weight address jumps in loops 3
#define CSR_MVUWJUMP_4 0xf29//Weight address jumps in loops 4
#define CSR_MVUIJUMP_0 0xf2a//Input data address jumps in loops 0
#define CSR_MVUIJUMP_1 0xf2b//Input data address jumps in loops 1
#define CSR_MVUIJUMP_2 0xf2c//Input data address jumps in loops 2
#define CSR_MVUIJUMP_3 0xf2d//Input data address jumps in loops 3
#define CSR_MVUIJUMP_4 0xf2e//Input data address jumps in loops 4
#define CSR_MVUSJUMP_0 0xf2f//Scaler memory address jumps (6 bits)
#define CSR_MVUSJUMP_1 0xf30//Scaler memory address jumps (6 bits)
#define CSR_MVUSJUMP_2 0xf31//Scaler memory address jumps (6 bits)
#define CSR_MVUSJUMP_3 0xf32//Scaler memory address jumps (6 bits)
#define CSR_MVUSJUMP_4 0xf33//Scaler memory address jumps (6 bits)
#define CSR_MVUBJUMP_0 0xf34//Bias memory address jumps (6 bits)
#define CSR_MVUBJUMP_1 0xf35//Bias memory address jumps (6 bits)
#define CSR_MVUBJUMP_2 0xf36//Bias memory address jumps (6 bits)
#define CSR_MVUBJUMP_3 0xf37//Bias memory address jumps (6 bits)
#define CSR_MVUBJUMP_4 0xf38//Bias memory address jumps (6 bits)
#define CSR_MVUOJUMP_0 0xf39//Output data address jumps in loops 0
#define CSR_MVUOJUMP_1 0xf3a//Output data address jumps in loops 1
#define CSR_MVUOJUMP_2 0xf3b//Output data address jumps in loops 2
#define CSR_MVUOJUMP_3 0xf3c//Output data address jumps in loops 3
#define CSR_MVUOJUMP_4 0xf3d//Output data address jumps in loops 4
#define CSR_MVUWLENGTH_0 0xf3e//Weight length in loops 0
#define CSR_MVUWLENGTH_1 0xf3f//Weight length in loops 1
#define CSR_MVUWLENGTH_2 0xf40//Weight length in loops 2
#define CSR_MVUWLENGTH_3 0xf41//Weight length in loops 3
#define CSR_MVUWLENGTH_4 0xf42//Weight length in loops 3
#define CSR_MVUILENGTH_1 0xf43//Input data length in loops 0
#define CSR_MVUILENGTH_2 0xf44//Input data length in loops 1
#define CSR_MVUILENGTH_3 0xf45//Input data length in loops 2
#define CSR_MVUILENGTH_4 0xf46//Input data length in loops 3
#define CSR_MVUSLENGTH_1 0xf47//Scaler tensor length 15 bits
#define CSR_MVUSLENGTH_2 0xf48//Scaler tensor length 15 bits
#define CSR_MVUSLENGTH_3 0xf49//Scaler tensor length 15 bits
#define CSR_MVUSLENGTH_4 0xf4a//Scaler tensor length 15 bits
#define CSR_MVUBLENGTH_1 0xf4b//Bias tensor length 15 bits
#define CSR_MVUBLENGTH_2 0xf4c//Bias tensor length 15 bits
#define CSR_MVUBLENGTH_3 0xf4d//Bias tensor length 15 bits
#define CSR_MVUBLENGTH_4 0xf4e//Bias tensor length 15 bits
#define CSR_MVUOLENGTH_1 0xf4f//Output data length in loops 0
#define CSR_MVUOLENGTH_2 0xf50//Output data length in loops 1
#define CSR_MVUOLENGTH_3 0xf51//Output data length in loops 2
#define CSR_MVUOLENGTH_4 0xf52//Output data length in loops 3
#define CSR_MVUPRECISION 0xf53//Precision in bits for all tensors
#define CSR_MVUSTATUS 0xf54//Status of MVU
#define CSR_MVUCOMMAND 0xf55//Kick to send command.
#define CSR_MVUQUANT 0xf56//MSB index position
#define CSR_MVUSCALER  0xf57//fixed point operand for multiplicative scaling
#define CSR_MVUCONFIG1 0xf58//Shift/accumulator load on jump select (only 0-4 valid) Pool/Activation clear on jump select (only 0-4 valid)
#define CSR_MVUOMVUSEL 0xf59//MVU selector bits for output
#define CSR_MVUIHPBASEADDR 0xf5a//high-precision data memory base address for input
#define CSR_MVUOHPBASEADDR 0xf5b//high-precision data memory base address for output
#define CSR_MVUOHPMVUSEL 0xf5c//MVU selector bits for high-precision output
#define CSR_MVUHPJUMP_0 0xf5d//Input jumps
#define CSR_MVUHPJUMP_1 0xf5e//Input jumps
#define CSR_MVUHPJUMP_2 0xf5f//Input jumps
#define CSR_MVUHPJUMP_3 0xf60//Input jumps
#define CSR_MVUHPJUMP_4 0xf61//Input jumps
#define CSR_MVUHPLENGTH_1 0xf62//Scaler length
#define CSR_MVUHPLENGTH_2 0xf63//Scaler length
#define CSR_MVUHPLENGTH_3 0xf64//Scaler length
#define CSR_MVUHPLENGTH_4 0xf65//Scaler length
#define CSR_MVUUSESCALER_MEM 0xf66//Use scalar mem if 1; otherwise use the scaler_b input for scaling
#define CSR_MVUUSEBIAS_MEM 0xf67//Use the bias memory if 1; if not, not bias is added in the scaler
#define CSR_MVUUSEPOOLER4HPOUT 0xf68//For the high-precision interconnect, use the output of pooler if 1, or use output of scaler1 if 0
#define CSR_MVUUSEHPADDER 0xf69//Use the hpadder if 1

#define __ASM_STR(x) #x
#define SET_CSR(reg, value)                                          \
    __asm__ volatile("csrw " __ASM_STR(reg) ", %0" : : "r"(value));

// pito mtvec configurations
#define pito_mtvec_mem_addr 0x00000000 // mtvec location in data memory
#define pito_mtvec          A000h // mtvec value

// Memory Regions

#define DMA_START_ADDR  0x40000000
#define MVU_START_ADDR  0x7FE00000

#endif
