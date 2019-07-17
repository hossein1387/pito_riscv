
typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
} riscv_type_r_t;

typedef struct packed {
    logic [11:0] imm;
    logic [ 4:0] rs1;
    logic [ 2:0] funct3;
    logic [ 4:0] rd;
    logic [ 6:0] opcode;
} riscv_type_i_t;

typedef struct packed {
    logic [6:0] imm_u;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] imm_l;
    logic [6:0] opcode;
} riscv_type_s_t;

typedef struct packed {
    logic [0:0] imm12;
    logic [5:0] immu;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [3:0] imm_l;
    logic [0:0] imm_11;
    logic [6:0] opcode;
} riscv_type_b_t;

typedef struct packed {
    logic [19:0] imm;
    logic [ 4:0] rd;
    logic [ 6:0] opcode;
} riscv_type_u_t;

typedef struct packed {
    logic [0:0] imm20;
    logic [9:0] imm_10_1;
    logic [0:0] imm11;
    logic [7:0] imm_19_12;
    logic [4:0] rd;
    logic [6:0] opcode;
} riscv_type_j_t;


typedef union packed {
    logic [31:0] riscv_instr;
    logic [31:0] riscv_type_r_t
    logic [31:0] riscv_type_i_t
    logic [31:0] riscv_type_s_t
    logic [31:0] riscv_type_b_t
    logic [31:0] riscv_type_u_t
    logic [31:0] riscv_type_j_t
} riscv_instr_t;