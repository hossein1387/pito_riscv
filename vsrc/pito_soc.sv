`include "rv32_defines.svh"

`ifdef DEBUG
    `include "testbench_macros.svh"
`endif

module pito_soc import rv32_pkg::*;import pito_pkg::*;(
    input  logic            sys_clk_i,
    input  logic            rst_n_i,
    input  logic [`PITO_NUM_HARTS-1 : 0] mvu_irq_i,
    input  logic            uart_rx_i,
    output logic            uart_tx_o,
    AXI_BUS.Master          m_axi,
    APB                     mvu_apb
);


logic clk, rst_n;
logic [`PITO_NUM_HARTS-1    : 0] mvu_irq;

assign clk   = sys_clk_i;
assign rst_n = rst_n_i;
// soc logic
logic mem_out_bound;
logic dmem_wen;

rv32_dmem_t rv32_dmem;
rv32_imem_t rv32_imem;
rv32_imem_addr_t imem_addr;
rv32_dmem_addr_t dmem_addr;
rv32_data_t dmem_rdata;

// UART
logic uart_wr_logic;
logic uart_rd_logic;
rv32_data_t uart_data_out;
rv32_data_t uart_data_in;
logic uart_busy;
logic uart_valid;
rv32_dmem_addr_t uart_addr;

// Memory External Interface
rv32_data_t      imem_wdata_i;
rv32_data_t      imem_rdata_o;
rv32_imem_addr_t imem_addr_i;
logic            imem_req_i;
logic            imem_we_i;
imem_be_t        imem_be_i;

rv32_data_t      dmem_wdata_i;
rv32_data_t      dmem_rdata_o;
rv32_dmem_addr_t dmem_addr_i;
logic            dmem_req_i;
logic            dmem_we_i;
dmem_be_t        dmem_be_i;

//====================================================================
//                   Pito Core 
//====================================================================

assign rv32_imem.addr[`PITO_INSTR_MEM_LOCAL_PORT] = imem_addr[`PITO_INSTR_MEM_ADDR_WIDTH-1:0];
assign rv32_dmem.addr[`PITO_DATA_MEM_LOCAL_PORT]  = dmem_addr[`PITO_DATA_MEM_ADDR_WIDTH-1:0]>>2;
assign mvu_irq = mvu_irq_i;

rv32_core pito(
    .clk        (clk                                        ),
    .rst_n      (rst_n                                      ),
    .imem_wdata (rv32_imem.wdata[`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_rdata (rv32_imem.rdata[`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_addr  (imem_addr                                  ),
    .imem_req   (rv32_imem.req  [`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_we    (rv32_imem.we   [`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_be    (rv32_imem.be   [`PITO_INSTR_MEM_LOCAL_PORT]),
    .dmem_wdata (rv32_dmem.wdata[`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_rdata (dmem_rdata                                 ),
    .dmem_addr  (dmem_addr                                  ),
    .dmem_req   (rv32_dmem.req  [`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_we    (dmem_wen                                   ),
    .dmem_be    (rv32_dmem.be   [`PITO_DATA_MEM_LOCAL_PORT] ),
    .mvu_irq    (mvu_irq_i                                  ),
    .mvu_apb    (mvu_apb                                    )
);

`ifdef DEBUG
    always @(posedge clk) begin
        if (rv32_dmem.req  [`PITO_DATA_MEM_LOCAL_PORT]==1) begin
            if (dmem_wen==1) begin
                    $display($sformatf("%t HART[%1d] is writing %8h to %8h",$time(), `hdl_path_top.rv32_hart_ex_cnt, rv32_dmem.wdata[`PITO_DATA_MEM_LOCAL_PORT], dmem_addr));
            end else begin
                    $display($sformatf("%t HART[%1d] is reading from %8h",$time(), `hdl_path_top.rv32_hart_ex_cnt, dmem_addr));
            end
        end
    end
`endif 

rv32_data_t io_val;
logic io_read;
always @(posedge clk) begin
    if ((rv32_dmem.req[`PITO_DATA_MEM_LOCAL_PORT] ==  1'b1) && (dmem_addr == 32'h8000_0001) && rv32_imem.we[`PITO_INSTR_MEM_LOCAL_PORT]==0) begin
        io_read <= 1'b1;
        io_val <= {8'b0, 8'b0, 7'b0, uart_busy, uart_data_out[7:0]};
    end else  begin
        io_read <= 1'b0;
        io_val  <= 32'b0;
    end
end

assign dmem_rdata = (io_read == 1'b1) ? io_val : rv32_dmem.rdata[`PITO_DATA_MEM_LOCAL_PORT];
assign mem_out_bound = (|dmem_addr[31:22]);
assign rv32_dmem.we[`PITO_DATA_MEM_LOCAL_PORT]  =  mem_out_bound ? 0 : dmem_wen;

//====================================================================
//                   Pito Memory Interface
//====================================================================

// Dual port SRAM memory for instruction Cache. Port 0 is used for external
// interface and port 1 is used for local interface.
assign rv32_imem.req  [`PITO_INSTR_MEM_EXT_PORT] = imem_req_i  ;
assign rv32_imem.we   [`PITO_INSTR_MEM_EXT_PORT] = imem_we_i   ;
assign rv32_imem.addr [`PITO_INSTR_MEM_EXT_PORT] = imem_addr_i[`PITO_INSTR_MEM_ADDR_WIDTH-1:0];
assign rv32_imem.wdata[`PITO_INSTR_MEM_EXT_PORT] = imem_wdata_i;
assign rv32_imem.be   [`PITO_INSTR_MEM_EXT_PORT] = imem_be_i   ;
assign imem_rdata_o = rv32_imem.rdata[`PITO_INSTR_MEM_EXT_PORT];

rv32_instruction_memory#(
    .NumWords   (`PITO_INSTR_MEM_SIZE ),
    .DataWidth  (`DATA_WIDTH          ),
    .ByteWidth  (`BYTE_WIDTH          ),
    .NumPorts   (`PITO_INSTR_MEM_PORTS),
    .Latency    (1                    ),
    .SimInit    ("zeros"              ), // in simulation, this will this will be overwritten by backdoor access to `hdl_path_imem_init
    .PrintSimCfg(1                    )) 
i_mem(
    .clk_i  (clk            ),
    .rst_ni (rst_n          ),
    .req_i  (rv32_imem.req  ),
    .we_i   (rv32_imem.we   ),
    .addr_i (rv32_imem.addr ),
    .wdata_i(rv32_imem.wdata),
    .be_i   (rv32_imem.be   ),
    .rdata_o(rv32_imem.rdata)
);

assign rv32_dmem.req  [`PITO_DATA_MEM_EXT_PORT] = dmem_req_i  ;
assign rv32_dmem.we   [`PITO_DATA_MEM_EXT_PORT] = dmem_we_i   ;
assign rv32_dmem.addr [`PITO_DATA_MEM_EXT_PORT] = dmem_addr_i[`PITO_DATA_MEM_ADDR_WIDTH-1:0] ;
assign rv32_dmem.wdata[`PITO_DATA_MEM_EXT_PORT] = dmem_wdata_i;
assign rv32_dmem.be   [`PITO_DATA_MEM_EXT_PORT] = dmem_be_i   ;

assign dmem_rdata_o = rv32_dmem.rdata[`PITO_DATA_MEM_EXT_PORT];

rv32_data_memory #(
    .NumWords   (`PITO_DATA_MEM_SIZE ),
    .DataWidth  (`DATA_WIDTH         ),
    .ByteWidth  (`BYTE_WIDTH         ),
    .NumPorts   (`PITO_DATA_MEM_PORTS),
    .Latency    (1                   ),
    .SimInit    ("zeros"             ), // in simulation, this will this will be overwritten by backdoor access to `hdl_path_dmem_init
    .PrintSimCfg(1                   ))
d_mem(
    .clk_i  (clk            ),
    .rst_ni (rst_n          ),
    .req_i  (rv32_dmem.req  ),
    .we_i   (rv32_dmem.we   ),
    .addr_i (rv32_dmem.addr ),
    .wdata_i(rv32_dmem.wdata),
    .be_i   (rv32_dmem.be   ),
    .rdata_o(rv32_dmem.rdata)
);

pito_mem_subsystem pito_mem_subsystem_inst(
    .clk_i            (clk          ),
    .rst_ni           (rst_n        ),
    .pito_dmem_wdata_o(dmem_wdata_i ),
    .pito_dmem_rdata_i(dmem_rdata_o ),
    .pito_dmem_addr_o (dmem_addr_i  ),
    .pito_dmem_req_o  (dmem_req_i   ),
    .pito_dmem_we_o   (dmem_we_i    ),
    .pito_dmem_be_o   (dmem_be_i    ),
    .pito_imem_wdata_o(imem_wdata_i ),
    .pito_imem_rdata_i(imem_rdata_o ),
    .pito_imem_addr_o (imem_addr_i  ),
    .pito_imem_req_o  (imem_req_i   ),
    .pito_imem_we_o   (imem_we_i    ),
    .pito_imem_be_o   (imem_be_i    ),
    .m_axi            (m_axi        )
);

//====================================================================
//                   Pito I/Os
//====================================================================

assign uart_data_in  = rv32_dmem.wdata[`PITO_DATA_MEM_LOCAL_PORT];
assign uart_addr     = dmem_addr;
assign uart_wr_logic = dmem_wen &&
                       uart_addr[31]==1 && 
                       uart_addr[30:0]==0;

assign uart_rd_logic = 1'b0; // For now, no read from UART is supported

pito_uart uart(
    .clk     (clk               ),
    .rst_n   (rst_n             ),
    .tx      (uart_tx_o         ),
    .rx      (uart_rx_i         ),
    .wr      (uart_wr_logic     ),
    .rd      (uart_rd_logic     ),
    .tx_data (uart_data_in [7:0]),
    .rx_data (uart_data_out[7:0]),
    .valid   (uart_valid        ),
    .busy    (uart_busy         )
);

endmodule