
class core_tester extends testbench_base;

    function new(Logger logger, virtual pito_interface inf, string firmware="Null.hex");
        firmware = "firmwares/add.hex";
        //firmware = "firmwares/addi.hex";
        //firmware = "firmwares/and.hex";
        //firmware = "firmwares/andi.hex";
        //firmware = "firmwares/auipc.hex";
        //firmware = "firmwares/beq.hex";
        //firmware = "firmwares/bge.hex";
        //firmware = "firmwares/bgeu.hex";
        //firmware = "firmwares/blt.hex";
        //firmware = "firmwares/bltu.hex";
        //firmware = "firmwares/bne.hex";
        //firmware = "firmwares/irq.hex";
        //firmware = "firmwares/j.hex";
        //firmware = "firmwares/jal.hex";
        //firmware = "firmwares/jalr.hex";
        //firmware = "firmwares/lb.hex";
        //firmware = "firmwares/lbu.hex";
        //firmware = "firmwares/lh.hex";
        //firmware = "firmwares/lhu.hex";
        //firmware = "firmwares/lui.hex";
        //firmware = "firmwares/lw.hex";
        //firmware = "firmwares/or.hex";
        //firmware = "firmwares/ori.hex";
        //firmware = "firmwares/sb.hex";
        //firmware = "firmwares/sh.hex";
        //firmware = "firmwares/simple.hex";
        //firmware = "firmwares/sll.hex";
        //firmware = "firmwares/slli.hex";
        //firmware = "firmwares/slt.hex";
        //firmware = "firmwares/slti.hex";
        //firmware = "firmwares/sra.hex";
        //firmware = "firmwares/srai.hex";
        //firmware = "firmwares/srl.hex";
        //firmware = "firmwares/srli.hex";
        //firmware = "firmwares/sub.hex";
        //firmware = "firmwares/sw.hex";
        //firmware = "firmwares/xor.hex";
        //firmware = "firmwares/xori.hex";
        super.new(logger, firmware, inf);
    endfunction

    task tb_setup();
        super.tb_setup();
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        fork
            this.monitor.run();
            // monitor_regs();
        join_any
    endtask

    task report();
        super.report();
    endtask

endclass

