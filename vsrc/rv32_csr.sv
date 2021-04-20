`timescale 1ns/1ps
import pito_pkg::*;
import rv32_pkg::*;

module rv32_csr #(
    parameter PITO_HART_ID = 0
    )(
    input  logic                      clk,        // Clock
    input  logic                      rst_n,      // Asynchronous reset active low
    input  logic [11 : 0]             csr_addr_i, // CSR register address
    input  logic [31 : 0]             csr_wdata_i,// Data to be written to CSR
    input  logic [2  : 0]             csr_op_i,   // CSR operation type
    output logic [31 : 0]             csr_rdata_o,// Data read from CSR
    // interrupts
    input  logic                      irq_i,      // External interrupt in (async)
    input  logic                      time_irq_i, // Timer threw a interrupt (async)
    input  logic                      ipi_i,      // Inter processor interrupt (async)

    // Core and Cluster ID
    input  logic [31 : 0]             boot_addr_i,// Address from which to start booting, mtvec is set to the same address
    // MVU interface
    input  logic                      mvu_irq_i,
    input logic [31 : 0]              csr_mvuwbaseptr,
    input logic [31 : 0]              csr_mvuibaseptr,
    input logic [31 : 0]              csr_mvusbaseptr,
    input logic [31 : 0]              csr_mvubbaseptr,
    input logic [31 : 0]              csr_mvuobaseptr,
    input logic [31 : 0]              csr_mvuwjump_0,
    input logic [31 : 0]              csr_mvuwjump_1,
    input logic [31 : 0]              csr_mvuwjump_2,
    input logic [31 : 0]              csr_mvuwjump_3,
    input logic [31 : 0]              csr_mvuwjump_4,
    input logic [31 : 0]              csr_mvuijump_0,
    input logic [31 : 0]              csr_mvuijump_1,
    input logic [31 : 0]              csr_mvuijump_2,
    input logic [31 : 0]              csr_mvuijump_3,
    input logic [31 : 0]              csr_mvuijump_4,
    input logic [31 : 0]              csr_mvusjump_0,
    input logic [31 : 0]              csr_mvusjump_1,
    input logic [31 : 0]              csr_mvubjump_0,
    input logic [31 : 0]              csr_mvubjump_1,
    input logic [31 : 0]              csr_mvuojump_0,
    input logic [31 : 0]              csr_mvuojump_1,
    input logic [31 : 0]              csr_mvuojump_2,
    input logic [31 : 0]              csr_mvuojump_3,
    input logic [31 : 0]              csr_mvuojump_4,
    input logic [31 : 0]              csr_mvuwlength_1,
    input logic [31 : 0]              csr_mvuwlength_2,
    input logic [31 : 0]              csr_mvuwlength_3,
    input logic [31 : 0]              csr_mvuwlength_4,
    input logic [31 : 0]              csr_mvuilength_1,
    input logic [31 : 0]              csr_mvuilength_2,
    input logic [31 : 0]              csr_mvuilength_3,
    input logic [31 : 0]              csr_mvuilength_4,
    input logic [31 : 0]              csr_mvuslength_1,
    input logic [31 : 0]              csr_mvublength_1,
    input logic [31 : 0]              csr_mvuolength_1,
    input logic [31 : 0]              csr_mvuolength_2,
    input logic [31 : 0]              csr_mvuolength_3,
    input logic [31 : 0]              csr_mvuolength_4,
    input logic [31 : 0]              csr_mvuprecision,
    input logic [31 : 0]              csr_mvustatus,
    input logic [31 : 0]              csr_mvucommand,
    input logic [31 : 0]              csr_mvuquant,
    input logic [31 : 0]              csr_mvuscaler,
    input logic [31 : 0]              csr_mvuconfig1,
    output logic                      mvu_start,

    output exception_t                csr_exception_o,// Attempts to access a CSR without appropriate privilege
                                                      // level or to write  a read-only register also
                                                      // raises illegal instruction exceptions.
    input  logic [31 : 0]             pc_i,       // PC of instruction accessing the CSR
    input  logic [31 : 0]             cause_i,    // Exception code
    input  logic                      enable_cycle_count_i, // Enable cycle count
    output irq_evt_t                  csr_irq_evt
);

    // internal signal to keep track of access exceptions
    logic [31:0]            csr_wdata, csr_rdata;
    logic                   read_access_exception;
    logic                   update_access_exception;
    logic                   csr_we, csr_read;
    logic                   wfi_q, wfi_d;
    pito_pkg::csr_t         csr_addr;
    pito_pkg::csr_op_t      csr_op;
    // RV32 Machine Mode CSRs
    logic [31:0]            mvendorid;
    logic [31:0]            marchid;
    logic [31:0]            mimpid;
    logic [31:0]            mhartdid;
    logic [31:0]            misa;
    rv32_pkg::status_rv32_t mstatus_q, mstatus_d;
    rv32_pkg::mip_rv32_t    mip_q, mip_d;
    rv32_pkg::mie_rv32_t    mie_q, mie_d;
    logic [31:0]            mcause_q, mcause_d;
    logic [31:0]            mtvec_q, mtvec_d;
    logic [31:0]            mepc_q, mepc_d;
    logic [31:0]            mtval_q, mtval_d;
    logic [63:0]            mcycle_q, mcycle_d;
    logic [63:0]            minstret_q, minstret_d;
    // return from M-mode exception
    logic        mret;  
    logic        mvu_irq_valid;
    logic        timer_irq_valid;
    logic        ipi_irq_valid;
    logic        is_irq;

    logic        mtvec_rst_load_q;// used to determine whether we came out of reset

    // MVU CSRs;
    logic [31:0] csr_mvuwbaseptr_q,  csr_mvuwbaseptr_d;
    logic [31:0] csr_mvuibaseptr_q,  csr_mvuibaseptr_d;
    logic [31:0] csr_mvusbaseptr_q,  csr_mvusbaseptr_d;
    logic [31:0] csr_mvubbaseptr_q,  csr_mvubbaseptr_d;
    logic [31:0] csr_mvuobaseptr_q,  csr_mvuobaseptr_d;
    logic [31:0] csr_mvuwjump_0_q,   csr_mvuwjump_0_d;
    logic [31:0] csr_mvuwjump_1_q,   csr_mvuwjump_1_d;
    logic [31:0] csr_mvuwjump_2_q,   csr_mvuwjump_2_d;
    logic [31:0] csr_mvuwjump_3_q,   csr_mvuwjump_3_d;
    logic [31:0] csr_mvuwjump_4_q,   csr_mvuwjump_4_d;
    logic [31:0] csr_mvuijump_0_q,   csr_mvuijump_0_d;
    logic [31:0] csr_mvuijump_1_q,   csr_mvuijump_1_d;
    logic [31:0] csr_mvuijump_2_q,   csr_mvuijump_2_d;
    logic [31:0] csr_mvuijump_3_q,   csr_mvuijump_3_d;
    logic [31:0] csr_mvuijump_4_q,   csr_mvuijump_4_d;
    logic [31:0] csr_mvusjump_0_q,   csr_mvusjump_0_d;
    logic [31:0] csr_mvusjump_1_q,   csr_mvusjump_1_d;
    logic [31:0] csr_mvubjump_0_q,   csr_mvubjump_0_d;
    logic [31:0] csr_mvubjump_1_q,   csr_mvubjump_1_d;
    logic [31:0] csr_mvuojump_0_q,   csr_mvuojump_0_d;
    logic [31:0] csr_mvuojump_1_q,   csr_mvuojump_1_d;
    logic [31:0] csr_mvuojump_2_q,   csr_mvuojump_2_d;
    logic [31:0] csr_mvuojump_3_q,   csr_mvuojump_3_d;
    logic [31:0] csr_mvuojump_4_q,   csr_mvuojump_4_d;
    logic [31:0] csr_mvuwlength_1_q, csr_mvuwlength_1_d;
    logic [31:0] csr_mvuwlength_2_q, csr_mvuwlength_2_d;
    logic [31:0] csr_mvuwlength_3_q, csr_mvuwlength_3_d;
    logic [31:0] csr_mvuwlength_4_q, csr_mvuwlength_4_d;
    logic [31:0] csr_mvuilength_1_q, csr_mvuilength_1_d;
    logic [31:0] csr_mvuilength_2_q, csr_mvuilength_2_d;
    logic [31:0] csr_mvuilength_3_q, csr_mvuilength_3_d;
    logic [31:0] csr_mvuilength_4_q, csr_mvuilength_4_d;
    logic [31:0] csr_mvuslength_1_q, csr_mvuslength_1_d;
    logic [31:0] csr_mvublength_1_q, csr_mvublength_1_d;
    logic [31:0] csr_mvuolength_1_q, csr_mvuolength_1_d;
    logic [31:0] csr_mvuolength_2_q, csr_mvuolength_2_d;
    logic [31:0] csr_mvuolength_3_q, csr_mvuolength_3_d;
    logic [31:0] csr_mvuolength_4_q, csr_mvuolength_4_d;
    logic [31:0] csr_mvuprecision_q, csr_mvuprecision_d;
    logic [31:0] csr_mvustatus_q,    csr_mvustatus_d;
    logic [31:0] csr_mvucommand_q,   csr_mvucommand_d;
    logic [31:0] csr_mvuquant_q,     csr_mvuquant_d;
    logic [31:0] csr_mvuscaler_q,    csr_mvuscaler_d;
    logic [31:0] csr_mvuconfig1_q,   csr_mvuconfig1_d;

//====================================================================
//                    Assignments
//====================================================================
    assign mvendorid= 32'b0;// not implemented
    assign marchid  = PITO_MARCHID;
    assign mimpid   = 32'b0;// not implemented
    assign mhartdid = PITO_HART_ID;
    assign misa     = ISA_CODE;
    assign csr_addr = pito_pkg::csr_t'(csr_addr_i);
    assign csr_op   = pito_pkg::csr_op_t'(csr_op_i);


    assign csr_mvuwbaseptr    = csr_mvuwbaseptr_q;
    assign csr_mvuibaseptr    = csr_mvuibaseptr_q;
    assign csr_mvusbaseptr    = csr_mvusbaseptr_q;
    assign csr_mvubbaseptr    = csr_mvubbaseptr_q;
    assign csr_mvuobaseptr    = csr_mvuobaseptr_q;
    assign csr_mvuwjump_0     = csr_mvuwjump_0_q;
    assign csr_mvuwjump_1     = csr_mvuwjump_1_q;
    assign csr_mvuwjump_2     = csr_mvuwjump_2_q;
    assign csr_mvuwjump_3     = csr_mvuwjump_3_q;
    assign csr_mvuwjump_4     = csr_mvuwjump_4_q;
    assign csr_mvuijump_0     = csr_mvuijump_0_q;
    assign csr_mvuijump_1     = csr_mvuijump_1_q;
    assign csr_mvuijump_2     = csr_mvuijump_2_q;
    assign csr_mvuijump_3     = csr_mvuijump_3_q;
    assign csr_mvuijump_4     = csr_mvuijump_4_q;
    assign csr_mvusjump_0     = csr_mvusjump_0_q;
    assign csr_mvusjump_1     = csr_mvusjump_1_q;
    assign csr_mvubjump_0     = csr_mvubjump_0_q;
    assign csr_mvubjump_1     = csr_mvubjump_1_q;
    assign csr_mvuojump_0     = csr_mvuojump_0_q;
    assign csr_mvuojump_1     = csr_mvuojump_1_q;
    assign csr_mvuojump_2     = csr_mvuojump_2_q;
    assign csr_mvuojump_3     = csr_mvuojump_3_q;
    assign csr_mvuojump_4     = csr_mvuojump_4_q;
    assign csr_mvuwlength_1   = csr_mvuwlength_1_q;
    assign csr_mvuwlength_2   = csr_mvuwlength_2_q;
    assign csr_mvuwlength_3   = csr_mvuwlength_3_q;
    assign csr_mvuwlength_4   = csr_mvuwlength_4_q;
    assign csr_mvuilength_1   = csr_mvuilength_1_q;
    assign csr_mvuilength_2   = csr_mvuilength_2_q;
    assign csr_mvuilength_3   = csr_mvuilength_3_q;
    assign csr_mvuilength_4   = csr_mvuilength_4_q;
    assign csr_mvuslength_1   = csr_mvuslength_1_q;
    assign csr_mvublength_1   = csr_mvublength_1_q;
    assign csr_mvuolength_1   = csr_mvuolength_1_q;
    assign csr_mvuolength_2   = csr_mvuolength_2_q;
    assign csr_mvuolength_3   = csr_mvuolength_3_q;
    assign csr_mvuolength_4   = csr_mvuolength_4_q;
    assign csr_mvuprecision   = csr_mvuprecision_q;
    assign csr_mvustatus_q    = { {31{1'b0}}, csr_mvustatus};
    assign csr_mvucommand     = csr_mvucommand_q;
    assign csr_mvuquant       = csr_mvuquant_q;
    assign csr_mvuscaler      = csr_mvuscaler_q;
    assign csr_mvuconfig1     = csr_mvuconfig1_q;

    assign timer_irq_valid    = 1'b0; // not supported for now
    assign ipi_irq_valid      = 1'b0; // not supported for now
    assign mvu_irq_valid      = mstatus_q.mie & mip_q[pito_pkg::IRQ_MVU_INTR] & mie_q[pito_pkg::IRQ_MVU_INTR];
    assign is_irq             = timer_irq_valid | ipi_irq_valid | mvu_irq_valid;
    assign csr_irq_evt.hart_id= PITO_HART_ID;
    assign csr_irq_evt.valid  = |mip_q;

//====================================================================
//                   CSR Read logic
//====================================================================
    always_comb begin : csr_read_process
        // a read access exception can only occur if we attempt to read a CSR which does not exist
        read_access_exception = 1'b0;
        csr_rdata = 32'b0;

        if (csr_read) begin
            unique case (csr_addr)
                // machine mode registers
                pito_pkg::CSR_MVENDORID:         csr_rdata = mvendorid; 
                pito_pkg::CSR_MARCHID  :         csr_rdata = marchid;
                pito_pkg::CSR_MIMPID   :         csr_rdata = mimpid; 
                pito_pkg::CSR_MHARTID  :         csr_rdata = mhartdid;

                pito_pkg::CSR_MSTATUS  :         csr_rdata = mstatus_q;
                pito_pkg::CSR_MISA     :         csr_rdata = misa;
                pito_pkg::CSR_MIE      :         csr_rdata = mie_q;
                pito_pkg::CSR_MTVEC    :         csr_rdata = mtvec_q;

                // pito_pkg::CSR_MSCRATCH:           csr_rdata = mscratch_q;
                pito_pkg::CSR_MEPC     :         csr_rdata = mepc_q;
                pito_pkg::CSR_MCAUSE   :         csr_rdata = mcause_q;
                pito_pkg::CSR_MTVAL    :         csr_rdata = mtval_q;
                pito_pkg::CSR_MIP      :         csr_rdata = mip_q;

                pito_pkg::CSR_MCYCLE   :         csr_rdata = mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET :         csr_rdata = minstret_q[31:0];
                pito_pkg::CSR_MCYCLEH  :         csr_rdata = mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH:         csr_rdata = minstret_q[63:32];

                // MVU related csrs
                pito_pkg::CSR_MVUWBASEPTR :      csr_rdata = csr_mvuwbaseptr_q;
                pito_pkg::CSR_MVUIBASEPTR :      csr_rdata = csr_mvuibaseptr_q;
                pito_pkg::CSR_MVUSBASEPTR :      csr_rdata = csr_mvusbaseptr_q;
                pito_pkg::CSR_MVUBBASEPTR :      csr_rdata = csr_mvubbaseptr_q;
                pito_pkg::CSR_MVUOBASEPTR :      csr_rdata = csr_mvuobaseptr_q;
                pito_pkg::CSR_MVUWJUMP_0  :      csr_rdata = csr_mvuwjump_0_q;
                pito_pkg::CSR_MVUWJUMP_1  :      csr_rdata = csr_mvuwjump_1_q;
                pito_pkg::CSR_MVUWJUMP_2  :      csr_rdata = csr_mvuwjump_2_q;
                pito_pkg::CSR_MVUWJUMP_3  :      csr_rdata = csr_mvuwjump_3_q;
                pito_pkg::CSR_MVUWJUMP_4  :      csr_rdata = csr_mvuwjump_4_q;
                pito_pkg::CSR_MVUIJUMP_0  :      csr_rdata = csr_mvuijump_0_q;
                pito_pkg::CSR_MVUIJUMP_1  :      csr_rdata = csr_mvuijump_1_q;
                pito_pkg::CSR_MVUIJUMP_2  :      csr_rdata = csr_mvuijump_2_q;
                pito_pkg::CSR_MVUIJUMP_3  :      csr_rdata = csr_mvuijump_3_q;
                pito_pkg::CSR_MVUIJUMP_4  :      csr_rdata = csr_mvuijump_4_q;
                pito_pkg::CSR_MVUSJUMP_0  :      csr_rdata = csr_mvusjump_0_q;
                pito_pkg::CSR_MVUSJUMP_1  :      csr_rdata = csr_mvusjump_1_q;
                pito_pkg::CSR_MVUBJUMP_0  :      csr_rdata = csr_mvubjump_0_q;
                pito_pkg::CSR_MVUBJUMP_1  :      csr_rdata = csr_mvubjump_1_q;
                pito_pkg::CSR_MVUOJUMP_0  :      csr_rdata = csr_mvuojump_0_q;
                pito_pkg::CSR_MVUOJUMP_1  :      csr_rdata = csr_mvuojump_1_q;
                pito_pkg::CSR_MVUOJUMP_2  :      csr_rdata = csr_mvuojump_2_q;
                pito_pkg::CSR_MVUOJUMP_3  :      csr_rdata = csr_mvuojump_3_q;
                pito_pkg::CSR_MVUOJUMP_4  :      csr_rdata = csr_mvuojump_4_q;
                pito_pkg::CSR_MVUWLENGTH_1:      csr_rdata = csr_mvuwlength_1_q;
                pito_pkg::CSR_MVUWLENGTH_2:      csr_rdata = csr_mvuwlength_2_q;
                pito_pkg::CSR_MVUWLENGTH_3:      csr_rdata = csr_mvuwlength_3_q;
                pito_pkg::CSR_MVUWLENGTH_4:      csr_rdata = csr_mvuwlength_4_q;
                pito_pkg::CSR_MVUILENGTH_1:      csr_rdata = csr_mvuilength_1_q;
                pito_pkg::CSR_MVUILENGTH_2:      csr_rdata = csr_mvuilength_2_q;
                pito_pkg::CSR_MVUILENGTH_3:      csr_rdata = csr_mvuilength_3_q;
                pito_pkg::CSR_MVUILENGTH_4:      csr_rdata = csr_mvuilength_4_q;
                pito_pkg::CSR_MVUSLENGTH_1:      csr_rdata = csr_mvuslength_1_q;
                pito_pkg::CSR_MVUBLENGTH_1:      csr_rdata = csr_mvublength_1_q;
                pito_pkg::CSR_MVUOLENGTH_1:      csr_rdata = csr_mvuolength_1_q;
                pito_pkg::CSR_MVUOLENGTH_2:      csr_rdata = csr_mvuolength_2_q;
                pito_pkg::CSR_MVUOLENGTH_3:      csr_rdata = csr_mvuolength_3_q;
                pito_pkg::CSR_MVUOLENGTH_4:      csr_rdata = csr_mvuolength_4_q;
                pito_pkg::CSR_MVUPRECISION:      csr_rdata = csr_mvuprecision_q;
                pito_pkg::CSR_MVUSTATUS   :      csr_rdata = csr_mvustatus_q;
                pito_pkg::CSR_MVUCOMMAND  :      csr_rdata = csr_mvucommand_q;
                pito_pkg::CSR_MVUQUANT    :      csr_rdata = csr_mvuquant_q;
                pito_pkg::CSR_MVUSCALER   :      csr_rdata = csr_mvuscaler_q;
                pito_pkg::CSR_MVUCONFIG1  :      csr_rdata = csr_mvuconfig1_q;

                default: read_access_exception = 1'b1;
            endcase
        end
    end

//====================================================================
//                   CSR Write and update logic
//====================================================================
    logic [31:0] mask;
    logic is_mip_w;
    assign is_mip_w = csr_we & (csr_addr == pito_pkg::CSR_MIP);
    always_comb begin : csr_update

        // --------------------
        // Counters
        // --------------------
        mcycle_d = mcycle_q;
        minstret_d = minstret_q;
        
        if (enable_cycle_count_i) mcycle_d = mcycle_q + 1'b1;
        //else mcycle_d = instret;

        mstatus_d               = mstatus_q;

        // check whether we come out of reset
        // this is a workaround. some tools have issues
        // having boot_addr_i in the asynchronous
        //reset assignment to mtvec_d, even though
        // boot_addr_i will be assigned a constant
        // on the top-level.
        if (mtvec_rst_load_q) begin
            mtvec_d             = boot_addr_i;
        end else begin
            mtvec_d             = mtvec_q;
        end

        mip_d                   = mip_q;
        mie_d                   = mie_q;
        mepc_d                  = mepc_q;
        mcause_d                = mcause_q;
        mtval_d                 = mtval_q;

        // TODO: priv check
        // check for correct access rights and that we are writing

        if (csr_we) begin
            update_access_exception = 1'b0;
            unique case (csr_addr)
                pito_pkg::CSR_MSTATUS: begin
                    mstatus_d      = csr_wdata;
                    mstatus_d.xs   = 2'b0;
                    mstatus_d.fs   = 2'b0;
                    mstatus_d.upie = 1'b0;
                    mstatus_d.uie  = 1'b0;
                end
                // MISA is WARL (Write Any Value, Reads Legal Value)
                pito_pkg::CSR_MISA:;
                // mask the register so that unsupported interrupts can never be set
                pito_pkg::CSR_MIE: begin
                    mask  = pito_pkg::MIP_MSIP | pito_pkg::MIP_MTIP | pito_pkg::MIP_MEIP | pito_pkg::MIP_MVIP;
                    mie_d = (mie_q & ~mask) | (csr_wdata & mask); // we only support M-mode interrupts
                end

                pito_pkg::CSR_MTVEC: begin
                    // mtvec_d = {csr_wdata[31:2], 1'b0, csr_wdata[0]};
                    mtvec_d = csr_wdata;
                    // we are in vector mode, this implementation requires the additional
                    // alignment constraint of 64 * 4 bytes
                    // if (csr_wdata[0]) mtvec_d = {csr_wdata[31:8], 7'b0, csr_wdata[0]};
                end
                pito_pkg::CSR_MEPC:               mepc_d      = {csr_wdata[31:1], 1'b0};
                // pito_pkg::CSR_MCAUSE:             mcause_d    = csr_wdata;
                pito_pkg::CSR_MTVAL:              mtval_d     = csr_wdata;
                pito_pkg::CSR_MIP: begin
                    mask  = pito_pkg::MIP_MSIP | pito_pkg::MIP_MTIP | pito_pkg::MIP_MEIP | pito_pkg::MIP_MVIP;
                    mip_d = (mip_q & ~mask) | (csr_wdata & mask);
                end
                // performance counters
                // pito_pkg::CSR_MCYCLE:             mcycle_d     = csr_wdata;
                // pito_pkg::CSR_MINSTRET:           instret     = csr_wdata;
                // pito_pkg::CSR_MCALL,
                // pito_pkg::CSR_MRET: begin
                //                         perf_data_o = csr_wdata;
                //                         perf_we_o   = 1'b1;
                // end
                // MVU related csrs

                pito_pkg::CSR_MVUWBASEPTR :      csr_mvuwbaseptr_q  = csr_wdata;
                pito_pkg::CSR_MVUIBASEPTR :      csr_mvuibaseptr_q  = csr_wdata;
                pito_pkg::CSR_MVUSBASEPTR :      csr_mvusbaseptr_q  = csr_wdata;
                pito_pkg::CSR_MVUBBASEPTR :      csr_mvubbaseptr_q  = csr_wdata;
                pito_pkg::CSR_MVUOBASEPTR :      csr_mvuobaseptr_q  = csr_wdata;
                pito_pkg::CSR_MVUWJUMP_0  :      csr_mvuwjump_0_q   = csr_wdata;
                pito_pkg::CSR_MVUWJUMP_1  :      csr_mvuwjump_1_q   = csr_wdata;
                pito_pkg::CSR_MVUWJUMP_2  :      csr_mvuwjump_2_q   = csr_wdata;
                pito_pkg::CSR_MVUWJUMP_3  :      csr_mvuwjump_3_q   = csr_wdata;
                pito_pkg::CSR_MVUWJUMP_4  :      csr_mvuwjump_4_q   = csr_wdata;
                pito_pkg::CSR_MVUIJUMP_0  :      csr_mvuijump_0_q   = csr_wdata;
                pito_pkg::CSR_MVUIJUMP_1  :      csr_mvuijump_1_q   = csr_wdata;
                pito_pkg::CSR_MVUIJUMP_2  :      csr_mvuijump_2_q   = csr_wdata;
                pito_pkg::CSR_MVUIJUMP_3  :      csr_mvuijump_3_q   = csr_wdata;
                pito_pkg::CSR_MVUIJUMP_4  :      csr_mvuijump_4_q   = csr_wdata;
                pito_pkg::CSR_MVUSJUMP_0  :      csr_mvusjump_0_q   = csr_wdata;
                pito_pkg::CSR_MVUSJUMP_1  :      csr_mvusjump_1_q   = csr_wdata;
                pito_pkg::CSR_MVUBJUMP_0  :      csr_mvubjump_0_q   = csr_wdata;
                pito_pkg::CSR_MVUBJUMP_1  :      csr_mvubjump_1_q   = csr_wdata;
                pito_pkg::CSR_MVUOJUMP_0  :      csr_mvuojump_0_q   = csr_wdata;
                pito_pkg::CSR_MVUOJUMP_1  :      csr_mvuojump_1_q   = csr_wdata;
                pito_pkg::CSR_MVUOJUMP_2  :      csr_mvuojump_2_q   = csr_wdata;
                pito_pkg::CSR_MVUOJUMP_3  :      csr_mvuojump_3_q   = csr_wdata;
                pito_pkg::CSR_MVUOJUMP_4  :      csr_mvuojump_4_q   = csr_wdata;
                pito_pkg::CSR_MVUWLENGTH_1:      csr_mvuwlength_1_q = csr_wdata;
                pito_pkg::CSR_MVUWLENGTH_2:      csr_mvuwlength_2_q = csr_wdata;
                pito_pkg::CSR_MVUWLENGTH_3:      csr_mvuwlength_3_q = csr_wdata;
                pito_pkg::CSR_MVUWLENGTH_4:      csr_mvuwlength_4_q = csr_wdata;
                pito_pkg::CSR_MVUILENGTH_1:      csr_mvuilength_1_q = csr_wdata;
                pito_pkg::CSR_MVUILENGTH_2:      csr_mvuilength_2_q = csr_wdata;
                pito_pkg::CSR_MVUILENGTH_3:      csr_mvuilength_3_q = csr_wdata;
                pito_pkg::CSR_MVUILENGTH_4:      csr_mvuilength_4_q = csr_wdata;
                pito_pkg::CSR_MVUSLENGTH_1:      csr_mvuslength_1_q = csr_wdata;
                pito_pkg::CSR_MVUBLENGTH_1:      csr_mvublength_1_q = csr_wdata;
                pito_pkg::CSR_MVUOLENGTH_1:      csr_mvuolength_1_q = csr_wdata;
                pito_pkg::CSR_MVUOLENGTH_2:      csr_mvuolength_2_q = csr_wdata;
                pito_pkg::CSR_MVUOLENGTH_3:      csr_mvuolength_3_q = csr_wdata;
                pito_pkg::CSR_MVUOLENGTH_4:      csr_mvuolength_4_q = csr_wdata;
                pito_pkg::CSR_MVUPRECISION:      csr_mvuprecision_q = csr_wdata;
                pito_pkg::CSR_MVUCOMMAND  :      csr_mvucommand_q   = csr_wdata;
                pito_pkg::CSR_MVUQUANT    :      csr_mvuquant_q     = csr_wdata;
                pito_pkg::CSR_MVUSCALER   :      csr_mvuscaler_q    = csr_wdata;
                pito_pkg::CSR_MVUCONFIG1  :      csr_mvuconfig1_q   = csr_wdata;

                default: update_access_exception = 1'b1;
            endcase
        end

        // hardwired extension registers
        mstatus_d.sd   = 1'b0;

        // ---------------------
        // External Interrupts
        // ---------------------
        // Machine Mode External Interrupt Pending
        mip_d[pito_pkg::IRQ_M_EXT] = irq_i;
        // Machine software interrupt
        mip_d[pito_pkg::IRQ_M_SOFT] = ipi_i;
        // Timer interrupt pending, coming from platform timer
        mip_d[pito_pkg::IRQ_M_TIMER] = time_irq_i;
        // MVU interrupt pending, coming from MVU
        mip_d[pito_pkg::IRQ_MVU_INTR] = (is_mip_w) ? csr_wdata[pito_pkg::IRQ_MVU_INTR] : mvu_irq_i | mip_q[pito_pkg::IRQ_MVU_INTR];

        // update exception CSRs
        // update mstatus
        if (is_irq) begin
            // disable intterupts
            mstatus_d.mie  = 1'b0;
            // set irq cause
            mcause_d       = {1'b1, {26{1'b0}}, cause_i[4:0]};
            // set mepc
            mepc_d         = pc_i;
            // set mtval or stval
            csr_irq_evt.data = mtvec_d;
            // set mpie to mie 
            mstatus_d.mpie = mstatus_q.mie;
        end

        // ------------------------------
        // Return from Environment
        // ------------------------------
        // When executing an xRET instruction, supposing xPP holds the value y, xIE is set to xPIE; the privilege
        // mode is changed to y; xPIE is set to 1; and xPP is set to U
        if (mret) begin
            // return to the previous privilege level and restore all enable flags
            // get the previous machine interrupt enable flag
            mstatus_d.mie  = mstatus_q.mpie;
            // set mpie to 1
            mstatus_d.mpie = 1'b1;
            // return to where we got the interrupt
            csr_irq_evt.data   = mepc_q;
        end
    end

//====================================================================
//                   CSR OP Select Logic
//====================================================================
    always_comb begin : csr_op_logic
        csr_wdata = csr_wdata_i;
        csr_we    = 1'b1;
        csr_read  = 1'b1;
        mret      = 1'b0;

        unique case (csr_op)
            MRET: begin
                // the return should not have any write or read side-effects
                csr_we   = 1'b0;
                csr_read = 1'b0;
                mret     = 1'b1; // signal a return from machine mode
            end
            CSR_READ_WRITE : csr_wdata   = csr_wdata_i;
            CSR_SET        : begin
                csr_wdata   = csr_wdata_i | csr_rdata;
                csr_rdata_o = csr_rdata;
            end
            CSR_CLEAR      : csr_wdata = (~csr_wdata_i) & csr_rdata;
            default: begin
                csr_we   = 1'b0;
                csr_read = 1'b0;
            end
        endcase
    end


//====================================================================
//                  CSR Exception Control
//====================================================================
    always_comb begin : exception_ctrl
        // ----------------------------------
        // Illegal Access (decode exception)
        // ----------------------------------
        // we got an exception in one of the processes above
        // throw an illegal instruction exception
        if (update_access_exception || read_access_exception) begin
            csr_exception_o.cause = pito_pkg::ILLEGAL_INSTR;
            // we don't set the tval field as this will be set by the commit stage
            // this spares the extra wiring from commit to CSR and back to commit
            csr_exception_o.valid = 1'b1;
        end
    end


//====================================================================
//                  Sequential Process
//====================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // machine mode registers
            mstatus_q              <= 32'b0;
            mtvec_q                <= 32'b0;
            mip_q                  <= 32'b0;
            mie_q                  <= 32'b0;
            mepc_q                 <= 32'b0;
            mcause_q               <= 32'b0;
            mtval_q                <= 32'b0;
            // timer and counters
            mcycle_q               <= 64'b0;
            minstret_q             <= 64'b0;
            // wait for interrupt
            wfi_q                  <= 1'b0;
            mtvec_rst_load_q       <= 1'b1;
            mvu_start              <= 1'b0;
            // csr pc valid signal
        end else begin
            // machine mode registers
            mtvec_rst_load_q       <= 1'b0;
            mstatus_q              <= mstatus_d;
            mtvec_q                <= mtvec_d;
            mip_q                  <= mip_d;
            mie_q                  <= mie_d;
            mepc_q                 <= mepc_d;
            mcause_q               <= mcause_d;
            mtval_q                <= mtval_d;
            // timer and counters
            mcycle_q               <= mcycle_d;
            minstret_q             <= minstret_d;
            // wait for interrupt
            wfi_q                  <= wfi_d;
            // MVU related csrs
            csr_mvuwbaseptr_q      <= csr_mvuwbaseptr_d ;
            csr_mvuibaseptr_q      <= csr_mvuibaseptr_d ;
            csr_mvusbaseptr_q      <= csr_mvusbaseptr_d ;
            csr_mvubbaseptr_q      <= csr_mvubbaseptr_d ;
            csr_mvuobaseptr_q      <= csr_mvuobaseptr_d ;
            csr_mvuwjump_0_q       <= csr_mvuwjump_0_d ;
            csr_mvuwjump_1_q       <= csr_mvuwjump_1_d ;
            csr_mvuwjump_2_q       <= csr_mvuwjump_2_d ;
            csr_mvuwjump_3_q       <= csr_mvuwjump_3_d ;
            csr_mvuwjump_4_q       <= csr_mvuwjump_4_d ;
            csr_mvuijump_0_q       <= csr_mvuijump_0_d ;
            csr_mvuijump_1_q       <= csr_mvuijump_1_d ;
            csr_mvuijump_2_q       <= csr_mvuijump_2_d ;
            csr_mvuijump_3_q       <= csr_mvuijump_3_d ;
            csr_mvuijump_4_q       <= csr_mvuijump_4_d ;
            csr_mvusjump_0_q       <= csr_mvusjump_0_d ;
            csr_mvusjump_1_q       <= csr_mvusjump_1_d ;
            csr_mvubjump_0_q       <= csr_mvubjump_0_d ;
            csr_mvubjump_1_q       <= csr_mvubjump_1_d ;
            csr_mvuojump_0_q       <= csr_mvuojump_0_d ;
            csr_mvuojump_1_q       <= csr_mvuojump_1_d ;
            csr_mvuojump_2_q       <= csr_mvuojump_2_d ;
            csr_mvuojump_3_q       <= csr_mvuojump_3_d ;
            csr_mvuojump_4_q       <= csr_mvuojump_4_d ;
            csr_mvuwlength_1_q     <= csr_mvuwlength_1_d ;
            csr_mvuwlength_2_q     <= csr_mvuwlength_2_d ;
            csr_mvuwlength_3_q     <= csr_mvuwlength_3_d ;
            csr_mvuwlength_4_q     <= csr_mvuwlength_4_d ;
            csr_mvuilength_1_q     <= csr_mvuilength_1_d ;
            csr_mvuilength_2_q     <= csr_mvuilength_2_d ;
            csr_mvuilength_3_q     <= csr_mvuilength_3_d ;
            csr_mvuilength_4_q     <= csr_mvuilength_4_d ;
            csr_mvuslength_1_q     <= csr_mvuslength_1_d ;
            csr_mvublength_1_q     <= csr_mvublength_1_d ;
            csr_mvuolength_1_q     <= csr_mvuolength_1_d ;
            csr_mvuolength_2_q     <= csr_mvuolength_2_d ;
            csr_mvuolength_3_q     <= csr_mvuolength_3_d ;
            csr_mvuolength_4_q     <= csr_mvuolength_4_d ;
            csr_mvuprecision_q     <= csr_mvuprecision_d ;
            csr_mvucommand_q       <= csr_mvucommand_d ;
            csr_mvuquant_q         <= csr_mvuquant_d ;
            csr_mvuscaler_q        <= csr_mvuscaler_d ;
            csr_mvuconfig1_q       <= csr_mvuconfig1_d ;

            if (csr_addr == pito_pkg::CSR_MVUCOMMAND) begin
                mvu_start <= 1'b1;
            end else begin
                mvu_start <= 1'b0;
            end

        end
    end


initial begin
    $display("csr.hart[%1d] is activated!", PITO_HART_ID);
end
endmodule
