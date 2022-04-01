`include "rv32_defines.svh"
interface pito_core_interface(input logic clk);
    import rv32_pkg::*;
    import pito_pkg::*;

    logic  rst_n;  // Synchronous reset active low
    logic  pito_program; // pito program signal
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
    output  imem_be   
    output  dmem_wdata,
    input   dmem_rdata,
    output  dmem_addr ,
    output  dmem_req  ,
    output  dmem_we   ,
    output  dmem_be   
);

modport  io (
    input rst_n,
    input pito_program,
    input uart_irq
);

endinterface

//=================================================
// MVU Interface
//=================================================

interface mvu_interface();
import rv32_pkg::*;
import pito_pkg::*;

// Interface with Accelerator (MVU)
logic [`PITO_NUM_HARTS-1    : 0] mvu_irq_i;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwbaseptr ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuibaseptr ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvusbaseptr ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvubbaseptr ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuobaseptr ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwjump_0  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwjump_1  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwjump_2  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwjump_3  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwjump_4  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuijump_0  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuijump_1  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuijump_2  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuijump_3  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuijump_4  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvusjump_0  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvusjump_1  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvubjump_0  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvubjump_1  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuojump_0  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuojump_1  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuojump_2  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuojump_3  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuojump_4  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwlength_1;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwlength_2;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwlength_3;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuwlength_4;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuilength_1;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuilength_2;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuilength_3;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuilength_4;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuslength_1;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvublength_1;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuolength_1;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuolength_2;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuolength_3;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuolength_4;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuprecision;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvustatus   ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvucommand  ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuquant    ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuscaler   ;
logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvuconfig1  ;
logic [`PITO_NUM_HARTS-1    : 0] mvu_start        ;

modport  mvu (
    output csr_mvuwbaseptr ,
    output csr_mvuibaseptr ,
    output csr_mvusbaseptr ,
    output csr_mvubbaseptr ,
    output csr_mvuobaseptr ,
    output csr_mvuwjump_0  ,
    output csr_mvuwjump_1  ,
    output csr_mvuwjump_2  ,
    output csr_mvuwjump_3  ,
    output csr_mvuwjump_4  ,
    output csr_mvuijump_0  ,
    output csr_mvuijump_1  ,
    output csr_mvuijump_2  ,
    output csr_mvuijump_3  ,
    output csr_mvuijump_4  ,
    output csr_mvusjump_0  ,
    output csr_mvusjump_1  ,
    output csr_mvubjump_0  ,
    output csr_mvubjump_1  ,
    output csr_mvuojump_0  ,
    output csr_mvuojump_1  ,
    output csr_mvuojump_2  ,
    output csr_mvuojump_3  ,
    output csr_mvuojump_4  ,
    output csr_mvuwlength_1,
    output csr_mvuwlength_2,
    output csr_mvuwlength_3,
    output csr_mvuwlength_4,
    output csr_mvuilength_1,
    output csr_mvuilength_2,
    output csr_mvuilength_3,
    output csr_mvuilength_4,
    output csr_mvuslength_1,
    output csr_mvublength_1,
    output csr_mvuolength_1,
    output csr_mvuolength_2,
    output csr_mvuolength_3,
    output csr_mvuolength_4,
    output csr_mvuprecision,
    output csr_mvuquant    ,
    output csr_mvuscaler   ,
    output csr_mvuconfig1  ,
    input  mvu_irq_i       ,
    output csr_mvustatus   ,
    output csr_mvucommand  ,
    output mvu_start
);

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

endinterface