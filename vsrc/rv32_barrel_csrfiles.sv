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
    
        input  logic [31 : 0]             pc[NUM_HARTS-1:0], // PC of instruction accessing the CSR
        input  logic [31 : 0]             cause,    // Exception code
        input  logic                      enable_cycle_count, // Enable cycle count
        output irq_evt_t [NUM_HARTS-1:0]  csr_irq_evt,
        input  hart_id_t                  hart_id_i, // hart id for accessign the csr file
        APB                               apb
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

apb_addr_t  [NUM_HARTS-1 : 0] apb_paddr  ;
logic       [NUM_HARTS-1 : 0] apb_psel   ;
logic       [NUM_HARTS-1 : 0] apb_penable;
logic       [NUM_HARTS-1 : 0] apb_pwrite ;
apb_data_t  [NUM_HARTS-1 : 0] apb_pwdata ;


logic [31 : 0] csr_rdata_sigs        [NUM_HARTS-1 : 0];
exception_t    csr_exception_sigs    [NUM_HARTS-1 : 0];

assign enable_cycle_count_sigs = 1'b1;

genvar hart_id;
    for(hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        rv32_csr #(hart_id,12'hF20,NUM_HARTS) csrfile(
                            .clk                   (clk                             ),
                            .rst_n                 (rst_n                           ),
                            .csr_addr_i            (csr_addr_sigs[hart_id]          ),
                            .csr_wdata_i           (csr_wdata_sigs[hart_id]         ),
                            .csr_op_i              (csr_op_sigs[hart_id]            ),
                            .csr_rdata_o           (csr_rdata_sigs[hart_id]         ),
                            .irq_i                 (irq_sigs[hart_id ]              ),
                            .time_irq_i            (time_irq_sigs[hart_id]          ),
                            .ipi_i                 (ipi_sigs[hart_id]               ),
                            .boot_addr_i           (boot_addr_sigs[hart_id]         ),
                            .mvu_irq_i             (mvu_irq_sigs[hart_id]           ),
                            .apb_paddr             (apb_paddr[hart_id]              ),
                            .apb_psel              (apb_psel[hart_id]               ),
                            .apb_penable           (apb_penable[hart_id]            ),
                            .apb_pwrite            (apb_pwrite[hart_id]             ),
                            .apb_pwdata            (apb_pwdata[hart_id]             ),
                            .csr_exception_o       (csr_exception_sigs[hart_id]     ),
                            .pc_i                  (pc_sigs[hart_id]                ),
                            .cause_i               (cause_sigs[hart_id]             ),
                            .enable_cycle_count_i  (enable_cycle_count_sigs         ),
                            .csr_irq_evt           (csr_irq_evt[hart_id]            )
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

// APB Interface:
// APB is accessed one hart at a time, gauranteed. It is safe to start 
// an APB transaction as soon as any hart raises the apb_penable signal. 

hart_id_t apb_hart_id;
logic apb_valid_transaction;

onehot_to_bin  #(.ONEHOT_WIDTH(HART_CNT_WIDTH)) onehot_to_bin_inst (apb_penable, apb_hart_id);
assign apb_valid_transaction = |apb_penable;

always_comb begin
    if (apb_valid_transaction) begin
        apb.paddr   = apb_paddr[apb_hart_id];
        apb.pwdata  = apb_pwdata[apb_hart_id];
        apb.pstrb   = 4'hF;
        apb.pwrite  = apb_pwrite[apb_hart_id];
        apb.psel    = apb_psel[apb_hart_id];
        apb.penable = apb_penable[apb_hart_id];
    end else begin
        apb.paddr   = 0;
        apb.pwdata  = 0;
        apb.pstrb   = 4'h0;
        apb.pwrite  = 1'b0;
        apb.psel    = 1'b0;
        apb.penable = 1'b0;
    end
end

assign csr_rdata      = csr_rdata_sigs[hart_id_i];
assign csr_exception  = csr_exception_sigs[hart_id_i];

endmodule