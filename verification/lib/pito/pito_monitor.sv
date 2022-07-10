`include "rv32_defines.svh"
`include "testbench_macros.svh"

import rv32_utils::*;
import utils::*;
import pito_pkg::*;
import rv32_pkg::*;

class pito_monitor extends BaseObj;

    virtual pito_soc_ext_interface inf;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    rv32_pkg::rv32_data_q instr_q;
    rv32_pkg::rv32_data_q rodata_q;
    int hart_ids_q[$]; // hart id to monitor
    logic predictor_silent_mode;

    function new (Logger logger, rv32_pkg::rv32_data_q instr_q, rv32_pkg::rv32_data_q rodata_q, virtual pito_soc_ext_interface pito_inf, int hart_ids_q[$], test_stats_t test_stat, logic predictor_silent_mode=0);
        super.new (logger);   // Calls 'new' method of parent class
        this.inf = pito_inf;
        this.instr_q = instr_q;
        this.rodata_q = rodata_q;
        this.rv32i_dec = new(this.logger);
        this.predictor_silent_mode = predictor_silent_mode;
        this.rv32i_pred = new(this.logger, this.instr_q, this.rodata_q, `PITO_NUM_HARTS, test_stat, `PITO_DATA_MEM_SIZE, this.predictor_silent_mode);
        this.hart_ids_q = hart_ids_q;
    endfunction

    function int read_hart_reg_val (int hart_id, int reg_num);
        case (hart_id)
            0: return `hdl_path_regf_0[reg_num];
            1: return `hdl_path_regf_1[reg_num];
            2: return `hdl_path_regf_2[reg_num];
            3: return `hdl_path_regf_3[reg_num];
            4: return `hdl_path_regf_4[reg_num];
            5: return `hdl_path_regf_5[reg_num];
            6: return `hdl_path_regf_6[reg_num];
            7: return `hdl_path_regf_7[reg_num];
            default : return 0;
        endcase
    endfunction 

    function test_stats_t get_results();
        return this.rv32i_pred.get_results();
    endfunction

    function rv32_regfile_t read_regs(int hart_id);
        rv32_regfile_t regs;
        for (int i=0; i<`NUM_REGS; i++) begin
            regs[i] = read_hart_reg_val(hart_id, i);
        end
        return regs;
    endfunction

    function rv32_csrfile_t read_csrs(int hart_id);
        rv32_csrfile_t csrs;
        pito_pkg::csr_t csr_addr;
        if (hart_id != 0) begin
            logger.print($sformatf("Only hart 0 is supported, returning csrs for hart 0"));
        end
        for (int csr=0; csr<`NUM_CSR; csr++) begin
            csr_addr = pito_pkg::csr_t'(csr);
            case (csr_addr)
                pito_pkg::CSR_MVENDORID      : csrs[csr] = `hdl_path_csrf_0.mvendorid;
                pito_pkg::CSR_MARCHID        : csrs[csr] = `hdl_path_csrf_0.marchid;
                pito_pkg::CSR_MIMPID         : csrs[csr] = `hdl_path_csrf_0.mimpid;
                pito_pkg::CSR_MHARTID        : csrs[csr] = `hdl_path_csrf_0.mhartdid;
                pito_pkg::CSR_MSTATUS        : csrs[csr] = `hdl_path_csrf_0.mstatus_q;
                pito_pkg::CSR_MISA           : csrs[csr] = `hdl_path_csrf_0.misa;
                pito_pkg::CSR_MIE            : csrs[csr] = `hdl_path_csrf_0.mie_q;
                pito_pkg::CSR_MTVEC          : csrs[csr] = `hdl_path_csrf_0.mtvec_q;
                pito_pkg::CSR_MEPC           : csrs[csr] = `hdl_path_csrf_0.mepc_q;
                pito_pkg::CSR_MCAUSE         : csrs[csr] = `hdl_path_csrf_0.mcause_q;
                pito_pkg::CSR_MTVAL          : csrs[csr] = `hdl_path_csrf_0.mtval_q;
                pito_pkg::CSR_MIP            : csrs[csr] = `hdl_path_csrf_0.mip_q;
                // pito_pkg::CSR_MCYCLE         : csrs[csr] = `hdl_path_csrf_0.mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET       : csrs[csr] = `hdl_path_csrf_0.minstret_q[31:0];
                // pito_pkg::CSR_MCYCLEH        : csrs[csr] = `hdl_path_csrf_0.mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH      : csrs[csr] = `hdl_path_csrf_0.minstret_q[63:32];
                pito_pkg::CSR_MVUWBASEPTR    : csrs[csr] = `hdl_path_csrf_0.csr_mvuwbaseptr_q;
                pito_pkg::CSR_MVUIBASEPTR    : csrs[csr] = `hdl_path_csrf_0.csr_mvuibaseptr_q;
                pito_pkg::CSR_MVUSBASEPTR    : csrs[csr] = `hdl_path_csrf_0.csr_mvusbaseptr_q;
                pito_pkg::CSR_MVUBBASEPTR    : csrs[csr] = `hdl_path_csrf_0.csr_mvubbaseptr_q;
                pito_pkg::CSR_MVUOBASEPTR    : csrs[csr] = `hdl_path_csrf_0.csr_mvuobaseptr_q;
                pito_pkg::CSR_MVUWJUMP_0     : csrs[csr] = `hdl_path_csrf_0.csr_mvuwjump_0_q;
                pito_pkg::CSR_MVUWJUMP_1     : csrs[csr] = `hdl_path_csrf_0.csr_mvuwjump_1_q;
                pito_pkg::CSR_MVUWJUMP_2     : csrs[csr] = `hdl_path_csrf_0.csr_mvuwjump_2_q;
                pito_pkg::CSR_MVUWJUMP_3     : csrs[csr] = `hdl_path_csrf_0.csr_mvuwjump_3_q;
                pito_pkg::CSR_MVUWJUMP_4     : csrs[csr] = `hdl_path_csrf_0.csr_mvuwjump_4_q;
                pito_pkg::CSR_MVUIJUMP_0     : csrs[csr] = `hdl_path_csrf_0.csr_mvuijump_0_q;
                pito_pkg::CSR_MVUIJUMP_1     : csrs[csr] = `hdl_path_csrf_0.csr_mvuijump_1_q;
                pito_pkg::CSR_MVUIJUMP_2     : csrs[csr] = `hdl_path_csrf_0.csr_mvuijump_2_q;
                pito_pkg::CSR_MVUIJUMP_3     : csrs[csr] = `hdl_path_csrf_0.csr_mvuijump_3_q;
                pito_pkg::CSR_MVUIJUMP_4     : csrs[csr] = `hdl_path_csrf_0.csr_mvuijump_4_q;
                pito_pkg::CSR_MVUSJUMP_0     : csrs[csr] = `hdl_path_csrf_0.csr_mvusjump_0_q;
                pito_pkg::CSR_MVUSJUMP_1     : csrs[csr] = `hdl_path_csrf_0.csr_mvusjump_1_q;
                pito_pkg::CSR_MVUBJUMP_0     : csrs[csr] = `hdl_path_csrf_0.csr_mvubjump_0_q;
                pito_pkg::CSR_MVUBJUMP_1     : csrs[csr] = `hdl_path_csrf_0.csr_mvubjump_1_q;
                pito_pkg::CSR_MVUOJUMP_0     : csrs[csr] = `hdl_path_csrf_0.csr_mvuojump_0_q;
                pito_pkg::CSR_MVUOJUMP_1     : csrs[csr] = `hdl_path_csrf_0.csr_mvuojump_1_q;
                pito_pkg::CSR_MVUOJUMP_2     : csrs[csr] = `hdl_path_csrf_0.csr_mvuojump_2_q;
                pito_pkg::CSR_MVUOJUMP_3     : csrs[csr] = `hdl_path_csrf_0.csr_mvuojump_3_q;
                pito_pkg::CSR_MVUOJUMP_4     : csrs[csr] = `hdl_path_csrf_0.csr_mvuojump_4_q;
                pito_pkg::CSR_MVUWLENGTH_1   : csrs[csr] = `hdl_path_csrf_0.csr_mvuwlength_1_q;
                pito_pkg::CSR_MVUWLENGTH_2   : csrs[csr] = `hdl_path_csrf_0.csr_mvuwlength_2_q;
                pito_pkg::CSR_MVUWLENGTH_3   : csrs[csr] = `hdl_path_csrf_0.csr_mvuwlength_3_q;
                pito_pkg::CSR_MVUWLENGTH_4   : csrs[csr] = `hdl_path_csrf_0.csr_mvuwlength_4_q;
                pito_pkg::CSR_MVUILENGTH_1   : csrs[csr] = `hdl_path_csrf_0.csr_mvuilength_1_q;
                pito_pkg::CSR_MVUILENGTH_2   : csrs[csr] = `hdl_path_csrf_0.csr_mvuilength_2_q;
                pito_pkg::CSR_MVUILENGTH_3   : csrs[csr] = `hdl_path_csrf_0.csr_mvuilength_3_q;
                pito_pkg::CSR_MVUILENGTH_4   : csrs[csr] = `hdl_path_csrf_0.csr_mvuilength_4_q;
                pito_pkg::CSR_MVUSLENGTH_1   : csrs[csr] = `hdl_path_csrf_0.csr_mvuslength_1_q;
                pito_pkg::CSR_MVUBLENGTH_1   : csrs[csr] = `hdl_path_csrf_0.csr_mvublength_1_q;
                pito_pkg::CSR_MVUOLENGTH_1   : csrs[csr] = `hdl_path_csrf_0.csr_mvuolength_1_q;
                pito_pkg::CSR_MVUOLENGTH_2   : csrs[csr] = `hdl_path_csrf_0.csr_mvuolength_2_q;
                pito_pkg::CSR_MVUOLENGTH_3   : csrs[csr] = `hdl_path_csrf_0.csr_mvuolength_3_q;
                pito_pkg::CSR_MVUOLENGTH_4   : csrs[csr] = `hdl_path_csrf_0.csr_mvuolength_4_q;
                pito_pkg::CSR_MVUPRECISION   : csrs[csr] = `hdl_path_csrf_0.csr_mvuprecision_q;
                pito_pkg::CSR_MVUSTATUS      : csrs[csr] = `hdl_path_csrf_0.csr_mvustatus_q;
                pito_pkg::CSR_MVUCOMMAND     : csrs[csr] = `hdl_path_csrf_0.csr_mvucommand_q;
                pito_pkg::CSR_MVUQUANT       : csrs[csr] = `hdl_path_csrf_0.csr_mvuquant_q;
                pito_pkg::CSR_MVUSCALER      : csrs[csr] = `hdl_path_csrf_0.csr_mvuscaler_q;
                pito_pkg::CSR_MVUCONFIG1     : csrs[csr] = `hdl_path_csrf_0.csr_mvuconfig1_q;
                default : csrs[csr] = 0;
            endcase
        end
        return csrs;
    endfunction 

    function automatic int read_dmem_word(rv32_pkg::rv32_inst_dec_t instr, int hart_id);
        rv32_opcode_enum_t    opcode    = instr.opcode   ;
        rv32_imm_t            imm       = instr.imm      ;
        rv32_register_field_t rs1       = instr.rs1      ;
        int                   addr;
        // int reg_val = `read_hart_reg(hart_id, rs1);
        int reg_val = read_hart_reg_val(hart_id, rs1);
        int read_val = 32'hDEADBEEF;
        case (opcode)
            RV32_SB     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            RV32_SH     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
            RV32_SW     : begin
                addr      = (rs1==0) ? (signed'(imm) - `PITO_DATA_MEM_OFFSET) : (reg_val+signed'(imm) - `PITO_DATA_MEM_OFFSET);
            end
        endcase
            // logger.print($sformatf("\t ->    addr[%8h] reg_val=%4d + imm=%4d - off=%d ", addr, reg_val, signed'(imm), `PITO_DATA_MEM_OFFSET));
            addr = addr >> 2;
            read_val = `hdl_path_dmem[addr];
            // logger.print($sformatf("\t -> %s is accessing mem[%8h]: %d", opcode.name, addr, read_val));
        // if (opcode==RV32_SB || opcode==RV32_SH || opcode==RV32_SW) begin
        //     logger.print($sformatf("\t -> reg_val[%2d]=%4h hart_id=%4d, addr=%4d, read_val=%4d", rs1, reg_val, hart_id, addr, read_val));
        // end
        return read_val;
    endfunction : read_dmem_word

    function automatic print_imem_region(int addr_from, int addr_to, string radix);
        string mem_val_str="";
        int mem_val;
        addr_from = addr_from;
        addr_to   = addr_to  ;
        for (int addr=addr_from; addr<=addr_to; addr+=4) begin
            mem_val = `hdl_path_dmem[addr];
            if (radix == "int") begin
                logger.print($sformatf("0x%4h: %8h", addr, mem_val));
            end else begin
                mem_val_str = $sformatf("0x%h: %d  %d  %d  %d",addr, mem_val[31:24], mem_val[23:16], mem_val[15:8], mem_val[7:0]);
                logger.print(mem_val_str);
            end
            // logger.print("test");
        end
    endfunction : print_imem_region

    function show_pipeline ();
            logger.print($sformatf("DECODE :  %s", `hdl_path_top.rv32_dec_opcode.name ));
            logger.print($sformatf("EXECUTE:  %s", `hdl_path_top.rv32_ex_opcode.name  ));
            logger.print($sformatf("WRITEB :  %s", `hdl_path_top.rv32_wb_opcode.name  ));
            logger.print($sformatf("WRITEF :  %s", `hdl_path_top.rv32_wf_opcode.name  ));
            logger.print("\n");
    endfunction 

    // The dut takes 5 clock cycle to process an instruction.
    // Before analysing the output, we first make sure we are 
    // in-sync with the processor. 
    task automatic sync_with_dut();
        bit time_out = 1;
        int NUM_WAIT_CYCELS = 100*`PITO_NUM_HARTS;
        rv32_inst_dec_t exp_instr = rv32i_dec.decode_instr(this.instr_q[0]);
        rv32_inst_dec_t act_instr; 
        logger.print($sformatf("Attempt to Sync with DUT hart id %1d...", this.hart_ids_q[0]));
        for (int cycle=0; cycle<NUM_WAIT_CYCELS; cycle++) begin
            logger.print($sformatf("hart id=%1d", `hdl_path_top.rv32_hart_wf_cnt));
            if (this.hart_ids_q[`hdl_path_top.rv32_hart_wf_cnt] == 1) begin
                act_instr       = rv32i_dec.decode_instr(`hdl_path_top.rv32_wf_instr);
                // logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", this.instr_q[0], exp_instr.opcode.name, `hdl_path_top.rv32_wf_instr, act_instr.opcode.name));
                logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", this.instr_q[0], exp_instr.opcode.name, `hdl_path_top.rv32_wf_instr, act_instr.opcode.name));
                // if (`hdl_path_top.rv32_wf_opcode == exp_instr.opcode) begin
                if (exp_instr.opcode.name == act_instr.opcode.name) begin
                    time_out = 0;
                    break;
                end
            end
            @(posedge inf.clk);
        end
        if (time_out) begin
            foreach(this.hart_ids_q[i]) begin
                if (this.hart_ids_q[i]==1) begin
                    logger.print_banner($sformatf("Failed to sync with DUT hart id %1d after %4d cycles.", i, NUM_WAIT_CYCELS), "ERROR");
                    $finish;
                end
            end
        end else begin
            foreach(this.hart_ids_q[i]) begin
                if (this.hart_ids_q[i]==1) begin
                    logger.print($sformatf("Sync with DUT hart id %1d completed...", i));
                end
            end
        end
    endtask

    function void show_regs(int hart_id, data_q_t regs_to_monitor);
        rv32_regfile_t regs;
        int idx=0;
        string temp_str = "";
        int pc;
        regs = read_regs(hart_id);
        if (regs_to_monitor.size()==0) begin
            for (int i=0; i<4; i++) begin
                for (int j=0; j<8; j++) begin
                    idx = j + i*8;
                    temp_str = $sformatf("%s  %4s: 0x%8h", temp_str, rv32_abi_reg_s[idx], regs[idx]);
                end
                logger.print($sformatf("%s", temp_str));
                temp_str = "";
            end
        end else begin
            foreach (regs_to_monitor[i]) begin
                idx = regs_to_monitor[i];
                temp_str = $sformatf("%s  %4s: 0x%8h", temp_str, rv32_abi_reg_s[idx], regs[idx]);
            end
            pc = `hdl_path_top.rv32_wf_pc[0];
            temp_str = $sformatf("%s  %4s: 0x%8h", temp_str, "pc", pc);
            logger.print($sformatf("%s", temp_str));
        end
    endfunction

    function void show_stack(int start_addr);
        int addr=0;
        int read_val;
        string temp_str = "";
        start_addr = start_addr >> 2;
        for (int i=0; i<8; i++) begin
            for (int j=0; j<4; j++) begin
                addr = start_addr - (j + i*4);
                read_val = `hdl_path_dmem[addr];
                temp_str = $sformatf("%s  %4h: 0x%8h", temp_str, addr, read_val);
            end
            logger.print($sformatf("%s", temp_str));
            temp_str = "";
        end
    endfunction

    task automatic monitor_uart();
        string str= $sformatf("");
        int char;
        logger.print("Monitoring UART ...");
        while (1) begin
            @(posedge `hdl_path_soc_top.uart_busy);
            char = `hdl_path_soc_top.uart_data_in[7:0];
            if (char==10) begin
                logger.print($sformatf("%s", str));
                str  = $sformatf("");
            end else begin
                str = $sformatf("%s%s", str, string'(char));
            end
        end
    endtask

    task automatic monitor_instructions();
        int hart_valid = 0;
        rv32_opcode_enum_t rv32_wf_opcode;
        rv32_inst_dec_t instr;
        rv32_instr_t    act_instr;
        rv32_pc_cnt_t   pc_cnt, pc_orig_cnt;
        int hart_id;
        logic is_sim_end = 1'b0;
        while(is_sim_end == 1'b0) begin
            if (hart_ids_q[`hdl_path_top.rv32_hart_wf_cnt] == 1) begin
                pc_cnt         = `hdl_path_top.rv32_wf_pc[`hdl_path_top.rv32_hart_wf_cnt];
                pc_orig_cnt    = `hdl_path_top.rv32_org_wf_pc;
                act_instr      = `hdl_path_top.rv32_wf_instr;
                instr          = this.rv32i_dec.decode_instr(act_instr);
                hart_valid     = 1;
                hart_id        = `hdl_path_top.rv32_hart_wf_cnt;
            end
            @(negedge inf.clk);
            if (hart_valid == 1) begin
                rv32i_pred.predict(act_instr, instr, pc_cnt, pc_orig_cnt, read_regs(hart_id), read_csrs(hart_id), read_dmem_word(instr, hart_id), hart_id);
                hart_valid = 0;
            end
            is_sim_end = ((`hdl_path_top.rv32_wf_opcode ==  rv32_pkg::RV32_ECALL) || (`hdl_path_top.rv32_wf_opcode ==  rv32_pkg::RV32_EBREAK)) ? 1'b1 : 1'b0;
        end
        logger.print($sformatf("Exception signal was received from HART[%0d] code name: %s, %8h", hart_id, `hdl_path_top.rv32_wf_opcode.name, `hdl_path_top.rv32_wf_opcode));
    endtask

    task automatic run();
        data_q_t regs_to_monitor;
        regs_to_monitor.push_back(rv32_abi_reg_i["ra"]);
        regs_to_monitor.push_back(rv32_abi_reg_i["sp"]);
        logger.print("Starting Monitor Task");
        logger.print("Monitoring the following harts:");
        foreach(this.hart_ids_q[i]) begin
            if (this.hart_ids_q[i]==1) begin
                logger.print($sformatf("\tHart[%0d]", i));
            end
        end
        this.sync_with_dut();
        fork
            monitor_instructions();
            monitor_uart();
        join_any
    endtask

endclass
