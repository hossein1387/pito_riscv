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


    AXI_BUS #(
        .AXI_ADDR_WIDTH(pito_pkg::AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(pito_pkg::AXI_DATA_WIDTH),
        .AXI_ID_WIDTH  (pito_pkg::AXI_ID_WIDTH  ),
        .AXI_USER_WIDTH(pito_pkg::AXI_USER_WIDTH)
    ) axi_master();

    AXI_BUS_DV #(
        .AXI_ADDR_WIDTH(pito_pkg::AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH(pito_pkg::AXI_DATA_WIDTH),
        .AXI_ID_WIDTH  (pito_pkg::AXI_ID_WIDTH  ),
        .AXI_USER_WIDTH(pito_pkg::AXI_USER_WIDTH)
    ) axi_master_dv(clk);
    

    pito_pkg::axi_master_drv_t axi_master_drv = new(axi_master_dv);

    `AXI_ASSIGN(axi_master, axi_master_dv)
    
    pito_soc soc(
        .sys_clk_i   (pito_inf.clk         ),
        .rst_n_i     (pito_inf.rst_n       ),
        .mvu_irq_i   (pito_inf.mvu_irq     ),
        .uart_rx_i   (pito_inf.uart_rx     ),
        .uart_tx_o   (pito_inf.uart_tx     ),
        .m_axi       (axi_master           ),
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
        tb = new(logger, pito_inf.tb, axi_master_drv);
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
