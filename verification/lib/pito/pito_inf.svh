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
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wbaseaddr;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ibaseaddr;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_obaseaddr;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wstride_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wstride_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wstride_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wstride_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_istride_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_istride_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_istride_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_istride_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ostride_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ostride_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ostride_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ostride_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wlength_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wlength_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wlength_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_wlength_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ilength_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ilength_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ilength_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_ilength_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_olength_0;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_olength_1;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_olength_2;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_olength_3;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_precision;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_status   ;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_command  ;
    logic [32*`PITO_NUM_HARTS-1 : 0] csr_mvu_quant    ;
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
                        output csr_mvu_wbaseaddr,
                        output csr_mvu_ibaseaddr,
                        output csr_mvu_obaseaddr,
                        output csr_mvu_wstride_0,
                        output csr_mvu_wstride_1,
                        output csr_mvu_wstride_2,
                        output csr_mvu_wstride_3,
                        output csr_mvu_istride_0,
                        output csr_mvu_istride_1,
                        output csr_mvu_istride_2,
                        output csr_mvu_istride_3,
                        output csr_mvu_ostride_0,
                        output csr_mvu_ostride_1,
                        output csr_mvu_ostride_2,
                        output csr_mvu_ostride_3,
                        output csr_mvu_wlength_0,
                        output csr_mvu_wlength_1,
                        output csr_mvu_wlength_2,
                        output csr_mvu_wlength_3,
                        output csr_mvu_ilength_0,
                        output csr_mvu_ilength_1,
                        output csr_mvu_ilength_2,
                        output csr_mvu_ilength_3,
                        output csr_mvu_olength_0,
                        output csr_mvu_olength_1,
                        output csr_mvu_olength_2,
                        output csr_mvu_olength_3,
                        output csr_mvu_precision,
                        output csr_mvu_status   ,
                        output csr_mvu_command  ,
                        output csr_mvu_quant    ,
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
                         output csr_mvu_wbaseaddr,
                         output csr_mvu_ibaseaddr,
                         output csr_mvu_obaseaddr,
                         output csr_mvu_wstride_0,
                         output csr_mvu_wstride_1,
                         output csr_mvu_wstride_2,
                         output csr_mvu_wstride_3,
                         output csr_mvu_istride_0,
                         output csr_mvu_istride_1,
                         output csr_mvu_istride_2,
                         output csr_mvu_istride_3,
                         output csr_mvu_ostride_0,
                         output csr_mvu_ostride_1,
                         output csr_mvu_ostride_2,
                         output csr_mvu_ostride_3,
                         output csr_mvu_wlength_0,
                         output csr_mvu_wlength_1,
                         output csr_mvu_wlength_2,
                         output csr_mvu_wlength_3,
                         output csr_mvu_ilength_0,
                         output csr_mvu_ilength_1,
                         output csr_mvu_ilength_2,
                         output csr_mvu_ilength_3,
                         output csr_mvu_olength_0,
                         output csr_mvu_olength_1,
                         output csr_mvu_olength_2,
                         output csr_mvu_olength_3,
                         output csr_mvu_precision,
                         output csr_mvu_status   ,
                         output csr_mvu_command  ,
                         output csr_mvu_quant    ,
                         output mvu_start        
);

endinterface