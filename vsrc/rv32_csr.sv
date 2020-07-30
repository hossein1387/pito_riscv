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
    output logic [1:0]                csr_mvu_mul_mode  ,
    output logic [28:0]               csr_mvu_countdown ,
    output logic [5:0]                csr_mvu_wprecision,
    output logic [5:0]                csr_mvu_iprecision,
    output logic [5:0]                csr_mvu_oprecision,
    output logic [8:0]                csr_mvu_wbaseaddr ,
    output logic [14:0]               csr_mvu_ibaseaddr ,
    output logic [14:0]               csr_mvu_obaseaddr ,
    output logic [14:0]               csr_mvu_wstride_0 ,
    output logic [14:0]               csr_mvu_wstride_1 ,
    output logic [14:0]               csr_mvu_wstride_2 ,
    output logic [14:0]               csr_mvu_istride_0 ,
    output logic [14:0]               csr_mvu_istride_1 ,
    output logic [14:0]               csr_mvu_istride_2 ,
    output logic [14:0]               csr_mvu_ostride_0 ,
    output logic [14:0]               csr_mvu_ostride_1 ,
    output logic [14:0]               csr_mvu_ostride_2 ,
    output logic [14:0]               csr_mvu_wlength_0 ,
    output logic [14:0]               csr_mvu_wlength_1 ,
    output logic [14:0]               csr_mvu_wlength_2 ,
    output logic [14:0]               csr_mvu_ilength_0 ,
    output logic [14:0]               csr_mvu_ilength_1 ,
    output logic [14:0]               csr_mvu_ilength_2 ,
    output logic [14:0]               csr_mvu_olength_0 ,
    output logic [14:0]               csr_mvu_olength_1 ,
    output logic [14:0]               csr_mvu_olength_2 ,
    output logic                      mvu_start,

    output exception_t                csr_exception_o,// Attempts to access a CSR without appropriate privilege
                                                      // level or to write  a read-only register also
                                                      // raises illegal instruction exceptions.
    input  logic [31 : 0]             pc_i,       // PC of instruction accessing the CSR
    input  logic [31 : 0]             cause_i,    // Exception code
    input  logic                      enable_cycle_count_i, // Enable cycle count
    output logic [31 : 0]             csr_epc_o   // epc 
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
    // logic [63:0]            mcycle_q, mcycle_d;
    logic [63:0]            minstret_q, minstret_d;
    // return from M-mode exception
    logic  mret;  

    // logic        mtvec_rst_load_q;// used to determine whether we came out of reset

    // MVU CSRs;
    logic [31:0] csr_mvu_mul_mode_q  , csr_mvu_mul_mode_d  ; // Config: multiply mode
    logic [31:0] csr_mvu_countdown_q , csr_mvu_countdown_d ; // Config: number of clocks to countdown for given task
    logic [31:0] csr_mvu_wprecision_q, csr_mvu_wprecision_d; // Config: weight precision
    logic [31:0] csr_mvu_iprecision_q, csr_mvu_iprecision_d; // Config: input precision
    logic [31:0] csr_mvu_oprecision_q, csr_mvu_oprecision_d; // Config: output precision
    logic [31:0] csr_mvu_wbaseaddr_q , csr_mvu_wbaseaddr_d ; // Config: weight memory base address
    logic [31:0] csr_mvu_ibaseaddr_q , csr_mvu_ibaseaddr_d ; // Config: data memory base address for input
    logic [31:0] csr_mvu_obaseaddr_q , csr_mvu_obaseaddr_d ; // Config: data memory base address for output
    logic [31:0] csr_mvu_wstride_0_q , csr_mvu_wstride_0_d ; // Config: weight stride in dimension 0 (x)
    logic [31:0] csr_mvu_wstride_1_q , csr_mvu_wstride_1_d ; // Config: weight stride in dimension 1 (y)
    logic [31:0] csr_mvu_wstride_2_q , csr_mvu_wstride_2_d ; // Config: weight stride in dimension 2 (z)
    logic [31:0] csr_mvu_istride_0_q , csr_mvu_istride_0_d ; // Config: input stride in dimension 0 (x)
    logic [31:0] csr_mvu_istride_1_q , csr_mvu_istride_1_d ; // Config: input stride in dimension 1 (y)
    logic [31:0] csr_mvu_istride_2_q , csr_mvu_istride_2_d ; // Config: input stride in dimension 2 (z)
    logic [31:0] csr_mvu_ostride_0_q , csr_mvu_ostride_0_d ; // Config: output stride in dimension 0 (x)
    logic [31:0] csr_mvu_ostride_1_q , csr_mvu_ostride_1_d ; // Config: output stride in dimension 1 (y)
    logic [31:0] csr_mvu_ostride_2_q , csr_mvu_ostride_2_d ; // Config: output stride in dimension 2 (z)
    logic [31:0] csr_mvu_wlength_0_q , csr_mvu_wlength_0_d ; // Config: weight length in dimension 0 (x)
    logic [31:0] csr_mvu_wlength_1_q , csr_mvu_wlength_1_d ; // Config: weight length in dimension 1 (y)
    logic [31:0] csr_mvu_wlength_2_q , csr_mvu_wlength_2_d ; // Config: weight length in dimension 2 (z)
    logic [31:0] csr_mvu_ilength_0_q , csr_mvu_ilength_0_d ; // Config: input length in dimension 0 (x)
    logic [31:0] csr_mvu_ilength_1_q , csr_mvu_ilength_1_d ; // Config: input length in dimension 1 (y)
    logic [31:0] csr_mvu_ilength_2_q , csr_mvu_ilength_2_d ; // Config: input length in dimension 2 (z)
    logic [31:0] csr_mvu_olength_0_q , csr_mvu_olength_0_d ; // Config: output length in dimension 0 (x)
    logic [31:0] csr_mvu_olength_1_q , csr_mvu_olength_1_d ; // Config: output length in dimension 1 (y)
    logic [31:0] csr_mvu_olength_2_q , csr_mvu_olength_2_d ; // Config: output length in dimension 2 (z)
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

    assign csr_mvu_mul_mode   = csr_mvu_mul_mode_q[1:0];
    assign csr_mvu_countdown  = csr_mvu_countdown_q[28:0];
    assign csr_mvu_wprecision = csr_mvu_wprecision_q[5:0];
    assign csr_mvu_iprecision = csr_mvu_iprecision_q[5:0];
    assign csr_mvu_oprecision = csr_mvu_oprecision_q[5:0];
    assign csr_mvu_wbaseaddr  = csr_mvu_wbaseaddr_q[8:0];
    assign csr_mvu_ibaseaddr  = csr_mvu_ibaseaddr_q[14:0];
    assign csr_mvu_obaseaddr  = csr_mvu_obaseaddr_q[14:0];
    assign csr_mvu_wstride_0  = csr_mvu_wstride_0_q[14:0];
    assign csr_mvu_wstride_1  = csr_mvu_wstride_1_q[14:0];
    assign csr_mvu_wstride_2  = csr_mvu_wstride_2_q[14:0];
    assign csr_mvu_istride_0  = csr_mvu_istride_0_q[14:0];
    assign csr_mvu_istride_1  = csr_mvu_istride_1_q[14:0];
    assign csr_mvu_istride_2  = csr_mvu_istride_2_q[14:0];
    assign csr_mvu_ostride_0  = csr_mvu_ostride_0_q[14:0];
    assign csr_mvu_ostride_1  = csr_mvu_ostride_1_q[14:0];
    assign csr_mvu_ostride_2  = csr_mvu_ostride_2_q[14:0];
    assign csr_mvu_wlength_0  = csr_mvu_wlength_0_q[14:0];
    assign csr_mvu_wlength_1  = csr_mvu_wlength_1_q[14:0];
    assign csr_mvu_wlength_2  = csr_mvu_wlength_2_q[14:0];
    assign csr_mvu_ilength_0  = csr_mvu_ilength_0_q[14:0];
    assign csr_mvu_ilength_1  = csr_mvu_ilength_1_q[14:0];
    assign csr_mvu_ilength_2  = csr_mvu_ilength_2_q[14:0];
    assign csr_mvu_olength_0  = csr_mvu_olength_0_q[14:0];
    assign csr_mvu_olength_1  = csr_mvu_olength_1_q[14:0];
    assign csr_mvu_olength_2  = csr_mvu_olength_2_q[14:0];
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
                pito_pkg::CSR_MVENDORID:          csr_rdata = mvendorid; 
                pito_pkg::CSR_MARCHID  :          csr_rdata = marchid;
                pito_pkg::CSR_MIMPID   :          csr_rdata = mimpid; 
                pito_pkg::CSR_MHARTID  :          csr_rdata = mhartdid;

                pito_pkg::CSR_MSTATUS  :          csr_rdata = mstatus_q;
                pito_pkg::CSR_MISA     :          csr_rdata = misa;
                pito_pkg::CSR_MIE      :          csr_rdata = mie_q;
                // pito_pkg::CSR_MTVEC    :          csr_rdata = mtvec_q;

                // pito_pkg::CSR_MSCRATCH:           csr_rdata = mscratch_q;
                pito_pkg::CSR_MEPC     :          csr_rdata = mepc_q;
                pito_pkg::CSR_MCAUSE   :          csr_rdata = mcause_q;
                pito_pkg::CSR_MTVAL    :          csr_rdata = mtval_q;
                pito_pkg::CSR_MIP      :          csr_rdata = mip_q;

                // pito_pkg::CSR_MCYCLE   :         csr_rdata = mcycle_q[31:0];
                pito_pkg::CSR_MINSTRET :         csr_rdata = minstret_q[31:0];
                // pito_pkg::CSR_MCYCLEH  :         csr_rdata = mcycle_q[63:32];
                pito_pkg::CSR_MINSTRETH:         csr_rdata = minstret_q[63:32];

                // MVU related csrs
                pito_pkg::CSR_MVU_MUL_MODE   :   csr_rdata = csr_mvu_mul_mode_q;
                pito_pkg::CSR_MVU_COUNTDOWN  :   csr_rdata = csr_mvu_countdown_q;
                pito_pkg::CSR_MVU_WPRECISION :   csr_rdata = csr_mvu_wprecision_q;
                pito_pkg::CSR_MVU_IPRECISION :   csr_rdata = csr_mvu_iprecision_q;
                pito_pkg::CSR_MVU_OPRECISION :   csr_rdata = csr_mvu_oprecision_q;
                pito_pkg::CSR_MVU_WBASEADDR  :   csr_rdata = csr_mvu_wbaseaddr_q;
                pito_pkg::CSR_MVU_IBASEADDR  :   csr_rdata = csr_mvu_ibaseaddr_q;
                pito_pkg::CSR_MVU_OBASEADDR  :   csr_rdata = csr_mvu_obaseaddr_q;
                pito_pkg::CSR_MVU_WSTRIDE_0  :   csr_rdata = csr_mvu_wstride_0_q;
                pito_pkg::CSR_MVU_WSTRIDE_1  :   csr_rdata = csr_mvu_wstride_1_q;
                pito_pkg::CSR_MVU_WSTRIDE_2  :   csr_rdata = csr_mvu_wstride_2_q;
                pito_pkg::CSR_MVU_ISTRIDE_0  :   csr_rdata = csr_mvu_istride_0_q;
                pito_pkg::CSR_MVU_ISTRIDE_1  :   csr_rdata = csr_mvu_istride_1_q;
                pito_pkg::CSR_MVU_ISTRIDE_2  :   csr_rdata = csr_mvu_istride_2_q;
                pito_pkg::CSR_MVU_OSTRIDE_0  :   csr_rdata = csr_mvu_ostride_0_q;
                pito_pkg::CSR_MVU_OSTRIDE_1  :   csr_rdata = csr_mvu_ostride_1_q;
                pito_pkg::CSR_MVU_OSTRIDE_2  :   csr_rdata = csr_mvu_ostride_2_q;
                pito_pkg::CSR_MVU_WLENGTH_0  :   csr_rdata = csr_mvu_wlength_0_q;
                pito_pkg::CSR_MVU_WLENGTH_1  :   csr_rdata = csr_mvu_wlength_1_q;
                pito_pkg::CSR_MVU_WLENGTH_2  :   csr_rdata = csr_mvu_wlength_2_q;
                pito_pkg::CSR_MVU_ILENGTH_0  :   csr_rdata = csr_mvu_ilength_0_q;
                pito_pkg::CSR_MVU_ILENGTH_1  :   csr_rdata = csr_mvu_ilength_1_q;
                pito_pkg::CSR_MVU_ILENGTH_2  :   csr_rdata = csr_mvu_ilength_2_q;
                pito_pkg::CSR_MVU_OLENGTH_0  :   csr_rdata = csr_mvu_olength_0_q;
                pito_pkg::CSR_MVU_OLENGTH_1  :   csr_rdata = csr_mvu_olength_1_q;
                pito_pkg::CSR_MVU_OLENGTH_2  :   csr_rdata = csr_mvu_olength_2_q;
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
        // mcycle_d = mcycle_q;
        minstret_d = minstret_q;
        
        // if (enable_cycle_count_i) mcycle_d = mcycle_q + 1'b1;
        //else mcycle_d = instret;

        mstatus_d               = mstatus_q;

        // check whether we come out of reset
        // this is a workaround. some tools have issues
        // having boot_addr_i in the asynchronous
        //reset assignment to mtvec_d, even though
        // boot_addr_i will be assigned a constant
        // on the top-level.
        // if (mtvec_rst_load_q) begin
            // mtvec_d             = boot_addr_i + 'h40;
        // end else begin
        //     mtvec_d             = mtvec_q;
        // end

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
                    // we are in vector mode, this implementation requires the additional
                    // alignment constraint of 64 * 4 bytes
                    // if (csr_wdata[0]) mtvec_d = {csr_wdata[31:8], 7'b0, csr_wdata[0]};
                end
                pito_pkg::CSR_MEPC:               mepc_d      = {csr_wdata[31:1], 1'b0};
                pito_pkg::CSR_MCAUSE:             mcause_d    = csr_wdata;
                pito_pkg::CSR_MTVAL:              mtval_d     = csr_wdata;
                // pito_pkg::CSR_MIP: begin
                //     mask = pito_pkg::MIP_SSIP | pito_pkg::MIP_STIP | pito_pkg::MIP_SEIP;
                //     mip_d = (mip_q & ~mask) | (csr_wdata & mask);
                // end
                // performance counters
                // pito_pkg::CSR_MCYCLE:             mcycle_d     = csr_wdata;
                // pito_pkg::CSR_MINSTRET:           instret     = csr_wdata;
                // pito_pkg::CSR_MCALL,
                // pito_pkg::CSR_MRET: begin
                //                         perf_data_o = csr_wdata;
                //                         perf_we_o   = 1'b1;
                // end
                // MVU related csrs
                pito_pkg::CSR_MVU_MUL_MODE   :   csr_mvu_mul_mode_d   = csr_wdata;
                pito_pkg::CSR_MVU_COUNTDOWN  :   csr_mvu_countdown_d  = csr_wdata;
                pito_pkg::CSR_MVU_WPRECISION :   csr_mvu_wprecision_d = csr_wdata;
                pito_pkg::CSR_MVU_IPRECISION :   csr_mvu_iprecision_d = csr_wdata;
                pito_pkg::CSR_MVU_OPRECISION :   csr_mvu_oprecision_d = csr_wdata;
                pito_pkg::CSR_MVU_WBASEADDR  :   csr_mvu_wbaseaddr_d  = csr_wdata;
                pito_pkg::CSR_MVU_IBASEADDR  :   csr_mvu_ibaseaddr_d  = csr_wdata;
                pito_pkg::CSR_MVU_OBASEADDR  :   csr_mvu_obaseaddr_d  = csr_wdata;
                pito_pkg::CSR_MVU_WSTRIDE_0  :   csr_mvu_wstride_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_WSTRIDE_1  :   csr_mvu_wstride_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_WSTRIDE_2  :   csr_mvu_wstride_2_d  = csr_wdata;
                pito_pkg::CSR_MVU_ISTRIDE_0  :   csr_mvu_istride_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_ISTRIDE_1  :   csr_mvu_istride_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_ISTRIDE_2  :   csr_mvu_istride_2_d  = csr_wdata;
                pito_pkg::CSR_MVU_OSTRIDE_0  :   csr_mvu_ostride_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_OSTRIDE_1  :   csr_mvu_ostride_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_OSTRIDE_2  :   csr_mvu_ostride_2_d  = csr_wdata;
                pito_pkg::CSR_MVU_WLENGTH_0  :   csr_mvu_wlength_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_WLENGTH_1  :   csr_mvu_wlength_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_WLENGTH_2  :   csr_mvu_wlength_2_d  = csr_wdata;
                pito_pkg::CSR_MVU_ILENGTH_0  :   csr_mvu_ilength_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_ILENGTH_1  :   csr_mvu_ilength_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_ILENGTH_2  :   csr_mvu_ilength_2_d  = csr_wdata;
                pito_pkg::CSR_MVU_OLENGTH_0  :   csr_mvu_olength_0_d  = csr_wdata;
                pito_pkg::CSR_MVU_OLENGTH_1  :   csr_mvu_olength_1_d  = csr_wdata;
                pito_pkg::CSR_MVU_OLENGTH_2  :   csr_mvu_olength_2_d  = csr_wdata;
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
        // mstatus_d.mpp  = priv_lvl_q;
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
            MRET: begin
                // the return should not have any write or read side-effects
                csr_we   = 1'b0;
                csr_read = 1'b0;
                mret     = 1'b1; // signal a return from machine mode
            end
            CSR_READ_WRITE : begin
                csr_wdata = csr_wdata_i;
            end
            CSR_SET        : csr_wdata = csr_wdata_i | csr_rdata;
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
            // set to boot address + direct mode + 4 byte offset which is the initial trap
            // mtvec_q                <= 32'b0;
            mip_q                  <= 32'b0;
            mie_q                  <= 32'b0;
            mepc_q                 <= 32'b0;
            mcause_q               <= 32'b0;
            mtval_q                <= 32'b0;
            // timer and counters
            // mcycle_q               <= 64'b0;
            minstret_q             <= 64'b0;
            // wait for interrupt
            wfi_q                  <= 1'b0;
            // mtvec_rst_load_q       <= 1'b1;
            mvu_start              <= 1'b0;
        end else begin
            // machine mode registers
            // mtvec_rst_load_q       <= 1'b0;
            mstatus_q              <= mstatus_d;
            mtvec_q                <= mtvec_d;
            mip_q                  <= mip_d;
            mie_q                  <= mie_d;
            mepc_q                 <= mepc_d;
            mcause_q               <= mcause_d;
            mtval_q                <= mtval_d;
            // timer and counters
            // mcycle_q               <= mcycle_d;
            minstret_q             <= minstret_d;
            // wait for interrupt
            wfi_q                  <= wfi_d;
            // MVU related csrs
            csr_mvu_mul_mode_q     <= csr_mvu_mul_mode_d;
            csr_mvu_countdown_q    <= csr_mvu_countdown_d;
            csr_mvu_wprecision_q   <= csr_mvu_wprecision_d;
            csr_mvu_iprecision_q   <= csr_mvu_iprecision_d;
            csr_mvu_oprecision_q   <= csr_mvu_oprecision_d;
            csr_mvu_wbaseaddr_q    <= csr_mvu_wbaseaddr_d;
            csr_mvu_ibaseaddr_q    <= csr_mvu_ibaseaddr_d;
            csr_mvu_obaseaddr_q    <= csr_mvu_obaseaddr_d;
            csr_mvu_wstride_0_q    <= csr_mvu_wstride_0_d;
            csr_mvu_wstride_1_q    <= csr_mvu_wstride_1_d;
            csr_mvu_wstride_2_q    <= csr_mvu_wstride_2_d;
            csr_mvu_istride_0_q    <= csr_mvu_istride_0_d;
            csr_mvu_istride_1_q    <= csr_mvu_istride_1_d;
            csr_mvu_istride_2_q    <= csr_mvu_istride_2_d;
            csr_mvu_ostride_0_q    <= csr_mvu_ostride_0_d;
            csr_mvu_ostride_1_q    <= csr_mvu_ostride_1_d;
            csr_mvu_ostride_2_q    <= csr_mvu_ostride_2_d;
            csr_mvu_wlength_0_q    <= csr_mvu_wlength_0_d;
            csr_mvu_wlength_1_q    <= csr_mvu_wlength_1_d;
            csr_mvu_wlength_2_q    <= csr_mvu_wlength_2_d;
            csr_mvu_ilength_0_q    <= csr_mvu_ilength_0_d;
            csr_mvu_ilength_1_q    <= csr_mvu_ilength_1_d;
            csr_mvu_ilength_2_q    <= csr_mvu_ilength_2_d;
            csr_mvu_olength_0_q    <= csr_mvu_olength_0_d;
            csr_mvu_olength_1_q    <= csr_mvu_olength_1_d;
            csr_mvu_olength_2_q    <= csr_mvu_olength_2_d;

            if (csr_addr == pito_pkg::CSR_MVU_COUNTDOWN) begin
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
