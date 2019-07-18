`include "types.svh"
`include "instr.svh"
`include "rv_defines.svh"

module decoder (
    input                      clk,
    input                      rst,
    input                      flush,
    input                      halt, 
    input riscv_instr_t        instr, // input instruction
    input rv_pc_cnt_t          pc,

    output alu_opcode_t        alu_opcode,
    output rv_register_t       rv_rs1,
    output rv_register_t       rv_rs2,
    output rv_register_t       rv_rd,

    output rv_imm_t            rv_imm,

    output rv32_opcode_enum_t  rv_opcode,
    output logic               instr_trap

);

    rv32_type_enum_t rv_imm_decoded_type;
    rv_imm_t         rv_imm_decoded;

    always @(posedge clk) begin
        rv_imm_decoded_type <= RV32_TYPE_UNKNOWN;
        case (instr[6:0])
            7'b0110111: begin // LUI
                rv_imm_decoded_type <= RV32_TYPE_U;
                rv_rd               <= instr[11:7];
                rv_opcode           <= RV32_LUI;
            end
            7'b0010111: begin // AUIPC
                rv_imm_decoded_type <= RV32_TYPE_U;
                rv_rd               <= instr[11:7];
                rv_opcode           <= RV32_AUIPC;
            end
            7'b1101111: begin // JAL
                rv_imm_decoded_type <= RV32_TYPE_J;
                rv_rd               <= instr[11:7];
                rv_opcode           <= RV32_JAL;
            end
            7'b1100111: begin // JALR
                rv_imm_decoded_type <= RV32_TYPE_I;
                rv_rd               <= instr[11: 7];
                rv_rs1              <= instr[19:15];
                rv_opcode           <= RV32_JALR;
            end
            7'b1100011: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU
                rv_imm_decoded_type <= RV32_TYPE_B;
                rv_rs2              <= instr[24:20];
                rv_rs1              <= instr[19:15];
                case (instr[14:12])
                    3'b000        : rv_opcode <= RV32_BEQ;
                    3'b001        : rv_opcode <= RV32_BNE;
                    3'b010, 3'b011: rv_opcode <= RV32_UNKNOWN;
                    3'b100        : rv_opcode <= RV32_BLT;
                    3'b101        : rv_opcode <= RV32_BGE;
                    3'b110        : rv_opcode <= RV32_BLTU;
                    3'b111        : rv_opcode <= RV32_BGEU;
                    default       : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0000011: begin // LB, LH, LW, LBU, LHU
                rv_imm_decoded_type <= RV32_TYPE_I;
                rv_rd               <= instr[11: 7];
                rv_rs1              <= instr[19:15];
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_LB;
                    3'b001                 : rv_opcode <= RV32_LH;
                    3'b010                 : rv_opcode <= RV32_LW;
                    3'b100                 : rv_opcode <= RV32_LBU;
                    3'b101                 : rv_opcode <= RV32_LHU;
                    3'b011, 3'b110, 3'b111 : rv_opcode <= RV32_UNKNOWN;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0100011: begin // SB, SH, SW
                rv_imm_decoded_type <= RV32_TYPE_S;
                rv_rs2              <= instr[24:20];
                rv_rs1              <= instr[19:15];
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_SB;
                    3'b001                 : rv_opcode <= RV32_SH;
                    3'b010                 : rv_opcode <= RV32_SW;
                    3'b011, 3'b100, 3'b101, 
                    3'b110, 3'b111         : rv_opcode <= RV32_UNKNOWN;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0010011: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                rv_imm_decoded_type <= RV32_TYPE_I;
                rv_rs1              <= instr[19:15];
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_ADDI;
                    3'b010                 : rv_opcode <= RV32_SLTI;
                    3'b010                 : rv_opcode <= RV32_SW;
                    3'b001, 3'b100, 3'b101, 
                    3'b110, 3'b111         : rv_opcode <= RV32_UNKNOWN;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0110011: begin // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                rv_imm_decoded_type <= RV32_TYPE_R;
            end
            7'b0001111: begin // FENCE, FENCEI
                rv_imm_decoded_type <= RV32_TYPE_I;
            end
            7'b1110011: begin // ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
                rv_imm_decoded_type <= RV32_TYPE_I;
            end
            default   : begin
                rv_imm_decoded_type <= RV32_TYPE_UNKNOWN;
            end /* default */
        endcase
    end


    imm_gen imm_gen_inst(   .rv_instr     (instr),
                            .rv_imm_type  (rv_imm_decoded_type),
                            .rv_imm       (rv_imm_decoded)
                        );


    assign rv_imm     = rv_imm_decoded;
    assign instr_trap = (rv_imm_decoded_type == RV32_TYPE_UNKNOWN) ? 1'b1 : 1'b0;

endmodule