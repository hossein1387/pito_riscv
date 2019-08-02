import utils::*;

module decoder_tester();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ

//==================================================================================================
// Signals
    logic               clk;
    logic               rst;
    logic               flush;
    logic               halt; 
    rv32_instr_t        instr; // input instruction
    rv_pc_cnt_t         pc;
    rv_register_t       rv_rs1;
    rv_register_t       rv_rs2;
    rv_register_t       rv_rd;
    rv_shamt_t          rv_shamt;
    rv_imm_t            rv_imm;
    logic[3:0]          rv_fence_succ;
    logic[3:0]          rv_fence_pred;
    rv_csr_t            rv_csr;
    rv_zimm_t           rv_zimm;
    rv32_opcode_enum_t  rv_opcode;
    logic               instr_trap;

rv32_decoder rv32_decoder_inst(
    .clk          (clk          ),
    .rst          (rst          ),
    .flush        (flush        ),
    .halt         (halt         ),
    .instr        (instr        ),
    .pc           (pc           ),
    .rv_rs1       (rv_rs1       ),
    .rv_rs2       (rv_rs2       ),
    .rv_rd        (rv_rd        ),
    .rv_shamt     (rv_shamt     ),
    .rv_imm       (rv_imm       ),
    .rv_fence_succ(rv_fence_succ),
    .rv_fence_pred(rv_fence_pred),
    .rv_csr       (rv_csr       ),
    .rv_zimm      (rv_zimm      ),
    .rv_opcode    (rv_opcode    ),
    .instr_trap   (instr_trap   )
);


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
