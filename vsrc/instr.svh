// Loads
`define LB     32'hxxxxxxxxxxxxxxxxx000xxxxx0000011
`define LH     32'hxxxxxxxxxxxxxxxxx001xxxxx0000011
`define LW     32'hxxxxxxxxxxxxxxxxx010xxxxx0000011
`define LBU    32'hxxxxxxxxxxxxxxxxx100xxxxx0000011
`define LHU    32'hxxxxxxxxxxxxxxxxx101xxxxx0000011
// Stores
`define SB     32'hxxxxxxxxxxxxxxxxx000xxxxx0100011
`define SH     32'hxxxxxxxxxxxxxxxxx001xxxxx0100011
`define SW     32'hxxxxxxxxxxxxxxxxx010xxxxx0100011
// Shifts
`define SLL    32'h0000000xxxxxxxxxx001xxxxx0110011
`define SLLI   32'h0000000xxxxxxxxxx001xxxxx0010011
`define SRL    32'h0000000xxxxxxxxxx101xxxxx0110011
`define SRLI   32'h0000000xxxxxxxxxx101xxxxx0010011
`define SRA    32'h0100000xxxxxxxxxx101xxxxx0110011
`define SRAI   32'h0100000xxxxxxxxxx101xxxxx0010011
// Arithmetic
`define ADD    32'h0000000xxxxxxxxxx000xxxxx0110011
`define ADDI   32'hxxxxxxxxxxxxxxxxx000xxxxx0010011
`define SUB    32'h0100000xxxxxxxxxx000xxxxx0110011
`define LUI    32'hxxxxxxxxxxxxxxxxxxxxxxxxx0110111
`define AUIPC  32'hxxxxxxxxxxxxxxxxxxxxxxxxx0010111
// Logical
`define XOR    32'h0000000xxxxxxxxxx100xxxxx0110011
`define XORI   32'hxxxxxxxxxxxxxxxxx100xxxxx0010011
`define OR     32'h0000000xxxxxxxxxx110xxxxx0110011
`define ORI    32'hxxxxxxxxxxxxxxxxx110xxxxx0010011
`define AND    32'h0000000xxxxxxxxxx111xxxxx0110011
`define ANDI   32'hxxxxxxxxxxxxxxxxx111xxxxx0010011
// Compare
`define SLT    32'h0000000xxxxxxxxxx010xxxxx0110011
`define SLTI   32'hxxxxxxxxxxxxxxxxx010xxxxx0010011
`define SLTU   32'h0000000xxxxxxxxxx011xxxxx0110011
`define SLTIU  32'hxxxxxxxxxxxxxxxxx011xxxxx0010011
// Branches
`define BEQ    32'hxxxxxxxxxxxxxxxxx000xxxxx1100011
`define BNE    32'hxxxxxxxxxxxxxxxxx001xxxxx1100011
`define BLT    32'hxxxxxxxxxxxxxxxxx100xxxxx1100011
`define BGE    32'hxxxxxxxxxxxxxxxxx101xxxxx1100011
`define BLTU   32'hxxxxxxxxxxxxxxxxx110xxxxx1100011
`define BGEU   32'hxxxxxxxxxxxxxxxxx111xxxxx1100011
// Jump & Link
`define JAL    32'hxxxxxxxxxxxxxxxxxxxxxxxxx1101111
`define JALR   32'hxxxxxxxxxxxxxxxxx000xxxxx1100111
// Synch
`define FENCE  32'h0000xxxxxxxx00000000000000001111
`define FENCEI 32'h00000000000000000001000000001111
// CSR Access
`define CSRRW  32'hxxxxxxxxxxxxxxxxx001xxxxx1110011
`define CSRRS  32'hxxxxxxxxxxxxxxxxx010xxxxx1110011
`define CSRRC  32'hxxxxxxxxxxxxxxxxx011xxxxx1110011
`define CSRRWI 32'hxxxxxxxxxxxxxxxxx101xxxxx1110011
`define CSRRSI 32'hxxxxxxxxxxxxxxxxx110xxxxx1110011
`define CSRRCI 32'hxxxxxxxxxxxxxxxxx111xxxxx1110011
// Change Level
`define ECALL  32'h00000000000000000000000001110011
`define EBREAK 32'h00000000000100000000000001110011
`define ERET   32'h00010000000000000000000001110011
`define WFI    32'h00010000001000000000000001110011
// No Operation
`define NOP    32'h00000000000000000000000000010011
