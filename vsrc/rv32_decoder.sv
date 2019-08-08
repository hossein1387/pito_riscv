// `include "rv32_types.svh"
// `include "rv32_instr.svh"
// `include "rv32_defines.svh"

module rv32_decoder (
    input                      clk,
    input rv32_instr_t         instr, // input instruction
    input rv_pc_cnt_t          pc,

    output rv_register_t       rv_rs1,
    output rv_register_t       rv_rs2,
    output rv_register_t       rv_rd,

    output rv_shamt_t          rv_shamt,

    output rv_imm_t            rv_imm,

    output logic[3:0]          rv_fence_succ,
    output logic[3:0]          rv_fence_pred,

    output rv_csr_t            rv_csr,
    output rv_zimm_t           rv_zimm,

    output rv32_opcode_enum_t  rv_opcode,
    output rv32_type_enum_t    rv_imm_decoded_type,
    output logic               instr_trap

);

    rv_imm_t         rv_imm_decoded;

    always @(posedge clk) begin
        rv_imm_decoded_type <= RV32_TYPE_UNKNOWN;
        case (instr[6:0])
            7'b0110111: begin // LUI
                rv_imm_decoded_type <= RV32_TYPE_U;
                rv_opcode           <= RV32_LUI;
            end
            7'b0010111: begin // AUIPC
                rv_imm_decoded_type <= RV32_TYPE_U;
                rv_opcode           <= RV32_AUIPC;
            end
            7'b1101111: begin // JAL
                rv_imm_decoded_type <= RV32_TYPE_J;
                rv_opcode           <= RV32_JAL;
            end
            7'b1100111: begin // JALR
                if (instr[14:12] == 3'b000) begin
                    rv_imm_decoded_type <= RV32_TYPE_I;
                    rv_opcode           <= RV32_JALR;
                end else begin
                    rv_opcode <= RV32_UNKNOWN;
                end
            end
            7'b1100011: begin // BEQ, BNE, BLT, BGE, BLTU, BGEU
                rv_imm_decoded_type <= RV32_TYPE_B;
                case (instr[14:12])
                    3'b000        : rv_opcode <= RV32_BEQ;
                    3'b001        : rv_opcode <= RV32_BNE;
                    3'b100        : rv_opcode <= RV32_BLT;
                    3'b101        : rv_opcode <= RV32_BGE;
                    3'b110        : rv_opcode <= RV32_BLTU;
                    3'b111        : rv_opcode <= RV32_BGEU;
                    default       : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0000011: begin // LB, LH, LW, LBU, LHU
                rv_imm_decoded_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_LB;
                    3'b001                 : rv_opcode <= RV32_LH;
                    3'b010                 : rv_opcode <= RV32_LW;
                    3'b100                 : rv_opcode <= RV32_LBU;
                    3'b101                 : rv_opcode <= RV32_LHU;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0100011: begin // SB, SH, SW
                rv_imm_decoded_type <= RV32_TYPE_S;
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_SB;
                    3'b001                 : rv_opcode <= RV32_SH;
                    3'b010                 : rv_opcode <= RV32_SW;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0010011: begin // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                rv_imm_decoded_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000                 : rv_opcode <= RV32_ADDI;
                    3'b001                 : if (instr[31:25]==7'b0) rv_opcode <= RV32_SLLI; else rv_opcode <= RV32_UNKNOWN;
                    3'b010                 : rv_opcode <= RV32_SLTI;
                    3'b011                 : rv_opcode <= RV32_SLTIU;
                    3'b100                 : rv_opcode <= RV32_XORI;
                    3'b101                 :begin
                                                case (instr[31:25])
                                                    7'b0000000: rv_opcode <= RV32_SRLI;
                                                    7'b0100000: rv_opcode <= RV32_SRAI;
                                                    default   : rv_opcode <= RV32_UNKNOWN;
                                                endcase
                                            end
                    3'b110                 : rv_opcode <= RV32_ORI;
                    3'b111                 : rv_opcode <= RV32_ANDI;
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0110011: begin // ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                rv_imm_decoded_type <= RV32_TYPE_R;
                case ({instr[31:25], instr[14:12]})
                    {7'b0000000, 3'b000}    : rv_opcode <= RV32_ADD;
                    {7'b0100000, 3'b000}    : rv_opcode <= RV32_SUB;
                    {7'b0000000, 3'b001}    : rv_opcode <= RV32_SLL;
                    {7'b0000000, 3'b010}    : rv_opcode <= RV32_SLT;
                    {7'b0000000, 3'b011}    : rv_opcode <= RV32_SLTU;
                    {7'b0000000, 3'b100}    : rv_opcode <= RV32_XOR;
                    {7'b0000000, 3'b101}    : rv_opcode <= RV32_SRA;
                    {7'b0100000, 3'b101}    : rv_opcode <= RV32_SRL;
                    {7'b0000000, 3'b110}    : rv_opcode <= RV32_OR;
                    {7'b0000000, 3'b111}    : rv_opcode <= RV32_AND;
                    default                 : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            7'b0001111: begin // FENCE, FENCEI
                rv_imm_decoded_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000                 :begin
                                                case({instr[31:28], instr[19:15], instr[11:7]})
                                                    14'h0:begin
                                                            rv_opcode     <= RV32_FENCE;
                                                            rv_fence_succ <= instr[23:20];
                                                            rv_fence_pred <= instr[27:24];
                                                        end
                                                    default: rv_opcode <= RV32_UNKNOWN;
                                                endcase
                                            end
                    3'b001                 :begin
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
                rv_imm_decoded_type <= RV32_TYPE_I;
                case (instr[14:12])
                    3'b000                 :begin
                                                case({instr[31:20], instr[19:15], instr[11:7]})
                                                    {22'b0       }: rv_opcode <= RV32_ECALL;
                                                    {12'b1, 10'b0}: rv_opcode <= RV32_EBREAK;
                                                    default: rv_opcode        <= RV32_UNKNOWN;
                                                endcase
                                            end
                    3'b001                 : begin rv_opcode <= RV32_CSRRW; end
                    3'b010                 : begin rv_opcode <= RV32_CSRRS; end
                    3'b011                 : begin rv_opcode <= RV32_CSRRC; end
                    3'b101                 : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRWI; end
                    3'b110                 : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRSI; end
                    3'b111                 : begin rv_zimm   <= instr[19:15]; rv_opcode <= RV32_CSRRCI; end
                    default                : rv_opcode <= RV32_UNKNOWN;
                endcase
            end
            default   : begin
                rv_imm_decoded_type <= RV32_TYPE_UNKNOWN;
            end /* default */
        endcase
    end


    rv32_imm_gen rv32_imm_gen_inst(.rv_instr     (instr),
                                   .rv_imm_type  (rv_imm_decoded_type),
                                   .rv_imm       (rv_imm_decoded)
                                  );


    assign rv_imm     = rv_imm_decoded;
    assign instr_trap = (rv_imm_decoded_type == RV32_TYPE_UNKNOWN) ? 1'b1 : 1'b0;
    assign rv_rs2     = instr[24:20];
    assign rv_rs1     = instr[19:15];
    assign rv_rd      = instr[11: 7];
    assign rv_shamt   = instr[24:20];

endmodule