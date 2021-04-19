`include "rv32_defines.svh"
interface pito_interface(input logic clk);
    import rv32_pkg::*;
    import pito_pkg::*;
    logic              pito_io_rst_n;  // Synchronous reset active low
    rv32_imem_addr_t   pito_io_imem_addr;
    rv32_instr_t       pito_io_imem_data;
    rv32_dmem_addr_t   pito_io_dmem_addr;
    rv32_data_t        pito_io_dmem_data;
    logic              pito_io_imem_w_en;
    logic              pito_io_dmem_w_en;
    logic              pito_io_program;

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


//=================================================
// Modport for Testbench interface 
//=================================================
modport  tb_interface (
                        input  clk,    // Clock
                        input  pito_io_rst_n,  // Synchronous reset active low
                        input  pito_io_imem_addr,
                        input  pito_io_imem_data,
                        input  pito_io_dmem_addr,
                        input  pito_io_dmem_data,
                        input  pito_io_imem_w_en,
                        input  pito_io_dmem_w_en,
                        input  pito_io_program,
                        input  mvu_irq_i,
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
                        output csr_mvustatus   ,
                        output csr_mvucommand  ,
                        output csr_mvuquant    ,
                        output csr_mvuscaler   ,
                        output csr_mvuconfig1  ,
                        output mvu_start        
);

//=================================================
// Modport for System interface 
//=================================================
modport  system_interface (    
                        input  clk,    // Clock
                        input  pito_io_rst_n,  // Synchronous reset active low
                        input  pito_io_imem_addr,
                        input  pito_io_imem_data,
                        input  pito_io_dmem_addr,
                        input  pito_io_dmem_data,
                        input  pito_io_imem_w_en,
                        input  pito_io_dmem_w_en,
                        input  pito_io_program,
                        input  mvu_irq_i,
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
                        output csr_mvustatus   ,
                        output csr_mvucommand  ,
                        output csr_mvuquant    ,
                        output csr_mvuscaler   ,
                        output csr_mvuconfig1  ,
                        output mvu_start        
);

endinterface