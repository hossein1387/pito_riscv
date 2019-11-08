`timescale 1 ps / 1 ps

module rv32_core (
`ifdef DEBUG
    output rv32_opcode_enum_t rv32_dec_opcode,
    output rv_pc_cnt_t        rv32_dec_pc,
`endif
    input  logic              rv32_io_clk,    // Clock
    input  logic              rv32_io_rst_n,  // Asynchronous reset active low
    input  rv_imem_addr_t     rv32_io_imem_addr,
    input  rv32_instr_t       rv32_io_imem_data,
    input  rv_dmem_addr_t     rv32_io_dmem_addr,
    input  rv32_data_t        rv32_io_dmem_data,
    input  logic              rv32_io_imem_w_en,
    input  logic              rv32_io_dmem_w_en,
    input  logic              rv32_io_program
);

//====================================================================
// General Wires and registers
//====================================================================

// General signals
logic              clk;
logic              rst_n;
rv_pc_cnt_t        rv32_pc;

// raw un-decoded rv32 instruction
rv32_instr_t        rv32_instr;

//====================================================================
// DEC stage wires
//====================================================================
// Register file wires
rv_regfile_addr_t rv32_regf_ra1;
rv_register_t     rv32_regf_rd1;
rv_regfile_addr_t rv32_regf_ra2;
rv_register_t     rv32_regf_rd2;
logic             rv32_regf_wen;
rv_regfile_addr_t rv32_regf_wa ;
rv_register_t     rv32_regf_wd ;

// decoder wires
`ifndef DEBUG
rv_pc_cnt_t        rv32_dec_pc;
`endif
rv_register_t      rv32_dec_rs1;
rv_register_t      rv32_dec_rd;
rv_register_t      rv32_dec_rs2;
rv_shamt_t         rv32_dec_shamt;
rv_imm_t           rv32_dec_imm;
logic[3:0]         rv32_dec_fence_succ;
logic[3:0]         rv32_dec_fence_pred;
rv_csr_t           rv32_dec_csr;
rv_zimm_t          rv32_dec_zimm;
rv32_type_enum_t   rv32_dec_inst_type;
logic              rv32_dec_instr_trap;
rv_alu_op_t        rv32_dec_alu_op;
`ifndef DEBUG
rv32_opcode_enum_t rv32_dec_opcode;
`endif

//====================================================================
// EX stage wires
//====================================================================
// alu wires
rv_register_t      rv32_alu_rs1;
rv_register_t      rv32_alu_rs2;
rv_register_t      rv32_ex_rd;
rv_register_t      rv32_alu_res;
rv_alu_op_t        rv32_alu_op;
logic              rv32_alu_z;
rv32_type_enum_t   rv32_ex_inst_type;
rv32_opcode_enum_t rv32_ex_opcode;
rv_pc_cnt_t        rv32_ex_pc;

//====================================================================
// WB stage wires
//====================================================================
rv32_opcode_enum_t rv32_wb_opcode;
rv_register_t      rv32_wb_rd;
rv_register_t      rv32_wb_out;
rv_register_t      rv32_wb_rs2_skip;
rv32_type_enum_t   rv32_wb_inst_type;
rv_pc_cnt_t        rv32_wb_pc;

//====================================================================
// WF stage wires
//====================================================================
// write regfile stage
rv32_opcode_enum_t rv32_wf_opcode;
rv_pc_cnt_t        rv32_wf_pc;
// Control Signals
logic pc_sel;
logic alu_src;
logic wb_skip;

// Instruction Memory signals
// The rest are control by io and internal lofgic
rv_dmem_addr_t  rv32_i_addr;

// Data Memory control
rv_dmem_addr_t rv32_dmem_addr_ctrl;
rv32_data_t    rv32_dmem_data_ctrl;
logic          rv32_dmem_w_en_ctrl;

// Data Memory signals
rv_dmem_addr_t  rv32_dw_addr;
rv32_data_t     rv32_dw_data;
logic           rv32_dw_en  ;
rv_dmem_addr_t  rv32_dr_addr;
rv32_data_t     rv32_dr_data;

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

bram16k i_mem(
                        .clock     (clk               ),
                        .data      (rv32_io_imem_data ),
                        .rdaddress (rv32_i_addr       ),
                        .wraddress (rv32_io_imem_addr ),
                        .wren      (rv32_io_imem_w_en ),
                        .q         (rv32_instr        )
    );

assign rv32_dw_addr = (rv32_io_program) ? rv32_io_dmem_addr : rv32_dmem_addr_ctrl;
assign rv32_dw_data = (rv32_io_program) ? rv32_io_dmem_data : rv32_dmem_data_ctrl;
assign rv32_dw_en   = (rv32_io_program) ? rv32_io_dmem_w_en : rv32_dmem_w_en_ctrl;

bram16k d_mem(
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
            rv32_dec_pc <= rv32_pc;
        end
    end
//====================================================================
//                   Execute Stage
//====================================================================
    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_ex_pc <= 0;
        end else begin
            // rv32_regf_wen    <= 1'b0;
            rv32_ex_opcode   <= rv32_dec_opcode;
            rv32_ex_inst_type<= rv32_dec_inst_type;
            if (rv32_dec_opcode != RV32_NOP) begin
                rv32_alu_op      <= rv32_dec_alu_op;
                rv32_alu_rs1     <= rv32_regf_rd1;
                rv32_wb_rs2_skip <= rv32_regf_rd2;
                rv32_ex_rd       <= rv32_dec_rd;
                if (alu_src == 0 ) begin
                    rv32_alu_rs2 <= rv32_regf_rd2;
                end else begin
                    if ((rv32_dec_alu_op == `ALU_SLL ) || (rv32_dec_alu_op == `ALU_SRL ) || (rv32_dec_alu_op == `ALU_SRA )) begin
                        rv32_alu_rs2 <= {27'b0, rv32_dec_shamt};
                    end else begin
                        rv32_alu_rs2 <= rv32_dec_imm;
                    end
                end
                // Compute the next PC
                rv32_ex_pc   <= rv32_dec_pc + rv32_dec_imm - 4 ;
                wb_skip      <= ~((rv32_dec_opcode == RV32_SB) || (rv32_dec_opcode == RV32_SH) || (rv32_dec_opcode == RV32_SW));
            end else begin
                rv32_ex_pc   <= rv32_dec_pc;
            end
        end
    end

//====================================================================
//                   Write Back Stage
//====================================================================

    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_wb_pc <= 0;
        end else begin
            rv32_wb_pc       <= rv32_ex_pc;
            rv32_wb_opcode   <= rv32_ex_opcode;
            rv32_wb_inst_type<= rv32_ex_inst_type;
            if (rv32_ex_opcode != RV32_NOP) begin
                rv32_wb_rd       <= rv32_ex_rd;
                if (wb_skip) begin
                    rv32_wb_out <= rv32_alu_res;
                end else begin
                    if ((rv32_ex_opcode == RV32_LB ) ||
                        (rv32_ex_opcode == RV32_LH ) ||
                        (rv32_ex_opcode == RV32_LW ) ||
                        (rv32_ex_opcode == RV32_LBU) ) begin
                        rv32_dr_addr <= rv32_alu_res;
                    end else begin
                        rv32_dmem_addr_ctrl <= rv32_alu_res;
                        rv32_dmem_data_ctrl <= rv32_wb_rs2_skip;
                        rv32_dmem_w_en_ctrl <= 1'b1;
                    end
                end
            end
        end
    end
//====================================================================
//                   RegFile Write Stage
//====================================================================

    always @(posedge clk) begin
        if(rv32_io_rst_n == 1'b0) begin
            rv32_regf_wa <= 0;
            rv32_wf_pc   <= 0;
            pc_sel       <= `PITO_PC_SEL_PLUS_4;
        end else begin
            rv32_wf_pc          <= rv32_wb_pc;
            rv32_wf_opcode      <= rv32_wb_opcode;
            rv32_dmem_w_en_ctrl <= 1'b0;
            if (rv32_wb_opcode != RV32_NOP) begin
                //                     == RV32_TYPE_B
                if ((rv32_wb_inst_type == RV32_TYPE_R) ||
                    (rv32_wb_inst_type == RV32_TYPE_I) ||
                    (rv32_wb_inst_type == RV32_TYPE_U) ) begin
                    rv32_regf_wa <= rv32_wb_rd;
                    if (rv32_wb_inst_type == RV32_TYPE_I) begin
                        rv32_regf_wd <= rv32_dr_data;
                    end else begin
                        rv32_regf_wd <= rv32_wb_out;
                    end
                    pc_sel <= `PITO_PC_SEL_PLUS_4;
                end else if (rv32_wb_inst_type == RV32_TYPE_J) begin
                    rv32_regf_wd <= rv32_wb_pc + 4;
                    pc_sel       <= `PITO_PC_SEL_COMPUTED;
                    rv32_regf_wa <= rv32_wb_rd;
                end
            end else begin
                pc_sel <= `PITO_PC_SEL_PLUS_4;
            end
        end
    end

    assign rv32_regf_wen = 1'b1;

endmodule