`timescale 1ns/1ps
`include "rv32_defines.svh"

module rv32_core import rv32_pkg::*;import pito_pkg::*; 
(
    input  logic                  clk,
    input  logic                  rst_n,
    output rv32_data_t            imem_wdata,
    input  rv32_data_t            imem_rdata,
    output rv32_imem_addr_t       imem_addr,
    output logic                  imem_req,
    output logic                  imem_we,
    output imem_be_t              imem_be,
    output rv32_data_t            dmem_wdata,
    input  rv32_data_t            dmem_rdata,
    output rv32_dmem_addr_t       dmem_addr,
    output logic                  dmem_req,
    output logic                  dmem_we,
    output dmem_be_t              dmem_be,
    input logic [NUM_HARTS-1 : 0] mvu_irq,
    APB                           mvu_apb
);

//====================================================================
// HART related signals
//====================================================================
rv32_hart_cnt_t rv32_hart_cnt;
rv32_hart_cnt_t rv32_hart_fet_cnt;
rv32_hart_cnt_t rv32_hart_dec_cnt;
rv32_hart_cnt_t rv32_hart_ex_cnt;
rv32_hart_cnt_t rv32_hart_wb_cnt;
rv32_hart_cnt_t rv32_hart_wf_cnt;

//====================================================================
// General Wires and registers
//====================================================================
// General signals
rv32_pc_cnt_t      rv32_pc [`PITO_NUM_HARTS-1 : 0];

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
rv32_pc_cnt_t       rv32_dec_pc;
rv32_register_t     rv32_dec_rs1;
rv32_register_t     rv32_dec_rd;
rv32_register_t     rv32_dec_rs2;
rv32_shamt_t        rv32_dec_shamt;
rv32_imm_t          rv32_dec_imm;
logic[3:0]          rv32_dec_fence_succ;
logic[3:0]          rv32_dec_fence_pred;
rv32_csr_t          rv32_dec_csr;
logic               rv32_dec_instr_trap;
rv32_alu_op_t       rv32_dec_alu_op;
rv32_opcode_enum_t  rv32_dec_opcode;
rv32_register_t     rv32_dec_rd1;
rv32_register_t     rv32_dec_rd2;

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
rv32_opcode_enum_t rv32_ex_opcode;
rv32_pc_cnt_t      rv32_ex_pc;
rv32_imm_t         rv32_ex_imm;
logic              rv32_ex_is_exception;
logic              rv32_ex_is_csrrw;
logic              rv32_ex_skip;
rv32_register_t    rv32_ex_rs2_skip;
rv32_register_t    rv32_ex_load_addr;

// csrs
csr_t              rv32_ex_csr_addr;
csr_op_t           rv32_ex_csr_op;
rv32_register_t    rv32_ex_csr_data;
rv32_register_t    rv32_ex_res_val;
//====================================================================
// WB stage wires
//====================================================================
rv32_opcode_enum_t rv32_wb_opcode;
rv32_register_t    rv32_wb_rd;
rv32_register_t    rv32_wb_rs1;
rv32_register_t    rv32_wb_out;
rv32_pc_cnt_t      rv32_wb_pc;
rv32_imm_t         rv32_wb_imm;
logic              rv32_wb_save_pc;
logic              rv32_wb_has_new_pc;
logic              rv32_wb_is_load;
rv32_register_t    rv32_wb_reg_pc;
rv32_pc_cnt_t      rv32_wb_next_pc_val;
rv32_data_t        rv32_wb_store_val;
dmem_be_t          rv32_wb_dmem_be;
rv32_dmem_addr_t   rv32_wb_dmem_addr;
//====================================================================
// WF stage wires
//====================================================================
// write regfile stage
rv32_pc_cnt_t      rv32_org_wf_pc;
rv32_opcode_enum_t rv32_wf_opcode;
rv32_pc_cnt_t      rv32_wf_pc[`PITO_NUM_HARTS-1 : 0];
logic              rv32_wf_skip;
logic              rv32_wf_is_load;
rv32_data_t        rv32_wf_load_val;
// Control Signals
logic pc_sel[`PITO_NUM_HARTS-1 : 0];
logic alu_src;
logic is_csrrw;
logic is_exception;
logic is_store;
logic is_load;
// Instruction Memory signals
// The rest are control by io and internal lofgic
rv32_imem_addr_t  rv32_i_addr;

// Data Memory control
rv32_dmem_addr_t rv32_dmem_addr;
rv32_data_t      rv32_dmem_data;
logic            rv32_dmem_w_en;
rv32_dmem_addr_t rv32_ex_dmem_addr;
// Data Memory signals
logic [`XPR_LEN-1 : 0 ] rv32_dr_data;
//====================================================================
//                   Module instansiation
//====================================================================

rv32_barrel_regfiles regfile(
                        .clk     (clk              ),
                        .rsa_hart(rv32_hart_dec_cnt),
                        .rsd_hart(rv32_hart_dec_cnt),
                        .rd_hart (rv32_hart_wf_cnt ),
                        .ra1     (rv32_dec_rs1[4:0]),
                        .rd1     (rv32_regf_rd1    ),
                        .ra2     (rv32_dec_rs2[4:0]),
                        .rd2     (rv32_regf_rd2    ),
                        .wen     (rv32_regf_wen    ),
                        .wa      (rv32_regf_wa     ),
                        .wd      (rv32_regf_wd     )
                    );

rv32_decoder decoder (
                        .instr         (rv32_instr         ),
                        .rv_rs1        (rv32_dec_rs1       ),
                        .rv_rs2        (rv32_dec_rs2       ),
                        .rv_rd         (rv32_dec_rd        ),
                        .rv_shamt      (rv32_dec_shamt     ),
                        .rv_imm        (rv32_dec_imm       ),
                        .rv_alu_op     (rv32_dec_alu_op    ),
                        .rv_opcode     (rv32_dec_opcode    ),
                        .instr_trap    (rv32_dec_instr_trap)
);

rv32_alu alu (
                        .rs1       (rv32_alu_rs1),
                        .rs2       (rv32_alu_rs2),
                        .alu_opcode(rv32_alu_op ),
                        .res       (rv32_alu_res),
                        .z         (rv32_alu_z  )
);

logic [31 : 0] csr_rdata, csr_ex_rdata;
logic          csr_irq;
logic          csr_timer_irq;
logic          csr_ipi_irq;
logic[32*`PITO_NUM_HARTS-1 :0] csr_boot_addr;
// logic          csr_mvu_irq;
exception_t    csr_exception;
logic [31:0]   csr_cause;
logic          csr_enable_cycle_count;

irq_evt_t [`PITO_NUM_HARTS-1:0] csr_irq_evt;

assign csr_enable_cycle_count = 1'b1;
// For now, we will tie these interrupts to ground since no
// application needs them at the moment.
assign csr_irq                = 1'b0;
assign csr_timer_irq          = 1'b0;
assign csr_ipi_irq            = 1'b0;
assign csr_cause              = 1'b0;

genvar hart_cnt_gen_var;

for (hart_cnt_gen_var = 0; hart_cnt_gen_var < `PITO_NUM_HARTS; hart_cnt_gen_var++) begin
    assign csr_boot_addr[hart_cnt_gen_var*32 +: 32] = 32'b0;
end

rv32_barrel_csrfiles csr(
                    .clk                (clk                        ),
                    .rst_n              (rst_n                      ),
                    .csr_addr           (rv32_ex_csr_addr           ),
                    .csr_wdata          (rv32_ex_csr_data           ),
                    .csr_op             (rv32_ex_csr_op             ),
                    .csr_rdata          (csr_rdata                  ),
                    .irq                (csr_irq                    ),
                    .time_irq           (csr_timer_irq              ),
                    .ipi                (csr_ipi_irq                ),
                    .boot_addr          (csr_boot_addr              ),
                    .mvu_irq            (mvu_csr_if.mvu_irq_i       ),
                    .csr_exception      (csr_exception              ),
                    .apb                (mvu_apb                    ),
                    .pc                 (rv32_pc                    ),
                    .cause              (csr_cause                  ),
                    .enable_cycle_count (csr_enable_cycle_count     ),
                    .csr_irq_evt        (csr_irq_evt                ),
                    .hart_id_i          (rv32_hart_dec_cnt          )
);


rv32_next_pc rv32_next_pc_cal(
                        .csr_irq_evt      (csr_irq_evt[rv32_hart_wb_cnt]    ),
                        .rv32_alu_res     (rv32_wb_out                      ),
                        .rv32_rs1         (rv32_wb_rs1                      ),
                        .rv32_imm         (rv32_wb_imm                      ),
                        .rv32_instr_opcode(rv32_wb_opcode                   ),
                        .rv32_cur_pc      (rv32_wb_pc                       ),
                        .rv32_save_pc     (rv32_wb_save_pc                  ),
                        .rv32_has_new_pc  (rv32_wb_has_new_pc               ),
                        .rv32_reg_pc      (rv32_wb_reg_pc                   ),
                        .rv32_next_pc_val (rv32_wb_next_pc_val              )
);

// pito uses seperate memory for instructions and data.
// The instruction memory can be written to from io ports
// The data memory can be read from internal logic but can
// be written by io or internal logic. To program the data
// one should use inf.pito_io_program signal so that the write 
// control signals can be passed to io ports. Note, for 
// instruction  memory, one can program (write into) 
// instruction memory  just by using inf.pito_io_imem_w_en since 
// all the write  operations are done by io ports and all 
// the reads are done by internal logic.
// for now, we access 32 bit at a time

// Dual port SRAM memory for instruction Cache. Port 0 is used for I/O
// and port 1 is used for local interface.

assign imem_wdata= 32'hDEAD_BEEF;
assign imem_addr = rv32_i_addr;
assign rv32_instr= imem_rdata;
assign imem_req  = 1'b1;
assign imem_be   = 4'b1111;
assign imem_we   = 1'b0;

assign dmem_wdata        = rv32_dmem_data;
assign dmem_we           = rv32_dmem_w_en;
assign dmem_addr         = rv32_dmem_addr;
assign rv32_dr_data      = dmem_rdata;
// assign dmem_req          = 1'b1;
// assign dmem_be           = 4'b1111;

//====================================================================
//                   Barreled HART counter
//====================================================================
// A strict round robin scheduler for implementing barreling
    always @(posedge clk) begin
        if(rst_n == 1'b0) begin
            rv32_hart_cnt <= 0;
        end else begin
             rv32_hart_cnt <= rv32_hart_cnt + 1;
        end
    end
//====================================================================
//                   Fetch Stage
//====================================================================
    always @(posedge clk) begin
        if(rst_n == 1'b0) begin
            for (int i = 0; i < `PITO_NUM_HARTS; i++) begin
                rv32_pc[i]  <= `EOF_ADDRESS;
            end
        end else begin
            rv32_hart_fet_cnt <= rv32_hart_cnt;
            // rv32_pc is the main program counter. Depending on the executed instruction
            // it can be either PC+4 or, in branch and jump instruction, comming from
            // instruction decoding. This decision is represented by pc_sel. Initially at 
            // reset, we set the pc_sel to PITO_PC_SEL_PLUS_4 so that the pc counter starts
            // executing instruction from memory.
            if (rv32_pc[rv32_hart_cnt] == `EOF_ADDRESS) begin
                rv32_pc[rv32_hart_cnt] <= `RESET_ADDRESS; //rv32_hart_cnt << 12;
                // rv32_pc[rv32_hart_cnt] <= `RESET_ADDRESS + rv32_hart_cnt << 12;
            end else begin
                if (pc_sel[rv32_hart_cnt] == `PITO_PC_SEL_PLUS_4) begin
                    rv32_pc[rv32_hart_cnt] <= rv32_pc[rv32_hart_cnt] + 4;
                end else begin
                    rv32_pc[rv32_hart_cnt] <= rv32_wf_pc[rv32_hart_cnt];
                end
            end
        end
    end

assign rv32_i_addr = rv32_pc[rv32_hart_fet_cnt] >> 2; // for now, we access 32 bit at a time

//====================================================================
//                   Decode Stage
//====================================================================
    // Decoder samples instruction right from the memory (no registering)
    assign rv32_dec_instr = rv32_instr;
    always @(posedge clk) begin
        // if(rst_n == 1'b0) begin
        //     rv32_dec_pc <= 0;
        // end else begin
            rv32_dec_pc       <= rv32_pc[rv32_hart_fet_cnt];
            rv32_hart_dec_cnt <= rv32_hart_fet_cnt;
            rv32_dec_rd1      <= rv32_regf_rd1;
            rv32_dec_rd2      <= rv32_regf_rd2;
        // end
    end
//====================================================================
//                   Execute Stage
//====================================================================
    assign rv32_ex_is_exception = ((rv32_dec_opcode == rv32_pkg::RV32_ECALL) || (rv32_dec_opcode == rv32_pkg::RV32_EBREAK)) ? 1'b1 : 1'b0;
    assign rv32_ex_is_csrrw     = ((rv32_dec_opcode == rv32_pkg::RV32_CSRRW ) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRS ) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRC ) ||
                                   (rv32_dec_opcode == rv32_pkg::RV32_CSRRWI) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRSI) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRCI)) ? 1'b1 : 1'b0;
    assign rv32_ex_skip         = rv32_ex_is_exception || rv32_ex_is_csrrw || (rv32_dec_opcode==rv32_pkg::RV32_NOP);


//==================
// CSR:
//==================

    assign rv32_ex_csr_addr     = pito_pkg::csr_t'(rv32_dec_instr[31:20]);
    assign rv32_ex_csr_data     = ((rv32_dec_opcode == rv32_pkg::RV32_CSRRWI) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRSI) || (rv32_dec_opcode==rv32_pkg::RV32_CSRRCI)) ?
                                    rv32_dec_imm : rv32_regf_rd1;

    always_comb begin
        case (rv32_dec_opcode)
             rv32_pkg::RV32_CSRRW  : rv32_ex_csr_op = pito_pkg::CSR_READ_WRITE;
             rv32_pkg::RV32_CSRRS  : rv32_ex_csr_op = pito_pkg::CSR_SET;
             rv32_pkg::RV32_CSRRC  : rv32_ex_csr_op = pito_pkg::CSR_CLEAR;
             rv32_pkg::RV32_CSRRWI : rv32_ex_csr_op = pito_pkg::CSR_READ_WRITE;
             rv32_pkg::RV32_CSRRSI : rv32_ex_csr_op = pito_pkg::CSR_SET;
             rv32_pkg::RV32_CSRRCI : rv32_ex_csr_op = pito_pkg::CSR_CLEAR;
             rv32_pkg::RV32_MRET   : rv32_ex_csr_op = pito_pkg::MRET;
             default : rv32_ex_csr_op = pito_pkg::CSR_UNKNOWN;
        endcase
    end

//==================
// ALU:
//==================

    assign alu_src   = ((rv32_dec_opcode == rv32_pkg::RV32_SRL ) || (rv32_dec_opcode == rv32_pkg::RV32_SRA  ) || (rv32_dec_opcode == rv32_pkg::RV32_ADD ) ||
                        (rv32_dec_opcode == rv32_pkg::RV32_XOR ) || (rv32_dec_opcode == rv32_pkg::RV32_OR   ) || (rv32_dec_opcode == rv32_pkg::RV32_AND ) ||
                        (rv32_dec_opcode == rv32_pkg::RV32_SLT ) || (rv32_dec_opcode == rv32_pkg::RV32_SLTU ) || (rv32_dec_opcode == rv32_pkg::RV32_SLL ) ||
                        (rv32_dec_opcode == rv32_pkg::RV32_BEQ ) || (rv32_dec_opcode == rv32_pkg::RV32_BNE  ) || (rv32_dec_opcode == rv32_pkg::RV32_BLT ) ||
                        (rv32_dec_opcode == rv32_pkg::RV32_BGE ) || (rv32_dec_opcode == rv32_pkg::RV32_BLTU ) || (rv32_dec_opcode == rv32_pkg::RV32_BGEU) ||
                        (rv32_dec_opcode == rv32_pkg::RV32_SUB ) ) ? `PITO_ALU_SRC_RS2 : `PITO_ALU_SRC_IMM ;
    always @(posedge clk) begin
        rv32_ex_opcode   <= rv32_dec_opcode;
        rv32_ex_instr    <= rv32_dec_instr;
        rv32_ex_imm      <= rv32_dec_imm;
        rv32_ex_pc       <= rv32_dec_pc;
        rv32_ex_rs1      <= rv32_regf_rd1; // copy for auipc calculation in wf stage
        rv32_hart_ex_cnt <= rv32_hart_dec_cnt;
        rv32_alu_op      <= rv32_dec_alu_op;
        rv32_alu_rs1     <= rv32_regf_rd1;
        rv32_ex_rs2_skip <= rv32_regf_rd2;
        rv32_ex_rd       <= rv32_dec_rd;
        csr_ex_rdata     <= csr_rdata;
        if ((rv32_dec_opcode == rv32_pkg::RV32_LB ) ||
            (rv32_dec_opcode == rv32_pkg::RV32_LH ) ||
            (rv32_dec_opcode == rv32_pkg::RV32_LW ) ||
            (rv32_dec_opcode == rv32_pkg::RV32_LBU) ||
            (rv32_dec_opcode == rv32_pkg::RV32_LHU) ) begin
            // $display($sformatf("LOAD instruction ===> Accessing mem at: %8h + %8h", rv32_dec_imm , rv32_regf_rd1));
            rv32_ex_dmem_addr <= rv32_dec_imm + rv32_regf_rd1;
        end else begin
            if (alu_src == `PITO_ALU_SRC_RS2 ) begin
                rv32_alu_rs2 <= rv32_regf_rd2;
            end else begin
                if ((rv32_dec_alu_op == `ALU_SLL ) || (rv32_dec_alu_op == `ALU_SRL ) || (rv32_dec_alu_op == `ALU_SRA )) begin
                    rv32_alu_rs2 <= {27'b0, rv32_dec_shamt};
                end else begin
                    rv32_alu_rs2 <= rv32_dec_imm;
                end
            end
        end
    end

//====================================================================
//                   Write Back Stage
//====================================================================
    assign is_exception = ((rv32_ex_opcode == rv32_pkg::RV32_ECALL) || (rv32_ex_opcode == rv32_pkg::RV32_EBREAK)) ? 1'b1 : 1'b0;
    assign is_csrrw     = ((rv32_ex_opcode == rv32_pkg::RV32_CSRRW ) || (rv32_ex_opcode==rv32_pkg::RV32_CSRRS ) || (rv32_ex_opcode==rv32_pkg::RV32_CSRRC ) ||
                           (rv32_ex_opcode == rv32_pkg::RV32_CSRRWI) || (rv32_ex_opcode==rv32_pkg::RV32_CSRRSI) || (rv32_ex_opcode==rv32_pkg::RV32_CSRRCI)) ? 1'b1 : 1'b0;
    assign rv32_ex_res_val = (is_csrrw == 1'b1) ? csr_ex_rdata : rv32_alu_res;
// The following circuit decides whether the write back to memory should
// be skipped or not. The write back stage should be skipped only when the 
// instruction is of type: NOT store
    assign is_store = ((rv32_ex_opcode == rv32_pkg::RV32_SB) || (rv32_ex_opcode == rv32_pkg::RV32_SH) || (rv32_ex_opcode == rv32_pkg::RV32_SW) ) ? 1'b1 : 1'b0;
    assign is_load = ((rv32_ex_opcode == rv32_pkg::RV32_LB) || (rv32_ex_opcode == rv32_pkg::RV32_LH) || (rv32_ex_opcode == rv32_pkg::RV32_LW) ||
                      (rv32_ex_opcode == rv32_pkg::RV32_LBU)|| (rv32_ex_opcode == rv32_pkg::RV32_LHU)) ? 1'b1 : 1'b0;

    // Data memory is word accessed. In the path to register file, 
    // the circuit below takes the correct value from the ram output.
    always_comb begin
        // Prepare store value
        if (is_load) begin
            rv32_dmem_w_en = 1'b0;
            dmem_req       = 1'b1;
            rv32_dmem_addr = rv32_ex_dmem_addr;
        end else if (is_store) begin
            case (rv32_ex_opcode)
                rv32_pkg::RV32_SB : begin
                rv32_wb_store_val = { {24{rv32_ex_rs2_skip[7 ]}}, rv32_ex_rs2_skip[7 : 0]};
                case (rv32_alu_res[1:0])
                    2'b00: begin
                        rv32_wb_dmem_be = 4'b0001;
                        rv32_wb_store_val = { {24{rv32_ex_rs2_skip[7 ]}}, rv32_ex_rs2_skip[7 : 0]};
                    end
                    2'b01: begin
                        rv32_wb_dmem_be = 4'b0010;
                        rv32_wb_store_val = { {16{rv32_ex_rs2_skip[7 ]}}, rv32_ex_rs2_skip[7 : 0], {8{1'b0}} };
                    end
                    2'b10: begin
                        rv32_wb_dmem_be = 4'b0100;
                        rv32_wb_store_val = { {8{rv32_ex_rs2_skip[7 ]}}, rv32_ex_rs2_skip[7 : 0], {16{1'b0}} };
                    end
                    2'b11: begin
                        rv32_wb_dmem_be = 4'b1000;
                        rv32_wb_store_val = { rv32_ex_rs2_skip[7 : 0], {24{1'b0}} };
                    end
                endcase
                end
                rv32_pkg::RV32_SH : begin
                case (rv32_alu_res[1])
                    0: begin
                        rv32_wb_dmem_be = 4'b0011;
                        rv32_wb_store_val = { {16{rv32_ex_rs2_skip[15]}}, rv32_ex_rs2_skip[15: 0]};
                    end
                    1: begin
                        rv32_wb_dmem_be = 4'b1100;
                        rv32_wb_store_val = { rv32_ex_rs2_skip[15: 0],  {16{1'b0}}};
                    end
                endcase
                end
                rv32_pkg::RV32_SW : begin
                    rv32_wb_store_val = rv32_ex_rs2_skip;
                    rv32_wb_dmem_be = 4'b1111;
                end
                default : begin
                    rv32_wb_store_val = {32{1'b0}};
                    rv32_wb_dmem_be = 4'b1111;
                end
            endcase
            rv32_dmem_addr = rv32_alu_res;
            rv32_dmem_data = rv32_wb_store_val;
            rv32_dmem_w_en = 1'b1; 
            dmem_req       = 1'b1;
            dmem_be        = rv32_wb_dmem_be;
        end else begin
            rv32_dmem_w_en = 1'b0; 
            dmem_req       = 1'b0;
        end
    end

    always @(posedge clk) begin
        rv32_wb_pc        <= rv32_ex_pc;
        rv32_wb_opcode    <= rv32_ex_opcode;
        rv32_wb_instr     <= rv32_ex_instr;
        rv32_wb_imm       <= rv32_ex_imm;
        rv32_wb_rs1       <= rv32_ex_rs1;
        rv32_wb_rd        <= rv32_ex_rd;
        rv32_hart_wb_cnt  <= rv32_hart_ex_cnt;
        rv32_wb_is_load   <= is_load;
        rv32_wb_dmem_addr <= rv32_dmem_addr; // For loads, need to store it for next stage
        rv32_wb_out       <= rv32_ex_res_val;
    end

//====================================================================
//                   RegFile Write Stage
//====================================================================

    assign rv32_wf_skip = ((rv32_wb_opcode == rv32_pkg::RV32_BEQ ) || (rv32_wb_opcode == rv32_pkg::RV32_BNE ) || (rv32_wb_opcode == rv32_pkg::RV32_BLT ) || 
                           (rv32_wb_opcode == rv32_pkg::RV32_BGE ) || (rv32_wb_opcode == rv32_pkg::RV32_BLTU) || (rv32_wb_opcode == rv32_pkg::RV32_BGEU) ||
                           (rv32_wb_opcode == rv32_pkg::RV32_SB  ) || (rv32_wb_opcode == rv32_pkg::RV32_SH  ) || (rv32_wb_opcode == rv32_pkg::RV32_SW  )) ? 1'b1 : 1'b0;
    assign rv32_wf_is_load = ((rv32_wb_opcode == rv32_pkg::RV32_LB) || (rv32_wb_opcode == rv32_pkg::RV32_LH) || (rv32_wb_opcode == rv32_pkg::RV32_LW) ||
                              (rv32_wb_opcode == rv32_pkg::RV32_LBU)|| (rv32_wb_opcode == rv32_pkg::RV32_LHU)) ? 1'b1 : 1'b0;
    // Memory is byte addressed but Data memory is word accessed. 
    // In the path to register file, the circuit below takes the correct 
    // value from the ram output. 
    always_comb begin
        case (rv32_wb_opcode)
             rv32_pkg::RV32_LB : begin
                        case (rv32_wb_dmem_addr[1:0])
                            2'b00: rv32_wf_load_val = { {24{rv32_dr_data[7 ]}}, rv32_dr_data[7 : 0]};
                            2'b01: rv32_wf_load_val = { {24{rv32_dr_data[15]}}, rv32_dr_data[15: 8]};
                            2'b10: rv32_wf_load_val = { {24{rv32_dr_data[23]}}, rv32_dr_data[23:16]};
                            2'b11: rv32_wf_load_val = { {24{rv32_dr_data[31]}}, rv32_dr_data[31:24]};
                            default : rv32_wf_load_val = 0;
                        endcase
                       end
             rv32_pkg::RV32_LH :  begin
                        case (rv32_wb_dmem_addr[1:0])
                            2'b00: rv32_wf_load_val = { {16{rv32_dr_data[15]}}, rv32_dr_data[15: 0]};
                            2'b10: rv32_wf_load_val = { {16{rv32_dr_data[31]}}, rv32_dr_data[31:16]};
                            default : rv32_wf_load_val = 0;
                        endcase
                       end
             rv32_pkg::RV32_LW : rv32_wf_load_val = rv32_dr_data;
             rv32_pkg::RV32_LBU: begin
                        case (rv32_wb_dmem_addr[1:0])
                            2'b00: rv32_wf_load_val = { {24{1'b0}}, rv32_dr_data[7 : 0]};
                            2'b01: rv32_wf_load_val = { {24{1'b0}}, rv32_dr_data[15: 8]};
                            2'b10: rv32_wf_load_val = { {24{1'b0}}, rv32_dr_data[23:16]};
                            2'b11: rv32_wf_load_val = { {24{1'b0}}, rv32_dr_data[31:24]};
                            default : rv32_wf_load_val = 0;
                        endcase
                       end
             rv32_pkg::RV32_LHU: begin
                        case (rv32_wb_dmem_addr[1:0])
                            2'b00: rv32_wf_load_val = { {16{1'b0}}, rv32_dr_data[15: 0]};
                            2'b10: rv32_wf_load_val = { {16{1'b0}}, rv32_dr_data[31:16]};
                            default : rv32_wf_load_val = 0;
                        endcase
                       end
             default : rv32_wf_load_val = {32{1'b0}};
        endcase
    end

    always @(posedge clk) begin
        rv32_wf_opcode    <= rv32_wb_opcode;
        rv32_wf_instr     <= rv32_wb_instr;
        rv32_hart_wf_cnt  <= rv32_hart_wb_cnt;
        rv32_regf_wen     <= 1'b0;
        //=================================================================================
        // Register File
        //=================================================================================
        // Decide if we need to write anything to RF. This is decided by rv32_wf_skip signal.
        // Most instructions (except the one in rv32_wf_skip) have to write results to RF.
        // They can be devided into these four types:
        // 1- Immediates: Only LUI instruction is in this cat. Load Immediate to RF.
        // 2- Return Add: For JAL and JALR, we need to save the return address into RF.
        // 3- Load operation: All load operations will write to RF.
        // 4- ALU Res: For all other types, store ALU output to the RF.
        if (!rv32_wf_skip) begin
            rv32_regf_wa <= rv32_wb_rd;
            rv32_regf_wen<= 1'b1;
            if (rv32_wb_opcode == rv32_pkg::RV32_LUI) begin // 1- Immediates: Load Upper Immediate to RF
                rv32_regf_wd <= rv32_wb_imm;
            end else if (rv32_wb_save_pc) begin // 2- Return Add: PC has to be written to RF
                rv32_regf_wd <= rv32_wb_reg_pc;
            end else if (rv32_wb_is_load) begin // 3- Load operation: All load operations will write to RF.
                rv32_regf_wd <= rv32_wf_load_val;
            end else begin // 4- ALU Res: All other instructions except rv32_wf_skip have to write ALU res into RF 
                rv32_regf_wd <= rv32_wb_out;
            end
        end else begin
            rv32_regf_wa <= 0;
            rv32_regf_wd <= 0;
        end
        //=================================================================================
        // Next PC Counter
        //=================================================================================
        // Decide if we need to update PC or not. Upto this point, we have been pipelining 
        // the PC. For jump, branch and mret instructions, we need to update the PC. For other 
        // instructions, we need to use the current (in Fetch stage) PC + 4. The rv32_next_pc_cal 
        // contains the calculated next PC value. With rv32_wb_has_new_pc we know if we 
        // need to use the calculated PC counter or just the current (in Fetch stage) PC + 4.
        if (rv32_wb_has_new_pc) begin
            pc_sel[rv32_hart_wb_cnt]     <= `PITO_PC_SEL_COMPUTED;
            rv32_wf_pc[rv32_hart_wb_cnt] <= rv32_wb_next_pc_val;
        end else begin
            pc_sel[rv32_hart_wb_cnt]     <= `PITO_PC_SEL_PLUS_4;
            rv32_wf_pc[rv32_hart_wb_cnt] <= rv32_wb_pc;
        end
        rv32_org_wf_pc <= rv32_wb_pc;
    end

    // assign rv32_regf_wen = 1'b1;

endmodule
