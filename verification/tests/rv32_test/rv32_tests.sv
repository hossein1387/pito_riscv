`include "testbench_base.sv"

class rv32_tests extends pito_testbench_base;
    const string rv32i_base_path = "/users/hemmat/MyRepos/pito_riscv/csrc/riscv_test_regression";
    int NUM_RV32I_TESTS = 35;
    string all_rv32i_tests [35] = '{"addi","and","andi","auipc","beq","bge","bgeu","blt","bltu",
                                  "bne","j","jal","jalr","lb","lbu","lh","lhu","lui",
                                  "lw","or","ori","sb","sh","sll","slli","slt","slti","sra","srai",
                                  "srl","srli","sub","sw","xor","xori"};
    function new(Logger logger, virtual pito_soc_ext_interface inf);
        super.new(logger, inf, {}, 1);
    endfunction

    task reset_and_program_pito(input rv32_pkg::rv32_data_q instr_q);
        logger.print("Putting PITO to reset mode");
        inf.pito_io_rst_n     = 1'b1;
        inf.pito_io_dmem_w_en = 1'b0;
        inf.pito_io_imem_w_en = 1'b0;
        inf.pito_io_imem_addr = 32'b0;
        inf.pito_io_dmem_addr = 32'b0;
        inf.pito_io_program   = 0;
        inf.mvu_irq_i         = 0;
        this.instr_q          = instr_q;

        @(posedge inf.clk);
        inf.pito_io_rst_n = 1'b0;
        @(posedge inf.clk);

        super.write_instr_to_ram(1, 0);
        super.write_data_to_ram(instr_q);

        @(posedge inf.clk);
        inf.pito_io_rst_n = 1'b1;
        @(posedge inf.clk);
    endtask

    task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Put DUT to reset and relax memory interface
        logger.print("Putting DUT to reset mode");
        inf.pito_io_rst_n     = 1'b1;
        inf.pito_io_dmem_w_en = 1'b0;
        inf.pito_io_imem_w_en = 1'b0;
        inf.pito_io_imem_addr = 32'b0;
        inf.pito_io_dmem_addr = 32'b0;
        inf.pito_io_program   = 0;
        inf.mvu_irq_i         = 0;
        logger.print("Setup Phase Done ...");
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        for (int test_num=0; test_num<NUM_RV32I_TESTS; test_num++) begin
            string test_name = all_rv32i_tests[test_num];
            firmware = $sformatf("%s/%s.hex", rv32i_base_path, test_name, test_name);
            instr_q = process_hex_file(firmware, logger, `NUM_INSTR_WORDS); 
            reset_and_program_pito(instr_q);
            this.monitor.run();
            check_rv32i_test_result(test_name);
        end
    endtask

    function void check_rv32i_test_result(string test_name);
        byte char_0 = `hdl_path_regf_0[rv32_abi_reg_i["a0"]];
        byte char_1 = `hdl_path_regf_0[rv32_abi_reg_i["a1"]];
        byte char_2 = `hdl_path_regf_0[rv32_abi_reg_i["a2"]];
        byte char_3 = `hdl_path_regf_0[rv32_abi_reg_i["a3"]];
        int  t_num  = `hdl_path_regf_0[rv32_abi_reg_i["t3"]];
        // check if the test has failed, if yes, print the test number
        if (char_1==69 && char_2==82 && char_3==79) begin 
            logger.print($sformatf("Testing %s failed at test:%2d", test_name, t_num));
        end
        logger.print_banner($sformatf("Testing %s was %s%s%s", test_name, char_0, char_1, char_2));
    endfunction

    task report();
        test_stats_t test_stat = this.monitor.get_results();
        logger.print_banner("Testbench Report phase");
        print_result(test_stat, VERB_LOW, logger);
    endtask

endclass

