import utils::*;

module decoder_tester();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
//==================================================================================================
// Signals
    logic               clk;
    logic               rst;
    logic               flush;
    logic               halt; 
    rv32_instr_t        instr; // input instruction
    rv32_pc_cnt_t       pc;
    rv32_register_t     rv_rs1;
    rv32_register_t     rv_rs2;
    rv32_register_t     rv_rd;
    rv32_shamt_t        rv_shamt;
    rv32_imm_t          rv_imm;
    logic[3:0]          rv_fence_succ;
    logic[3:0]          rv_fence_pred;
    rv32_csr_t            rv_csr;
    rv32_zimm_t           rv_zimm;
    rv32_opcode_enum_t  rv_opcode;
    logic               instr_trap;
    rv32_type_enum_t    rv_imm_decoded_type;

rv32_decoder rv32_decoder_inst(
    .clk                 (clk                ),
    .rst                 (rst                ),
    .flush               (flush              ),
    .halt                (halt               ),
    .instr               (instr              ),
    .pc                  (pc                 ),
    .rv_rs1              (rv_rs1             ),
    .rv_rs2              (rv_rs2             ),
    .rv_rd               (rv_rd              ),
    .rv_shamt            (rv_shamt           ),
    .rv_imm              (rv_imm             ),
    .rv_fence_succ       (rv_fence_succ      ),
    .rv_fence_pred       (rv_fence_pred      ),
    .rv_csr              (rv_csr             ),
    .rv_zimm             (rv_zimm            ),
    .rv_opcode           (rv_opcode          ),
    .rv_imm_decoded_type (rv_imm_decoded_type),
    .instr_trap          (instr_trap         )
);

    function rv32_decoder(string instr_str);
        
    endfunction

    initial begin
        string line, temp, instr_str, rs1, rs2, rd;
        static int fd = $fopen ("code.txt", "r");
        logger = new("decoder_tester.log");
        if (fd)  begin $display("File was opened successfully : %0d", fd); end
        else     begin $display("File was NOT opened successfully : %0d", fd); $finish(); end
        @(posedge clk);
        for (int i=0; i<15; i++) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr = rv32_instr_t'(instr_str.atohex());
            end
            @(posedge clk);
            rs1 = rv32_abi_reg_s[rv_rs1];
            rs2 = rv32_abi_reg_s[rv_rs2];
            rd  = rv32_abi_reg_s[rv_rd];
            logger.print($sformatf("%s: type:%10s   rs1: %4s  rs2: %4s  rd: %4s  shamt: %2d  imm: %10d  op: %11s  trap: %2d\n", instr_str, rv_imm_decoded_type.name, rs1, rs2, rd, rv_shamt, $signed(rv_imm), rv_opcode.name, instr_trap));
            // logger.print("test");
        end
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
