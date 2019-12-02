package rv32_utils;
import utils::*;
`include "../../../vsrc/rv32_types.svh"
//==================================================================================================
// RV32IDecoder class used for verification and simulation purposes 
//==================================================================================================

class BaseObj;
    Logger logger;

   function new (Logger logger);
      this.logger = logger;
   endfunction

endclass

class RV32IDecoder extends BaseObj;

    function new (Logger logger);
        super.new (logger);   // Calls 'new' method of parent class
    endfunction

    function rv32_inst_dec_t dec_nop_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "NOP-Type";
        if ((instr[6:0] == 7'b0010011) && (instr[31:7] == {25{1'b0}})) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s                              ", inst_type, "nop");
            rv32_inst_dec.opcode = RV32_NOP;
            rv32_inst_dec.inst_type = RV32_TYPE_NOP;
        end else begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.imm = `PITO_NULL;
        rv32_inst_dec.csr = `PITO_NULL;
        rv32_inst_dec.rs1 = `PITO_NULL;
        rv32_inst_dec.rs2 = `PITO_NULL;
        rv32_inst_dec.rd  = `PITO_NULL;
        return rv32_inst_dec;
    endfunction


    function rv32_inst_dec_t dec_u_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "U-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{12{instr[31]}}, instr[31:12]};
        rv32_register_field_t rd = instr[11:7]; 
        if          (opcode == 7'b0110111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "lui", rd, imm);
            rv32_inst_dec.opcode         = RV32_LUI;
            rv32_inst_dec.rd             = rd;
            rv32_inst_dec.imm            = imm;
            rv32_inst_dec.inst_type    = RV32_TYPE_U;
        end else if (opcode == 7'b0010111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "auipc", rd, imm);
            rv32_inst_dec.opcode         = RV32_AUIPC;
            rv32_inst_dec.rd             = rd;
            rv32_inst_dec.imm            = imm;
            rv32_inst_dec.inst_type    = RV32_TYPE_U;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = `PITO_NULL;
        rv32_inst_dec.rs2            = `PITO_NULL;
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_j_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "J-Type";
        logic [6:0] opcode = instr[6:0];
        logic [19:0] pre_imm = instr[31:12];
        int imm = {{12{pre_imm[19]}}, {pre_imm[19], pre_imm[9:0], pre_imm[10], pre_imm[18:11]}};
        rv32_register_field_t rd = instr[11:7]; 
        if          (opcode == 7'b1101111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d                imm=%4d", inst_type, "jal", rd, imm);
            rv32_inst_dec.opcode      = RV32_JAL;
            rv32_inst_dec.rd          = rd;
            rv32_inst_dec.imm         = imm;
            rv32_inst_dec.inst_type = RV32_TYPE_J;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        rv32_inst_dec.csr = `PITO_NULL;
        rv32_inst_dec.rs1 = `PITO_NULL;
        rv32_inst_dec.rs2 = `PITO_NULL;
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_i_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        string inst_type = "I-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = {{20{instr[31]}}, instr[31:20]};
        rv32_register_field_t rd  = instr[11:7]; 
        rv32_register_field_t rs1 = instr[19:15]; 
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd          = rd;
        rv32_inst_dec.rs1         = rs1;
        rv32_inst_dec.imm         = imm;
        rv32_inst_dec.inst_type = RV32_TYPE_I;
        rv32_inst_dec.csr         = `PITO_NULL;
        if          (opcode == 7'b1100111) begin
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, "jalr", rd, rs1, imm);
            rv32_inst_dec.opcode = RV32_JALR;
        end else if (opcode == 7'b0000011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_LB     ; funct3_str = "lb"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_LH     ; funct3_str = "lh"; end
                3'b010  : begin rv32_inst_dec.opcode = RV32_LW     ; funct3_str = "lw"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_LBU    ; funct3_str = "lbu"; end
                3'b101  : begin rv32_inst_dec.opcode = RV32_LHU    ; funct3_str = "lhu"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0010011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_ADDI; funct3_str = "addi"; end
                3'b001  : begin if (instr[31:25]==0) begin 
                                    funct3_str = "slli"; 
                                    rv32_inst_dec.opcode = RV32_SLLI; 
                                    rv32_inst_dec.imm    = instr[25:20];
                                end else begin
                                    rv32_inst_dec.opcode = RV32_UNKNOWN; 
                                    funct3_str = "unknown"; 
                                end 
                          end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SLTI; funct3_str = "slti"; end
                3'b011  : begin rv32_inst_dec.opcode = RV32_SLTIU;funct3_str = "sltiu"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_XORI; funct3_str = "xori"; end
                3'b101  : begin if (instr[31:25]==0) begin
                                    funct3_str = "srli";
                                    rv32_inst_dec.opcode = RV32_SRLI;
                                    rv32_inst_dec.imm    = instr[25:20];
                                end else if (instr[31:25]==7'b0100000) begin
                                    funct3_str = "srai";
                                    rv32_inst_dec.imm    = instr[25:20];
                                    rv32_inst_dec.opcode = RV32_SRAI;
                                end else begin
                                    funct3_str = "unknown";
                                    rv32_inst_dec.opcode = RV32_UNKNOWN;
                                end
                            end
                3'b110  : begin rv32_inst_dec.opcode = RV32_ORI;     funct3_str = "ori"; end
                3'b111  : begin rv32_inst_dec.opcode = RV32_ANDI;    funct3_str = "andi"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end/* default */
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d           imm=%4d", inst_type, funct3_str, rd, rs1, imm);
        end else if (opcode == 7'b0001111) begin
            /*
            TODO: Decode the fence instructions here
            */
            //rv32_inst_dec.ins_str = "fence instruction   [NOT SUPPORTED]";
            rv32_inst_dec.opcode = RV32_FENCE;
        end else if (opcode == 7'b1110011) begin
            /*
            TODO: Decode the csr instructions here
            */
            //rv32_inst_dec.ins_str = "csr instruction     [NOT SUPPORTED]";
            rv32_inst_dec.opcode = RV32_CSRRC;
            rv32_inst_dec.csr    = `PITO_NULL;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
            rv32_inst_dec.inst_type = RV32_TYPE_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_b_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "B-Type";
        logic [6:0] opcode = instr[6:0];
        logic [11:0] pre_imm = {instr[31:25], instr[11:7]};
        int imm = { {20{pre_imm[11]}}, {pre_imm[11], pre_imm[0], pre_imm[10:5], pre_imm[4:1]}};
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd              = `PITO_NULL;
        rv32_inst_dec.imm             = imm;
        rv32_inst_dec.inst_type     = RV32_TYPE_B;
        rv32_inst_dec.csr             = `PITO_NULL;
        rv32_inst_dec.rs1             = rs1;
        rv32_inst_dec.rs2             = rs2;
        if          (opcode == 7'b1100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_BEQ    ; funct3_str = "beq"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_BNE    ; funct3_str = "bne"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_BLT    ; funct3_str = "blt"; end
                3'b101  : begin rv32_inst_dec.opcode = RV32_BGE    ; funct3_str = "bge"; end
                3'b110  : begin rv32_inst_dec.opcode = RV32_BLTU   ; funct3_str = "bltu"; end
                3'b111  : begin rv32_inst_dec.opcode = RV32_BGEU   ; funct3_str = "bgeu"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);;
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_s_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "S-Type";
        logic [6:0] opcode = instr[6:0];
        int imm = { {20{instr[31]}}, {instr[31:25], instr[11:7]}};
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        
        rv32_inst_dec.rd             = `PITO_NULL;
        rv32_inst_dec.imm            = imm;
        rv32_inst_dec.inst_type    = RV32_TYPE_S;
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = rs1;
        rv32_inst_dec.rs2            = rs2;
        if          (opcode == 7'b0100011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin rv32_inst_dec.opcode = RV32_SB;      funct3_str = "sb"; end
                3'b001  : begin rv32_inst_dec.opcode = RV32_SH;      funct3_str = "sh"; end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SW;      funct3_str = "sw"; end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s:       rs1=%2d rs2=  %2d  imm=%4d", inst_type, funct3_str, rs1, rs2, imm);
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode         = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t dec_r_type (rv32_instr_t instr);
        rv32_inst_dec_t rv32_inst_dec;
        //string ins_str;
        string inst_type = "R-Type";
        logic [6:0] opcode = instr[6:0];
        rv32_register_field_t rd  = instr[11:7];
        rv32_register_field_t rs1 = instr[19:15];
        rv32_register_field_t rs2 = instr[24:20];
        fnct3_t             funct3 = instr[14:12];
        rv32_inst_dec.rd             = rd;
        rv32_inst_dec.imm            = `PITO_NULL;
        rv32_inst_dec.inst_type      = RV32_TYPE_R;
        rv32_inst_dec.csr            = `PITO_NULL;
        rv32_inst_dec.rs1            = rs1;
        rv32_inst_dec.rs2            = rs2;
        if          (opcode == 7'b0110011) begin
            string funct3_str;
            case (funct3)
                3'b000  : begin if (instr[31:25]==7'b0000000) begin
                                  funct3_str = "add"; 
                                  rv32_inst_dec.opcode  = RV32_ADD;
                                end else if (instr[31:25]==7'b0100000) begin
                                  funct3_str = "sub"; 
                                  rv32_inst_dec.opcode  = RV32_SUB;
                                end else begin 
                                  funct3_str = "unknown";
                                  rv32_inst_dec.opcode  = RV32_UNKNOWN;
                                end
                          end
                3'b001  : begin rv32_inst_dec.opcode = RV32_SLL;  funct3_str = "sll";  end
                3'b010  : begin rv32_inst_dec.opcode = RV32_SLT;  funct3_str = "slt";  end
                3'b011  : begin rv32_inst_dec.opcode = RV32_SLTU; funct3_str = "sltu"; end
                3'b100  : begin rv32_inst_dec.opcode = RV32_XOR;  funct3_str = "xor";  end
                3'b101  : begin if (instr[31:25]==7'b0000000) begin
                                    funct3_str = "srl"; 
                                    rv32_inst_dec.opcode = RV32_SRL;
                                end else if (instr[31:25]==7'b0100000) begin 
                                    funct3_str = "sra"; 
                                    rv32_inst_dec.opcode = RV32_SRA;
                                end else begin 
                                    funct3_str = "unknown";
                                    rv32_inst_dec.opcode = RV32_UNKNOWN;
                                end
                          end
                3'b110  : begin rv32_inst_dec.opcode = RV32_OR ;     funct3_str = "or";     end
                3'b111  : begin rv32_inst_dec.opcode = RV32_AND;     funct3_str = "and";     end
                default : begin rv32_inst_dec.opcode = RV32_UNKNOWN; funct3_str = "unknown"; end
            endcase
            //rv32_inst_dec.ins_str = $sformatf("%8s.%7s: rd=%2d rs1=%2d rs2=  %2d          ", inst_type, funct3_str, rd, rs1, rs2);
        end else                           begin
            //rv32_inst_dec.ins_str = "!unknown instruction!";
            rv32_inst_dec.opcode = RV32_UNKNOWN;
        end
        return rv32_inst_dec;
    endfunction

    function rv32_inst_dec_t decode_instr (rv32_instr_t instr);
        static rv32_inst_dec_t decode_ins;
        static logic [6:0] opcode;
        opcode = instr[6:0];
        if ((opcode == 7'b0110111) || (opcode == 7'b0010111) ) begin //U-Type
            decode_ins = dec_u_type(instr);
        end else if (opcode == 7'b1101111) begin // J-Type
            decode_ins = dec_j_type(instr);
        end else if ((opcode == 7'b1100111) || 
                     (opcode == 7'b0000011) || 
                     (opcode == 7'b0010011) || 
                     (opcode == 7'b0001111) || 
                     (opcode == 7'b1110011)) begin // I-Type
            if (instr[31:7] == {25{1'b0}}) begin
                decode_ins = dec_nop_type(instr);
            end else begin
                decode_ins = dec_i_type(instr);
            end
        end else if (opcode == 7'b1100011) begin // B-Type
            decode_ins = dec_b_type(instr);
        end else if (opcode == 7'b0100011) begin // S-Type
            decode_ins = dec_s_type(instr);
        end else if (opcode == 7'b0110011) begin // R-Type
            decode_ins = dec_r_type(instr);
        end else begin
            decode_ins.opcode    = RV32_UNKNOWN;
            decode_ins.imm       = 0;
            decode_ins.csr       = 0;
            decode_ins.rs1       = 0;
            decode_ins.rs2       = 0;
            decode_ins.rd        = 0;
            decode_ins.inst_type = RV32_TYPE_UNKNOWN;
        end
        return decode_ins;
    endfunction

endclass

class RV32IPredictor extends BaseObj;
    test_stats_t test_stat;
    rv32_regfile_t regf_model;

    function new (Logger logger, rv32_regfile_t  regs);
        super.new(logger);   // Calls 'new' method of parent class
        test_stat = '{pass_cnt: 0, fail_cnt: 0};
        this.update_regf(regs);
    endfunction

    function report_result ();
        print_result(this.test_stat, VERB_LOW, logger);
    endfunction : report_result

    function update_regf(rv32_regfile_t regf);
        this.regf_model = regf;
    endfunction

    function void check_res(rv32_instr_t act_instr, int exp_val, real_val, string info="");
        if ( exp_val == real_val) begin
            this.test_stat.pass_cnt ++;
            logger.print($sformatf("Test Pass [0x%8h: %s]: Expecting %0d got %0d", act_instr, info, exp_val, real_val));
        end else begin
            this.test_stat.fail_cnt ++;
            logger.print($sformatf("Test Fail [0x%8h: %s]: Expecting %0d got %0d", act_instr, info, exp_val, real_val));
        end
    endfunction

    function void predict (rv32_instr_t act_instr, rv32_inst_dec_t instr, rv32_pc_cnt_t pc_cnt, rv32_pc_cnt_t pc_orig_cnt, rv32_regfile_t regf);
        rv32_opcode_enum_t    opcode    = instr.opcode   ;
        rv32_imm_t            imm       = instr.imm      ;
        rv32_csr_t            csr       = instr.csr      ;
        rv32_register_field_t rs1       = instr.rs1      ;
        rv32_register_field_t rs2       = instr.rs2      ;
        rv32_register_field_t rd        = instr.rd       ;
        rv32_type_enum_t      inst_type = instr.inst_type;
        string                instr_str = get_instr_str(instr);
        int                   exp_val, real_val;
        string                info;
        case (opcode)
            RV32_LB     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_LH     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_LW     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_LBU    : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_LHU    : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_SB     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_SH     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_SW     : begin
                logger.print($sformatf("checking 0x%8h: %s  is not supported yet", int'(act_instr), instr_str));
            end
            RV32_SLL    : begin
                exp_val  = (regf_model[rs1] << regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SLLI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (regf_model[rs1] << imm);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SRL    : begin
                exp_val  = (regf_model[rs1] >> regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SRLI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (regf_model[rs1] >> imm);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SRA    : begin
                exp_val  = (regf_model[rs1] >>> regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SRAI   : begin
                imm = int'(imm[4:0]);
                exp_val  = (regf_model[rs1] >>> imm);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_ADD    : begin
                exp_val  = (regf_model[rs1] + regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_ADDI   : begin
                exp_val  = (regf_model[rs1] + int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SUB    : begin
                exp_val  = (regf_model[rs1] - regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_LUI    : begin
                exp_val  = (int'(imm)<<12);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_AUIPC  : begin
                exp_val  = (int'(pc_cnt)) + (int'(imm)<<12);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_XOR    : begin
                exp_val  = (regf_model[rs1] ^ regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_XORI   : begin
                exp_val  = (regf_model[rs1] ^ int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_OR     : begin
                exp_val  = (regf_model[rs1] | regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_ORI    : begin
                exp_val  = (regf_model[rs1] | int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_AND    : begin
                exp_val  = (regf_model[rs1] & regf_model[rs2]);
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_ANDI   : begin
                exp_val  = (regf_model[rs1] & int'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SLT    : begin
                exp_val  = (regf_model[rs1] < regf_model[rs2]) ? 1 : 0;
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SLTI   : begin
                exp_val  = (regf_model[rs1] < int'(imm)) ? 1 : 0;
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SLTU   : begin
                exp_val  = (unsigned'(regf_model[rs1]) < unsigned'(regf_model[rs2]));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_SLTIU  : begin
                exp_val  = (unsigned'(regf_model[rs1]) < signed'(imm));
                real_val =  regf[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BEQ    : begin
                $display($sformatf("BEQ-------> rs1=%0d rs2=%0d",signed'(regf_model[rs1]), signed'(regf_model[rs2])));
                exp_val  = (signed'(regf_model[rs1]) == signed'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BNE    : begin
                exp_val  = (signed'(regf_model[rs1]) != signed'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BLT    : begin
                exp_val  = (signed'(regf_model[rs1]) < signed'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BGE    : begin
                exp_val  = (signed'(regf_model[rs1]) >= signed'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BLTU   : begin
                exp_val  = (unsigned'(regf_model[rs1]) < unsigned'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_BGEU   : begin
                exp_val  = (unsigned'(regf_model[rs1]) >= unsigned'(regf_model[rs2])) ? (pc_orig_cnt + signed'(imm)) : pc_orig_cnt;
                real_val =  pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_JAL    : begin
                exp_val  = pc_orig_cnt + signed'(imm);
                real_val = pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
                exp_val  = pc_orig_cnt + 4;
                real_val = regf_model[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_JALR   : begin
                exp_val  = regf_model[rs1] + signed'(imm);
                real_val = pc_cnt;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
                exp_val  = pc_orig_cnt + 4;
                real_val = regf_model[rd];
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_FENCEI, RV32_FENCE,
            RV32_CSRRW, RV32_CSRRS, RV32_CSRRC, RV32_CSRRWI, 
            RV32_CSRRSI, RV32_CSRRCI, RV32_ECALL, RV32_EBREAK, 
            RV32_ERET, RV32_WFI: begin
                logger.print($sformatf("checking %s  is not supported yet", instr_str));
            end
            RV32_NOP: begin
                // TODO: Write better test to check for NOP, I am not testing it now!
                exp_val  = opcode;
                real_val = RV32_NOP;
                info     = instr_str;
                check_res(act_instr, exp_val, real_val, info);
            end
            RV32_UNKNOWN : begin
                // TODO: send a signal to check_res function to increase filed counts
                logger.print("Unknown Instruction");
                logger.print($sformatf("Unknown Instruction: %s", instr_str));
            end
            endcase
            this.update_regf(regf);
    endfunction

endclass

    function automatic string reg_file_to_str(rv32_regfile_t regfile);
        int NUM_ROWS = 4;
        int NUM_COLS = 8;
        string reg_vals = "";
        for (int i=0; i< NUM_ROWS; i++) begin
            for (int j=0; j< NUM_COLS; j++) begin
                reg_vals = $sformatf("%s[%4s]:0x%8h  ", reg_vals, rv32_abi_reg_s[i*NUM_COLS+j], regfile[i*NUM_COLS+j]);
            end
            reg_vals = $sformatf("%s\n", reg_vals);
        end
        return reg_vals;
    endfunction

    function automatic string get_instr_str(rv32_inst_dec_t instr);
        string instr_str;
        string   opcode    = instr.opcode.name        ;
        rv32_imm_t imm     = instr.imm                ;
        rv32_csr_t csr     = instr.csr                ;
        string   rs1       = rv32_abi_reg_s[instr.rs1];
        string   rs2       = rv32_abi_reg_s[instr.rs2];
        string   rd        = rv32_abi_reg_s[instr.rd ];
        string   inst_type = instr.inst_type.name     ;
        case (instr.inst_type)
            RV32_TYPE_R       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s rs2=  %4s          ", inst_type, opcode, rd, rs1, rs2);
            RV32_TYPE_I       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s           imm=%4d", inst_type, opcode, rd, rs1, imm);
            RV32_TYPE_S       : instr_str = $sformatf("%17s.%12s:       rs1=%4s rs2=  %4s  imm=%4d", inst_type, opcode, rs1, rs2, imm);
            RV32_TYPE_B       : instr_str = $sformatf("%17s.%12s:       rs1=%4s rs2=  %4s  imm=%4d", inst_type, opcode, rs1, rs2, imm);
            RV32_TYPE_U       : instr_str = $sformatf("%17s.%12s: rd=%4s rs1=%4s           imm=%4d", inst_type, opcode, rd, rs1, imm);
            RV32_TYPE_J       : instr_str = $sformatf("%17s.%12s: rd=%4s                imm=%4d", inst_type, opcode, rd, imm);
            RV32_TYPE_NOP     : instr_str = $sformatf("%17s.%12s:                             ", inst_type, opcode);
            RV32_TYPE_UNKNOWN : instr_str = "!unknown instruction!";
        endcase
        return instr_str;
    endfunction

    function automatic rv32_instr_q process_hex_file(string hex_file, Logger logger, int nwords);
        int fd = $fopen (hex_file, "r");
        string instr_str, temp, line;
        rv32_instr_q instr_q;
        int word_cnt = 0;
        if (fd)  begin logger.print($sformatf("File was opened successfully : %0d", fd)); end
        else     begin logger.print($sformatf("File was NOT opened successfully : %0d", fd)); $finish(); end
        while (!$feof(fd) && word_cnt<nwords) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr_q.push_back(rv32_instr_t'(instr_str.atohex()));
            end
        end
        return instr_q;
    endfunction

endpackage: rv32_utils
