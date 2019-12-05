import utils::*;
import rv32_utils::*;

module core_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    string program_hex_file = "test.hex";
    string sim_log_file     = "core_tester.log";
//==================================================================================================
// DUT Signals
    logic              clk;
    logic              rst_n;  // Asynchronous reset active low
    rv32_imem_addr_t     imem_addr;
    rv32_instr_t       imem_data;
    rv32_dmem_addr_t     dmem_addr;
    rv32_data_t        dmem_data;
    logic              imem_w_en;
    logic              dmem_w_en;
    logic              pito_program;

    rv32_core core(
                    .rv32_io_clk       (clk            ),
                    .rv32_io_rst_n     (rst_n          ),
                    .rv32_io_imem_addr (imem_addr      ),
                    .rv32_io_imem_data (imem_data      ),
                    .rv32_io_dmem_addr (dmem_addr      ),
                    .rv32_io_dmem_data (dmem_data      ),
                    .rv32_io_imem_w_en (imem_w_en      ),
                    .rv32_io_dmem_w_en (dmem_w_en      ),
                    .rv32_io_program   (pito_program   )
    );

    task write_instr_to_ram(rv32_instr_q instr_q);
        @(posedge clk);
        imem_w_en = 1'b1;
        @(posedge clk);
        logger.print_banner($sformatf("Writing %6d instructions to the RAM", instr_q.size()));
        logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        for (int i=0; i<instr_q.size(); i++) begin
            @(posedge clk);
            imem_data = instr_q[i];
            imem_addr = i;
            logger.print($sformatf("[%4d]: 0x%8h     %s", i, instr_q[i], get_instr_str(rv32i_dec.decode_instr(instr_q[i]))));
        end
        @(posedge clk);
        imem_w_en = 1'b0;
    endtask

    function rv32_regfile_t read_regs();
        rv32_regfile_t regs;
        for (int i=0; i<`NUM_REGS; i++) begin
            regs[i] = core.regfile.data[i];
        end
        return regs;
    endfunction : read_regs

    function show_pipeline ();
            logger.print($sformatf("DECODE :  %s", core.rv32_dec_opcode.name ));
            logger.print($sformatf("EXECUTE:  %s", core.rv32_ex_opcode.name  ));
            logger.print($sformatf("WRITEB :  %s", core.rv32_wb_opcode.name  ));
            logger.print($sformatf("WRITEF :  %s", core.rv32_wf_opcode.name  ));
            logger.print($sformatf("CAP    :  %s", core.rv32_cap_opcode.name  ));
            logger.print("\n");
    endfunction 
    // The dut takes 5 clock cycle to process an instruction.
    // Before analysing the output, we first make sure we are 
    // in-sync with the processor. 
    task automatic sync_with_dut(rv32_instr_q instr_q);
        bit time_out = 1;
        int NUM_WAIT_CYCELS = 100;
        rv32_inst_dec_t exp_instr = rv32i_dec.decode_instr(instr_q[0]);
        rv32_inst_dec_t act_instr; 
        logger.print("Attempt to Sync with DUT...");
        for (int cycle=0; cycle<NUM_WAIT_CYCELS; cycle++) begin
            act_instr       = rv32i_dec.decode_instr(core.rv32_wf_instr);
            logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", instr_q[0], exp_instr.opcode.name, core.rv32_wf_instr, act_instr.opcode.name));
            if (core.rv32_cap_opcode == exp_instr.opcode) begin
                time_out = 0;
                break;
            end
            @(posedge clk);
        end
        if (time_out) begin
            logger.print($sformatf("Failed to sync with DUT after %4d cycles.", NUM_WAIT_CYCELS), "ERROR");
            $finish;
        end else begin
            logger.print("Sync with DUT completed...");
        end
    endtask

    task automatic monitor_pito(rv32_instr_q instr_q);
        bit all_instr_processed = 0;
        rv32_inst_dec_t instr;
        rv32_instr_t    exp_instr;
        rv32_instr_t    act_instr;
        rv32_pc_cnt_t   pc_cnt, pc_orig_cnt;
        logger.print_banner("Starting Monitor Task");
        sync_with_dut(instr_q);
        while(all_instr_processed!=1) begin
            // logger.print($sformatf("pc=%d       decode:%s", core.rv32_dec_pc, core.rv32_dec_opcode.name));
            // logger.print($sformatf("%s",read_regs()));
            exp_instr   = instr_q.pop_front();
            all_instr_processed = (instr_q.size()==0) ? 1 : 0;
            pc_cnt      = core.rv32_wf_pc;
            pc_orig_cnt = core.rv32_org_wf_pc;
            act_instr   = core.rv32_wf_instr;
            // logger.print($sformatf("Decoding %h", core.rv32_wf_instr));
            instr       = rv32i_dec.decode_instr(act_instr);
            @(posedge clk);
            rv32i_pred.predict(act_instr, instr, pc_cnt, pc_orig_cnt, read_regs());
            @(negedge clk);
        end
        if (all_instr_processed) begin
            logger.print_banner("All instructions were processed.");
        end else begin
            logger.print_banner("Failed to process all instructions.");
        end
    endtask

    task monitor_regs();
        Logger reg_logger = new("reg_logs.log", 1, 0);
        @(posedge clk);
        while(1) begin
            reg_logger.print($sformatf("\n%s\n", reg_file_to_str(read_regs())));
            @(posedge clk);
        end
    endtask

    initial begin
        rv32_instr_q instr_q;
        rst_n        = 1'b1;
        dmem_w_en    = 1'b0;
        imem_w_en    = 1'b0;
        imem_addr    = 32'b0;
        dmem_addr    = 32'b0;
        pito_program = 0;

        logger = new(sim_log_file);
        rv32i_dec = new(logger);
        rv32i_pred = new(logger);

        instr_q = process_hex_file(program_hex_file, logger, 100); // read hex file and store the first 100 words to the ram

        @(posedge clk);
        rst_n     = 1'b0;
        @(posedge clk);
        write_instr_to_ram(instr_q);
        @(posedge clk);
        rst_n     = 1'b1;
        @(posedge clk);
        fork
            monitor_pito(instr_q);
            monitor_regs();
        join_any
        rv32i_pred.report_result();
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #2000ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
