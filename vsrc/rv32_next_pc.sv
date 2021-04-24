`timescale 1ns/1ps
module rv32_next_pc import rv32_pkg::*;import pito_pkg::*;(
    input  irq_evt_t          csr_irq_evt,
    input  rv32_register_t    rv32_alu_res,
    input  rv32_register_t    rv32_rs1,
    input  rv32_imm_t         rv32_imm,         // decoded immediate value
    input  rv32_opcode_enum_t rv32_instr_opcode,// decoded instruction
    input  rv32_pc_cnt_t      rv32_cur_pc,      // current PC counter
    output logic              rv32_save_pc,     // indicates if pc needs to be saved in RF
    output logic              rv32_has_new_pc,  // indicates if the pc has a new value (other than pc+4 )
    output rv32_register_t    rv32_reg_pc,      // pc val to save in RF
    output rv32_pc_cnt_t      rv32_next_pc_val  // calculated pc
);

    rv32_pc_cnt_t      rv32_next_pc;
    logic              rv32_new_pc;

    always_comb begin
        case (rv32_instr_opcode)
            rv32_pkg::RV32_AUIPC: begin
                // rv32_next_pc_val = rv32_cur_pc + rv32_imm; 
                rv32_reg_pc      = rv32_cur_pc + rv32_imm;
                rv32_new_pc      = 1'b0; 
                rv32_next_pc     = 0;
            end
            rv32_pkg::RV32_BEQ ,
            rv32_pkg::RV32_BNE ,
            rv32_pkg::RV32_BLT ,
            rv32_pkg::RV32_BGE ,
            rv32_pkg::RV32_BLTU,
            rv32_pkg::RV32_BGEU : begin
                rv32_next_pc     = (rv32_alu_res == 1) ? rv32_cur_pc + (rv32_imm<<1) : rv32_cur_pc; 
                rv32_new_pc      = (rv32_alu_res == 1) ? 1'b1 : 1'b0; 
            end
            rv32_pkg::RV32_JAL  : begin 
                rv32_next_pc     = rv32_cur_pc + (rv32_imm<<1); 
                rv32_reg_pc      = rv32_cur_pc + 4; 
                rv32_new_pc      = 1'b1; 
            end
            rv32_pkg::RV32_JALR : begin 
                rv32_next_pc     = rv32_rs1 + rv32_imm; 
                rv32_reg_pc      = rv32_cur_pc + 4; 
                rv32_new_pc      = 1'b1; 
            end
            rv32_pkg::RV32_MRET : begin
                rv32_next_pc     = csr_irq_evt.data;
                rv32_new_pc      = 1'b1; 
            end
            default : begin
                rv32_reg_pc      = 0;
                rv32_next_pc     = rv32_cur_pc;
                rv32_new_pc      = 1'b0; 
            end
        endcase
    end
    assign rv32_next_pc_val = (csr_irq_evt.valid) ? csr_irq_evt.data : rv32_next_pc;
    assign rv32_has_new_pc  = (csr_irq_evt.valid) ? 1'b1 : rv32_new_pc;
    assign rv32_save_pc = (rv32_has_new_pc && ((rv32_instr_opcode == rv32_pkg::RV32_JAL) || (rv32_instr_opcode == rv32_pkg::RV32_JALR))) || (rv32_instr_opcode == rv32_pkg::RV32_AUIPC) ? 1'b1 : 1'b0;

endmodule