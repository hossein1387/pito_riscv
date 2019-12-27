import utils::*;
import rv32_utils::*;

module mem_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    rv32_utils::RV32IDecoder rv32i_dec;
    rv32_utils::RV32IPredictor rv32i_pred;
    string program_hex_file = "test.hex";
    string sim_log_file     = "core_tester.log";
//==================================================================================================
// DUT Signals
logic            clk;
rv32_dmem_addr_t rv32_iw_addr;
rv32_data_t      rv32_iw_data;
logic            rv32_iw_en  ;
rv32_dmem_addr_t rv32_ir_addr;
rv32_data_t      rv32_ir_data;

rv32_instruction_memory i_mem(
                        .clock     (clk          ),
                        .wraddress (rv32_iw_addr ),
                        .data      (rv32_iw_data ),
                        .wren      (rv32_iw_en   ),
                        .rdaddress (rv32_ir_addr ),
                        .q         (rv32_ir_data )
    );

    task write_instr_to_ram(rv32_instr_q instr_q);
        @(posedge clk);
        rv32_iw_en = 1'b1;
        @(posedge clk);
        logger.print_banner($sformatf("Writing %6d instructions to the RAM", instr_q.size()));
        logger.print($sformatf(" ADDR  INSTRUCTION          INSTR TYPE       OPCODE          DECODING"));
        for (int i=0; i<instr_q.size(); i++) begin
            @(posedge clk);
            rv32_iw_data = instr_q[i];
            rv32_iw_addr = i;
            logger.print($sformatf("[%4d]: 0x%8h     %s", i, instr_q[i], get_instr_str(rv32i_dec.decode_instr(instr_q[i]))));
        end
        @(posedge clk);
        rv32_iw_en = 1'b0;
    endtask

    task read_imem_region(int addr_from, int addr_to);
        logger.print_banner($sformatf("Reading Memory Region 0x%4h to 0x%4h", addr_from, addr_to));
        @(posedge clk);
        rv32_iw_en = 1'b0;
        @(posedge clk);
        for (int addr=addr_from; addr<=addr_to; addr++) begin
            rv32_ir_addr = addr;
            @(posedge clk);
            logger.print($sformatf("0x%4h: %8h", addr, rv32_ir_data));
        end
    endtask : read_imem_region

    initial begin
        rv32_instr_q instr_q;

        logger = new(sim_log_file);
        rv32i_dec = new(logger);

        instr_q = process_hex_file(program_hex_file, logger, 108); // read hex file and store the first 100 words to the ram

        @(posedge clk);
        rv32_iw_en   = 1'b0;
        rv32_iw_data = 8'hFFFF_FFFF;
        rv32_iw_addr = 4'hFFFF;
        rv32_ir_addr = 4'hFFFF;
        @(posedge clk);
        write_instr_to_ram(instr_q);
        @(posedge clk);
        @(posedge clk);
        read_imem_region(0, 108);
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        $timeformat(-9, 2, " ns", 12);
        clk   = 0;
        forever begin
            #((CLOCK_SPEED)*1ns) clk = !clk;
        end
    end

    initial begin
        #2000ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
