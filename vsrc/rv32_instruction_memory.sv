module rv32_instruction_memory (
                    input  logic            clock    ,
                    input  rv32_data_t      data     ,
                    input  rv32_dmem_addr_t rdaddress,
                    input  rv32_dmem_addr_t wraddress,
                    input  logic            wren     ,
                    output rv32_data_t      q        
                );

wire clka;
wire ena;
wire [0 : 0] wea;
wire [12 : 0] addra;
wire [31 : 0] dina;
wire clkb;
wire enb;
wire [12 : 0] addrb;
wire [31 : 0] doutb;

assign clka = clock;
assign ena  = 1'b1;
assign wea  = wren;
assign addra= wraddress;
assign dina = data;
assign clkb = clock;
assign enb  = 1'b1;
assign addrb= rdaddress;
assign q = doutb;


bram_32Kb bram_32Kb_inst(
    .clka  (clka ),
    .ena   (ena  ),
    .wea   (wea  ),
    .addra (addra),
    .dina  (dina ),
    .clkb  (clkb ),
    .enb   (enb  ),
    .addrb (addrb),
    .doutb (doutb)
);

endmodule
