`include "testbench_base.sv"

class core_tester extends pito_testbench_base;

    function new(Logger logger, virtual pito_soc_ext_interface inf);
        super.new(logger, inf, {}, 1);
    endfunction

    task tb_setup();
        super.tb_setup();
    endtask

    task monitor_instr();
        while (1) begin
            @(posedge `hdl_path_top.clk)
            this.logger.print($sformatf("%8h", `hdl_path_top.rv32_wf_instr));
        end
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass

