`timescale 1 ps / 1 ps

module rv32_core (
    input  logic              rv32_io_clk,    // Clock
    input  logic              rv32_io_rst_n,  // Synchronous reset active low
    input  rv32_imem_addr_t   rv32_io_imem_addr,
    input  rv32_instr_t       rv32_io_imem_data,
    input  rv32_dmem_addr_t   rv32_io_dmem_addr,
    input  rv32_data_t        rv32_io_dmem_data,
    input  logic              rv32_io_imem_w_en,
    input  logic              rv32_io_dmem_w_en,
    input  logic              rv32_io_program
);

//====================================================================
// General Wires and registers
//====================================================================

`ifdef DEBUG
// Captureing original pc counter witout altering during pc related 
// instructions
rv32_pc_cnt_t        rv32_org_ex_pc;
rv32_pc_cnt_t        rv32_org_wb_pc;
rv32_pc_cnt_t        rv32_org_wf_pc;
rv32_pc_cnt_t        rv32_org_cap_pc;

rv32_register_t     rv32_wb_alu_rs1;
rv32_register_t     rv32_wb_alu_rs2;
rv32_register_t     rv32_wf_alu_rs1;
rv32_register_t     rv32_wf_alu_rs2;
rv32_register_t     rv32_cap_alu_rs1;
rv32_register_t     rv32_cap_alu_rs2;
`endif
// General signals
logic              clk;
logic              rst_n;
rv32_pc_cnt_t      rv32_pc;

// raw un-decoded rv32 instruction
rv32_instr_t        rv32_instr;
rv32_instr_t        rv32_dec_instr;
rv32_instr_t        rv32_ex_instr;
rv32_instr_t        rv32_wb_instr;
rv32_instr_t        rv32_wf_instr;

//====================================================================
// DEC stage wires
//====================================================================
// Register file wires
rv32_regfile_addr_t rv32_regf_ra1;
rv32_register_t     rv32_regf_rd1;
rv32_regfile_addr_t rv32_regf_ra2;
rv32_register_t     rv32_regf_rd2;
logic               rv32_regf_wen;
rv32_regfile_addr_t rv32_regf_wa ;
rv32_register_t     rv32_regf_wd ;

// decoder wires
rv32_pc_cnt_t      rv32_dec_pc;
rv32_register_t    rv32_dec_rs1;
rv32_register_t    rv32_dec_rd;
rv32_register_t    rv32_dec_rs2;
rv32_shamt_t       rv32_dec_shamt;
rv32_imm_t         rv32_dec_imm;
logic[3:0]         rv32_dec_fence_succ;
logic[3:0]         rv32_dec_fence_pred;
rv32_csr_t         rv32_dec_csr;
rv32_zimm_t        rv32_dec_zimm;
rv32_type_enum_t   rv32_dec_inst_type;
logic              rv32_dec_instr_trap;
rv32_alu_op_t      rv32_dec_alu_op;
rv32_opcode_enum_t rv32_dec_opcode;

//====================================================================
// EX stage wires
//====================================================================
// alu wires
rv32_register_t    rv32_alu_rs1;
rv32_register_t    rv32_alu_rs2;
rv32_register_t    rv32_ex_rd;
rv32_register_t    rv32_ex_rs1;
rv32_register_t    rv32_alu_res;
rv32_alu_op_t      rv32_alu_op;
logic              rv32_alu_z;
rv32_type_enum_t   rv32_ex_inst_type;
rv32_opcode_enum_t rv32_ex_opcode;
rv32_pc_cnt_t      rv32_ex_pc;
rv32_imm_t         rv32_ex_imm;

//====================================================================
// WB stage wires
//====================================================================
rv32_opcode_enum_t rv32_wb_opcode;
rv32_register_t    rv32_wb_rd;
rv32_register_t    rv32_wb_rs1;
rv32_register_t    rv32_wb_out;
rv32_register_t    rv32_wb_rs2_skip;
rv32_type_enum_t   rv32_wb_inst_type;
rv32_pc_cnt_t      rv32_wb_pc;
rv32_imm_t         rv32_wb_imm;
logic              rv32_wb_save_pc;
logic              rv32_wb_has_new_pc;
logic              rv32_wb_skip;
rv32_register_t    rv32_wb_reg_pc;
rv32_pc_cnt_t      rv32_wb_next_pc_val;

//====================================================================
// WF stage wires
//====================================================================
// write regfile stage
rv32_opcode_enum_t rv32_wf_opcode;
rv32_pc_cnt_t      rv32_wf_pc;
logic              rv32_wf_skip;
// Control Signals
logic pc_sel;
logic alu_src;
logic is_csr;
logic is_exception;
logic is_store;
// Instruction Memory signals
// The rest are control by io and internal lofgic
rv32_imem_addr_t  rv32_i_addr;

// Data Memory control
rv32_dmem_addr_t rv32_dmem_addr;
rv32_data_t      rv32_dmem_data;
logic            rv32_dmem_w_en;

// Data Memory signals
rv32_dmem_addr_t rv32_dw_addr;
rv32_data_t      rv32_dw_data;
logic            rv32_dw_en  ;
rv32_dmem_addr_t rv32_dr_addr;
rv32_data_t      rv32_dr_data;

// connect io clock and reset to internal logic
assign clk   = rv32_io_clk;
assign rst_n = rv32_io_rst_n;

//====================================================================
//                   Module instansiation
//====================================================================

rv32_regfile regfile(
                        .clk(clk              ),
                        .ra1(rv32_dec_rs1[4:0]),
                        .rd1(rv32_regf_rd1    ),
                        .ra2(rv32_dec_rs2[4:0]),
                        .rd2(rv32_regf_rd2    ),
                        .wen(rv32_regf_wen    ),
                        .wa (rv32_regf_wa     ),
                        .wd (rv32_regf_wd     )
                    );

rv32_decoder decoder (
                        .instr         (rv32_instr         ),
                        .rv_rs1        (rv32_dec_rs1       ),
                        .rv_rs2        (rv32_dec_rs2       ),
                        .rv_rd         (rv32_dec_rd        ),
                        .rv_shamt      (rv32_dec_shamt     ),
                        .rv_imm        (rv32_dec_imm       ),
                        .rv_alu_op     (rv32_dec_alu_op    ),
                        .rv_fence_succ (rv32_dec_fence_succ),
                        .rv_fence_pred (rv32_dec_fence_pred),
                        .rv_csr        (rv32_dec_csr       ),
                        .rv_zimm       (rv32_dec_zimm      ),
                        .rv_opcode     (rv32_dec_opcode    ),
                        .rv_inst_type  (rv32_dec_inst_type ),
                        .instr_trap    (rv32_dec_instr_trap)
);

rv32_alu alu (
                        .rs1       (rv32_alu_rs1),
                        .rs2       (rv32_alu_rs2),
                        .alu_opcode(rv32_alu_op ),
                        .res       (rv32_alu_res),
                        .z         (rv32_alu_z  )
);

rv32_next_pc rv32_next_pc_cal(
                        .rv32_alu_res     (rv32_wb_out         ),
                        .rv32_rs1         (rv32_wb_rs1         ),
                        .rv32_imm         (rv32_wb_imm         ),
                        .rv32_instr_opcode(rv32_wb_opcode      ),
                        .rv32_cur_pc      (rv32_wb_pc          ),
                        .rv32_save_pc     (rv32_wb_save_pc     ),
                        .rv32_has_new_pc  (rv32_wb_has_new_pc  ),
                        .rv32_reg_pc      (rv32_wb_reg_pc      ),
                        .rv32_next_pc_val (rv32_wb_next_pc_val )
);

// pito uses seperate memory for instructions and data.
// The instruction memory can be written to from io ports
// The data memory can be read from internal logic but can
// be written by io or internal logic. To program the data
// one should use rv32_io_program signal so that the write 
// control signals can be passed to io ports. Note, for 
// instruction  memory, one can program (write into) 
// instruction memory  just by using rv32_io_imem_w_en since 
// all the write  operations are done by io ports and all 
// the reads are done by internal logic.

rv32_instruction_memory i_mem(
                        .clock     (clk               ),
                        .data      (rv32_io_imem_data ),
                        .rdaddress (rv32_i_addr       ),
                        .wraddress (rv32_io_imem_addr ),
                        .wren      (rv32_io_imem_w_en ),
                        .q         (rv32_instr        )
    );

assign rv32_dw_addr = (rv32_io_program) ? rv32_io_dmem_addr : rv32_dmem_addr;
assign rv32_dw_data = (rv32_io_program) ? rv32_io_dmem_data : rv32_dmem_data;
assign rv32_dw_en   = (rv32_io_program) ? rv32_io_dmem_w_en : rv32_dmem_w_en;

rv32_data_memory d_mem(
                        .clock     (clk         ),
                        .data      (rv32_dw_data),
                        .rdaddress (rv32_dr_addr),
                        .wraddress (rv32_dw_addr),
                        .wren      (rv32_dw_en  ),
                        .q         (rv32_dr_data)
    );

//====================================================================
//                   Fetch Stage
//====================================================================
// pipeline
    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_pc         <= `RESET_ADDRESS;
        end else begin
            // rv32_pc is the main program counter. Depending on the executed instruction
            // it can be either PC+4 or, in branch and jump instruction, comming from
            // instruction decoding. This decision is represented by pc_sel. Initially at 
            // reset, we set the pc_sel to PITO_PC_SEL_PLUS_4 so that the pc counter starts
            // executing instruction from memory.
            if (rv32_pc == `RESET_ADDRESS) begin
                rv32_pc <= 0;
            end else begin
                if (pc_sel == `PITO_PC_SEL_PLUS_4) begin
                    rv32_pc <= rv32_pc + 4;
                end else begin
                    rv32_pc <= rv32_wf_pc;
                end
            end
        end
    end

assign rv32_i_addr = rv32_pc>>2; // for now, we access 32 bit at a time

//====================================================================
//                   Decode Stage
//====================================================================

    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_dec_pc <= 0;
        end else begin
            rv32_dec_pc    <= rv32_pc;
            rv32_dec_instr <= rv32_instr;
        end
    end
//====================================================================
//                   Execute Stage
//====================================================================
    // assign rv32_ex_is_exception = ((rv32_dec_opcode == RV32_ECALL) || (rv32_dec_opcode == RV32_EBREAK)) ? 1'b1 : 1'b0;
    // assign rv32_ex_is_csr       = ((rv32_dec_opcode == RV32_CSRRW ) || (rv32_dec_opcode==RV32_CSRRS ) || (rv32_dec_opcode==RV32_CSRRC ) ||
    //                                (rv32_dec_opcode == RV32_CSRRWI) || (rv32_dec_opcode==RV32_CSRRSI) || (rv32_dec_opcode==RV32_CSRRCI)) ? 1'b1 : 1'b0;
    // assign rv32_ex_skip         = rv32_ex_is_exception || rv32_ex_is_csr || (rv32_dec_opcode==RV32_NOP);

    assign alu_src   = ((rv32_dec_opcode == RV32_SRL ) || (rv32_dec_opcode == RV32_SRA  ) || (rv32_dec_opcode == RV32_ADD ) ||
                        (rv32_dec_opcode == RV32_XOR ) || (rv32_dec_opcode == RV32_OR   ) || (rv32_dec_opcode == RV32_AND ) ||
                        (rv32_dec_opcode == RV32_SLT ) || (rv32_dec_opcode == RV32_SLTU ) || (rv32_dec_opcode == RV32_SLL ) ||
                        (rv32_dec_opcode == RV32_BEQ ) || (rv32_dec_opcode == RV32_BNE  ) || (rv32_dec_opcode == RV32_BLT ) ||
                        (rv32_dec_opcode == RV32_BGE ) || (rv32_dec_opcode == RV32_BLTU ) || (rv32_dec_opcode == RV32_BGEU) ||
                        (rv32_dec_opcode == RV32_SUB ) ) ? `PITO_ALU_SRC_RS2 : `PITO_ALU_SRC_IMM ;
    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_ex_pc    <= 0;
            rv32_dec_instr<= {32{1'b0}};
        end else begin
            // rv32_regf_wen    <= 1'b0;
            rv32_ex_opcode    <= rv32_dec_opcode;
            rv32_ex_inst_type <= rv32_dec_inst_type;
            rv32_ex_instr     <= rv32_dec_instr;
            rv32_ex_imm       <= rv32_dec_imm;
            rv32_ex_pc        <= rv32_dec_pc;
            rv32_ex_rs1       <= rv32_dec_rs1; // copy for auipc calculation in wf stage
            if (rv32_dec_opcode != RV32_NOP) begin
                rv32_alu_op      <= rv32_dec_alu_op;
                rv32_alu_rs1     <= rv32_regf_rd1;
                rv32_wb_rs2_skip <= rv32_regf_rd2;
                rv32_ex_rd       <= rv32_dec_rd;
                if (alu_src == `PITO_ALU_SRC_RS2 ) begin
                    rv32_alu_rs2 <= rv32_regf_rd2;
                end else begin
                    if ((rv32_dec_alu_op == `ALU_SLL ) || (rv32_dec_alu_op == `ALU_SRL ) || (rv32_dec_alu_op == `ALU_SRA )) begin
                        rv32_alu_rs2 <= {27'b0, rv32_dec_shamt};
                    end else begin
                        rv32_alu_rs2 <= rv32_dec_imm;
                    end
                end
            end else begin
                rv32_ex_pc   <= rv32_dec_pc;
            end
            `ifdef DEBUG
                rv32_org_ex_pc <= rv32_dec_pc;
            `endif
        end
    end

//====================================================================
//                   Write Back Stage
//====================================================================
    assign is_exception = ((rv32_ex_opcode == RV32_ECALL) || (rv32_ex_opcode == RV32_EBREAK)) ? 1'b1 : 1'b0;
    assign is_csr       = ((rv32_ex_opcode == RV32_CSRRW ) || (rv32_ex_opcode==RV32_CSRRS ) || (rv32_ex_opcode==RV32_CSRRC ) ||
                           (rv32_ex_opcode == RV32_CSRRWI) || (rv32_ex_opcode==RV32_CSRRSI) || (rv32_ex_opcode==RV32_CSRRCI)) ? 1'b1 : 1'b0;
// The following circuit decides whether the write back to memory should
// be skipped or not. The write back stage should be skipped only when the 
// instruction is of type: NOT store
    assign rv32_wb_skip = ((rv32_ex_opcode == RV32_SB) || (rv32_ex_opcode == RV32_SH) || (rv32_ex_opcode == RV32_SW)) ? 1'b0 : 1'b1;

    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_wb_pc   <= 0;
            rv32_wb_instr<= {32{1'b0}};
        end else begin
            rv32_wb_pc       <= rv32_ex_pc;
            rv32_wb_opcode   <= rv32_ex_opcode;
            rv32_wb_inst_type<= rv32_ex_inst_type;
            rv32_wb_instr    <= rv32_ex_instr;
            rv32_wb_imm      <= rv32_ex_imm;
            rv32_wb_rs1      <= rv32_ex_rs1;
            rv32_wb_rd       <= rv32_ex_rd;
            rv32_dmem_w_en   <= 1'b0;
            if (rv32_ex_opcode != RV32_NOP ) begin
                if (rv32_wb_skip) begin
                    rv32_wb_out <= rv32_alu_res;
                end else begin
                    if ((rv32_ex_opcode == RV32_LB ) ||
                        (rv32_ex_opcode == RV32_LH ) ||
                        (rv32_ex_opcode == RV32_LW ) ||
                        (rv32_ex_opcode == RV32_LBU) ) begin
                        rv32_dr_addr   <= rv32_alu_res;
                    end else begin
                        rv32_dmem_addr <= rv32_alu_res;
                        rv32_dmem_data <= rv32_wb_rs2_skip;
                        rv32_dmem_w_en <= 1'b1; 
                    end
                end
            end
            `ifdef DEBUG
                rv32_org_wb_pc <= rv32_org_ex_pc;
                rv32_wb_alu_rs1<= rv32_alu_rs1;
                rv32_wb_alu_rs2<= rv32_alu_rs2;
            `endif
        end
    end
//====================================================================
//                   RegFile Write Stage
//====================================================================

    assign rv32_wf_skip = ((rv32_wb_opcode == RV32_BEQ ) || (rv32_wb_opcode == RV32_BNE ) || (rv32_wb_opcode == RV32_BLT ) || 
                           (rv32_wb_opcode == RV32_BGE ) || (rv32_wb_opcode == RV32_BLTU) || (rv32_wb_opcode == RV32_BGEU) ||
                           (rv32_wb_opcode == RV32_SB  ) || (rv32_wb_opcode == RV32_SH  ) || (rv32_wb_opcode == RV32_SW  )) ? 1'b1 : 1'b0;
    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_regf_wa <= 0;
            rv32_wf_pc   <= 0;
            pc_sel       <= `PITO_PC_SEL_PLUS_4;
            rv32_wf_instr<= {32{1'b0}};
        end else begin
            rv32_wf_opcode      <= rv32_wb_opcode;
            rv32_wf_instr       <= rv32_wb_instr;
            if (rv32_wb_opcode != RV32_NOP) begin
                //=================================================================================
                // Register File
                //=================================================================================
                // Decide if we need to write anything to RF. This is decided by rv32_wf_skip signal.
                // Most instructions (except the one in rv32_wf_skip) have to write results to RF.
                // They can be devided into these three types:
                // 1- Immediates: Only LUI instruction is in this cat. Load Immediate to RF.
                // 2- Return Add: For JAL and JALR, we need to save the return address into RF.
                // 3- ALU Res: For all other types, store ALU output to the RF.
                if (!rv32_wf_skip) begin
                    rv32_regf_wa <= rv32_wb_rd;
                    if (rv32_wb_opcode == RV32_LUI) begin // 1- Immediates: Load Upper Immediate to RF
                        rv32_regf_wd <= rv32_wb_imm;
                    end else if (rv32_wb_save_pc) begin // 2- Return Add: PC has to be written to RF
                        rv32_regf_wd <= rv32_wb_reg_pc;
                    end else begin // 3- ALU Res: All other instructions except rv32_wf_skip have to write ALU res into RF 
                        rv32_regf_wd <= rv32_wb_out;
                    end
                end
                //=================================================================================
                // Next PC Counter
                //=================================================================================
                // Decide if we need to update PC or not. Upto this point, we have been pipelining 
                // the PC. For jump and branch instructions, we need to update the PC. For other 
                // instructions, we need to use the current (in Fetch stage) PC + 4. The rv32_next_pc_cal 
                // has already calculated the next PC value. With rv32_wb_has_new_pc we know if we 
                // need to use the calculated PC counter or just the current (in Fetch stage) PC + 4.
                if (rv32_wb_has_new_pc) begin
                    pc_sel     <= `PITO_PC_SEL_COMPUTED;
                    rv32_wf_pc <= rv32_wb_next_pc_val;
                end else begin
                    pc_sel     <= `PITO_PC_SEL_PLUS_4;
                    rv32_wf_pc <= rv32_wb_pc;
                end
            end else begin
                pc_sel     <= `PITO_PC_SEL_PLUS_4;
                rv32_wf_pc <= rv32_wb_pc;
            end
            `ifdef DEBUG
                rv32_org_wf_pc <= rv32_org_wb_pc;
                rv32_wf_alu_rs1<= rv32_wb_alu_rs1;
                rv32_wf_alu_rs2<= rv32_wb_alu_rs2;
            `endif
        end
    end

    assign rv32_regf_wen = 1'b1;


//====================================================================
// Capture Stage
//====================================================================
`ifdef DEBUG
rv32_opcode_enum_t rv32_cap_opcode;
rv32_pc_cnt_t      rv32_cap_pc;
rv32_instr_t       rv32_cap_instr;
logic is_end;

assign is_end = (rv32_wf_opcode ==  RV32_ECALL) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_cap_pc     <= 0;
        end else begin
            rv32_cap_pc     <= rv32_wf_pc;
            rv32_cap_opcode <= rv32_wf_opcode;
            rv32_cap_instr  <= rv32_wf_instr;
            rv32_org_cap_pc <= rv32_org_wf_pc;
            rv32_cap_alu_rs1<= rv32_wf_alu_rs1;
            rv32_cap_alu_rs2<= rv32_wf_alu_rs2;
        end
    end
`endif
endmodule
