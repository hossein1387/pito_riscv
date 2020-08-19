//-------------------------------------------------------------------
//                          System Macros
//-------------------------------------------------------------------
`define DEBUG 1
`define PITO_NULL  0
`define NUM_REGS 32
`define NUM_CSR 4096
`define REG_FILE_INIT "regfile.mem"
`define CSR_FILE_INIT "csrfile.mem"
`define DECODER_FILE_INIT "decoderlut.mem"
`define NUM_MVUS 8
`define NUM_INSTR_WORDS (1024*`NUM_MVUS)
//-------------------------------------------------------------------
//                          Reset Macros
//-------------------------------------------------------------------
`define RESET_ADDRESS        32'h0000_0000
`define EOF_ADDRESS          32'hFFFF_FFFF
//-------------------------------------------------------------------
//                          pito specific consts
//-------------------------------------------------------------------
`define PITO_INSTR_MEM_SIZE  (8192)
`define PITO_INSTR_MEM_WIDTH $clog2(`PITO_INSTR_MEM_SIZE)
`define PITO_DATA_MEM_SIZE   (8192)
`define PITO_DATA_MEM_WIDTH  $clog2(`PITO_DATA_MEM_SIZE)
`define PITO_DATA_MEM_OFFSET (32'h1000_0000)
`define PITO_PC_SEL_PLUS_4   (1'b1)
`define PITO_PC_SEL_COMPUTED (1'b0)
`define PITO_ALU_SRC_RS2     (1'b1)
`define PITO_ALU_SRC_IMM     (1'b0)
`define PITO_NUM_HARTS       (`NUM_MVUS)
`define PITO_HART_CNT_WIDTH  $clog2(`PITO_NUM_HARTS)
//-------------------------------------------------------------------
//                           Width-related constants
//-------------------------------------------------------------------
`define INST_WIDTH       32
`define REG_ADDR_WIDTH   5
`define XPR_LEN          32
`define OPCODE_LEN       7
`define ALU_OPCODE_WIDTH 4
//-------------------------------------------------------------------
//                          ALU opcodes
//-------------------------------------------------------------------
// custom mapping alu opcodes

`define ALU_SLL   `ALU_OPCODE_WIDTH'd0
`define ALU_SRL   `ALU_OPCODE_WIDTH'd1
`define ALU_SRA   `ALU_OPCODE_WIDTH'd2
`define ALU_ADD   `ALU_OPCODE_WIDTH'd3
`define ALU_SUB   `ALU_OPCODE_WIDTH'd4
`define ALU_XOR   `ALU_OPCODE_WIDTH'd5
`define ALU_OR    `ALU_OPCODE_WIDTH'd6
`define ALU_AND   `ALU_OPCODE_WIDTH'd7
`define ALU_SLT   `ALU_OPCODE_WIDTH'd8
`define ALU_SLTU  `ALU_OPCODE_WIDTH'd9
`define ALU_SBT   `ALU_OPCODE_WIDTH'd10
`define ALU_SBTU  `ALU_OPCODE_WIDTH'd11
`define ALU_EQ    `ALU_OPCODE_WIDTH'd12
`define ALU_NEQ   `ALU_OPCODE_WIDTH'd13
`define ALU_NOP   `ALU_OPCODE_WIDTH'd15

//-------------------------------------------------------------------
//                          Macros
//-------------------------------------------------------------------
`define and_q(q, res)\
    begin\
        logic __tmp = 1;\
        for(int i=0; i<q.size(); i++)\
            __tmp &= q[i];\
        res = __tmp;\
    end

`define init_q(q, val)\
    begin\
        for(int i=0; i<q.size(); i++)\
            q[i] = val;\
    end

`define wait_for_all_begin(q)\
    begin\
        logic ___all_done = 0;\
        logic __tmp;\
        while(!___all_done) begin\
            ___all_done = 1;\
            `and_q(q, __tmp)\
            ___all_done &= __tmp;

`define wait_for_all_end\
        end\
    end