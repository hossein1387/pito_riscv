package rv32_utils;

`include "rv32_types.svh"
//==================================================================================================
// RV32IDecoder class used for verification and simulation purposes 
//==================================================================================================
    
class RV32IDecoder;

    function string dec_nop_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "NOP-Type";
        if ((instr[6:0] == 7'b0010011) && (instr[31:7] == {25{1'b0}})) begin
            decode_ins_str = $sformatf("%8s.%7s                              ", inst_type, "nop");
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction


    function string dec_u_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "U-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{12{instr[31]}}, instr[31:12]};
        rv_register_field_t rd = instr[11:7]; 
        if          (opcode == 7'b0110111) begin
        decode_ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "lui", rd, imm);
        end else if (opcode == 7'b0010111) begin
        decode_ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "auipc", rd, imm);
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction

    function string dec_j_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "J-Type";
        logic [6:0] opcode = instr[6:0];
        logic [19:0] pre_imm = instr[31:12];
        int imm = {{12{pre_imm[19]}}, {pre_imm[19], pre_imm[9:0], pre_imm[10], pre_imm[18:11]}};
        rv_register_field_t rd = instr[11:7]; 
        if          (opcode == 7'b0110111) begin
        decode_ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "jal", rd, imm);
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction

    function string dec_i_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "I-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{20{instr[31]}}, instr[31:20]};
        rv_register_field_t rd  = instr[11:7]; 
        rv_register_field_t rs1 = instr[19:15]; 
        fnct3_t             funct3 = instr[14:12];
        if          (opcode == 7'b1100111) begin
            decode_ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, "jalr", rd, rs1, imm);
        end else if (opcode == 7'b0000011) begin
            string funct3_str;
            case (funct3)
                3'b000  : funct3_str = "lb";
                3'b001  : funct3_str = "lh";
                3'b010  : funct3_str = "lw";
                3'b100  : funct3_str = "lbu";
                3'b101  : funct3_str = "lhu";
                default : funct3_str = "unknown";/* default */
            endcase
            decode_ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0010011) begin
            string funct3_str;
            case (funct3)
                3'b000  : funct3_str = "addi";
                3'b001  : begin if (instr[31:25]==0) funct3_str = "slli"; else funct3_str = "unknown"; end
                3'b010  : funct3_str = "slti";
                3'b011  : funct3_str = "sltiu";
                3'b100  : funct3_str = "xori";
                3'b101  : begin if (instr[31:25]==0) funct3_str = "srli"; else if (instr[31:25]==7'b0100000) funct3_str = "srai"; else funct3_str = "unknown"; end
                3'b110  : funct3_str = "ori";
                3'b111  : funct3_str = "andi";
                default : funct3_str = "unknown";/* default */
            endcase
            decode_ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0001111) begin
            decode_ins_str = "fence instruction";
        end else if (opcode == 7'b1110011) begin
            decode_ins_str = "csr instruction";
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction

    function string dec_b_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "B-Type";
        logic [6:0] opcode = instr[6:0];
        logic [11:0] pre_imm = {instr[31:25], instr[11:7]};
        int imm = { {20{pre_imm[11]}}, {pre_imm[11], pre_imm[0], pre_imm[10:5], pre_imm[4:1]}};
        rv_register_field_t rs1 = instr[19:15];
        rv_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        if          (opcode == 7'b1100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : funct3_str = "beq";
                3'b001  : funct3_str = "bne";
                3'b100  : funct3_str = "blt";
                3'b101  : funct3_str = "bge";
                3'b110  : funct3_str = "bltu";
                3'b111  : funct3_str = "bgeu";
                default : funct3_str = "unknown";
            endcase
            decode_ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction

    function string dec_s_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "S-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = { {20{instr[31]}}, {instr[31:25], instr[11:7]}};
        rv_register_field_t rs1 = instr[19:15];
        rv_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        if          (opcode == 7'b0100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : funct3_str = "sb";
                3'b001  : funct3_str = "sh";
                3'b010  : funct3_str = "sw";
                default : funct3_str = "unknown";
            endcase
            decode_ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction

    function string dec_r_type (rv32_instr_t instr);
        string decode_ins_str;
        string inst_type = "R-Type";
        logic [6:0] opcode = instr[6:0];
        rv_register_field_t rd  = instr[11:7];
        rv_register_field_t rs1 = instr[19:15];
        rv_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        if          (opcode == 7'b0110011) begin
            string funct3_str;
            case (funct3)
                3'b000  : if (instr[31:25]==7'b0000000) funct3_str = "add"; else if (instr[31:25]==7'b0100000) funct3_str = "sub"; else funct3_str = "unknown";
                3'b001  : funct3_str = "sll";
                3'b010  : funct3_str = "slt";
                3'b011  : funct3_str = "sltu";
                3'b100  : funct3_str = "xor";
                3'b101  : if (instr[31:25]==7'b0000000) funct3_str = "srl"; else if (instr[31:25]==7'b0100000) funct3_str = "sra"; else funct3_str = "unknown";
                3'b110  : funct3_str = "or";
                3'b111  : funct3_str = "and";
                default : funct3_str = "unknown";
            endcase
            decode_ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d rs2=  %2d          ", inst_type, funct3_str, rd, rs1, rs2);
        end else                           begin
            decode_ins_str = "!unknown instruction!";
        end
        return decode_ins_str;
    endfunction
endclass

endpackage: rv32_utils
