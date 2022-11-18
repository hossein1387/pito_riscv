`timescale 1ns/1ps
`include "rv32_defines.svh"

`ifdef TB_CORE
    `include "core_tester.sv"
`elsif TB_IRQ
    `include "irq_tester.sv"
`elsif TB_REGRESSION
    `include "rv32_tests.sv"
`else
    `include "core_tester.sv"
`endif

module testbench_top import utils::*; ();
//==================================================================================================
// Test variables
    Logger logger;
    string sim_log_file = "simulation.log";
//==================================================================================================
    logic clk;
    pito_soc_ext_interface pito_inf(clk);
    APB #(
        .ADDR_WIDTH(pito_pkg::APB_ADDR_WIDTH), 
        .DATA_WIDTH(pito_pkg::APB_DATA_WIDTH)
    ) apb_master();
    pito_soc soc(pito_inf.soc_ext,
                 apb_master);
    // interface_tester tb;
    `ifdef TB_CORE
        core_tester tb;
    `elsif TB_IRQ
        irq_tester tb;
    `elsif TB_REGRESSION
        rv32_tests tb;
    `else
        core_tester tb;
    `endif
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
