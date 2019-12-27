add_wave {{/mem_tester/clk}}
add_wave {{/mem_tester/rv32_iw_addr}}
add_wave {{/mem_tester/rv32_iw_data}}
add_wave {{/mem_tester/rv32_iw_en}}
add_wave {{/mem_tester/rv32_ir_addr}}
add_wave {{/mem_tester/rv32_ir_data}}
set_property display_limit 300000 [current_wave_config]
add_wave {{/mem_tester/i_mem/bram_32Kb_inst/inst/\native_mem_module.blk_mem_gen_v8_4_3_inst /memory}} 