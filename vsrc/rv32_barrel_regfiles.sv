`timescale 1ns/1ps
module rv32_barrel_regfiles #(
        parameter NUM_HARTS      = 8,
        parameter HART_CNT_WIDTH = $clog2(NUM_HARTS)
    )
    (
        input                        clk,
        input [HART_CNT_WIDTH-1 : 0] rsa_hart,
        input [HART_CNT_WIDTH-1 : 0] rsd_hart,
        input [HART_CNT_WIDTH-1 : 0] rd_hart,
        input [`REG_ADDR_WIDTH-1:0 ] ra1,
        output[`XPR_LEN-1       :0 ] rd1,
        input [`REG_ADDR_WIDTH-1:0 ] ra2,
        output[`XPR_LEN-1       :0 ] rd2,
        input                        wen,
        input [`REG_ADDR_WIDTH-1:0 ] wa,
        input [`XPR_LEN-1       :0 ] wd
);

    // A register file is sitting between decoder and execute stage.
    // Read from RegF:
    logic[`REG_ADDR_WIDTH-1:0 ] ra1_sigs [NUM_HARTS-1 : 0];
    logic[`REG_ADDR_WIDTH-1:0 ] ra2_sigs [NUM_HARTS-1 : 0];
    logic[`XPR_LEN-1       :0 ] rd1_sigs [NUM_HARTS-1 : 0];
    logic[`XPR_LEN-1       :0 ] rd2_sigs [NUM_HARTS-1 : 0];
    // Write to RegF:
    logic [`REG_ADDR_WIDTH-1:0 ] wa_sigs [NUM_HARTS-1 : 0];
    logic                        wen_sigs[NUM_HARTS-1 : 0];
    // logic[`XPR_LEN-1       :0 ]  wd_sigs [NUM_HARTS-1 : 0];

genvar hart_id;
    for(hart_id=0; hart_id<NUM_HARTS; hart_id++) begin
        rv32_regfile regfile(
                                .clk(clk              ),
                                .ra1(ra1_sigs[hart_id]),
                                .rd1(rd1_sigs[hart_id]),
                                .ra2(ra2_sigs[hart_id]),
                                .rd2(rd2_sigs[hart_id]),
                                .wen(wen_sigs[hart_id]),
                                .wa (wa_sigs[hart_id ]),
                                .wd (wd               )
                            );
    end

genvar rs_var;
generate 
  for (rs_var = 0; rs_var < NUM_HARTS; rs_var++)  begin
    assign ra1_sigs[rs_var] = (rs_var==rsa_hart) ? ra1 : 0;
    assign ra2_sigs[rs_var] = (rs_var==rsa_hart) ? ra2 : 0;
    // assign rd1 = (rs_var==rsd_hart) ? rd1_sigs[rs_var] : 0;
    // assign rd2 = (rs_var==rsd_hart) ? rd2_sigs[rs_var] : 0;
  end
endgenerate

assign rd1 = rd1_sigs[rsa_hart];
assign rd2 = rd2_sigs[rsa_hart];

genvar rd_var;
generate 
  for (rd_var = 0; rd_var < NUM_HARTS; rd_var++)  begin
    assign wa_sigs [rd_var] = (rd_var==rd_hart) ? wa  : 0;
    assign wen_sigs[rd_var] = (rd_var==rd_hart) ? wen : 0;
    // assign wd_sigs [rd_var] = (rd_var==rd_hart) ? wd  : 0;
  end
endgenerate


endmodule