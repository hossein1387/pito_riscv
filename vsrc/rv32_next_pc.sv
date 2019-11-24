`timescale 1 ps / 1 ps

module rv32_next_pc (
    input  rv32_register_t    rv32_alu_res,
    input  rv32_register_t    rv32_rs1,
    input  rv32_imm_t         rv32_imm,
    input  rv32_opcode_enum_t rv32_instr_opcode,
    input  rv32_pc_cnt_t      rv32_cur_pc,
    output logic              rv32_save_pc,    // indicates if pc needs to be saved in RF
    output logic              rv32_has_new_pc, // indicates if the pc has a new value (other than pc+4 )
    output rv32_register_t    rv32_reg_pc,     // pc val to save in RF
    output rv32_pc_cnt_t      rv32_next_pc_val // calculated pc
);

    assign rv32_has_new_pc = ((rv32_instr_opcode == RV32_AUIPC) ||
                              (rv32_instr_opcode == RV32_BEQ  ) ||
                              (rv32_instr_opcode == RV32_BNE  ) ||
                              (rv32_instr_opcode == RV32_BLT  ) ||
                              (rv32_instr_opcode == RV32_BGE  ) ||
                              (rv32_instr_opcode == RV32_BLTU ) ||
                              (rv32_instr_opcode == RV32_BGEU ) ||
                              (rv32_instr_opcode == RV32_JAL  ) ||
                              (rv32_instr_opcode == RV32_JALR ) );

    always_comb begin
        if (rv32_has_new_pc) begin
            case (rv32_instr_opcode)
                RV32_AUIPC: rv32_next_pc_val = rv32_cur_pc + rv32_imm; 
                RV32_BEQ , RV32_BNE , RV32_BLT , RV32_BGE , RV32_BLTU, RV32_BGEU : rv32_next_pc_val = (rv32_alu_res == 1) ? rv32_cur_pc + rv32_imm : rv32_cur_pc; 
                RV32_JAL  : begin rv32_next_pc_val = rv32_cur_pc + rv32_imm; rv32_reg_pc = rv32_cur_pc + 4; end
                RV32_JALR : begin rv32_next_pc_val = rv32_rs1 + rv32_imm; rv32_reg_pc = rv32_cur_pc + 4; end
                default : rv32_next_pc_val = rv32_cur_pc;
            endcase
        end else begin
            rv32_next_pc_val = rv32_cur_pc;
        end
    end

    assign rv32_save_pc = (rv32_has_new_pc && ((rv32_instr_opcode == RV32_JAL) || (rv32_instr_opcode == RV32_JALR))) ? 1'b1 : 1'b0;

endmodule