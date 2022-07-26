`include "testbench_base.sv"

import pito_pkg::*;

class irq_tester extends pito_testbench_base;

    function new(Logger logger, virtual pito_soc_ext_interface inf);
        super.new(logger, inf, {}, 1);
    endfunction

    task automatic check_irq();
        for (int hart_id=pito_pkg::NUM_HARTS-1; hart_id>-1; hart_id--) begin
            #40us;
            inf.mvu_irq[hart_id] = 1;
            logger.print($sformatf("irq_tester::raise_irq(): Raising MVU IRQ on Hart[%0d]", hart_id));
            #100ns;
            inf.mvu_irq[hart_id] = 0;
            #100us;
        end
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

