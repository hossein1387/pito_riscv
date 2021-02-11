import utils::*;
import testbench_pkg::*;

module testbench_top();
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
    base_testbench tb;

    initial begin
        logger = new(sim_log_file);
        tb = new base_testbench(logger, program_hex_file, pito_inf.tb_interface);

        tb.tb_setup();
        tb.run();
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
