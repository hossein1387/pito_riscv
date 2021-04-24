`include "testbench_base.sv"

class irq_tester extends pito_testbench_base;

    function new(Logger logger, virtual pito_interface inf);
        super.new(logger, inf);
    endfunction

    task automatic check_irq(int hart_id);
        #40us;
        inf.mvu_irq_i[hart_id] = 1;
        logger.print($sformatf("irq_tester::raise_irq(): Raising MVU IRQ on Hart[%0d]", hart_id));
        #100ns;
        inf.mvu_irq_i[hart_id] = 0;
        #100ns;
        logger.print("irq_tester::raise_irq(): Waiting for start signal to go high");
        @(posedge inf.mvu_start)
        logger.print("irq_tester::raise_irq(): MVU start signal is high!");
    endtask

    task tb_setup();
        super.tb_setup();
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
            check_irq(0);
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass
