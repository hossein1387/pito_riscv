`include "types.vh"


module rv32_alu (
    input  rv_register_t       rs1,
    input  rv_register_t       rs2,
    input  rv_alu_op_t         alu_opcode,
    output rv_register_t       res,
    output logic               z
);

    always @(*) begin
        case (alu_opcode)
            ALU_SLL     : res = rs1 << rs2;
            ALU_SRL     : res = rs1 >> rs2;
            ALU_SRA     : res = $signed(rs1) >>> rs2;
            ALU_ADD     : res = rs1 + rs2;
            ALU_SUB     : res = rs1 - rs2;
            ALU_XOR     : res = rs1 ^ rs2;
            ALU_OR      : res = rs1 | rs2;
            ALU_AND     : res = rs1 & rs2;
            ALU_SLT     : res = {31'b0, $signed(rs1) < $signed(rs2)};
            ALU_SLTU    : res = {31'b0, rs1 < rs2};
            ALU_EQ      : res = {31'b0, rs1==rs2};
            default     : res = 0;
        endcase
    end

    assign z = (res==0);

endmodule