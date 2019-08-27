import utils::*;
import rv32_utils::*;

module core_tester ();
//==================================================================================================
// Global Variables
    localparam CLOCK_SPEED          = 50; // 10MHZ
    Logger logger;
    RV32IDecoder rv32i_dec;
//==================================================================================================
// DUT Signals
    logic              clk;
    logic              rst_n;  // Asynchronous reset active low
    rv_imem_addr_t     imem_addr;
    rv32_instr_t       imem_data;
    rv_dmem_addr_t     dmem_addr;
    rv32_data_t        dmem_data;
    logic              imem_w_en;
    logic              dmem_w_en;
    logic              pito_program;
    rv32_opcode_enum_t rv32_dec_opcode;
    rv_pc_cnt_t        rv32_pc;

    rv32_core core(
                    .rv32_io_clk       (clk            ),
                    .rv32_io_rst_n     (rst_n          ),
                    .rv32_io_imem_addr (imem_addr      ),
                    .rv32_io_imem_data (imem_data      ),
                    .rv32_io_dmem_addr (dmem_addr      ),
                    .rv32_io_dmem_data (dmem_data      ),
                    .rv32_io_imem_w_en (imem_w_en      ),
                    .rv32_io_dmem_w_en (dmem_w_en      ),
                    .rv32_io_program   (pito_program   ),
                    .rv32_dec_opcode   (rv32_dec_opcode),
                    .rv32_pc           (rv32_pc        )
    );

    function string decode_instr (rv32_instr_t instr);
        static string decode_ins_str;
        static logic [6:0] opcode = instr[6:0];

        if ((opcode == 7'b0110111) || (opcode == 7'b0010111) ) begin //U-Type
            decode_ins_str = rv32i_dec.dec_u_type(instr);
        end else if (opcode == 7'b1101111) begin // J-Type
            decode_ins_str = rv32i_dec.dec_j_type(instr);
        end else if ((opcode == 7'b1100111) || 
                     (opcode == 7'b0000011) || 
                     (opcode == 7'b0010011) || 
                     (opcode == 7'b0001111) || 
                     (opcode == 7'b1110011)) begin // I-Type
            decode_ins_str = rv32i_dec.dec_i_type(instr);
        end else if (opcode == 7'b1100011) begin // B-Type
            decode_ins_str = rv32i_dec.dec_b_type(instr);
        end else if (opcode == 7'b0100011) begin // S-Type
            decode_ins_str = rv32i_dec.dec_s_type(instr);
        end else if (opcode == 7'b0110011) begin // R-Type
            decode_ins_str = rv32i_dec.dec_r_type(instr);
        end else begin 
            logger.print($sformatf("Error: Undefined type of instruction! %b", opcode));
        end
        return decode_ins_str;
    endfunction

    task write_instr_to_ram();
        rv32_instr_t        instr; // input instruction
        rv_register_t       rv_rs1;
        rv_register_t       rv_rs2;
        rv_register_t       rv_rd;
        rv_shamt_t          rv_shamt;
        rv_imm_t            rv_imm;
        string line, temp, instr_str, rs1, rs2, rd;
        static int fd = $fopen ("code.txt", "r");
        logger = new("core_tester.log");
        rv32i_dec = new;
        if (fd)  begin $display("File was opened successfully : %0d", fd); end
        else     begin $display("File was NOT opened successfully : %0d", fd); $finish(); end
        @(posedge clk);
        imem_w_en = 1'b1;
        @(posedge clk);
        for (int i=0; i<16; i++) begin
            temp = $fgets(line, fd);
            if (line.substr(0, 1) != "//") begin
                instr_str = line.substr(0, 7);
                instr = rv32_instr_t'(instr_str.atohex());
            end
            @(posedge clk);
            rs1 = rv32_abi_reg_s[rv_rs1];
            rs2 = rv32_abi_reg_s[rv_rs2];
            rd  = rv32_abi_reg_s[rv_rd];
            imem_data = instr;
            imem_addr = i;
            logger.print($sformatf("%s", decode_instr(instr)));
        end
        @(posedge clk);
        imem_w_en = 1'b0;
    endtask

    task monitor_pito();
        for (int i=0; i<100; i++) begin
            logger.print($sformatf("pc=%d       decode:%s", rv32_pc,  rv32_dec_opcode.name));
            @(posedge clk);
        end
    endtask

    initial begin
        rst_n        = 1'b1;
        dmem_w_en    = 1'b0;
        imem_w_en    = 1'b0;
        imem_addr    = 32'b0;
        dmem_addr    = 32'b0;
        pito_program = 0;
        @(posedge clk);
        rst_n     = 1'b0;
        @(posedge clk);
        write_instr_to_ram();
        @(posedge clk);
        rst_n     = 1'b1;
        @(posedge clk);
        monitor_pito();
        $finish();
    end

//==================================================================================================
// Simulation specific Threads

    initial begin 
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
