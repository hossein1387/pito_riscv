// `include "rv32_defines.svh"

typedef logic [`XPR_LEN-1     : 0 ] rv_pc_cnt_t;
typedef logic [4              : 0 ] rv_register_t;
typedef logic [`ALU_OP_WIDTH-1: 0 ] alu_opcode_t;
typedef logic [`XPR_LEN-1     : 0 ] rv_imm_t;
typedef logic [2              : 0 ] fnct3_t;
typedef logic [6              : 0 ] fnct7_t;
typedef logic [`OPCODE_LEN-1  : 0 ] rv_opcode_t;
typedef logic [12             : 0 ] rv_csr_t;
typedef logic [4              : 0 ] rv_zimm_t;
typedef logic [4              : 0 ] rv_shamt_t;


//-------------------------------------------------------------------
//                          RV32 Insrtuction Types Decoding
//-------------------------------------------------------------------

typedef struct packed {
    fnct7_t       funct7;
    rv_register_t rs2;   
    rv_register_t rs1;   
    fnct3_t       funct3;
    rv_register_t rd;    
    rv_opcode_t   opcode;
} rv32_type_r_t;

typedef struct packed {
    logic [11:0]  imm;
    rv_register_t rs1;
    fnct3_t       funct3;
    rv_register_t rd;
    rv_opcode_t   opcode;
} rv32_type_i_t;

typedef struct packed {
    logic [6:0]   imm_u;
    rv_register_t rs2;
    rv_register_t rs1;
    fnct3_t       funct3;
    logic [4:0]   imm_l;
    rv_opcode_t   opcode;
} rv32_type_s_t;

typedef struct packed {
    logic [0:0]   imm12;
    logic [5:0]   immu;
    rv_register_t rs2;
    rv_register_t rs1;
    fnct3_t       funct3;
    logic [3:0]   imm_l;
    logic [0:0]   imm_11;
    rv_opcode_t   opcode;
} rv32_type_b_t;

typedef struct packed {
    logic [19:0]  imm;
    rv_register_t rd;
    rv_opcode_t   opcode;
} rv32_type_u_t;

typedef struct packed {
    logic [0:0]   imm20;
    logic [9:0]   imm_10_1;
    logic [0:0]   imm11;
    logic [7:0]   imm_19_12;
    rv_register_t rd;
    rv_opcode_t   opcode;
} rv32_type_j_t;

typedef struct packed {
    logic [24:0]  rst_instr;
    rv_opcode_t   opcode;
} rv32_dec_op_t;


typedef union packed {
    logic [`XPR_LEN-1:0] rv32_instr;
    rv32_dec_op_t        rv32_dec_op;
    rv32_type_r_t        rv32_type_r;
    rv32_type_i_t        rv32_type_i;
    rv32_type_s_t        rv32_type_s;
    rv32_type_b_t        rv32_type_b;
    rv32_type_u_t        rv32_type_u;
    rv32_type_j_t        rv32_type_j;
} rv32_instr_t;


//-------------------------------------------------------------------
//                     RV32 Insrtuction Format Mapping
//-------------------------------------------------------------------
typedef enum {
    RV32_TYPE_R       = {26'b0, 6'b100000},
    RV32_TYPE_I       = {26'b0, 6'b010000},
    RV32_TYPE_S       = {26'b0, 6'b001000},
    RV32_TYPE_B       = {26'b0, 6'b000100},
    RV32_TYPE_U       = {26'b0, 6'b000010},
    RV32_TYPE_J       = {26'b0, 6'b000001},
    RV32_TYPE_UNKNOWN = {26'b0, 6'b111111}
} rv32_type_enum_t;


//-------------------------------------------------------------------
//             RV32 Insrtuction Opcodes Custom Mapping
//-------------------------------------------------------------------
typedef enum {
        RV32_LB     = {26'b0, 6'b000000},
        RV32_LH     = {26'b0, 6'b000001},
        RV32_LW     = {26'b0, 6'b000010},
        RV32_LBU    = {26'b0, 6'b000011},
        RV32_LHU    = {26'b0, 6'b000100},
        RV32_SB     = {26'b0, 6'b000101},
        RV32_SH     = {26'b0, 6'b000110},
        RV32_SW     = {26'b0, 6'b000111},
        RV32_SLL    = {26'b0, 6'b001000},
        RV32_SLLI   = {26'b0, 6'b001001},
        RV32_SRL    = {26'b0, 6'b001010},
        RV32_SRLI   = {26'b0, 6'b001011},
        RV32_SRA    = {26'b0, 6'b001100},
        RV32_SRAI   = {26'b0, 6'b001101},
        RV32_ADD    = {26'b0, 6'b001110},
        RV32_ADDI   = {26'b0, 6'b001111},
        RV32_SUB    = {26'b0, 6'b010000},
        RV32_LUI    = {26'b0, 6'b010001},
        RV32_AUIPC  = {26'b0, 6'b010010},
        RV32_XOR    = {26'b0, 6'b010011},
        RV32_XORI   = {26'b0, 6'b010100},
        RV32_OR     = {26'b0, 6'b010101},
        RV32_ORI    = {26'b0, 6'b010110},
        RV32_AND    = {26'b0, 6'b010111},
        RV32_ANDI   = {26'b0, 6'b011000},
        RV32_SLT    = {26'b0, 6'b011001},
        RV32_SLTI   = {26'b0, 6'b011010},
        RV32_SLTU   = {26'b0, 6'b011011},
        RV32_SLTIU  = {26'b0, 6'b011100},
        RV32_BEQ    = {26'b0, 6'b011101},
        RV32_BNE    = {26'b0, 6'b011110},
        RV32_BLT    = {26'b0, 6'b011111},
        RV32_BGE    = {26'b0, 6'b100000},
        RV32_BLTU   = {26'b0, 6'b100001},
        RV32_BGEU   = {26'b0, 6'b100010},
        RV32_JAL    = {26'b0, 6'b100011},
        RV32_JALR   = {26'b0, 6'b100100},
        RV32_FENCE  = {26'b0, 6'b100101},
        RV32_FENCEI = {26'b0, 6'b100110},
        RV32_CSRRW  = {26'b0, 6'b100111},
        RV32_CSRRS  = {26'b0, 6'b101000},
        RV32_CSRRC  = {26'b0, 6'b101001},
        RV32_CSRRWI = {26'b0, 6'b101010},
        RV32_CSRRSI = {26'b0, 6'b101011},
        RV32_CSRRCI = {26'b0, 6'b101100},
        RV32_ECALL  = {26'b0, 6'b101101},
        RV32_EBREAK = {26'b0, 6'b101110},
        RV32_ERET   = {26'b0, 6'b101111},
        RV32_WFI    = {26'b0, 6'b110000},
        RV32_NOP    = {26'b0, 6'b110001},
        RV32_UNKNOWN= {26'b0, 6'b111111}
    } rv32_opcode_enum_t;





