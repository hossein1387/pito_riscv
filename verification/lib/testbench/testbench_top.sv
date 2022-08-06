`timescale 1ns/1ps
`include "rv32_defines.svh"

`ifdef TB_CORE
    `include "core_tester.sv"
`elsif TB_IRQ
    `include "irq_tester.sv"
`else
    `include "core_tester.sv"
`endif

module testbench_top import utils::*; ();
//==================================================================================================
// Test variables
    Logger logger;
    string sim_log_file = "core_tester.log";
//==================================================================================================
    logic clk;
    pito_soc_ext_interface pito_inf(clk);
    APB #(
        .ADDR_WIDTH(pito_pkg::APB_ADDR_WIDTH), 
        .DATA_WIDTH(pito_pkg::APB_DATA_WIDTH)
    ) apb_master();
    pito_soc soc(
        .sys_clk_i   (pito_inf.clk         ),
        .rst_n_i     (pito_inf.rst_n       ),
        .mvu_irq_i   (pito_inf.mvu_irq     ),
        .dmem_wdata_i(pito_inf.dmem_wdata  ),
        .dmem_rdata_o(pito_inf.dmem_rdata  ),
        .dmem_addr_i (pito_inf.dmem_addr   ),
        .dmem_req_i  (pito_inf.dmem_req    ),
        .dmem_we_i   (pito_inf.dmem_we     ),
        .dmem_be_i   (pito_inf.dmem_be     ),
        .imem_wdata_i(pito_inf.imem_wdata  ),
        .imem_rdata_o(pito_inf.imem_rdata  ),
        .imem_addr_i (pito_inf.imem_addr   ),
        .imem_req_i  (pito_inf.imem_req    ),
        .imem_we_i   (pito_inf.imem_we     ),
        .imem_be_i   (pito_inf.imem_be     ),
        .uart_rx_i   (pito_inf.uart_rx     ),
        .uart_tx_o   (pito_inf.uart_tx     ),
        .mvu_apb     (apb_master           ));
    // interface_tester tb;
    `ifdef TB_CORE
        core_tester tb;
    `elsif TB_IRQ
        irq_tester tb;
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
