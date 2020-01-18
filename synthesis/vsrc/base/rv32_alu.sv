`timescale 1 ps / 1 ps
//`include"rv32_types.svh"
//`include"rv32_defines.svh"

module rv32_alu (
    input  logic [`XPR_LEN-1          : 0 ] rs1,
    input  logic [`XPR_LEN-1          : 0 ] rs2,
    input  logic [`ALU_OPCODE_WIDTH-1 : 0 ] alu_opcode,
    output logic [`XPR_LEN-1          : 0 ] res
);

    always @(*) begin
        case (alu_opcode)
            `ALU_SLL     : res = rs1 << rs2[4:0];
            `ALU_SRL     : res = rs1 >> rs2[4:0];
            `ALU_SRA     : res = $signed(rs1) >>> rs2[4:0];
            `ALU_ADD     : res = rs1 + rs2;
            `ALU_SUB     : res = rs1 - rs2;
            `ALU_XOR     : res = rs1 ^ rs2;
            `ALU_OR      : res = rs1 | rs2;
            `ALU_AND     : res = rs1 & rs2;
            `ALU_SLT     : res = {31'b0, $signed(rs1) < $signed(rs2)};
            `ALU_SLTU    : res = {31'b0, rs1 < rs2};
            `ALU_SBT     : res = {31'b0, $signed(rs1) >= $signed(rs2)};
            `ALU_SBTU    : res = {31'b0, rs1 >= rs2};
            `ALU_EQ      : res = {31'b0, rs1==rs2};
            `ALU_NEQ     : res = {31'b0, rs1!=rs2};
            default     : res = 0;
        endcase
    end

endmodule