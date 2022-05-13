`include "rv32_defines.svh"

module pito_soc import rv32_pkg::*;import pito_pkg::*;(
    pito_soc_ext_interface.soc_ext ext_intf,
    mvu_interface  mvu_intf
);

logic clk;
logic rst_n;

assign clk = ext_intf.clk;
assign rst_n = ext_intf.rst_n;

rv32_dmem_t rv32_dmem;
rv32_imem_t rv32_imem;
rv32_imem_addr_t imem_addr;
rv32_dmem_addr_t dmem_addr;
//====================================================================
//                   Pito Core 
//====================================================================

assign rv32_imem.addr[`PITO_INSTR_MEM_LOCAL_PORT] = imem_addr[`PITO_INSTR_MEM_ADDR_WIDTH-1:0];
assign rv32_dmem.addr[`PITO_DATA_MEM_LOCAL_PORT]  = dmem_addr[`PITO_DATA_MEM_ADDR_WIDTH-1:0];

rv32_core pito(
    .clk          (clk                                        ),
    .rst_n        (rst_n                                      ),
    .pito_program (ext_intf.pito_program                      ),
    .imem_wdata   (rv32_imem.wdata[`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_rdata   (rv32_imem.rdata[`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_addr    (imem_addr                                  ),
    .imem_req     (rv32_imem.req  [`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_we      (rv32_imem.we   [`PITO_INSTR_MEM_LOCAL_PORT]),
    .imem_be      (rv32_imem.be   [`PITO_INSTR_MEM_LOCAL_PORT]),
    .dmem_wdata   (rv32_dmem.wdata[`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_rdata   (rv32_dmem.rdata[`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_addr    (dmem_addr                                  ),
    .dmem_req     (rv32_dmem.req  [`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_we      (rv32_dmem.we   [`PITO_DATA_MEM_LOCAL_PORT] ),
    .dmem_be      (rv32_dmem.be   [`PITO_DATA_MEM_LOCAL_PORT] ),
    .mvu_if       (mvu_intf                                   )
);

//====================================================================
//                   Pito Memory Interface
//====================================================================

// Dual port SRAM memory for instruction Cache. Port 0 is used for external
// interface and port 1 is used for local interface.
assign rv32_imem.req  [`PITO_INSTR_MEM_EXT_PORT] = ext_intf.imem_req  ;
assign rv32_imem.we   [`PITO_INSTR_MEM_EXT_PORT] = ext_intf.imem_we   ;
assign rv32_imem.addr [`PITO_INSTR_MEM_EXT_PORT] = ext_intf.imem_addr[`PITO_INSTR_MEM_ADDR_WIDTH-1:0];
assign rv32_imem.wdata[`PITO_INSTR_MEM_EXT_PORT] = ext_intf.imem_wdata;
assign rv32_imem.be   [`PITO_INSTR_MEM_EXT_PORT] = ext_intf.imem_be   ;
assign ext_intf.imem_rdata = rv32_imem.rdata[`PITO_INSTR_MEM_EXT_PORT];

rv32_instruction_memory#(
    .NumWords   (`PITO_INSTR_MEM_SIZE ),
    .DataWidth  (`DATA_WIDTH          ),
    .ByteWidth  (`BYTE_WIDTH          ),
    .NumPorts   (`PITO_INSTR_MEM_PORTS),
    .Latency    (1                    ),
    .SimInit    ("zeros"              ), // in simulation, this will this will be overwritten by backdoor access to `hdl_path_imem_init
    .PrintSimCfg(1                    )) 
i_mem(
    .clk_i  (clk),
    .rst_ni (rst_n),
    .req_i  (rv32_imem.req  ),
    .we_i   (rv32_imem.we   ),
    .addr_i (rv32_imem.addr ),
    .wdata_i(rv32_imem.wdata),
    .be_i   (rv32_imem.be   ),
    .rdata_o(rv32_imem.rdata)
);

assign rv32_dmem.req  [`PITO_DATA_MEM_EXT_PORT] = ext_intf.dmem_req  ;
assign rv32_dmem.we   [`PITO_DATA_MEM_EXT_PORT] = ext_intf.dmem_we   ;
assign rv32_dmem.addr [`PITO_DATA_MEM_EXT_PORT] = ext_intf.dmem_addr[`PITO_DATA_MEM_ADDR_WIDTH-1:0] ;
assign rv32_dmem.wdata[`PITO_DATA_MEM_EXT_PORT] = ext_intf.dmem_wdata;
assign rv32_dmem.be   [`PITO_DATA_MEM_EXT_PORT] = ext_intf.dmem_be   ;

assign ext_intf.dmem_rdata = rv32_dmem.rdata[`PITO_DATA_MEM_EXT_PORT];

rv32_data_memory #(    
    .NumWords   (`PITO_DATA_MEM_SIZE ),
    .DataWidth  (`DATA_WIDTH         ),
    .ByteWidth  (`BYTE_WIDTH         ),
    .NumPorts   (`PITO_DATA_MEM_PORTS),
    .Latency    (1                   ),
    .SimInit    ("zeros"             ), // in simulation, this will this will be overwritten by backdoor access to `hdl_path_dmem_init
    .PrintSimCfg(1                   ))
d_mem(
    .clk_i  (clk),
    .rst_ni (rst_n),
    .req_i  (rv32_dmem.req  ),
    .we_i   (rv32_dmem.we   ),
    .addr_i (rv32_dmem.addr ),
    .wdata_i(rv32_dmem.wdata),
    .be_i   (rv32_dmem.be   ),
    .rdata_o(rv32_dmem.rdata)
);

//====================================================================
//                   Pito I/Os
//====================================================================

logic uart_wr_logic;
logic uart_rd_logic;
rv32_data_t uart_data_out;
rv32_data_t uart_data_in;
logic      uart_busy;
logic uart_valid;
rv32_dmem_addr_t uart_addr;

assign uart_data_in  = rv32_dmem.wdata[`PITO_DATA_MEM_LOCAL_PORT];
assign uart_addr     = dmem_addr;
assign uart_wr_logic = rv32_dmem.we[`PITO_DATA_MEM_LOCAL_PORT] &&
                       uart_addr[31]==1 && 
                       uart_addr[30:0]==0;
                       
assign uart_rd_logic = 1'b0; // For now, no read from UART is supported

pito_uart uart(
    .clk     (ext_intf.clk    ),
    .rst_n   (ext_intf.rst_n  ),
    .tx      (ext_intf.uart_tx),
    .rx      (ext_intf.uart_rx),
    .wr      (uart_wr_logic   ),
    .rd      (uart_rd_logic   ),
    .tx_data (uart_data_in [7:0]),
    .rx_data (uart_data_out[7:0]),
    .valid   (uart_valid      ),
    .busy    (uart_busy      )
);

endmodule