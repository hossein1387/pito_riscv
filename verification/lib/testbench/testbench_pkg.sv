package testbench_pkg;

class BaseObj;
    Logger logger;
   function new (Logger logger);
      this.logger = logger;
   endfunction
endclass

class base_testbench extends BaseObj;

    string firmware;
    pito_interface inf;
    rv32_data_q instr_q;
    monitor_pkg::pito_monitor monitor;
    int hart_ids_q[$]; // hart id to monitor

    function new (Logger logger, string firmware, virtual pito_interface inf);
        super.new (logger);
        this.firmware = firmware;
        this.inf = inf;
        // read hex file and store the first n words to the ram
        instr_q = process_hex_file(program_hex_file, logger, `NUM_INSTR_WORDS); 
        

        // Initialize harts in the system
        for (int i=0; i<`PITO_NUM_HARTS; i++) begin
            hart_ids_q.push_back(0);
        end
        // Enables those to monitor:
        hart_ids_q[0] = 1;

        monitor = new(this.logger, this.instr_q, this.inf, this.hart_ids_q);
    endfunction


    function automatic rv32_data_q process_hex_file(string hex_file, Logger logger, int nwords);
        int fd = $fopen (hex_file, "r");
        string instr_str, temp, line;
        rv32_data_q instr_q;
        int word_cnt = 0;
        if (fd)  begin logger.print($sformatf("%s was opened successfully : %0d", hex_file, fd)); end
        else     begin logger.print($sformatf("%s was NOT opened successfully : %0d", hex_file, fd)); $finish(); end
        while (!$feof(fd) && word_cnt<nwords) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr_q.push_back(rv32_instr_t'(instr_str.atohex()));
                word_cnt += 1;
            end
        end
        return instr_q;
    endfunction

    task write_data_to_ram(rv32_data_q data_q);
        for (int i=0; i<data_q.size(); i++) begin
            core.d_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[i] = data_q[i];
        end
    endtask

    task write_instr_to_ram(int backdoor, int log_to_console);
        if(log_to_console) begin
            logger.print_banner($sformatf("Writing %6d instructions to the RAM", this.instr_q.size()));
            logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        end
        if (backdoor == 1) begin
            for (int addr=0 ; addr<this.instr_q.size(); addr++) begin
                core.i_mem.bram_32Kb_inst.inst.native_mem_module.blk_mem_gen_v8_4_3_inst.memory[addr] = this.instr_q[addr];
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, this.instr_q[addr], get_instr_str(rv32i_dec.decode_instr(this.instr_q[addr]))));
                end
            end
        end else begin
            @(posedge inf.clk);
            inf.pito_io_imem_w_en = 1'b1;
            @(posedge inf.clk);
            for (int addr=0; addr<this.instr_q.size(); addr++) begin
                @(posedge inf.clk);
                inf.pito_io_imem_data = this.instr_q[addr];
                inf.pito_io_imem_addr = addr;
                if(log_to_console) begin
                    logger.print($sformatf("[%4d]: 0x%8h     %s", addr, this.instr_q[addr], get_instr_str(rv32i_dec.decode_instr(this.instr_q[addr]))));
                end
            end
            @(posedge inf.clk);
            inf.pito_io_imem_w_en = 1'b0;
        end
    endtask
endclass

endpackage