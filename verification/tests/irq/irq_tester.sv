`include "testbench_base.sv"

import pito_pkg::*;

class irq_tester extends pito_testbench_base;

    function new(Logger logger, virtual pito_soc_ext_interface inf, pito_pkg::axi_master_drv_t axi_master_dv);
        super.new(logger, inf, axi_master_dv, {}, 1);
    endfunction

    task automatic check_irq();
        for (int hart_id=pito_pkg::NUM_HARTS-1; hart_id>-1; hart_id--) begin
            #200us;
            inf.mvu_irq[hart_id] = 1;
            logger.print($sformatf("irq_tester::raise_irq(): Raising MVU IRQ on Hart[%0d]", hart_id));
            @(posedge inf.clk);
            inf.mvu_irq[hart_id] = 0;
            @(posedge inf.clk);
            @(posedge inf.clk);
            @(posedge inf.clk);
            @(posedge inf.clk);
        end
        #1000ms;
    endtask

    task tb_setup();
        super.tb_setup();
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
            check_irq();
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass

