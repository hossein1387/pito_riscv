`include "testbench_base.sv"

class core_tester extends pito_testbench_base;

    function new(Logger logger, virtual pito_interface inf);
        super.new(logger, inf);
    endfunction

    task tb_setup();
        super.tb_setup();
    endtask

    task monitor_instr();
        while (1) begin
            @(posedge `hdl_path_top.clk)
                this.logger.print($sformatf("%8h", `hdl_path_top.rv32_wf_instr));
                // logger.print($sformatf("exp=0x%8h: %s        actual=0x%8h: %s", this.instr_q[0], exp_instr.opcode.name, `hdl_path_top.rv32_wf_instr, act_instr.opcode.name));
        end
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
            monitor_instr(); 
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass

