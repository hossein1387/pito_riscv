// All riscv32i instructions.
// Note, not all instructions listed below are implemented by
// pito riscv. A "*" near the instruction means the instruction
// is not implemented.


// Loads
`define RV32_LB     32'hxxxxxxxxxxxxxxxxx000xxxxx0000011  // *
`define RV32_LH     32'hxxxxxxxxxxxxxxxxx001xxxxx0000011  // *
`define RV32_LW     32'hxxxxxxxxxxxxxxxxx010xxxxx0000011  // *
`define RV32_LBU    32'hxxxxxxxxxxxxxxxxx100xxxxx0000011  // *
`define RV32_LHU    32'hxxxxxxxxxxxxxxxxx101xxxxx0000011  // *
// Stores
`define RV32_SB     32'hxxxxxxxxxxxxxxxxx000xxxxx0100011  // *
`define RV32_SH     32'hxxxxxxxxxxxxxxxxx001xxxxx0100011  // *
`define RV32_SW     32'hxxxxxxxxxxxxxxxxx010xxxxx0100011  // *
// Shifts
`define RV32_SLL    32'h0000000xxxxxxxxxx001xxxxx0110011  // *
`define RV32_SLLI   32'h0000000xxxxxxxxxx001xxxxx0010011  // *
`define RV32_SRL    32'h0000000xxxxxxxxxx101xxxxx0110011  // *
`define RV32_SRLI   32'h0000000xxxxxxxxxx101xxxxx0010011  // *
`define RV32_SRA    32'h0100000xxxxxxxxxx101xxxxx0110011  // *
`define RV32_SRAI   32'h0100000xxxxxxxxxx101xxxxx0010011  // *
// Arithmetic
`define RV32_ADD    32'h0000000xxxxxxxxxx000xxxxx0110011  // *
`define RV32_ADDI   32'hxxxxxxxxxxxxxxxxx000xxxxx0010011  // *
`define RV32_SUB    32'h0100000xxxxxxxxxx000xxxxx0110011  // *
`define RV32_LUI    32'hxxxxxxxxxxxxxxxxxxxxxxxxx0110111  // *
`define RV32_AUIPC  32'hxxxxxxxxxxxxxxxxxxxxxxxxx0010111  // *
// Logical
`define RV32_XOR    32'h0000000xxxxxxxxxx100xxxxx0110011  // *
`define RV32_XORI   32'hxxxxxxxxxxxxxxxxx100xxxxx0010011  // *
`define RV32_OR     32'h0000000xxxxxxxxxx110xxxxx0110011  // *
`define RV32_ORI    32'hxxxxxxxxxxxxxxxxx110xxxxx0010011  // *
`define RV32_AND    32'h0000000xxxxxxxxxx111xxxxx0110011  // *
`define RV32_ANDI   32'hxxxxxxxxxxxxxxxxx111xxxxx0010011  // *
// Compare
`define RV32_SLT    32'h0000000xxxxxxxxxx010xxxxx0110011  // *
`define RV32_SLTI   32'hxxxxxxxxxxxxxxxxx010xxxxx0010011  // *
`define RV32_SLTU   32'h0000000xxxxxxxxxx011xxxxx0110011  // *
`define RV32_SLTIU  32'hxxxxxxxxxxxxxxxxx011xxxxx0010011  // *
// Branches
`define RV32_BEQ    32'hxxxxxxxxxxxxxxxxx000xxxxx1100011  // *
`define RV32_BNE    32'hxxxxxxxxxxxxxxxxx001xxxxx1100011  // *
`define RV32_BLT    32'hxxxxxxxxxxxxxxxxx100xxxxx1100011  // *
`define RV32_BGE    32'hxxxxxxxxxxxxxxxxx101xxxxx1100011  // *
`define RV32_BLTU   32'hxxxxxxxxxxxxxxxxx110xxxxx1100011  // *
`define RV32_BGEU   32'hxxxxxxxxxxxxxxxxx111xxxxx1100011  // *
// Jump & Link
`define RV32_JAL    32'hxxxxxxxxxxxxxxxxxxxxxxxxx1101111  // *
`define RV32_JALR   32'hxxxxxxxxxxxxxxxxx000xxxxx1100111  // *
// Synch
`define RV32_FENCE  32'h0000xxxxxxxx00000000000000001111  // *
`define RV32_FENCEI 32'h00000000000000000001000000001111  // *
// CSR Access
`define RV32_CSRRW  32'hxxxxxxxxxxxxxxxxx001xxxxx1110011  // *
`define RV32_CSRRS  32'hxxxxxxxxxxxxxxxxx010xxxxx1110011  // *
`define RV32_CSRRC  32'hxxxxxxxxxxxxxxxxx011xxxxx1110011  // *
`define RV32_CSRRWI 32'hxxxxxxxxxxxxxxxxx101xxxxx1110011  // *
`define RV32_CSRRSI 32'hxxxxxxxxxxxxxxxxx110xxxxx1110011  // *
`define RV32_CSRRCI 32'hxxxxxxxxxxxxxxxxx111xxxxx1110011  // *
// Change Level
`define RV32_ECALL  32'h00000000000000000000000001110011  // *
`define RV32_EBREAK 32'h00000000000100000000000001110011  // *
`define RV32_ERET   32'h00010000000000000000000001110011  // *
`define RV32_WFI    32'h00010000001000000000000001110011  // *
// No Operation
`define RV32_NOP    32'h00000000000000000000000000010011  // *
