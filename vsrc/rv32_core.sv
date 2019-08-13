module rv32_core (
    input  rv32_clk,    // Clock
    input  rv32_rst_n,  // Asynchronous reset active low
    input  rv32_i_data,
    output rv32_i_addr,
    input  rv32_d_data,
    output rv32_d_addr,
    output rv32_o_data,
    output rv32_wr_en,
    output rv32_rd_en
);

//====================================================================
// General Wires and registers
//====================================================================

logic [`XPR_LEN-1 : 0] rv32_pc;
logic [`XPR_LEN-1 : 0] rv32_decode_pc;
logic [`XPR_LEN-1 : 0] rv32_execute_pc;
logic [`XPR_LEN-1 : 0] rv32_plus_4_pc;


// register file wires
rv_regfile_addr_t rv32_regf_ra1;
rv_register_t     rv32_regf_rd1;
rv_regfile_addr_t rv32_regf_rd2;
rv_register_t     rv32_regf_rd2;
logic             rv32_regf_wen;
rv_regfile_addr_t rv32_regf_wa ;
rv_regfile_addr_t rv32_regf_wd ;

// decoder wires
rv_register_t       dec_rs1;
rv_register_t       dec_rs2;
rv_register_t       dec_rd;
rv_shamt_t          dec_shamt;
rv_imm_t            dec_imm;
logic[3:0]          dec_fence_succ;
logic[3:0]          dec_fence_pred;
rv_csr_t            dec_csr;
rv_zimm_t           dec_zimm;
rv32_opcode_enum_t  dec_opcode;
rv32_type_enum_t    dec_imm_decoded_type;
logic               dec_instr_trap;

// raw un-decoded rv32 instruction
rv32_instr_t      rv32_instr;

// alu wires
rv_register_t       alu_rs1;
rv_register_t       alu_rs2;
rv_register_t       alu_res;
rv_alu_op_t         alu_op;
logic               alu_z;


// Control Signals
logic pc_sel;
logic alu_src;

//====================================================================
//                   Module instansiation
//====================================================================
rv32_regfile regfile(
                        .clk(clk          ),
                        .ra1(rv32_regf_ra1),
                        .rd1(rv32_regf_rd1),
                        .ra2(rv32_regf_ra2),
                        .rd2(rv32_regf_rd2),
                        .wen(rv32_regf_wen),
                        .wa (rv32_regf_wa ),
                        .wd (rv32_regf_wd )
                    );

rv32_decoder decoder (
                        .instr              (rv32_instr           ),
                        .rv_rs1             (rv32_rs1             ),
                        .rv_rs2             (rv32_rs2             ),
                        .rv_rd              (rv32_rd              ),
                        .rv_shamt           (rv32_shamt           ),
                        .rv_imm             (rv32_imm             ),
                        .rv_fence_succ      (rv32_fence_succ      ),
                        .rv_fence_pred      (rv32_fence_pred      ),
                        .rv_csr             (rv32_csr             ),
                        .rv_zimm            (rv32_zimm            ),
                        .rv_opcode          (rv32_opcode          ),
                        .rv_imm_decoded_type(rv32_imm_decoded_type),
                        .instr_trap         (rv32_instr_trap      )
);

rv32_alu alu (
                        .rs1       (alu_rs1),
                        .rs2       (alu_rs2),
                        .alu_opcode(alu_op ),
                        .res       (alu_res),
                        .z         (alu_z  )
);

//====================================================================
//                   Fetch stage
//====================================================================

    assign rv32_plus_4_pc = rv32_plus_4_pc + 4;
// pipeline
    always @(posedge clk) begin
        rv32_pc        <= (pc_sel == 0) ? rv32_plus_4_pc : rv32_execute_pc;
        rv32_i_addr    <= rv32_pc;
    end

//====================================================================
//                   Decode stage
//====================================================================

    always @(posedge clk) begin
        rv32_decode_pc <= rv32_pc;
        rv32_instr     <= rv32_i_data;
    end

    case (rv32_opcode)
            RV32_LB     : alu_op = `ALU_NOP;
            RV32_LH     : alu_op = `ALU_NOP;
            RV32_LW     : alu_op = `ALU_NOP;
            RV32_LBU    : alu_op = `ALU_NOP;
            RV32_LHU    : alu_op = `ALU_NOP;
            RV32_SB     : alu_op = `ALU_NOP;
            RV32_SH     : alu_op = `ALU_NOP;
            RV32_SW     : alu_op = `ALU_NOP;
            RV32_SLL    : alu_op = `ALU_NOP;
            RV32_SLLI   : alu_op = `ALU_NOP;
            RV32_SRL    : alu_op = `ALU_NOP;
            RV32_SRLI   : alu_op = `ALU_NOP;
            RV32_SRA    : alu_op = `ALU_NOP;
            RV32_SRAI   : alu_op = `ALU_NOP;
            RV32_ADD    : alu_op = `ALU_NOP;
            RV32_ADDI   : alu_op = `ALU_NOP;
            RV32_SUB    : alu_op = `ALU_NOP;
            RV32_LUI    : alu_op = `ALU_NOP;
            RV32_AUIPC  : alu_op = `ALU_NOP;
            RV32_XOR    : alu_op = `ALU_NOP;
            RV32_XORI   : alu_op = `ALU_NOP;
            RV32_OR     : alu_op = `ALU_NOP;
            RV32_ORI    : alu_op = `ALU_NOP;
            RV32_AND    : alu_op = `ALU_NOP;
            RV32_ANDI   : alu_op = `ALU_NOP;
            RV32_SLT    : alu_op = `ALU_NOP;
            RV32_SLTI   : alu_op = `ALU_NOP;
            RV32_SLTU   : alu_op = `ALU_NOP;
            RV32_SLTIU  : alu_op = `ALU_NOP;
            RV32_BEQ    : alu_op = `ALU_NOP;
            RV32_BNE    : alu_op = `ALU_NOP;
            RV32_BLT    : alu_op = `ALU_NOP;
            RV32_BGE    : alu_op = `ALU_NOP;
            RV32_BLTU   : alu_op = `ALU_NOP;
            RV32_BGEU   : alu_op = `ALU_NOP;
            RV32_JAL    : alu_op = `ALU_NOP;
            RV32_JALR   : alu_op = `ALU_NOP;
            RV32_FENCE  : alu_op = `ALU_NOP;
            RV32_FENCEI : alu_op = `ALU_NOP;
            RV32_CSRRW  : alu_op = `ALU_NOP;
            RV32_CSRRS  : alu_op = `ALU_NOP;
            RV32_CSRRC  : alu_op = `ALU_NOP;
            RV32_CSRRWI : alu_op = `ALU_NOP;
            RV32_CSRRSI : alu_op = `ALU_NOP;
            RV32_CSRRCI : alu_op = `ALU_NOP;
            RV32_ECALL  : alu_op = `ALU_NOP;
            RV32_EBREAK : alu_op = `ALU_NOP;
            RV32_ERET   : alu_op = `ALU_NOP;
            RV32_WFI    : alu_op = `ALU_NOP;
            RV32_NOP    : alu_op = `ALU_NOP;
            default     : alu_op = `ALU_NOP;
    endcase

//====================================================================
//                   Execute stage
//====================================================================
    always @(posedge clk) begin
        rv32_decode_pc <= rv32_pc;
        alu_rs1        <= rv32_regf_ra1;
        alu_rs2        <= (alu_src == 0 ) ? (rv32_regf_ra2) : rv32_imm;
        rv32_execute_pc<= rv32_decode_pc + rv32_imm<<1;
    end

endmodule