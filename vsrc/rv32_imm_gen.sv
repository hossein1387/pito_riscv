`include "rv32_defines.svh"
// `include "rv32_types.svh"

`timescale 1 ps / 1 ps

module rv32_imm_gen (
    // input  logic    rv_instr,    // riscv 32 instruction
    input  
    logic [`XPR_LEN-1 : 0 ] rv_instr, // input instruction
    output logic [`XPR_LEN-1 : 0 ] rv_imm       // riscv 32 decoded immediate
);


    always_comb begin
        case (rv_instr[6:0])
            //RV32_TYPE_I:
             7'b1100111,
             7'b0000011,
             7'b0010011,
             7'b0001111 : rv_imm = { {20{rv_instr[31]}}, rv_instr[31:20]}; 
             7'b1110011 : rv_imm = { {27{rv_instr[19]}}, rv_instr[19:15]}; // CSRXI
             //RV32_TYPE_S
             7'b0100011 : rv_imm = { {20{rv_instr[31]}}, rv_instr[31:25], rv_instr[11:7]};
             //RV32_TYPE_B
             7'b1100011 : rv_imm = { {20{rv_instr[31]}}, rv_instr[31], rv_instr[7], rv_instr[30:25], rv_instr[11:8]};
             //RV32_TYPE_U
             7'b0110111,
             7'b0010111 : rv_imm = rv_instr[31:12] <<< 12;
             //RV32_TYPE_J
             7'b1101111 : rv_imm = { {12{rv_instr[31]}}, rv_instr[31], rv_instr[19:12], rv_instr[20], rv_instr[30:21]};
             default    : rv_imm = { {20{rv_instr[31]}}, rv_instr[31:20]};
        endcase
    end
endmodule