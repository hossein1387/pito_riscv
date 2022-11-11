
module pito_mem_subsystem import rv32_pkg::*;import pito_pkg::*;
#(
    parameter int unsigned INSTR_RAM_BEGIN_ADDR = 32'h00200000,
    parameter int unsigned DATA_RAM_BEGIN_ADDR  = 32'h00202000,
    parameter int unsigned AxiIdWidth           = 6,
    parameter int unsigned AxiAddrWidth         = 32,
    parameter int unsigned AxiDataWidth         = 32,
    parameter int unsigned AxiUserWidth         = 1,
    // Dependant parameters. DO NOT CHANGE!
    localparam type        axi_data_t   = logic [AxiDataWidth-1:0],
    localparam type        axi_strb_t   = logic [AxiDataWidth/8-1:0],
    localparam type        axi_addr_t   = logic [AxiAddrWidth-1:0],
    localparam type        axi_user_t   = logic [AxiUserWidth-1:0],
    localparam type        axi_id_t     = logic [AxiIdWidth-1:0]
)(
    input  logic            clk_i,
    input  logic            rst_ni,
    output rv32_data_t      pito_dmem_wdata_o,
    input  rv32_data_t      pito_dmem_rdata_i,
    output rv32_dmem_addr_t pito_dmem_addr_o,
    output logic            pito_dmem_req_o,
    output logic            pito_dmem_we_o,
    output dmem_be_t        pito_dmem_be_o,
    output rv32_data_t      pito_imem_wdata_o,
    input  rv32_data_t      pito_imem_rdata_i,
    output rv32_imem_addr_t pito_imem_addr_o,
    output logic            pito_imem_req_o,
    output logic            pito_imem_we_o,
    output imem_be_t        pito_imem_be_o,
    AXI_BUS.Master          m_axi
);
`include "axi/assign.svh"
`include "axi/typedef.svh"
`include "common_cells/registers.svh"

//=================================================================================
//  Memory Regions  
//=================================================================================
localparam NrAXIMasters = 1; // Actually masters, but slaves on the crossbar

typedef enum int unsigned {
  IMEM = 0,
  DMEM  = 1
} axi_slaves_e;
localparam NrAXISlaves = DMEM + 1;

// Memory Map
// 1GByte of DDR (split between two chips on Genesys2)
localparam logic [31:0] DMEMLength = 32'h2000;
localparam logic [31:0] IMEMLength = 32'h2000;

typedef enum logic [31:0] {
  IMEMBase = 32'h0020_0000,
  DMEMBase = 32'h0020_2000
} soc_bus_start_e;

  // AXI Typedefs
`AXI_TYPEDEF_ALL(soc, axi_addr_t, axi_id_t, axi_data_t, axi_strb_t, axi_user_t)


  // Buses
soc_req_t  soc_axi_req;
soc_resp_t soc_axi_resp;

soc_req_t    [NrAXISlaves-1:0] periph_axi_req;
soc_resp_t   [NrAXISlaves-1:0] periph_axi_resp;


//=================================================================================
//  Crossbar
//=================================================================================

localparam axi_pkg::xbar_cfg_t XBarCfg = '{
  NoSlvPorts        : NrAXIMasters,
  NoMstPorts        : NrAXISlaves,
  MaxMstTrans       : 4,
  MaxSlvTrans       : 4,
  FallThrough       : 1'b0,
  LatencyMode       : axi_pkg::CUT_MST_PORTS,
  AxiIdWidthSlvPorts: AxiIdWidth,
  AxiIdUsedSlvPorts : AxiIdWidth,
  UniqueIds         : 1'b0,
  AxiAddrWidth      : AxiAddrWidth,
  AxiDataWidth      : AxiDataWidth,
  NoAddrRules       : NrAXISlaves
};

axi_pkg::xbar_rule_32_t [NrAXISlaves-1:0] routing_rules;
assign routing_rules = '{
  '{idx: IMEM, start_addr: IMEMBase, end_addr: IMEMBase + IMEMLength},
  '{idx: DMEM, start_addr: DMEMBase, end_addr: DMEMBase + DMEMLength}
};

axi_xbar #(
  .Cfg          (XBarCfg                ),
  .ATOPs        (1'b0                   ),
  .slv_aw_chan_t(soc_aw_chan_t          ),
  .mst_aw_chan_t(soc_aw_chan_t          ),
  .w_chan_t     (soc_w_chan_t           ),
  .slv_b_chan_t (soc_b_chan_t           ),
  .mst_b_chan_t (soc_b_chan_t           ),
  .slv_ar_chan_t(soc_ar_chan_t          ),
  .mst_ar_chan_t(soc_ar_chan_t          ),
  .slv_r_chan_t (soc_r_chan_t           ),
  .mst_r_chan_t (soc_r_chan_t           ),
  .slv_req_t    (soc_req_t              ),
  .slv_resp_t   (soc_resp_t             ),
  .mst_req_t    (soc_req_t              ),
  .mst_resp_t   (soc_resp_t             ),
  .rule_t       (axi_pkg::xbar_rule_32_t)
) i_soc_xbar (
  .clk_i                (clk_i           ),
  .rst_ni               (rst_ni          ),
  .test_i               (1'b0            ),
  .slv_ports_req_i      (soc_axi_req     ),
  .slv_ports_resp_o     (soc_axi_resp    ),
  .mst_ports_req_o      (periph_axi_req  ),
  .mst_ports_resp_i     (periph_axi_resp ),
  .addr_map_i           (routing_rules   ),
  .en_default_mst_port_i('0              ),
  .default_mst_port_i   ('0              )
);

`AXI_ASSIGN_TO_REQ(soc_axi_req, m_axi)
`AXI_ASSIGN_FROM_RESP(m_axi, soc_axi_resp)

//=================================================================================
//  AXI Peripherals
//=================================================================================

logic pito_dmem_rvalid, pito_imem_rvalid;
  // One-cycle latency
`FF(pito_dmem_rvalid, pito_dmem_req_o, 1'b0);
`FF(pito_imem_rvalid, pito_imem_req_o, 1'b0);

// Data memory

axi_to_mem #(
  .AddrWidth   (AxiAddrWidth         ),
  .DataWidth   (AxiDataWidth         ),
  .IdWidth     (AxiIdWidth           ),
  .NumBanks    (1                    ),
  .axi_req_t   (soc_req_t            ),
  .axi_resp_t  (soc_resp_t           )
) i_axi_to_mem (
  .clk_i       (clk_i                ),
  .rst_ni      (rst_ni               ),
  .axi_req_i   (periph_axi_req[IMEM] ),
  .axi_resp_o  (periph_axi_resp[IMEM]),
  .mem_req_o   (pito_imem_req_o      ),
  .mem_gnt_i   (pito_imem_req_o      ), // Always available
  .mem_we_o    (pito_imem_we_o       ),
  .mem_addr_o  (pito_imem_addr_o     ),
  .mem_strb_o  (pito_imem_be_o       ),
  .mem_wdata_o (pito_imem_wdata_o    ),
  .mem_rdata_i (pito_imem_rdata_i    ),
  .mem_rvalid_i(pito_imem_rvalid     ),
  .mem_atop_o  (/* Unused */         ),
  .busy_o      (/* Unused */         )
);


// Instruction memory
axi_to_mem #(
  .AddrWidth   (AxiAddrWidth         ),
  .DataWidth   (AxiDataWidth         ),
  .IdWidth     (AxiIdWidth           ),
  .NumBanks    (1                    ),
  .axi_req_t   (soc_req_t            ),
  .axi_resp_t  (soc_resp_t           )
) d_axi_to_mem (
  .clk_i       (clk_i                ),
  .rst_ni      (rst_ni               ),
  .axi_req_i   (periph_axi_req[DMEM] ),
  .axi_resp_o  (periph_axi_resp[DMEM]),
  .mem_req_o   (pito_dmem_req_o      ),
  .mem_gnt_i   (pito_dmem_req_o      ), // Always available
  .mem_we_o    (pito_dmem_we_o       ),
  .mem_addr_o  (pito_dmem_addr_o     ),
  .mem_strb_o  (pito_dmem_be_o       ),
  .mem_wdata_o (pito_dmem_wdata_o    ),
  .mem_rdata_i (pito_dmem_rdata_i    ),
  .mem_rvalid_i(pito_dmem_rvalid     ),
  .mem_atop_o  (/* Unused */         ),
  .busy_o      (/* Unused */         )
);

endmodule