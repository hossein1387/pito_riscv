package pito_pkg;
`include "rv32_defines.svh"

localparam int NUM_HARTS      = 8;
localparam int HART_CNT_WIDTH = $clog2(NUM_HARTS);
localparam bit RVA = 1'b0; // Is Atomic extension enabled
localparam bit RVC = 1'b0; // Is Compressed extension enabled
localparam bit RVD = 1'b0; // Is Double extension enabled
localparam bit RVF = 1'b0; // Is Float extension enabled
localparam bit RVI = 1'b1; // Is Integer extension enabled
localparam bit RVM = 1'b0; // Is M extension enabled

localparam logic [31:0] ISA_CODE =         (RVA <<  0)  // A - Atomic Instructions extension
                                         | (RVC <<  2)  // C - Compressed extension
                                         | (RVD <<  3)  // D - Double precsision floating-point extension
                                         | (RVF <<  5)  // F - Single precsision floating-point extension
                                         | (RVI <<  8)  // I - RV32I/64I/128I base ISA
                                         | (RVM << 12)  // M - Integer Multiply/Divide extension
                                         | (0   << 13)  // N - User level interrupts supported
                                         | (0   << 18)  // S - Supervisor mode implemented
                                         | (1   << 20)  // U - User mode implemented
                                         | (0   << 23)  // X - Non-standard extensions present
                                         | (1   << (`XPR_LEN-2)); // RV32
localparam logic [31:0] PITO_MARCHID  = `XPR_LEN'h8C100;

//-------------------------------------------------------------------
//                     PITO Control Status Registers
//-------------------------------------------------------------------
typedef enum logic [11:0] {
    // RV32I Machine Mode CSRs 0-31
    // Machine Information Registers
    CSR_MVENDORID      = 12'hF11,
    CSR_MARCHID        = 12'hF12,
    CSR_MIMPID         = 12'hF13,
    CSR_MHARTID        = 12'hF14,

    // Machine Trap Setup
    CSR_MSTATUS        = 12'h300,
    CSR_MISA           = 12'h301,
    CSR_MIE            = 12'h304,
    CSR_MTVEC          = 12'h305,

    //Machine Trap Handling
    CSR_MSCRATCH       = 12'h340,
    CSR_MEPC           = 12'h341,
    CSR_MCAUSE         = 12'h342,
    CSR_MTVAL          = 12'h343,
    CSR_MIP            = 12'h344,

    //Machine Counter/Timers
    CSR_MCYCLE         = 12'hB00,
    CSR_MINSTRET       = 12'hB02,
    CSR_MCYCLEH        = 12'hB80,
    CSR_MINSTRETH      = 12'hB82,

    CSR_MCALL          = 12'hB0C,  // Procedure call
    CSR_MRET           = 12'hB0D,  // Procedure Return

    // MVU CSRs            
    CSR_MVUWBASEPTR    = 12'hF20, // Base address for weight memory
    CSR_MVUIBASEPTR    = 12'hF21, // Base address for input memory
    CSR_MVUSBASEPTR    = 12'hF22, // Base address for scaler memory (6 bits)
    CSR_MVUBBASEPTR    = 12'hF23, // Base address for bias memory (6 bits)
    CSR_MVUOBASEPTR    = 12'hF24, // Output base address
    CSR_MVUWJUMP_0     = 12'hF25, // Weight address jumps in loops 0
    CSR_MVUWJUMP_1     = 12'hF26, // Weight address jumps in loops 1
    CSR_MVUWJUMP_2     = 12'hF27, // Weight address jumps in loops 2
    CSR_MVUWJUMP_3     = 12'hF28, // Weight address jumps in loops 3
    CSR_MVUWJUMP_4     = 12'hF29, // Weight address jumps in loops 4
    CSR_MVUIJUMP_0     = 12'hF2A, // Input data address jumps in loops 0
    CSR_MVUIJUMP_1     = 12'hF2B, // Input data address jumps in loops 1
    CSR_MVUIJUMP_2     = 12'hF2C, // Input data address jumps in loops 2
    CSR_MVUIJUMP_3     = 12'hF2D, // Input data address jumps in loops 3
    CSR_MVUIJUMP_4     = 12'hF2E, // Input data address jumps in loops 4
    CSR_MVUSJUMP_0     = 12'hF2F, // Scaler memory address jumps (6 bits)
    CSR_MVUSJUMP_1     = 12'hF30, // Scaler memory address jumps (6 bits)
    CSR_MVUBJUMP_0     = 12'hF31, // Bias memory address jumps (6 bits)
    CSR_MVUBJUMP_1     = 12'hF32, // Bias memory address jumps (6 bits)
    CSR_MVUOJUMP_0     = 12'hF33, // Output data address jumps in loops 0
    CSR_MVUOJUMP_1     = 12'hF34, // Output data address jumps in loops 1
    CSR_MVUOJUMP_2     = 12'hF35, // Output data address jumps in loops 2
    CSR_MVUOJUMP_3     = 12'hF36, // Output data address jumps in loops 3
    CSR_MVUOJUMP_4     = 12'hF37, // Output data address jumps in loops 4
    CSR_MVUWLENGTH_1   = 12'hF38, // Weight length in loops 0
    CSR_MVUWLENGTH_2   = 12'hF39, // Weight length in loops 1
    CSR_MVUWLENGTH_3   = 12'hF3A, // Weight length in loops 2
    CSR_MVUWLENGTH_4   = 12'hF3B, // Weight length in loops 3
    CSR_MVUILENGTH_1   = 12'hF3C, // Input data length in loops 0
    CSR_MVUILENGTH_2   = 12'hF3D, // Input data length in loops 1
    CSR_MVUILENGTH_3   = 12'hF3E, // Input data length in loops 2
    CSR_MVUILENGTH_4   = 12'hF3F, // Input data length in loops 3
    CSR_MVUSLENGTH_1   = 12'hF40, // Scaler tensor length 15 bits
    CSR_MVUBLENGTH_1   = 12'hF41, // Bias tensor length 15 bits
    CSR_MVUOLENGTH_1   = 12'hF42, // Output data length in loops 0
    CSR_MVUOLENGTH_2   = 12'hF43, // Output data length in loops 1
    CSR_MVUOLENGTH_3   = 12'hF44, // Output data length in loops 2
    CSR_MVUOLENGTH_4   = 12'hF45, // Output data length in loops 3
    CSR_MVUPRECISION   = 12'hF46, // Precision in bits for all tensors
    CSR_MVUSTATUS      = 12'hF47, // Status of MVU
    CSR_MVUCOMMAND     = 12'hF48, // Kick to send command.
    CSR_MVUQUANT       = 12'hF49, // MSB index position
    CSR_MVUSCALER      = 12'hF4A, // fixed point operand for multiplicative scaling
    CSR_MVUCONFIG1     = 12'hF4B  //Shift/accumulator load on jump select (only 0-4 valid) Pool/Activation clear on jump select (only 0-4 valid)


} csr_t;


typedef enum logic [2:0] {
    MRET           = 3'b000,
    CSR_READ_WRITE = 3'b001,
    CSR_SET        = 3'b010,
    CSR_CLEAR      = 3'b011,
    CSR_UNKNOWN    = 3'b111
} csr_op_t;

typedef struct packed {
     logic [HART_CNT_WIDTH:0] hart_id; // hart id that received an irq
     logic [31:0] data; // data to be passed with the irq
     logic        valid;
} irq_evt_t;

//-------------------------------------------------------------------
//                     PITO Interrupt and Exception Codes
//-------------------------------------------------------------------
localparam int unsigned IRQ_M_SOFT   = 3;
localparam int unsigned IRQ_M_TIMER  = 7;
localparam int unsigned IRQ_M_EXT    = 11;
localparam int unsigned IRQ_MVU_INTR = 16;

localparam logic [31:0] MIP_MSIP = 1 << IRQ_M_SOFT;
localparam logic [31:0] MIP_MTIP = 1 << IRQ_M_TIMER;
localparam logic [31:0] MIP_MEIP = 1 << IRQ_M_EXT;
localparam logic [31:0] MIP_MVIP = 1 << IRQ_MVU_INTR;

localparam logic [31:0] MACH_SW_INTR = (1 << 31) | IRQ_M_SOFT;  //Machine software interrupt
localparam logic [31:0] MACH_T_INTR  = (1 << 31) | IRQ_M_TIMER; //Machine timer interrupt
localparam logic [31:0] MACH_EX_INTR = (1 << 31) | IRQ_M_EXT;   //User software interrupt
localparam logic [31:0] MVU_INTR     = (1 << 31) | IRQ_MVU_INTR;//MVU interrupt

localparam logic [31:0] INSTR_ADDR_MISALIGNED = 0;  // Instruction address misaligned
localparam logic [31:0] INSTR_ACCESS_FAULT    = 1;  // Instruction access fault
localparam logic [31:0] ILLEGAL_INSTR         = 2;  // Illegal instruction
localparam logic [31:0] LD_ADDR_MISALIGNED    = 4;  // Load address misaligned
localparam logic [31:0] LD_ACCESS_FAULT       = 5;  // Load access fault
localparam logic [31:0] ST_ADDR_MISALIGNED    = 6;  // Store/AMO address misaligned
localparam logic [31:0] ST_ACCESS_FAULT       = 7;  // Store/AMO access fault
localparam logic [31:0] ENV_CALL_MMODE        = 11; // environment call from machine mode //Reserved

endpackage