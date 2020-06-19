module rv32_barrel_csrfiles #(
        parameter NUM_HARTS      = 8,
        parameter HART_CNT_WIDTH = $clog2(NUM_HARTS)
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
        input  logic [31 : 0]             boot_addr,// Address from which to start booting, mtvec is set to the same address

        // MVU interface
        input  logic                      mvu_irq,  // MVU requesting an interrupt

        output exception_t                csr_exception,// Attempts to access a CSR without appropriate privilege
                                                          // level or to write  a read-only register also
                                                          // raises illegal instruction exceptions.
        input  logic [31 : 0]             pc,       // PC of instruction accessing the CSR
        input  logic [31 : 0]             cause,    // Exception code
        input  logic                      enable_cycle_count, // Enable cycle count
        output logic [31 : 0]             csr_epc,  // epc 

        input  logic [HART_CNT_WIDTH-1:0] hart_id_i // hart id for accessign the csr file
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

assign enable_cycle_count_sigs = 1'b1;

genvar hart_id;
    for(hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        rv32_csr csrfile(
                            .clk                 (clk                    ),
                            .rst_n               (rst_n                  ),
                            .csr_addr_i          (csr_addr_sigs[hart_id] ),
                            .csr_wdata_i         (csr_wdata_sigs[hart_id]),
                            .csr_op_i            (csr_op_sigs[hart_id]   ),
                            .csr_rdata_o         (csr_rdata              ),
                            .irq_i               (irq_sigs[hart_id ]     ),
                            .time_irq_i          (time_irq_sigs[hart_id] ),
                            .ipi_i               (ipi_sigs[hart_id]      ),
                            .boot_addr_i         (boot_addr_sigs[hart_id]),
                            .mvu_irq_i           (mvu_irq_sigs[hart_id]  ),
                            .csr_exception_o     (csr_exception          ),
                            .pc_i                (pc_sigs[hart_id]       ),
                            .cause_i             (cause_sigs[hart_id]    ),
                            .enable_cycle_count_i(enable_cycle_count_sigs),
                            .csr_epc_o           (csr_epc                )
                        );
    end
endgenerate

genvar hart_id;
generate 
  for (hart_id = 0; hart_id < NUM_HARTS; hart_id++)  begin
    assign csr_addr_sigs[hart_id]  = (hart_id==hart_id_i) ? csr_addr  : 0;
    assign csr_wdata_sigs[hart_id] = (hart_id==hart_id_i) ? csr_wdata : 0;
    assign csr_op_sigs[hart_id]    = (hart_id==hart_id_i) ? csr_op    : 0;
    assign irq_sigs[hart_id]       = (hart_id==hart_id_i) ? irq       : 0;
    assign time_irq_sigs[hart_id]  = (hart_id==hart_id_i) ? time_irq  : 0;
    assign ipi_sigs[hart_id]       = (hart_id==hart_id_i) ? ipi       : 0;
    assign boot_addr_sigs[hart_id] = (hart_id==hart_id_i) ? boot_addr : 0;
    assign mvu_irq_sigs[hart_id]   = (hart_id==hart_id_i) ? mvu_irq   : 0;
    assign pc_sigs[hart_id]        = (hart_id==hart_id_i) ? pc        : 0;
    assign cause_sigs[hart_id]     = (hart_id==hart_id_i) ? cause     : 0;
  end
endgenerate


endmodule