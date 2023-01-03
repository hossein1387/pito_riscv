`include "rv32_defines.svh"
`include "testbench_macros.svh"
`include "testbench_config.sv"
`include "pito_monitor.sv"
`include "axi/assign.svh"

import utils::*;
import rv32_pkg::*;
import rv32_utils::*;
import pito_pkg::*;

class pito_testbench_base extends BaseObj;

    string firmware;
    string rodata;
    virtual pito_soc_ext_interface inf;
    pito_pkg::axi_master_drv_t axi_master_drv;
    rv32_pkg::rv32_data_q instr_q;
    rv32_pkg::rv32_data_q rodata_q;
    pito_monitor monitor;
    int hart_ids_q[$]; // hart id to monitor
    rv32_utils::RV32IDecoder rv32i_dec;
    test_stats_t test_stat;
    tb_config cfg;
    logic predictor_silent_mode;
    
    axi_master_drv_t::ax_beat_t aw_beat = new, ar_beat = new;
    axi_master_drv_t::w_beat_t w_beat = new;
    axi_master_drv_t::b_beat_t b_beat;
    axi_master_drv_t::r_beat_t r_beat;

    function new (Logger logger, virtual pito_soc_ext_interface inf, pito_pkg::axi_master_drv_t axi_master_dv, int hart_mon_en[$]={}, logic predictor_silent_mode=0, logic rv_reg_tests=0);
        super.new(logger);
        cfg = new(logger);
        void'(cfg.parse_args());
        this.inf = inf;
        this.axi_master_drv = axi_master_dv;

        this.predictor_silent_mode = predictor_silent_mode;
        // For RISC-V regression tests, we initialize ram at run stage
        if (rv_reg_tests==0) begin
            this.firmware = cfg.firmware;
            this.rodata = cfg.rodata;
            // read hex file and store the first n words to the ram
            instr_q = process_hex_file(firmware, logger, `NUM_INSTR_WORDS); 
            rodata_q = process_hex_file(rodata, logger, `NUM_INSTR_WORDS); 
        end

        // Check if user has requested to monitor any particular hart/s
        if (hart_mon_en.size()==0) begin
            // Initialize harts in the system
            for (int i=0; i<`PITO_NUM_HARTS; i++) begin
                hart_ids_q.push_back(0);
            end
            // Enables those to monitor:
            hart_ids_q[0] = 1;
        end else begin
            this.hart_ids_q = hart_mon_en;
        end
        monitor = new(this.logger, this.instr_q, this.rodata_q, this.inf, this.hart_ids_q, this.test_stat, predictor_silent_mode);
        this.rv32i_dec = new(this.logger);
    endfunction

    function automatic rv32_data_q process_hex_file(string hex_file, Logger logger, int nwords);
        int fd = $fopen (hex_file, "r");
        string instr_str, temp, line;
        rv32_data_q instr_q;
        int word_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", hex_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", hex_file, fd)); $finish(); end
        while (!$feof(fd) && word_cnt<nwords) begin
            temp = string'($fgets(line, fd));
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr_q.push_back(rv32_instr_t'(instr_str.atohex()));
                word_cnt += 1;
            end
        end
        return instr_q;
    endfunction

    // task write_data_to_ram(rv32_data_q data_q);
    //     for (int i=0; i<data_q.size(); i++) begin
    //         `hdl_path_dmem_init[i] = data_q[i];
    //     end
    // endtask

    task write_instr_to_ram(input int backdoor, input int log_to_console, input int base_addr, input int wordsz);
        real percentile=0;
        int num_words = this.instr_q.size();
        int axi_len = 255;
        int axi_word_sz = 4;

        percentile = real'(num_words)/real'(`PITO_INSTR_MEM_SIZE) * 100.0;
        logger.print($sformatf("Writing %6d (%2.2f) instruction words to the Instruction RAM", num_words, percentile));
        if (num_words>=`PITO_INSTR_MEM_SIZE) begin
            logger.print("Memory instruction is FULL. Aborting simulation");
            $finish();
        end
        if(log_to_console) begin
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<num_words; addr++) begin
                `hdl_path_imem_init[addr] = this.instr_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, this.instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(this.instr_q[addr]))));
                end
            end
        end else begin
            @(posedge inf.clk);
            fork
                begin
                    aw_beat.ax_addr = base_addr;
                    for (int addr=0; addr<num_words; addr+=axi_len) begin
                        logger.print($sformatf("preparing AW beat for addr=%0d ...", aw_beat.ax_addr));
                        aw_beat.ax_id   = 0;
                        aw_beat.ax_len  = axi_len;
                        aw_beat.ax_size = $clog2(4);
                        aw_beat.ax_burst= axi_pkg::BURST_INCR;
                        axi_master_drv.send_aw(aw_beat);
                        aw_beat.ax_addr += axi_len*axi_word_sz;
                    end
                end
                begin
                    for (int wrd_num=0; wrd_num<num_words; wrd_num++) begin
                        w_beat.w_data = instr_q[wrd_num];
                        w_beat.w_strb = '1;
                        w_beat.w_last = ((wrd_num+1) == num_words);
                        logger.print($sformatf("preparing W beat %0d/%0d ...", wrd_num, num_words));
                        axi_master_drv.send_w(w_beat);
                        if (w_beat.w_last) begin
                            logger.print($sformatf("Final W beat #%0d", wrd_num));
                        end else begin
                            logger.print($sformatf("Done writing at %0d ...", wrd_num));
                        end
                        if(log_to_console) begin
                            logger.print($sformatf("[%4d]: 0x%8h     %s", wrd_num, instr_q[wrd_num], rv32_utils::get_instr_str(rv32i_dec.decode_instr(instr_q[wrd_num]))));
                        end
                    end
                end
                begin
                    for (int wrd_num=0; wrd_num<num_words; wrd_num+=axi_len) begin
                        axi_master_drv.recv_b(b_beat);
                    end
                end
            join

            // inf.imem_we = 1'b1;
            // @(posedge inf.clk);
            // for (int addr=0; addr<instr_q.size(); addr++) begin
            //     @(posedge inf.clk);
            //     inf.imem_wdata = instr_q[addr];
            //     inf.imem_addr = addr;
            //     if(log_to_console) begin
            //         logger.print($sformatf("[%4d]: 0x%8h     %s", addr, instr_q[addr], rv32_utils::get_instr_str(rv32i_dec.decode_instr(instr_q[addr]))));
            //     end
            // end
            // @(posedge inf.clk);
            // inf.imem_we = 1'b0;
        end
    endtask

    task write_data_to_ram(int backdoor, int log_to_console);
        logger.print($sformatf("Writing %6d data words to the Data RAM", this.rodata_q.size()));
        if (backdoor == 1) begin
            for (int addr=0 ; addr<this.rodata_q.size(); addr++) begin
                `hdl_path_dmem_init[addr] = this.rodata_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h", addr, this.rodata_q[addr]));
                end
            end
        end else begin
            @(posedge inf.clk);
            inf.dmem_we = 1'b1;
            @(posedge inf.clk);
            for (int addr=0; addr<this.rodata_q.size(); addr++) begin
                @(posedge inf.clk);
                inf.dmem_wdata = this.rodata_q[addr];
                inf.dmem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h", addr, this.rodata_q[addr]));
                end
            end
            @(posedge inf.clk);
            inf.dmem_we = 1'b0;
        end
    endtask

    virtual task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Put DUT to reset and relax memory interface
        logger.print("Putting DUT to reset mode");
        inf.rst_n        = 1'b1;
        inf.dmem_we      = 1'b0;
        inf.dmem_be      = 4'b1111;
        inf.dmem_req     = 1'b0;
        inf.dmem_addr    = {`PITO_DATA_ADDR_WIDTH{1'b0}};
        inf.dmem_wdata   = 32'b0;
        inf.imem_we      = 1'b0;
        inf.imem_be      = 4'b1111;
        inf.imem_req     = 1'b0;
        inf.imem_addr    = {`PITO_INSTR_ADDR_WIDTH{1'b0}};
        inf.imem_wdata   = 32'b0;

        for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
            inf.mvu_irq[hart_id] = 0;
        end

        @(posedge inf.clk);
        inf.rst_n = 1'b0;
        @(posedge inf.clk);

        @(posedge inf.clk);
        inf.rst_n = 1'b1;
        @(posedge inf.clk);

        axi_master_drv.reset_master();
        this.write_instr_to_ram(0, 0, 32'h0020_0000, 4);
        this.write_data_to_ram(1, 1);

        logger.print("Setup Phase Done ...");
    endtask

    virtual task run();
        logger.print_banner("Testbench Run phase");
        logger.print("Run method is not implemented");
        logger.print("Run phase done ...");
    endtask 

    virtual task report();
        test_stats_t test_stat = this.monitor.get_results();
        int total_num_instr=0;
        logger.print_banner("Testbench Report phase");
        `ifdef RV32_TEST
            print_result(test_stat, VERB_MEDIUM, logger);
            for (int hart=0; hart<NUM_HARTS; hart++) begin
                if (this.hart_ids_q[hart] == 1) begin
                    byte char_0 = `hdl_path_regf_0[rv32_abi_reg_i["a0"]];
                    byte char_1 = `hdl_path_regf_0[rv32_abi_reg_i["a1"]];
                    byte char_2 = `hdl_path_regf_0[rv32_abi_reg_i["a2"]];
                    byte char_3 = `hdl_path_regf_0[rv32_abi_reg_i["a3"]];
                    int  t_num  = `hdl_path_regf_0[rv32_abi_reg_i["t3"]];
                    logger.print($sformatf("RISC-V TEST Result:%s%s%s%s", char_0, char_1, char_2, char_3));
                    // check if the test has failed, if yes, print the test number
                    if (char_1==69 && char_2==82 && char_3==79) begin 
                        logger.print($sformatf("Failed at test:%2d", t_num));
                    end
                end
            end
        `else
            total_num_instr = test_stat.pass_cnt+test_stat.fail_cnt;
            logger.print($sformatf("Total number of instructions: %d", total_num_instr));
        `endif
    endtask

endclass
