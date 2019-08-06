`include "types.vh"


module alu (
    input  rv_register_t       rs1,
    input  rv_register_t       rs2,
    input  rv_shamt_t          shamt,
    input  rv_imm_t            imm,
    input  rv32_opcode_enum_t  opcode
    output rv_register_t       rd,
);

    always @(*) begin
        case (rv_opcode)
            RV32_SLL    : rd = rs1 << rs2;
            RV32_SLLI   : rd = rs1 << shamt;
            RV32_SRL    : rd = rs1 >> rs2;
            RV32_SRLI   : rd = rs1 >> shamt;
            RV32_SRA    : rd = $signed(rs1) >>> rs2;
            RV32_SRAI   : rd = $signed(rs1) >>> shamt;
            RV32_ADD    : rd = rs1 + rs2;
            RV32_ADDI   : rd = rs1 + imm;
            RV32_SUB    : rd = rs1 - rs2;
            RV32_XOR    : rd = rs1 ^ rs2;
            RV32_XORI   : rd = rs1 ^ imm;
            RV32_OR     : rd = rs1 | rs2;
            RV32_ORI    : rd = rs1 | imm;
            RV32_AND    : rd = rs1 & rs2;
            RV32_ANDI   : rd = rs1 & imm;
            RV32_SLT    : rd = {31'b0, $signed(rs1) < $signed(rs2)};
            RV32_SLTI   : rd = {31'b0, $signed(rs1) < $signed(imm)};
            RV32_SLTU   : rd = {31'b0, rs1 < rs2};
            RV32_SLTIU  : rd = {31'b0, rs1 < imm};
            default     : rd = 0;
        endcase
    end

endmodule