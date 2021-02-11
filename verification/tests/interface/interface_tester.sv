import utils::*;
import rv32_utils::*;
import pito_pkg::*;
import monitor_pkg::*;

module interface_tester();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    string program_hex_file = "test.hex";
    string sim_log_file     = "csr_tester.log";
//==================================================================================================
    logic clk;
    pito_interface pito_inf(clk);
    rv32_core core(pito_inf.system_interface);

    initial begin
        pito_inf.pito_io_rst_n     = 1'b1;
        pito_inf.pito_io_dmem_w_en = 1'b0;
        pito_inf.pito_io_imem_w_en = 1'b0;
        pito_inf.pito_io_imem_addr = 32'b0;
        pito_inf.pito_io_dmem_addr = 32'b0;
        pito_inf.pito_io_program   = 0;
        pito_inf.mvu_irq_i         = 0;


        logger = new(sim_log_file);

        @(posedge clk);
        pito_inf.pito_io_rst_n = 1'b0;
        @(posedge clk);
        write_instr_to_ram(instr_q, 1, 0);
        write_to_dram(instr_q);
        @(posedge clk);
        pito_inf.pito_io_rst_n = 1'b1;
        @(posedge clk);
        // print_imem_region(0, 511);
        // print_imem_region( int'(`PITO_DATA_MEM_OFFSET), int'(`PITO_DATA_MEM_OFFSET+4), "char");
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
        #1ms;
        $display("Simulation took more than expected ( more than 600ms)");
        $finish();
    end
endmodule
