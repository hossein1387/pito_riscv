// `include "rv32_types.svh"
// `include "rv32_instr.svh"
// `include "rv32_defines.svh"
`timescale 1 ps / 1 ps

module rv32_decoder (
    input rv32_instr_t           instr, // input instruction

    output rv32_register_t       rv_rs1,
    output rv32_register_t       rv_rs2,
    output rv32_register_t       rv_rd,

    output rv32_shamt_t          rv_shamt,

    output rv32_imm_t            rv_imm,
    output rv32_alu_op_t         rv_alu_op,

    output logic[3:0]            rv_fence_succ,
    output logic[3:0]            rv_fence_pred,

    output rv32_csr_t            rv_csr,
    output rv32_zimm_t           rv_zimm,

    output rv32_opcode_enum_t    rv_opcode,
    output rv32_type_enum_t      rv_inst_type,
    output logic                 instr_trap

);

    rv32_imm_t         rv_imm_decoded;

    always @(*) begin
        rv_inst_type <= RV32_TYPE_UNKNOWN;
        rv_alu_op    <= `ALU_NOP;
        case (instr[6:0])
            7'b0110111: begin // LUI
                rv_inst_type <= RV32_TYPE_U;
                rv_opcode           <= RV32_LUI;
            end
            7'b0010111: begin // AUIPC
                rv_inst_type <= RV32_TYPE_U;
                rv_opcode    <= RV32_AUIPC;
            end
            7'b1101111: begin // JAL
                rv_inst_type <= RV32_TYPE_J;
                rv_opcode    <= RV32_JAL;
            end
            7'b1100111: begin // JALR
                if (instr[14:12] == 3'b000) begin
                    rv_inst_type <= RV32_TYPE_I;
                    rv_opcode    <= RV32_JALR;
                end else begin
                    rv_opcode <= RV32_UNKNOWN;
                end
            end
            7'b1100011: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU
                rv_inst_type <= RV32_TYPE_B;
                case (instr[14:12])
                    3'b000  : begin rv_opcode <= RV32_BEQ;  rv_alu_op <= `ALU_EQ;   end
                    3'b001  : begin rv_opcode <= RV32_BNE;  rv_alu_op <= `ALU_NEQ;  end
                    3'b100  : begin rv_opcode <= RV32_BLT;  rv_alu_op <= `ALU_SLT;  end
                    3'b101  : begin rv_opcode <= RV32_BGE;  rv_alu_op <= `ALU_SBT;  end
                    3'b110  : begin rv_opcode <= RV32_BLTU; rv_alu_op <= `ALU_SLTU; end
                    3'b111  : begin rv_opcode <= RV32_BGEU; rv_alu_op <= `ALU_SBTU; end
                    default : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0000011: begin // LB, LH, LW, LBU, LHU
                rv_inst_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000  : begin rv_opcode <= RV32_LB ; rv_alu_op <= `ALU_ADD; end
                    3'b001  : begin rv_opcode <= RV32_LH ; rv_alu_op <= `ALU_ADD; end
                    3'b010  : begin rv_opcode <= RV32_LW ; rv_alu_op <= `ALU_ADD; end
                    3'b100  : begin rv_opcode <= RV32_LBU; rv_alu_op <= `ALU_ADD; end
                    3'b101  : begin rv_opcode <= RV32_LHU; rv_alu_op <= `ALU_ADD; end
                    default : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0100011: begin // SB, SH, SW
                rv_inst_type <= RV32_TYPE_S;
                case (instr[14:12])
                    3'b000  : begin rv_opcode <= RV32_SB; rv_alu_op <= `ALU_ADD; end
                    3'b001  : begin rv_opcode <= RV32_SH; rv_alu_op <= `ALU_ADD; end
                    3'b010  : begin rv_opcode <= RV32_SW; rv_alu_op <= `ALU_ADD; end
                    default : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0010011: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI, NOP
                if (instr[31:7] == {25{1'b0}}) begin
                    rv_inst_type <= RV32_TYPE_NOP;
                    rv_opcode    <= RV32_NOP;
                end else begin
                    rv_inst_type <= RV32_TYPE_I;
                    case (instr[14:12])
                        3'b000  : begin rv_opcode <= RV32_ADDI; rv_alu_op <= `ALU_ADD; end
                        3'b001  : if (instr[31:25]==7'b0) begin rv_opcode <= RV32_SLLI; rv_alu_op <= `ALU_SLL; end else rv_opcode <= RV32_UNKNOWN;
                        3'b010  : begin rv_opcode <= RV32_SLTI;  rv_alu_op <= `ALU_SLT; end 
                        3'b011  : begin rv_opcode <= RV32_SLTIU; rv_alu_op <= `ALU_SLTU;end 
                        3'b100  : begin rv_opcode <= RV32_XORI;  rv_alu_op <= `ALU_XOR; end 
                        3'b101  :begin
                                     case (instr[31:25])
                                         7'b0000000: begin rv_opcode <= RV32_SRLI; rv_alu_op <= `ALU_SRL; end 
                                         7'b0100000: begin rv_opcode <= RV32_SRAI; rv_alu_op <= `ALU_SRA; end
                                         default   : rv_opcode <= RV32_UNKNOWN;
                                     endcase
                                 end
                        3'b110  : begin rv_opcode <= RV32_ORI;  rv_alu_op <= `ALU_OR;  end
                        3'b111  : begin rv_opcode <= RV32_ANDI; rv_alu_op <= `ALU_AND; end
                        default : rv_opcode <= RV32_UNKNOWN;
                    endcase
                end
            end
            7'b0110011: begin // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                rv_inst_type <= RV32_TYPE_R;
                case ({instr[31:25], instr[14:12]})
                    {7'b0000000, 3'b000} : begin rv_opcode <= RV32_ADD;  rv_alu_op <= `ALU_ADD; end
                    {7'b0100000, 3'b000} : begin rv_opcode <= RV32_SUB;  rv_alu_op <= `ALU_SUB; end
                    {7'b0000000, 3'b001} : begin rv_opcode <= RV32_SLL;  rv_alu_op <= `ALU_SLL; end
                    {7'b0000000, 3'b010} : begin rv_opcode <= RV32_SLT;  rv_alu_op <= `ALU_SLT; end
                    {7'b0000000, 3'b011} : begin rv_opcode <= RV32_SLTU; rv_alu_op <= `ALU_SLTU;end
                    {7'b0000000, 3'b100} : begin rv_opcode <= RV32_XOR;  rv_alu_op <= `ALU_XOR; end
                    {7'b0100000, 3'b101} : begin rv_opcode <= RV32_SRA;  rv_alu_op <= `ALU_SRA; end
                    {7'b0000000, 3'b101} : begin rv_opcode <= RV32_SRL;  rv_alu_op <= `ALU_SRL;end
                    {7'b0000000, 3'b110} : begin rv_opcode <= RV32_OR;   rv_alu_op <= `ALU_OR;  end
                    {7'b0000000, 3'b111} : begin rv_opcode <= RV32_AND;  rv_alu_op <= `ALU_AND; end
                    default              : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0001111: begin // FENCE, FENCEI
                rv_inst_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000 :begin
                                case({instr[31:28], instr[19:15], instr[11:7]})
                                    14'h0:begin
                                            rv_opcode     <= RV32_FENCE;
                                            rv_fence_succ <= instr[23:20];
                                            rv_fence_pred <= instr[27:24];
                                        end
                                    default: rv_opcode <= RV32_UNKNOWN;
                                endcase
                            end
                    3'b001 :begin
                                case({instr[31:15], instr[11:7]})
                                    22'h0:begin
                                            rv_opcode     <= RV32_FENCEI;
                                        end
                                    default: rv_opcode <= RV32_UNKNOWN;
                                endcase
                            end
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b1110011: begin // ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI
                rv_inst_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000  :begin
                                 case({instr[31:20], instr[19:15], instr[11:7]})
                                     {22'b0       }: rv_opcode <= RV32_ECALL;
                                     {12'b1, 10'b0}: rv_opcode <= RV32_EBREAK;
                                     default: rv_opcode        <= RV32_UNKNOWN;
                                 endcase
                             end
                    3'b001  : begin rv_opcode <= RV32_CSRRW; end
                    3'b010  : begin rv_opcode <= RV32_CSRRS; end
                    3'b011  : begin rv_opcode <= RV32_CSRRC; end
                    3'b101  : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRWI; end
                    3'b110  : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRSI; end
                    3'b111  : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRCI; end
                    default : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            default   : begin
                rv_inst_type <= RV32_TYPE_UNKNOWN;
                rv_opcode    <= RV32_UNKNOWN;
            end /* default */
        endcase
    end


    rv32_imm_gen rv32_imm_gen_inst(.rv_instr     (instr),
                                   .rv32_imm_type  (rv_inst_type),
                                   .rv_imm       (rv_imm_decoded)
                                  );


    assign rv_imm     = rv_imm_decoded;
    assign instr_trap = (rv_inst_type == RV32_TYPE_UNKNOWN) ? 1'b1 : 1'b0;
    assign rv_rs2     = instr[24:20];
    assign rv_rs1     = instr[19:15];
    assign rv_rd      = instr[11: 7];
    assign rv_shamt   = instr[24:20];

endmodule