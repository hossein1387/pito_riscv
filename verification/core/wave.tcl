add_wave_group core
add_wave -into core {{/core_tester/core}} 
add_wave_group i_mem
add_wave -into i_mem {{/core_tester/core/i_mem}} 
add_wave_group decoder
add_wave -into decoder {{/core_tester/core/decoder}} 
add_wave_group regfile
add_wave -into regfile {{/core_tester/core/regfile}} 
add_wave_group alu
add_wave -into alu {{/core_tester/core/alu}} 
