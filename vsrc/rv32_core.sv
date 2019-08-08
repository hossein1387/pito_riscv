module core (
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

// PC source select
logic pc_sel;

// register file wires
rv_regfile_addr_t rv32_regf_ra1;
rv_register_t     rv32_regf_rd1;
rv_regfile_addr_t rv32_regf_rd2;
rv_register_t     rv32_regf_rd2;
logic             rv32_regf_wen;
rv_regfile_addr_t rv32_regf_wa ;
rv_regfile_addr_t rv32_regf_wd ;

// decoder wires
rv_register_t       rv32_rs1;
rv_register_t       rv32_rs2;
rv_register_t       rv32_rd;
rv_shamt_t          rv32_shamt;
rv_imm_t            rv32_imm;
logic[3:0]          rv32_fence_succ;
logic[3:0]          rv32_fence_pred;
rv_csr_t            rv32_csr;
rv_zimm_t           rv32_zimm;
rv32_opcode_enum_t  rv32_opcode;
rv32_type_enum_t    rv32_imm_decoded_type;
logic               rv32_instr_trap;

// raw un-decoded rv32 instruction
rv32_instr_t      rv32_instr;

//====================================================================
//                   Module instansiation
//====================================================================
rv32_regfile regfile(
                        .clk(clk     ),
                        .ra1(rv32_regf_ra1),
                        .rd1(rv32_regf_rd1),
                        .ra2(rv32_regf_ra2),
                        .rd2(rv32_regf_rd2),
                        .wen(rv32_regf_wen),
                        .wa (rv32_regf_wa ),
                        .wd (rv32_regf_wd )
                    );

rv32_decoder decoder (
                        .clk                (clk                  ),
                        .instr              (rv32_instr           ),
                        .pc                 (rv32_pc              ),
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
//====================================================================
//                   Fetch stage
//====================================================================

    assign rv32_plus_4_pc = rv32_plus_4_pc + 4;
    assign rv32_i_addr    = rv32_pc;
    assign rv32_instr     = rv32_i_data;
// pipeline
    always @(posedge clk) begin
        rv32_pc        <= (pc_sel == 0) ? rv32_plus_4_pc : rv32_execute_pc;
    end

//====================================================================
//                   Decode stage
//====================================================================

    always @(posedge clk) begin
        rv32_decode_pc <= rv32_pc;
    end

endmodule