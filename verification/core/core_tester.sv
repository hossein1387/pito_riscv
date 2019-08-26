import utils::*;

module core_tester();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
//==================================================================================================
// DUT Signals
    logic          clk;
    logic          rst_n;  // Asynchronous reset active low
    rv_imem_addr_t imem_addr;
    rv32_instr_t   imem_data;
    rv_dmem_addr_t dmem_addr;
    rv32_data_t    dmem_data;
    logic          imem_w_en;
    logic          dmem_w_en;
    logic          program;

    rv32_core core(
                    .rv32_io_clk      (clk      ),
                    .rv32_io_rst_n    (rst_n    ),
                    .rv32_io_imem_addr(imem_addr),
                    .rv32_io_imem_data(imem_data),
                    .rv32_io_dmem_addr(dmem_addr),
                    .rv32_io_dmem_data(dmem_data),
                    .rv32_io_imem_w_en(imem_w_en),
                    .rv32_io_dmem_w_en(dmem_w_en),
                    .rv32_io_program  (program  )
    );

    initial begin
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
        rst = 1;
        clk = 0;
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
