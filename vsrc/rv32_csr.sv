import pito_pkg::*;
import rv32_pkg::*;



module rv32_csr #(
    parameter PITO_HART_ID = 0
    )(
    input  logic                      clk,        // Clock
    input  logic                      rst_n,      // Asynchronous reset active low
    input  logic [11 : 0]             csr_addr_i, // csr register address
    input  logic [31 : 0]             csr_wdata_i,// data to be written to csr
    output logic [31 : 0]             csr_rdata_o,// data read from csr
    // interrupts
    input  logic                      irq_i,      // external interrupt in (async)
    input  logic                      time_irq_i, // Timer threw a interrupt (async)
    input  logic                      ipi_i,      // inter processor interrupt (async)

    // MVU interface
    input  logic                      mvu_irq_i,  // mvu requestin an interrupt

    input  logic [31 : 0]             pc_i,       // PC of instruction accessing the CSR
    input  logic [31 : 0]             cause_i,    // exception code
    input  logic [2  : 0]             csr_op_i,   // csr operation type
    input  logic                      enable_cycle_count_i, // enable cycle count
    output logic [31 : 0]             csr_epc_o   // epc 
);

    // internal signal to keep track of access exceptions
    logic [31:0]            csr_wdata, csr_rdata;
    logic                   read_access_exception;
    logic                   csr_we, csr_read;
    logic                   wfi_q, wfi_d;
    pito_pkg::csr_t         csr_addr;
    pito_pkg::csr_op_t      csr_op;
    // RV32 Machine Mode CSRs
    rv32_pkg::status_rv32_t mstatus_q, mstatus_d;
    rv32_pkg::mip_rv32_t    mip_q, mip_d;
    rv32_pkg::mie_rv32_t    mie_q, mie_d;
    logic [31:0]            mcause_q, mcause_d;
    logic [31:0]            mtvec_q, mtvec_d;
    logic [31:0]            mepc_q, mepc_d;
    logic [31:0]            mtval_q, mtval_d;
    logic [63:0]            csr_mcycle_q, csr_mcycle_d;
    logic [63:0]            csr_instret_q, csr_instret_d;
    // return from M-mode exception
    logic  mret;  

    // // MVU CSRs;
    // rv32_csr_t csr_mvu_wbaseptr   ;
    // rv32_csr_t csr_mvu_ibaseptr   ;
    // rv32_csr_t csr_mvu_obaseptr   ;
    // rv32_csr_t csr_mvu_wstride_0  ;
    // rv32_csr_t csr_mvu_wstride_1  ;
    // rv32_csr_t csr_mvu_wstride_2  ;
    // rv32_csr_t csr_mvu_istride_0  ;
    // rv32_csr_t csr_mvu_istride_1  ;
    // rv32_csr_t csr_mvu_istride_2  ;
    // rv32_csr_t csr_mvu_ostride_0  ;
    // rv32_csr_t csr_mvu_ostride_1  ;
    // rv32_csr_t csr_mvu_ostride_2  ;
    // rv32_csr_t csr_mvu_wlength_0  ;
    // rv32_csr_t csr_mvu_wlength_1  ;
    // rv32_csr_t csr_mvu_wlength_2  ;
    // rv32_csr_t csr_mvu_ilength_0  ;
    // rv32_csr_t csr_mvu_ilength_1  ;
    // rv32_csr_t csr_mvu_ilength_2  ;
    // rv32_csr_t csr_mvu_olength_0  ;
    // rv32_csr_t csr_mvu_olength_1  ;
    // rv32_csr_t csr_mvu_olength_2  ;
    // rv32_csr_t csr_mvu_precision  ;
    // rv32_csr_t csr_mvu_status     ;
    // rv32_csr_t csr_mvu_command    ;
    // rv32_csr_t csr_mvu_quant      ;


//====================================================================
//                    Assignments
//====================================================================

    assign csr_addr = pito_pkg::csr_t'(csr_addr_i);
    assign csr_op   = pito_pkg::csr_op_t'(csr_op_i);
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
                pito_pkg::CSR_MVENDORID:          csr_rdata = 32'b0; // not implemented
                pito_pkg::CSR_MARCHID:            csr_rdata = PITO_MARCHID;
                pito_pkg::CSR_MIMPID:             csr_rdata = 32'b0; // not implemented
                pito_pkg::CSR_MHARTID:            csr_rdata = PITO_HART_ID;

                pito_pkg::CSR_MSTATUS:            csr_rdata = mstatus_q;
                pito_pkg::CSR_MISA:               csr_rdata = ISA_CODE;
                pito_pkg::CSR_MIE:                csr_rdata = mie_q;
                pito_pkg::CSR_MTVEC:              csr_rdata = mtvec_q;

                // pito_pkg::CSR_MSCRATCH:           csr_rdata = mscratch_q;
                pito_pkg::CSR_MEPC:               csr_rdata = mepc_q;
                pito_pkg::CSR_MCAUSE:             csr_rdata = mcause_q;
                pito_pkg::CSR_MTVAL:              csr_rdata = mtval_q;
                pito_pkg::CSR_MIP:                csr_rdata = mip_q;

                pito_pkg::CSR_MCYCLE:             csr_rdata = csr_mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET:           csr_rdata = csr_instret_q[31:0];
                pito_pkg::CSR_MCYCLEH:            csr_rdata = csr_mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH:          csr_rdata = csr_instret_q[63:32];

                default: read_access_exception = 1'b1;
            endcase
        end
    end

//====================================================================
//                   CSR Write and update logic
//====================================================================
    logic [63:0] mask;
    always_comb begin : csr_update

        // --------------------
        // Counters
        // --------------------
        cycle_d = cycle_q;
        instret_d = instret_q;
        
        if (enable_cycle_count_i) cycle_d = cycle_q + 1'b1;
        else cycle_d = instret;

        mstatus_d               = mstatus_q;

        // check whether we come out of reset
        // this is a workaround. some tools have issues
        // having boot_addr_i in the asynchronous
        // reset assignment to mtvec_d, even though
        // boot_addr_i will be assigned a constant
        // on the top-level.
        if (mtvec_rst_load_q) begin
            mtvec_d             = boot_addr_i + 'h40;
        end else begin
            mtvec_d             = mtvec_q;
        end

        mip_d                   = mip_q;
        mie_d                   = mie_q;
        mepc_d                  = mepc_q;
        mcause_d                = mcause_q;
        mtval_d                 = mtval_q;

        // check for correct access rights and that we are writing
        if (csr_we) begin
            unique case (csr_addr.address)
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
                    mtvec_d = {csr_wdata[31:2], 1'b0, csr_wdata[0]};
                    // we are in vector mode, this implementation requires the additional
                    // alignment constraint of 64 * 4 bytes
                    if (csr_wdata[0]) mtvec_d = {csr_wdata[31:8], 7'b0, csr_wdata[0]};
                end
                pito_pkg::CSR_MEPC:               mepc_d      = {csr_wdata[31:1], 1'b0};
                pito_pkg::CSR_MCAUSE:             mcause_d    = csr_wdata;
                pito_pkg::CSR_MTVAL:              mtval_d     = csr_wdata;
                pito_pkg::CSR_MIP: begin
                    mask = pito_pkg::MIP_SSIP | pito_pkg::MIP_STIP | pito_pkg::MIP_SEIP;
                    mip_d = (mip_q & ~mask) | (csr_wdata & mask);
                end
                // performance counters
                pito_pkg::CSR_MCYCLE:             cycle_d     = csr_wdata;
                pito_pkg::CSR_MINSTRET:           instret     = csr_wdata;
                pito_pkg::CSR_MCALL,
                pito_pkg::CSR_MRET: begin
                                        perf_data_o = csr_wdata;
                                        perf_we_o   = 1'b1;
                end
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
        mip_d[pito_pkg::IRQ_MVU_INTR] = mvu_irq_i;

        // -----------------------
        // Manage Exception Stack
        // -----------------------
        // update exception CSRs
        // we got an exception update cause, pc and stval register
        // update mstatus
        mstatus_d.mie  = 1'b0;
        mstatus_d.mpie = mstatus_q.mie;
        // save the previous privilege mode
        mstatus_d.mpp  = priv_lvl_q;
        mcause_d       = cause_i;
        // set epc
        mepc_d         = pc_i;
        // set mtval or stval
        mtval_d        =  32'b0;

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
            CSR_MRET: begin
                // the return should not have any write or read side-effects
                csr_we   = 1'b0;
                csr_read = 1'b0;
                mret     = 1'b1; // signal a return from machine mode
            end
            CSR_WRITE: csr_wdata = csr_wdata_i;
            CSR_READ:  csr_we    = 1'b0;
            CSR_SET:   csr_wdata = csr_wdata_i | csr_rdata;
            CSR_CLEAR: csr_wdata = (~csr_wdata_i) & csr_rdata;
            default: begin
                csr_we   = 1'b0;
                csr_read = 1'b0;
            end
        endcase
    end

//====================================================================
//                  Sequential Process
//====================================================================
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // machine mode registers
            mstatus_q              <= (`XPR_LEN){1'b0};
            // set to boot address + direct mode + 4 byte offset which is the initial trap
            mtvec_q                <= (`XPR_LEN){1'b0};
            mip_q                  <= (`XPR_LEN){1'b0};
            mie_q                  <= (`XPR_LEN){1'b0};
            mepc_q                 <= (`XPR_LEN){1'b0};
            mcause_q               <= (`XPR_LEN){1'b0};
            mtval_q                <= (`XPR_LEN){1'b0};
            // timer and counters
            cycle_q                <= 64'b0;
            instret_q              <= 64'b0;
            // wait for interrupt
            wfi_q                  <= 1'b0;
        end else begin
            // machine mode registers
            mstatus_q              <= mstatus_d;
            mtvec_q                <= mtvec_d;
            mip_q                  <= mip_d;
            mie_q                  <= mie_d;
            mepc_q                 <= mepc_d;
            mcause_q               <= mcause_d;
            mtval_q                <= mtval_d;
            // timer and counters
            cycle_q                <= cycle_d;
            instret_q              <= instret_d;
            // wait for interrupt
            wfi_q                  <= wfi_d;
        end
    end

endmodule