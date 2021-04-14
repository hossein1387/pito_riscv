`timescale 1ns/1ps
module rv32_barrel_csrfiles import rv32_pkg::*;import pito_pkg::*; #(
        parameter NUM_HARTS = 8
    ) 
    (

        input  logic                      clk,        // Clock
        input  logic                      rst_n,      // Asynchronous reset active low
        input  logic [11 : 0]             csr_addr,   // CSR register address
        input  logic [31 : 0]             csr_wdata,  // Data to be written to CSR
        input  logic [2  : 0]             csr_op,     // CSR operation type
        output logic [31 : 0]             csr_rdata,  // Data read from CSR
        // interrupts
        input  logic                      irq,      // External interrupt in (async)
        input  logic                      time_irq, // Timer threw a interrupt (async)
        input  logic                      ipi,      // Inter processor interrupt (async)

        // Core and Cluster ID
        input  logic [32*NUM_HARTS-1 : 0] boot_addr,// Address from which to start booting, mtvec is set to the same address

        // MVU interface
        input  logic [NUM_HARTS-1:0]      mvu_irq,  // MVU requesting an interrupt

        output exception_t                csr_exception,// Attempts to access a CSR without appropriate privilege
                                                          // level or to write  a read-only register also
                                                          // raises illegal instruction exceptions.
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wbaseaddr,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ibaseaddr,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_obaseaddr,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wstride_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wstride_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wstride_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_istride_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_istride_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_istride_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ostride_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ostride_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ostride_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wlength_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wlength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wlength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ilength_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ilength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ilength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_olength_0,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_olength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_olength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_precision,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_status   ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_command  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_quant    ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wstride_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_istride_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ostride_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_wlength_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_ilength_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvu_olength_3,

        output logic [NUM_HARTS-1   : 0]  mvu_start,
    
        input  logic [31 : 0]             pc[NUM_HARTS-1:0], // PC of instruction accessing the CSR
        input  logic [31 : 0]             cause,    // Exception code
        input  logic                      enable_cycle_count, // Enable cycle count
        output irq_evt_t [NUM_HARTS-1:0]  csr_irq_evt,
        input  logic [pito_pkg::HART_CNT_WIDTH-1:0] hart_id_i // hart id for accessign the csr file
);

// Signals for connecting csr files to I/O:
// Inputs:
logic[11 : 0 ] csr_addr_sigs  [NUM_HARTS-1 : 0];
logic[31 : 0 ] csr_wdata_sigs [NUM_HARTS-1 : 0];
logic[2  : 0 ] csr_op_sigs    [NUM_HARTS-1 : 0];
logic          irq_sigs       [NUM_HARTS-1 : 0];
logic          time_irq_sigs  [NUM_HARTS-1 : 0];
logic          ipi_sigs       [NUM_HARTS-1 : 0];
logic[31 : 0 ] boot_addr_sigs [NUM_HARTS-1 : 0];
logic          mvu_irq_sigs   [NUM_HARTS-1 : 0];
logic[31 : 0 ] pc_sigs        [NUM_HARTS-1 : 0];
logic[31 : 0 ] cause_sigs     [NUM_HARTS-1 : 0];
logic          enable_cycle_count_sigs;

logic [31 : 0] csr_rdata_sigs     [NUM_HARTS-1 : 0];
exception_t    csr_exception_sigs [NUM_HARTS-1 : 0];

logic [31 : 0] csr_mvu_wbaseaddr_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ibaseaddr_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_obaseaddr_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wstride_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wstride_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wstride_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_istride_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_istride_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_istride_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ostride_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ostride_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ostride_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wlength_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wlength_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wlength_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ilength_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ilength_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ilength_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_olength_0_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_olength_1_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_olength_2_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_precision_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wstride_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_istride_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ostride_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_wlength_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_ilength_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_olength_3_sigs [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_status_sigs    [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_command_sigs   [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvu_quant_sigs     [NUM_HARTS-1 : 0];
logic          mvu_start_sigs         [NUM_HARTS-1 : 0];


assign enable_cycle_count_sigs = 1'b1;

genvar hart_id;
    for(hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        rv32_csr #(hart_id) csrfile(
                            .clk                 (clk                             ),
                            .rst_n               (rst_n                           ),
                            .csr_addr_i          (csr_addr_sigs[hart_id]          ),
                            .csr_wdata_i         (csr_wdata_sigs[hart_id]         ),
                            .csr_op_i            (csr_op_sigs[hart_id]            ),
                            .csr_rdata_o         (csr_rdata_sigs[hart_id]         ),
                            .irq_i               (irq_sigs[hart_id ]              ),
                            .time_irq_i          (time_irq_sigs[hart_id]          ),
                            .ipi_i               (ipi_sigs[hart_id]               ),
                            .boot_addr_i         (boot_addr_sigs[hart_id]         ),
                            .mvu_irq_i           (mvu_irq_sigs[hart_id]           ),
                            .csr_exception_o     (csr_exception_sigs[hart_id]     ),
                            .pc_i                (pc_sigs[hart_id]                ),
                            .cause_i             (cause_sigs[hart_id]             ),
                            .enable_cycle_count_i(enable_cycle_count_sigs         ),
                            .csr_irq_evt         (csr_irq_evt[hart_id]            ),
                            .mvu_start           (mvu_start_sigs[hart_id]         ),
                            .csr_mvu_wbaseaddr   (csr_mvu_wbaseaddr_sigs[hart_id] ),
                            .csr_mvu_ibaseaddr   (csr_mvu_ibaseaddr_sigs[hart_id] ),
                            .csr_mvu_obaseaddr   (csr_mvu_obaseaddr_sigs[hart_id] ),
                            .csr_mvu_wstride_0   (csr_mvu_wstride_0_sigs[hart_id] ),
                            .csr_mvu_wstride_1   (csr_mvu_wstride_1_sigs[hart_id] ),
                            .csr_mvu_wstride_2   (csr_mvu_wstride_2_sigs[hart_id] ),
                            .csr_mvu_istride_0   (csr_mvu_istride_0_sigs[hart_id] ),
                            .csr_mvu_istride_1   (csr_mvu_istride_1_sigs[hart_id] ),
                            .csr_mvu_istride_2   (csr_mvu_istride_2_sigs[hart_id] ),
                            .csr_mvu_ostride_0   (csr_mvu_ostride_0_sigs[hart_id] ),
                            .csr_mvu_ostride_1   (csr_mvu_ostride_1_sigs[hart_id] ),
                            .csr_mvu_ostride_2   (csr_mvu_ostride_2_sigs[hart_id] ),
                            .csr_mvu_wlength_0   (csr_mvu_wlength_0_sigs[hart_id] ),
                            .csr_mvu_wlength_1   (csr_mvu_wlength_1_sigs[hart_id] ),
                            .csr_mvu_wlength_2   (csr_mvu_wlength_2_sigs[hart_id] ),
                            .csr_mvu_ilength_0   (csr_mvu_ilength_0_sigs[hart_id] ),
                            .csr_mvu_ilength_1   (csr_mvu_ilength_1_sigs[hart_id] ),
                            .csr_mvu_ilength_2   (csr_mvu_ilength_2_sigs[hart_id] ),
                            .csr_mvu_olength_0   (csr_mvu_olength_0_sigs[hart_id] ),
                            .csr_mvu_olength_1   (csr_mvu_olength_1_sigs[hart_id] ),
                            .csr_mvu_olength_2   (csr_mvu_olength_2_sigs[hart_id] ),
                            .csr_mvu_precision   (csr_mvu_precision_sigs[hart_id] ),
                            .csr_mvu_wstride_3   (csr_mvu_wstride_3_sigs[hart_id] ),
                            .csr_mvu_istride_3   (csr_mvu_istride_3_sigs[hart_id] ),
                            .csr_mvu_ostride_3   (csr_mvu_ostride_3_sigs[hart_id] ),
                            .csr_mvu_wlength_3   (csr_mvu_wlength_3_sigs[hart_id] ),
                            .csr_mvu_ilength_3   (csr_mvu_ilength_3_sigs[hart_id] ),
                            .csr_mvu_olength_3   (csr_mvu_olength_3_sigs[hart_id] ),
                            .csr_mvu_status      (csr_mvu_status_sigs[hart_id]    ),
                            .csr_mvu_command     (csr_mvu_command_sigs[hart_id]   ),
                            .csr_mvu_quant       (csr_mvu_quant_sigs[hart_id]     )
                        );
    end



// genvar hart_id;
generate 
    for (hart_id = 0; hart_id < NUM_HARTS; hart_id++)  begin
        assign csr_addr_sigs[hart_id]  = (hart_id==hart_id_i) ? csr_addr  : 0;
        assign csr_wdata_sigs[hart_id] = (hart_id==hart_id_i) ? csr_wdata : 0;
        assign csr_op_sigs[hart_id]    = (hart_id==hart_id_i) ? csr_op    : 3'b111; // Unknown for rest of the cycle
        assign boot_addr_sigs[hart_id] = (hart_id==hart_id_i) ? boot_addr : 0;
        assign cause_sigs[hart_id]     = (hart_id==hart_id_i) ? cause     : 0;
        assign mvu_irq_sigs[hart_id]   = mvu_irq[hart_id];
        assign pc_sigs[hart_id]        = pc[hart_id];
        assign irq_sigs[hart_id]       = irq;
        assign time_irq_sigs[hart_id]  = time_irq;
        assign ipi_sigs[hart_id]       = ipi;
    end
endgenerate


assign csr_rdata      = csr_rdata_sigs[hart_id_i];
assign csr_exception  = csr_exception_sigs[hart_id_i];

generate 
    for (hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        assign csr_mvu_wbaseaddr [hart_id*32 +: 32] = csr_mvu_wbaseaddr_sigs[hart_id];
        assign csr_mvu_ibaseaddr [hart_id*32 +: 32] = csr_mvu_ibaseaddr_sigs[hart_id];
        assign csr_mvu_obaseaddr [hart_id*32 +: 32] = csr_mvu_obaseaddr_sigs[hart_id];
        assign csr_mvu_wstride_0 [hart_id*32 +: 32] = csr_mvu_wstride_0_sigs[hart_id];
        assign csr_mvu_wstride_1 [hart_id*32 +: 32] = csr_mvu_wstride_1_sigs[hart_id];
        assign csr_mvu_wstride_2 [hart_id*32 +: 32] = csr_mvu_wstride_2_sigs[hart_id];
        assign csr_mvu_istride_0 [hart_id*32 +: 32] = csr_mvu_istride_0_sigs[hart_id];
        assign csr_mvu_istride_1 [hart_id*32 +: 32] = csr_mvu_istride_1_sigs[hart_id];
        assign csr_mvu_istride_2 [hart_id*32 +: 32] = csr_mvu_istride_2_sigs[hart_id];
        assign csr_mvu_ostride_0 [hart_id*32 +: 32] = csr_mvu_ostride_0_sigs[hart_id];
        assign csr_mvu_ostride_1 [hart_id*32 +: 32] = csr_mvu_ostride_1_sigs[hart_id];
        assign csr_mvu_ostride_2 [hart_id*32 +: 32] = csr_mvu_ostride_2_sigs[hart_id];
        assign csr_mvu_wlength_0 [hart_id*32 +: 32] = csr_mvu_wlength_0_sigs[hart_id];
        assign csr_mvu_wlength_1 [hart_id*32 +: 32] = csr_mvu_wlength_1_sigs[hart_id];
        assign csr_mvu_wlength_2 [hart_id*32 +: 32] = csr_mvu_wlength_2_sigs[hart_id];
        assign csr_mvu_ilength_0 [hart_id*32 +: 32] = csr_mvu_ilength_0_sigs[hart_id];
        assign csr_mvu_ilength_1 [hart_id*32 +: 32] = csr_mvu_ilength_1_sigs[hart_id];
        assign csr_mvu_ilength_2 [hart_id*32 +: 32] = csr_mvu_ilength_2_sigs[hart_id];
        assign csr_mvu_olength_0 [hart_id*32 +: 32] = csr_mvu_olength_0_sigs[hart_id];
        assign csr_mvu_olength_1 [hart_id*32 +: 32] = csr_mvu_olength_1_sigs[hart_id];
        assign csr_mvu_olength_2 [hart_id*32 +: 32] = csr_mvu_olength_2_sigs[hart_id];
        assign csr_mvu_precision [hart_id*32 +: 32] = csr_mvu_precision_sigs[hart_id];
        assign csr_mvu_wstride_3 [hart_id*32 +: 32] = csr_mvu_wstride_3_sigs[hart_id];
        assign csr_mvu_istride_3 [hart_id*32 +: 32] = csr_mvu_istride_3_sigs[hart_id];
        assign csr_mvu_ostride_3 [hart_id*32 +: 32] = csr_mvu_ostride_3_sigs[hart_id];
        assign csr_mvu_wlength_3 [hart_id*32 +: 32] = csr_mvu_wlength_3_sigs[hart_id];
        assign csr_mvu_ilength_3 [hart_id*32 +: 32] = csr_mvu_ilength_3_sigs[hart_id];
        assign csr_mvu_olength_3 [hart_id*32 +: 32] = csr_mvu_olength_3_sigs[hart_id];
        assign csr_mvu_status    [hart_id*32 +: 32] = csr_mvu_status_sigs[hart_id];
        assign csr_mvu_command   [hart_id*32 +: 32] = csr_mvu_command_sigs[hart_id];
        assign csr_mvu_quant     [hart_id*32 +: 32] = csr_mvu_quant_sigs[hart_id];
        assign mvu_start         [ hart_id        ] = mvu_start_sigs[hart_id];
    end
endgenerate

endmodule