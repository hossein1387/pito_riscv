`include "rv32_defines.svh"
interface pito_core_interface(input logic clk);
    import rv32_pkg::*;
    import pito_pkg::*;

    logic  rst_n;   // Synchronous reset active low
    // Pito Memory Interface signals
    rv32_data_t      imem_wdata;
    rv32_data_t      imem_rdata;
    rv32_imem_addr_t imem_addr;
    logic            imem_req;
    logic            imem_we;
    imem_be_t        imem_be;
    
    rv32_data_t      dmem_wdata;
    rv32_data_t      dmem_rdata;
    rv32_dmem_addr_t dmem_addr;
    logic            dmem_req;
    logic            dmem_we;
    dmem_be_t        dmem_be;

    // Pito I/O interface signals
    logic uart_irq;
    
//=================================================
// Modport for System interface 
//=================================================

modport  mem (
    output  imem_wdata,
    input   imem_rdata,
    output  imem_addr ,
    output  imem_req  ,
    output  imem_we   ,
    output  imem_be   ,
    output  dmem_wdata,
    input   dmem_rdata,
    output  dmem_addr ,
    output  dmem_req  ,
    output  dmem_we   ,
    output  dmem_be   
);

modport  io (
    input clk,
    input rst_n,
    input uart_irq
);

endinterface

//=================================================
// MVU Interface
//=================================================

interface mvu_csr_interface();
import rv32_pkg::*;
import pito_pkg::*;

// Interface with Accelerator (MVU)
logic [`PITO_NUM_HARTS-1    : 0] mvu_irq_i;

endinterface


//=================================================
// External Interface: 
//     - uart
//     - ram programming interafce
//     - mvu 
//=================================================

interface pito_soc_ext_interface(input logic clk);
import rv32_pkg::*;
import pito_pkg::*;
logic            rst_n;
logic            uart_rx;
logic            uart_tx;
rv32_data_t      imem_wdata;
rv32_data_t      imem_rdata;
rv32_imem_addr_t imem_addr;
logic            imem_req;
logic            imem_we;
imem_be_t        imem_be;

rv32_data_t      dmem_wdata;
rv32_data_t      dmem_rdata;
rv32_dmem_addr_t dmem_addr;
logic            dmem_req;
logic            dmem_we;
dmem_be_t        dmem_be;

modport  soc_ext (
    input  clk,
    input  rst_n,
    input  dmem_wdata,
    output dmem_rdata,
    input  dmem_addr ,
    input  dmem_req  ,
    input  dmem_we   ,
    input  dmem_be   ,
    input  imem_wdata,
    output imem_rdata,
    input  imem_addr ,
    input  imem_req  ,
    input  imem_we   ,
    input  imem_be   ,
    input  uart_rx   ,
    output uart_tx
);

modport  tb (
    input  clk,
    output rst_n,
    output dmem_wdata,
    input  dmem_rdata,
    output dmem_addr ,
    output dmem_req  ,
    output dmem_we   ,
    output dmem_be   ,
    output imem_wdata,
    input  imem_rdata,
    output imem_addr ,
    output imem_req  ,
    output imem_we   ,
    output imem_be   ,
    output uart_rx   ,
    input  uart_tx
);

endinterface