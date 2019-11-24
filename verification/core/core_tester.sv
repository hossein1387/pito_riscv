import utils::*;
import rv32_utils::*;

module core_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    string program_hex_file = "lui.hex";
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
        for (int i=0; i<instr_q.size(); i++) begin
            @(posedge clk);
            imem_data = instr_q[i];
            imem_addr = i;
            logger.print($sformatf("%s", get_instr_str(rv32i_dec.decode_instr(instr_q[i]))));
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

    task monitor_pito(rv32_instr_q instr_q);
        rv32_inst_dec_t instr;
        rv32_regfile_t  regs;
        rv32_pc_cnt_t     pc_cnt, pc_orig_cnt;
        logger.print_banner("Starting Monitor Task");
        @(posedge clk);
        for (int i=0; i<100; i++) begin
            // logger.print($sformatf("pc=%d       decode:%s", core.rv32_dec_pc, core.rv32_dec_opcode.name));
            // logger.print($sformatf("%s",read_regs()));
            pc_cnt      = core.rv32_cap_pc;
            pc_orig_cnt = core.rv32_org_cap_pc;
            instr       = rv32i_dec.decode_instr(core.rv32_cap_instr);
            regs        = read_regs();
            rv32i_pred.predict(instr, regs, pc_cnt, pc_orig_cnt);
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

        instr_q = process_hex_file(program_hex_file, logger);

        @(posedge clk);
        rst_n     = 1'b0;
        @(posedge clk);
        write_instr_to_ram(instr_q);
        @(posedge clk);
        rst_n     = 1'b1;
        @(posedge clk);
        monitor_pito(instr_q);
        rv32i_pred.report_result();
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
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
