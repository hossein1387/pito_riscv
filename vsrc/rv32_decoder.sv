`timescale 1ns/1ps
// `include "rv32_types.svh"
// `include "rv32_instr.svh"
`include "rv32_defines.svh"
module rv32_decoder import rv32_pkg::*;(
    input  logic [`XPR_LEN-1          : 0 ] instr, // input instruction
    output logic [`XPR_LEN-1          : 0 ] rv_rs1,
    output logic [`XPR_LEN-1          : 0 ] rv_rs2,
    output logic [`XPR_LEN-1          : 0 ] rv_rd,
    output logic [4                   : 0 ] rv_shamt,
    output logic [`XPR_LEN-1          : 0 ] rv_imm,
    output logic [`ALU_OPCODE_WIDTH-1 : 0 ] rv_alu_op,
    // output logic[3:0]             rv_fence_succ,
    // output logic[3:0]             rv_fence_pred,
    // output rv32_csr_t             rv_csr,
    // output rv32_zimm_t            rv_zimm,
    output rv32_opcode_enum_t     rv_opcode,
    output logic                  instr_trap

);

    rv32_imm_t         rv_imm_decoded;

    // always_comb begin
    // // always @(*) begin
    //     rv_alu_op = `ALU_NOP;
    //     case (instr[6:2])
    //         5'b01101: begin // LUI
    //             rv_opcode = RV32_LUI;
    //         end
    //         5'b00101: begin // AUIPC
    //             rv_opcode = RV32_AUIPC;
    //         end
    //         5'b11011: begin // JAL
    //             rv_opcode = RV32_JAL;
    //         end
    //         5'b11001: begin // JALR
    //             if (instr[14:12] == 3'b000) begin
    //                 rv_opcode = RV32_JALR;
    //             end else begin
    //             end
    //         end
    //         5'b11000: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU
    //             case (instr[14:12])
    //                 3'b000  : begin rv_opcode = RV32_BEQ;  rv_alu_op = `ALU_EQ;   end
    //                 3'b001  : begin rv_opcode = RV32_BNE;  rv_alu_op = `ALU_NEQ;  end
    //                 3'b100  : begin rv_opcode = RV32_BLT;  rv_alu_op = `ALU_SLT;  end
    //                 3'b101  : begin rv_opcode = RV32_BGE;  rv_alu_op = `ALU_SBT;  end
    //                 3'b110  : begin rv_opcode = RV32_BLTU; rv_alu_op = `ALU_SLTU; end
    //                 3'b111  : begin rv_opcode = RV32_BGEU; rv_alu_op = `ALU_SBTU; end
    //             endcase
    //         end
    //         5'b00000: begin // LB, LH, LW, LBU, LHU
    //             case (instr[14:12])
    //                 3'b000  : begin rv_opcode = RV32_LB ; rv_alu_op = `ALU_ADD; end
    //                 3'b001  : begin rv_opcode = RV32_LH ; rv_alu_op = `ALU_ADD; end
    //                 3'b010  : begin rv_opcode = RV32_LW ; rv_alu_op = `ALU_ADD; end
    //                 3'b100  : begin rv_opcode = RV32_LBU; rv_alu_op = `ALU_ADD; end
    //                 3'b101  : begin rv_opcode = RV32_LHU; rv_alu_op = `ALU_ADD; end
    //             endcase
    //         end
    //         5'b01000: begin // SB, SH, SW
    //             case (instr[14:12])
    //                 3'b000  : begin rv_opcode = RV32_SB; rv_alu_op = `ALU_ADD; end
    //                 3'b001  : begin rv_opcode = RV32_SH; rv_alu_op = `ALU_ADD; end
    //                 3'b010  : begin rv_opcode = RV32_SW; rv_alu_op = `ALU_ADD; end
    //             endcase
    //         end
    //         5'b00100: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, NOP
    //             case ({instr[30], instr[14:12]})
    //                 4'b0000 : begin rv_opcode = RV32_ADDI;  rv_alu_op = `ALU_ADD; end
    //                 4'b0001 : begin rv_opcode = RV32_SLLI;  rv_alu_op = `ALU_SLL; end
    //                 4'b0010 : begin rv_opcode = RV32_SLTI;  rv_alu_op = `ALU_SLT; end 
    //                 4'b0011 : begin rv_opcode = RV32_SLTIU; rv_alu_op = `ALU_SLTU;end 
    //                 4'b0100 : begin rv_opcode = RV32_XORI;  rv_alu_op = `ALU_XOR; end 
    //                 4'b0101 : begin rv_opcode = RV32_SRLI;  rv_alu_op = `ALU_SRL; end 
    //                 4'b1101 : begin rv_opcode = RV32_SRAI;  rv_alu_op = `ALU_SRA; end
    //                 4'b0110 : begin rv_opcode = RV32_ORI;   rv_alu_op = `ALU_OR;  end
    //                 4'b0111 : begin rv_opcode = RV32_ANDI;  rv_alu_op = `ALU_AND; end
    //             endcase
    //         end
    //         5'b01100: begin // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
    //             case ({instr[30], instr[14:12]})
    //                 {1'b0, 3'b000} : begin rv_opcode = RV32_ADD;  rv_alu_op = `ALU_ADD; end
    //                 {1'b1, 3'b000} : begin rv_opcode = RV32_SUB;  rv_alu_op = `ALU_SUB; end
    //                 {1'b0, 3'b001} : begin rv_opcode = RV32_SLL;  rv_alu_op = `ALU_SLL; end
    //                 {1'b0, 3'b010} : begin rv_opcode = RV32_SLT;  rv_alu_op = `ALU_SLT; end
    //                 {1'b0, 3'b011} : begin rv_opcode = RV32_SLTU; rv_alu_op = `ALU_SLTU;end
    //                 {1'b0, 3'b100} : begin rv_opcode = RV32_XOR;  rv_alu_op = `ALU_XOR; end
    //                 {1'b1, 3'b101} : begin rv_opcode = RV32_SRA;  rv_alu_op = `ALU_SRA; end
    //                 {1'b0, 3'b101} : begin rv_opcode = RV32_SRL;  rv_alu_op = `ALU_SRL;end
    //                 {1'b0, 3'b110} : begin rv_opcode = RV32_OR;   rv_alu_op = `ALU_OR;  end
    //                 {1'b0, 3'b111} : begin rv_opcode = RV32_AND;  rv_alu_op = `ALU_AND; end
    //             endcase
    //         end
    //         5'b00011: begin // FENCE, FENCEI
    //             case (instr[14:12])
    //                 3'b000 :begin
    //                             rv_opcode = RV32_FENCE;
    //                             // rv_fence_succ = instr[23:20];
    //                             // rv_fence_pred = instr[27:24];
    //                         end
    //                 3'b001 : rv_opcode = RV32_FENCEI;
    //             endcase
    //         end
    //         5'b11100: begin // ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
    //             // rv_zimm      = 0;
    //             case ({instr[20], instr[14:12]})
    //                 4'b0000  : begin rv_opcode = RV32_ECALL; end
    //                 4'b1000  : begin rv_opcode = RV32_EBREAK; end
    //                 4'b0001  : begin rv_opcode = RV32_CSRRW; end //rv_zimm = 0;            
    //                 4'b0010  : begin rv_opcode = RV32_CSRRS; end //rv_zimm = 0;            
    //                 4'b0011  : begin rv_opcode = RV32_CSRRC; end //rv_zimm = 0;            
    //                 4'b0101  : begin rv_opcode = RV32_CSRRWI; end //rv_zimm = instr[19:15]; 
    //                 4'b0110  : begin rv_opcode = RV32_CSRRSI; end //rv_zimm = instr[19:15]; 
    //                 4'b0111  : begin rv_opcode = RV32_CSRRCI; end //rv_zimm = instr[19:15]; 
    //             endcase
    //         end
    //         default   : begin
    //             rv_opcode    = RV32_UNKNOWN;
    //         end /* default */
    //     endcase
    // end
    reg [`XPR_LEN-1:0]  decode_dict [1023:0];

    initial begin
        $display("Loading decoder rom.");
        $readmemh(`DECODER_FILE_INIT, decode_dict);
    end

    logic [`XPR_LEN-1:0] rv32_decoded_instr;
    logic [9:0] decoder_key;

    assign decoder_key        = {instr[30], instr[20], instr[14:12], instr[6:2]};
    assign rv32_decoded_instr = decode_dict[decoder_key];
    assign rv_opcode          = rv32_opcode_enum_t'({26'b0, rv32_decoded_instr[5:0]});
    assign rv_alu_op          = rv32_decoded_instr[9:6];

    rv32_imm_gen rv32_imm_gen_inst(.rv_instr     (instr),
                                   .rv_imm       (rv_imm_decoded)
                                  );

    // assign rv_opcode  = RV32_AND;
    assign rv_imm     = rv_imm_decoded;
    assign instr_trap = (rv_opcode == RV32_UNKNOWN) ? 1'b1 : 1'b0;
    assign rv_rs2     = instr[24:20];
    assign rv_rs1     = instr[19:15];
    assign rv_rd      = instr[11: 7];
    assign rv_shamt   = instr[24:20];

endmodule