`timescale 1ns/1ps
module rv32_data_memory  #(
    parameter int unsigned NumWords     = 32'd8096, // Number of Words in data array
    parameter int unsigned DataWidth    = 32'd32,   // Data signal width (in bits)
    parameter int unsigned ByteWidth    = 32'd8,    // Width of a data byte (in bits)
    parameter int unsigned NumPorts     = 32'd2,    // Number of read and write ports
    parameter int unsigned Latency      = 32'd1,    // Latency when the read data is available
    parameter              SimInit      = "zeros",  // Simulation initialization, fixed to zero here!
    parameter bit          PrintSimCfg  = 1'b1,      // Print configuration
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
    parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
    parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth, // ceil_div
    parameter type         addr_t    = logic [AddrWidth-1:0],
    parameter type         data_t    = logic [DataWidth-1:0],
    parameter type         be_t      = logic [BeWidth-1:0]
)
(
    input  logic                 clk_i,      // Clock
    input  logic                 rst_ni,     // Asynchronous reset active low
    // input ports
    input  logic  [NumPorts-1:0] req_i,      // request
    input  logic  [NumPorts-1:0] we_i,       // write enable
    input  addr_t [NumPorts-1:0] addr_i,     // request address
    input  data_t [NumPorts-1:0] wdata_i,    // write data
    input  be_t   [NumPorts-1:0] be_i,       // write byte enable
    // output ports
    output data_t [NumPorts-1:0] rdata_o     // read data
);

tc_sram #(
    .NumWords   (NumWords),   // Number of Words in data array
    .DataWidth  (DataWidth),  // Data signal width (in bits)
    .ByteWidth  (ByteWidth),
    .NumPorts   (NumPorts),   // Number of read and write ports
    .Latency    (Latency),    // Latency when the read data is available
    .SimInit    (SimInit),    // Simulation initialization fixed to zero here!
    .PrintSimCfg(PrintSimCfg) // Print configuration
  ) ram (
    .clk_i      (clk_i  ), // Clock
    .rst_ni     (rst_ni ), // Asynchronous reset active low
    .req_i      (req_i  ), // request
    .we_i       (we_i   ), // write enable
    .addr_i     (addr_i ), // request address
    .wdata_i    (wdata_i), // write data
    .be_i       (be_i   ), // write byte enable
    .rdata_o    (rdata_o) // read data
  );

endmodule