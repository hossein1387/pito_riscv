module rv32_controller (
    input  rv32_clk,    // Clock
    input  rv32_rst_n,  // Asynchronous reset active low
    input  rv32_i_data,
    output rv32_i_addr,
    input  rv32_d_data,
    output rv32_d_addr,
    output rv32_o_data,
    output rv32_wr_en,
    output rv32_rd_en
);
