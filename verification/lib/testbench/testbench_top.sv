`timescale 1ns/1ps
`include "core_tester.sv"
`include "rv32_defines.svh"
module testbench_top import utils::*; ();
//==================================================================================================
// Test variables
    Logger logger;
    string sim_log_file = "core_tester.log";
//==================================================================================================
    logic clk;
    pito_soc_ext_interface pito_inf(clk);
    mvu_csr_interface mvu_inf();
    APB #(
        .ADDR_WIDTH(pito_pkg::APB_ADDR_WIDTH), 
        .DATA_WIDTH(pito_pkg::APB_DATA_WIDTH)
    ) apb_master();
    pito_soc soc(pito_inf.soc_ext,
                 mvu_inf,
                 apb_master);
    // interface_tester tb;
    core_tester tb;
    initial begin
        logger = new(sim_log_file);
        tb = new(logger, pito_inf.tb);
        tb.tb_setup();
        tb.run();
        tb.report();
        $finish();

    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((`CLOCK_SPEED_NS)*1ns) clk = !clk;
        end
    end

    initial begin
        #1000ms;
        $display("Simulation took more than expected ( more than 1ms)");
        $finish();
    end
endmodule
