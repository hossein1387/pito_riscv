`timescale 1ns/1ps
import pito_pkg::*;


module rv32_barrel_csrfiles #(
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
        input  logic [31 : 0]             boot_addr,// Address from which to start booting, mtvec is set to the same address

        // MVU interface
        input  logic [NUM_HARTS-1:0]      mvu_irq,  // MVU requesting an interrupt

        output exception_t                csr_exception,// Attempts to access a CSR without appropriate privilege
                                                          // level or to write  a read-only register also
                                                          // raises illegal instruction exceptions.
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwbaseptr ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuibaseptr ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvusbaseptr ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvubbaseptr ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuobaseptr ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwjump_0  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwjump_1  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwjump_2  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwjump_3  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwjump_4  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuijump_0  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuijump_1  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuijump_2  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuijump_3  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuijump_4  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvusjump_0  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvusjump_1  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvubjump_0  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvubjump_1  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuojump_0  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuojump_1  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuojump_2  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuojump_3  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuojump_4  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwlength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwlength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwlength_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuwlength_4,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuilength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuilength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuilength_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuilength_4,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuslength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvublength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuolength_1,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuolength_2,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuolength_3,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuolength_4,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuprecision,
        output logic [32*NUM_HARTS-1 : 0] csr_mvustatus   ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvucommand  ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuquant    ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuscaler   ,
        output logic [32*NUM_HARTS-1 : 0] csr_mvuconfig1  ,

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

logic [31 : 0] csr_rdata_sigs        [NUM_HARTS-1 : 0];
exception_t    csr_exception_sigs    [NUM_HARTS-1 : 0];
logic [31 : 0] csr_mvuwbaseptr_sigs  [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuibaseptr_sigs  [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvusbaseptr_sigs  [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvubbaseptr_sigs  [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuobaseptr_sigs  [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwjump_0_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwjump_1_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwjump_2_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwjump_3_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwjump_4_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuijump_0_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuijump_1_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuijump_2_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuijump_3_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuijump_4_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvusjump_0_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvusjump_1_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvubjump_0_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvubjump_1_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuojump_0_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuojump_1_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuojump_2_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuojump_3_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuojump_4_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwlength_1_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwlength_2_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwlength_3_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuwlength_4_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuilength_1_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuilength_2_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuilength_3_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuilength_4_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuslength_1_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvublength_1_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuolength_1_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuolength_2_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuolength_3_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuolength_4_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuprecision_sigs [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvustatus_sigs    [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvucommand_sigs   [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuquant_sigs     [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuscaler_sigs    [NUM_HARTS-1 : 0 ];
logic [31 : 0] csr_mvuconfig1_sigs   [NUM_HARTS-1 : 0 ];
logic          mvu_start_sigs        [NUM_HARTS-1 : 0];


assign enable_cycle_count_sigs = 1'b1;

genvar hart_id;
    for(hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        rv32_csr #(hart_id) csrfile(
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
                            .csr_mvuwbaseptr       (csr_mvuwbaseptr_sigs[hart_id]   ),
                            .csr_mvuibaseptr       (csr_mvuibaseptr_sigs[hart_id]   ),
                            .csr_mvusbaseptr       (csr_mvusbaseptr_sigs[hart_id]   ),
                            .csr_mvubbaseptr       (csr_mvubbaseptr_sigs[hart_id]   ),
                            .csr_mvuobaseptr       (csr_mvuobaseptr_sigs[hart_id]   ),
                            .csr_mvuwjump_0        (csr_mvuwjump_0_sigs[hart_id]    ),
                            .csr_mvuwjump_1        (csr_mvuwjump_1_sigs[hart_id]    ),
                            .csr_mvuwjump_2        (csr_mvuwjump_2_sigs[hart_id]    ),
                            .csr_mvuwjump_3        (csr_mvuwjump_3_sigs[hart_id]    ),
                            .csr_mvuwjump_4        (csr_mvuwjump_4_sigs[hart_id]    ),
                            .csr_mvuijump_0        (csr_mvuijump_0_sigs[hart_id]    ),
                            .csr_mvuijump_1        (csr_mvuijump_1_sigs[hart_id]    ),
                            .csr_mvuijump_2        (csr_mvuijump_2_sigs[hart_id]    ),
                            .csr_mvuijump_3        (csr_mvuijump_3_sigs[hart_id]    ),
                            .csr_mvuijump_4        (csr_mvuijump_4_sigs[hart_id]    ),
                            .csr_mvusjump_0        (csr_mvusjump_0_sigs[hart_id]    ),
                            .csr_mvusjump_1        (csr_mvusjump_1_sigs[hart_id]    ),
                            .csr_mvubjump_0        (csr_mvubjump_0_sigs[hart_id]    ),
                            .csr_mvubjump_1        (csr_mvubjump_1_sigs[hart_id]    ),
                            .csr_mvuojump_0        (csr_mvuojump_0_sigs[hart_id]    ),
                            .csr_mvuojump_1        (csr_mvuojump_1_sigs[hart_id]    ),
                            .csr_mvuojump_2        (csr_mvuojump_2_sigs[hart_id]    ),
                            .csr_mvuojump_3        (csr_mvuojump_3_sigs[hart_id]    ),
                            .csr_mvuojump_4        (csr_mvuojump_4_sigs[hart_id]    ),
                            .csr_mvuwlength_1      (csr_mvuwlength_1_sigs[hart_id]  ),
                            .csr_mvuwlength_2      (csr_mvuwlength_2_sigs[hart_id]  ),
                            .csr_mvuwlength_3      (csr_mvuwlength_3_sigs[hart_id]  ),
                            .csr_mvuwlength_4      (csr_mvuwlength_4_sigs[hart_id]  ),
                            .csr_mvuilength_1      (csr_mvuilength_1_sigs[hart_id]  ),
                            .csr_mvuilength_2      (csr_mvuilength_2_sigs[hart_id]  ),
                            .csr_mvuilength_3      (csr_mvuilength_3_sigs[hart_id]  ),
                            .csr_mvuilength_4      (csr_mvuilength_4_sigs[hart_id]  ),
                            .csr_mvuslength_1      (csr_mvuslength_1_sigs[hart_id]  ),
                            .csr_mvublength_1      (csr_mvublength_1_sigs[hart_id]  ),
                            .csr_mvuolength_1      (csr_mvuolength_1_sigs[hart_id]  ),
                            .csr_mvuolength_2      (csr_mvuolength_2_sigs[hart_id]  ),
                            .csr_mvuolength_3      (csr_mvuolength_3_sigs[hart_id]  ),
                            .csr_mvuolength_4      (csr_mvuolength_4_sigs[hart_id]  ),
                            .csr_mvuprecision      (csr_mvuprecision_sigs[hart_id]  ),
                            .csr_mvustatus         (csr_mvustatus_sigs[hart_id]     ),
                            .csr_mvucommand        (csr_mvucommand_sigs[hart_id]    ),
                            .csr_mvuquant          (csr_mvuquant_sigs[hart_id]      ),
                            .csr_mvuscaler         (csr_mvuscaler_sigs[hart_id]     ),
                            .csr_mvuconfig1        (csr_mvuconfig1_sigs[hart_id]    ),
                            .mvu_start             (mvu_start_sigs[hart_id]         ),
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


assign csr_rdata      = csr_rdata_sigs[hart_id_i];
assign csr_exception  = csr_exception_sigs[hart_id_i];

generate 
    for (hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        assign csr_mvuwbaseptr[hart_id*32 +: 32]  = csr_mvuwbaseptr_sigs[hart_id] ;
        assign csr_mvuibaseptr[hart_id*32 +: 32]  = csr_mvuibaseptr_sigs[hart_id] ;
        assign csr_mvusbaseptr[hart_id*32 +: 32]  = csr_mvusbaseptr_sigs[hart_id] ;
        assign csr_mvubbaseptr[hart_id*32 +: 32]  = csr_mvubbaseptr_sigs[hart_id] ;
        assign csr_mvuobaseptr[hart_id*32 +: 32]  = csr_mvuobaseptr_sigs[hart_id] ;
        assign csr_mvuwjump_0[hart_id*32 +: 32]   = csr_mvuwjump_0_sigs[hart_id]  ;
        assign csr_mvuwjump_1[hart_id*32 +: 32]   = csr_mvuwjump_1_sigs[hart_id]  ;
        assign csr_mvuwjump_2[hart_id*32 +: 32]   = csr_mvuwjump_2_sigs[hart_id]  ;
        assign csr_mvuwjump_3[hart_id*32 +: 32]   = csr_mvuwjump_3_sigs[hart_id]  ;
        assign csr_mvuwjump_4[hart_id*32 +: 32]   = csr_mvuwjump_4_sigs[hart_id]  ;
        assign csr_mvuijump_0[hart_id*32 +: 32]   = csr_mvuijump_0_sigs[hart_id]  ;
        assign csr_mvuijump_1[hart_id*32 +: 32]   = csr_mvuijump_1_sigs[hart_id]  ;
        assign csr_mvuijump_2[hart_id*32 +: 32]   = csr_mvuijump_2_sigs[hart_id]  ;
        assign csr_mvuijump_3[hart_id*32 +: 32]   = csr_mvuijump_3_sigs[hart_id]  ;
        assign csr_mvuijump_4[hart_id*32 +: 32]   = csr_mvuijump_4_sigs[hart_id]  ;
        assign csr_mvusjump_0[hart_id*32 +: 32]   = csr_mvusjump_0_sigs[hart_id]  ;
        assign csr_mvusjump_1[hart_id*32 +: 32]   = csr_mvusjump_1_sigs[hart_id]  ;
        assign csr_mvubjump_0[hart_id*32 +: 32]   = csr_mvubjump_0_sigs[hart_id]  ;
        assign csr_mvubjump_1[hart_id*32 +: 32]   = csr_mvubjump_1_sigs[hart_id]  ;
        assign csr_mvuojump_0[hart_id*32 +: 32]   = csr_mvuojump_0_sigs[hart_id]  ;
        assign csr_mvuojump_1[hart_id*32 +: 32]   = csr_mvuojump_1_sigs[hart_id]  ;
        assign csr_mvuojump_2[hart_id*32 +: 32]   = csr_mvuojump_2_sigs[hart_id]  ;
        assign csr_mvuojump_3[hart_id*32 +: 32]   = csr_mvuojump_3_sigs[hart_id]  ;
        assign csr_mvuojump_4[hart_id*32 +: 32]   = csr_mvuojump_4_sigs[hart_id]  ;
        assign csr_mvuwlength_1[hart_id*32 +: 32] = csr_mvuwlength_1_sigs[hart_id];
        assign csr_mvuwlength_2[hart_id*32 +: 32] = csr_mvuwlength_2_sigs[hart_id];
        assign csr_mvuwlength_3[hart_id*32 +: 32] = csr_mvuwlength_3_sigs[hart_id];
        assign csr_mvuwlength_4[hart_id*32 +: 32] = csr_mvuwlength_4_sigs[hart_id];
        assign csr_mvuilength_1[hart_id*32 +: 32] = csr_mvuilength_1_sigs[hart_id];
        assign csr_mvuilength_2[hart_id*32 +: 32] = csr_mvuilength_2_sigs[hart_id];
        assign csr_mvuilength_3[hart_id*32 +: 32] = csr_mvuilength_3_sigs[hart_id];
        assign csr_mvuilength_4[hart_id*32 +: 32] = csr_mvuilength_4_sigs[hart_id];
        assign csr_mvuslength_1[hart_id*32 +: 32] = csr_mvuslength_1_sigs[hart_id];
        assign csr_mvublength_1[hart_id*32 +: 32] = csr_mvublength_1_sigs[hart_id];
        assign csr_mvuolength_1[hart_id*32 +: 32] = csr_mvuolength_1_sigs[hart_id];
        assign csr_mvuolength_2[hart_id*32 +: 32] = csr_mvuolength_2_sigs[hart_id];
        assign csr_mvuolength_3[hart_id*32 +: 32] = csr_mvuolength_3_sigs[hart_id];
        assign csr_mvuolength_4[hart_id*32 +: 32] = csr_mvuolength_4_sigs[hart_id];
        assign csr_mvuprecision[hart_id*32 +: 32] = csr_mvuprecision_sigs[hart_id];
        assign csr_mvustatus[hart_id*32 +: 32]    = csr_mvustatus_sigs[hart_id]   ;
        assign csr_mvucommand[hart_id*32 +: 32]   = csr_mvucommand_sigs[hart_id]  ;
        assign csr_mvuquant[hart_id*32 +: 32]     = csr_mvuquant_sigs[hart_id]    ;
        assign csr_mvuscaler[hart_id*32 +: 32]    = csr_mvuscaler_sigs[hart_id]   ;
        assign csr_mvuconfig1[hart_id*32 +: 32]   = csr_mvuconfig1_sigs[hart_id]  ;
        assign mvu_start [ hart_id        ]       = mvu_start_sigs[hart_id];
    end
endgenerate

endmodule