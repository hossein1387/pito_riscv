module pito_soc(
    pito_soc_ext_interface ext_intf,
    pito_mvu_interface  mvu_intf,
);

logic clk;
logic rst_n;

assign clk = ext_intf.clk;
assign rst_n = ext_intf.rst_n;

rv32_dmem_t rv32_dmem;
rv32_imem_t rv32_imem;

pito_core_interface core_intf(clk); 

//====================================================================
//                   Pito Core 
//====================================================================

rv32_core pito(
    .clk(clk)
    .rst_n(rst_n)
    .imem_intf(core_intf.imem),
    .dmem_intf(core_intf.dmem),
    .mvu_interface (mvu_intf)
);


//====================================================================
//                   Pito Memory Interface
//====================================================================

// Dual port SRAM memory for instruction Cache. Port 0 is used for external
// interface and port 1 is used for local interface.
assign rv32_imem.req      = {ext_intf.pito_imem_req  , core_intf.mem.imem_req  };
assign rv32_imem.we       = {ext_intf.pito_imem_we   , core_intf.mem.imem_we   };
assign rv32_imem.addr     = {ext_intf.pito_imem_addr , core_intf.mem.imem_addr };
assign rv32_imem.wdata    = {ext_intf.pito_imem_wdata, core_intf.mem.imem_wdata};
assign rv32_imem.be       = {ext_intf.pito_imem_be   , core_intf.mem.imem_be   };

assign ext_intf.pito_imem_rdata = rv32_imem.rdata[`PITO_INSTR_MEM_EXT_PORT];
assign core_intf.mem.imem_rdata = rv32_imem.rdata[`PITO_INSTR_MEM_LOCAL_PORT];

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

assign rv32_dmem.req      = {ext_intf.pito_dmem_req  , core_intf.mem.dmem_req  };
assign rv32_dmem.we       = {ext_intf.pito_dmem_we   , core_intf.mem.dmem_we   };
assign rv32_dmem.addr     = {ext_intf.pito_dmem_addr , core_intf.mem.dmem_addr };
assign rv32_dmem.wdata    = {ext_intf.pito_dmem_wdata, core_intf.mem.dmem_wdata};
assign rv32_dmem.be       = {ext_intf.pito_dmem_be   , core_intf.mem.dmem_be   };

assign ext_intf.pito_dmem_rdata = rv32_dmem.rdata[`PITO_DATA_MEM_EXT_PORT];
assign core_intf.mem.dmem_rdata = rv32_dmem.rdata[`PITO_DATA_MEM_LOCAL_PORT];

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
logic uart_irq;
rv32_data_t uart_data_out;
rv32_byte_t uart_rx;
logic[3:0] uart_debug;

assign uart_wr_logic = rv32_dmem.we && rv32_dmem.addr[31]==1 && rv32_dmem.addr[30:0]==0;
assign uart_rd_logic = 1'b0; // For now, no read from UART is supported
pito_uart uart(
    .CLK   (inf.clk)
    .RES   (inf.pito_io_rst_n)
    .RD    (uart_rd_logic)
    .WR    (uart_wr_logic)
    .BE    (rv32_dmem.be)
    .DATAI (rv32_dmem.wdata)
    .DATAO (uart_data_out)
    .IRQ   (uart_irq)
    .RXD   (uart_rx)
    .TXD   (uart_tx)
    .DEBUG (uart_debug)
)
