class interface_tester extends base_testbench;

    function new(Logger logger, string firmware, virtual pito_interface inf);
        super.new(logger, firmware, inf);
    endfunction

    task tb_setup();
        super.tb_setup();
    endtask

    virtual task run();
        super.run();
    endtask 


endclass