
class irq_tester extends testbench_base;

    function new(Logger logger, virtual pito_interface inf, string firmware="Null.hex");
        firmware = "firmware/irq.hex";
        super.new(logger, firmware, inf);
    endfunction

    task automatic raise_irq(int hart_id);
        #10us;
        mvu_irq[hart_id] = 1;
        logger.print($sformatf("Raising MVU IRQ on Hart[%0d]", hart_id));
        #100ns;
        mvu_irq[hart_id] = 0;
        @(negedge clk);
    endtask

    task tb_setup();
        super.tb_setup();
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
            raise_irq(0);
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass
