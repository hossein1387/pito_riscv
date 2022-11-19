`include "testbench_base.sv"

class rv32_tests extends pito_testbench_base;
    const string rv32i_base_path = "/users/hemmat/MyRepos/pito_riscv/csrc/riscv_test_regression";
    int NUM_RV32I_TESTS = 37;
    string all_rv32i_tests [37] = '{"addi","and","andi","auipc","beq","bge","bgeu","blt","bltu",
                                  "bne","j","jal","jalr","lb","lbu","lh","lhu","lui",
                                  "lw","or","ori","sb","sh","sll","slli","slt","slti","sra","srai",
                                  "srl","srli","sub","sw", "sh", "sb", "xor","xori"};
    string test_results[$];
    function new(Logger logger, virtual pito_soc_ext_interface inf);
        super.new(logger, inf, {}, 1, 1);
    endfunction

    task reset_and_program_pito(input rv32_pkg::rv32_data_q instr_q, input rv32_pkg::rv32_data_q rodata_q);
        logger.print("Putting DUT to reset mode");
        this.instr_q     = instr_q;
        this.rodata_q    = rodata_q;
        inf.rst_n        = 1'b1;
        inf.dmem_we      = 1'b0;
        inf.dmem_be      = 4'b1111;
        inf.dmem_req     = 1'b0;
        inf.dmem_addr    = {`PITO_DATA_ADDR_WIDTH{1'b0}};
        inf.dmem_wdata   = 32'b0;
        inf.imem_we      = 1'b0;
        inf.imem_be      = 4'b1111;
        inf.imem_req     = 1'b0;
        inf.imem_addr    = {`PITO_INSTR_ADDR_WIDTH{1'b0}};
        inf.imem_wdata   = 32'b0;

        @(posedge inf.clk);
        inf.rst_n = 1'b0;
        @(posedge inf.clk);

        this.write_instr_to_ram(1, 0);
        this.write_data_to_ram(1, 0);

        @(posedge inf.clk);
        inf.rst_n = 1'b1;
        @(posedge inf.clk);
    endtask

    task tb_setup();
        logger.print_banner("Testbench Setup Phase");
        // Put DUT to reset and relax memory interface
        logger.print("Putting DUT to reset mode");
        inf.rst_n        = 1'b1;
        inf.dmem_we      = 1'b0;
        inf.dmem_be      = 4'b1111;
        inf.dmem_req     = 1'b0;
        inf.dmem_addr    = {`PITO_DATA_ADDR_WIDTH{1'b0}};
        inf.dmem_wdata   = 32'b0;
        inf.imem_we      = 1'b0;
        inf.imem_be      = 4'b1111;
        inf.imem_req     = 1'b0;
        inf.imem_addr    = {`PITO_INSTR_ADDR_WIDTH{1'b0}};
        inf.imem_wdata   = 32'b0;
        for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
            inf.mvu_irq[hart_id] = 0;
        end
    endtask

    task run();
        logger.print_banner("Testbench Run phase");
        for (int test_num=0; test_num<NUM_RV32I_TESTS; test_num++) begin
            string test_name = all_rv32i_tests[test_num];
            logger.print($sformtf("Running %s ...", test_name));
            firmware = $sformatf("%s/%s_text.hex", rv32i_base_path, test_name);
            rodata = $sformatf("%s/%s_data.hex", rv32i_base_path, test_name);
            instr_q = process_hex_file(firmware, logger, `NUM_INSTR_WORDS); 
            rodata_q = process_hex_file(rodata, logger, `NUM_INSTR_WORDS); 
            this.monitor = new(this.logger, instr_q, rodata_q, this.inf, this.hart_ids_q, this.test_stat, 1);
            fork
                this.monitor.run();
                reset_and_program_pito(instr_q, rodata_q);
            join
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
            test_results.push_back("Failed");
        end else begin
            test_results.push_back("Passed");
        end
        logger.print_banner($sformatf("Testing %s was %s%s%s", test_name, char_0, char_1, char_2));
    endfunction

    task report();
        test_stats_t test_stat = this.monitor.get_results();
        logger.print_banner("Testbench Report phase");
        for (int test_num=0; test_num<NUM_RV32I_TESTS; test_num++) begin
            logger.print($sformatf("%5s     %s", all_rv32i_tests[test_num], test_results[test_num]));
        end
        print_result(test_stat, VERB_LOW, logger);
    endtask

endclass

