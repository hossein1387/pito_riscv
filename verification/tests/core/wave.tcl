add_wave_group core
    add_wave -into core {{/testbench_top/soc/pito/clk}}
    add_wave -into core {{/testbench_top/soc/pito/rst_n}}
    add_wave_group -into core FetchStage
        add_wave -into FetchStage {{/testbench_top/soc/pito/rv32_pc}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_wdata}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_rdata}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_addr}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_req}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_we}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/imem_be}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_wdata}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_rdata}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_addr}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_req}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_we}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/dmem_be}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/pito_program}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/rv32_instr}}
        add_wave -into FetchStage {{/testbench_top/soc/pito/pc_sel}}
    add_wave_group -into core DecStage
        add_wave_group -into DecStage RegFile
            add_wave -into RegFile {{/testbench_top/soc/pito/regfile/clk}} 
            add_wave -into RegFile {{/testbench_top/soc/pito/regfile/rsa_hart}} 
            add_wave -into RegFile {{/testbench_top/soc/pito/regfile/rsd_hart}} 
            add_wave -into RegFile {{/testbench_top/soc/pito/regfile/rd_hart}} 
            add_wave_group -into RegFile RegFileTop
            add_wave -into RegFileTop {{/testbench_top/soc/pito/regfile}} 
            add_wave_group -into RegFile RegFile_0
                add_wave -into RegFile_0 {{/testbench_top/soc/pito/regfile/\genblk1[0].regfile }} 
            add_wave_group -into RegFile RegFile_1
                add_wave -into RegFile_1 {{/testbench_top/soc/pito/regfile/\genblk1[1].regfile }} 
            add_wave_group -into RegFile RegFile_2
                add_wave -into RegFile_2 {{/testbench_top/soc/pito/regfile/\genblk1[2].regfile }} 
            add_wave_group -into RegFile RegFile_3
                add_wave -into RegFile_3 {{/testbench_top/soc/pito/regfile/\genblk1[3].regfile }} 
            add_wave_group -into RegFile RegFile_4
                add_wave -into RegFile_4 {{/testbench_top/soc/pito/regfile/\genblk1[4].regfile }} 
            add_wave_group -into RegFile RegFile_5
                add_wave -into RegFile_5 {{/testbench_top/soc/pito/regfile/\genblk1[5].regfile }} 
            add_wave_group -into RegFile RegFile_6
                add_wave -into RegFile_6 {{/testbench_top/soc/pito/regfile/\genblk1[6].regfile }} 
            add_wave_group -into RegFile RegFile_7
                add_wave -into RegFile_7 {{/testbench_top/soc/pito/regfile/\genblk1[7].regfile }} 
        add_wave_group -into DecStage Decoder
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_pc}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_rs1}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_rd}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_rs2}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_shamt}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_imm}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_rd1}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_rd2}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_fence_succ}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_fence_pred}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_csr}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_instr_trap}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_alu_op}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_opcode}}
            add_wave -into Decoder {{/testbench_top/soc/pito/rv32_dec_instr}}
    add_wave_group -into core EXStage
        add_wave_group -into EXStage Alu
            add_wave -into Alu {{/testbench_top/soc/pito/alu_src}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_alu_rs1}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_alu_rs2}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_ex_rd}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_alu_res}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_alu_op}}
            add_wave -into Alu {{/testbench_top/soc/pito/rv32_alu_z}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_instr}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_rd}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_rs1}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_opcode}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_pc}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_imm}}
        add_wave -into EXStage {{/testbench_top/soc/pito/rv32_ex_readd_addr}}

    add_wave_group -into core WBStage
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_opcode}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_rd}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_out}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_rs2_skip}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_pc}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_skip}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_instr}}
        add_wave -into WBStage {{/testbench_top/soc/pito/rv32_wb_readd_addr}}
    add_wave_group -into core WFStage
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_wf_opcode}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_wf_pc}}
        add_wave -into WFStage {{/testbench_top/soc/pito/pc_sel}}
        add_wave -into WFStage {{/testbench_top/soc/pito/alu_src}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_i_addr}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dmem_addr}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dmem_data}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dmem_w_en}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dw_addr}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dw_data}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dw_en}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dr_addr}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_dr_data}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_wf_instr}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_wf_load_val}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_wf_load_val}}
        add_wave -into WFStage {{/testbench_top/soc/pito/rv32_regf_wd}}
    add_wave_group -into WFStage Next_PC
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_alu_res}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_rs1}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_imm}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_instr_opcode}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_cur_pc}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_save_pc}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_has_new_pc}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_reg_pc}}
            add_wave -into Next_PC {{/testbench_top/soc/pito/rv32_next_pc_cal/rv32_next_pc_val}}
add_wave_group decoder
    add_wave -into decoder {{/testbench_top/soc/pito/decoder}} 
add_wave_group regfile
    add_wave -into regfile {{/testbench_top/soc/pito/regfile}} 
add_wave_group alu
    add_wave -into alu {{/testbench_top/soc/pito/alu}} 
add_wave_group pipeline
    add_wave_group -into pipeline pc_counters
        add_wave -into pc_counters {{/testbench_top/soc/pito/pc_sel}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_dec_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_ex_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_wb_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_wf_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_org_ex_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_org_wb_pc}}
        add_wave -into pc_counters {{/testbench_top/soc/pito/rv32_org_wf_pc}}
    add_wave_group -into pipeline instructions
        add_wave -into instructions {{/testbench_top/soc/pito/rv32_instr}}
        add_wave -into instructions {{/testbench_top/soc/pito/rv32_dec_instr}}
        add_wave -into instructions {{/testbench_top/soc/pito/rv32_ex_instr}}
        add_wave -into instructions {{/testbench_top/soc/pito/rv32_wb_instr}}
        add_wave -into instructions {{/testbench_top/soc/pito/rv32_wf_instr}}
    add_wave_group -into pipeline opcodes
        add_wave -into opcodes {{/testbench_top/soc/pito/rv32_instr}}
        add_wave -into opcodes {{/testbench_top/soc/pito/rv32_dec_opcode}}
        add_wave -into opcodes {{/testbench_top/soc/pito/rv32_ex_opcode}}
        add_wave -into opcodes {{/testbench_top/soc/pito/rv32_wb_opcode}}
        add_wave -into opcodes {{/testbench_top/soc/pito/rv32_wf_opcode}}
    add_wave_group -into pipeline rs1_2
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_wb_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_wb_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_wf_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_wf_alu_rs2}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_cap_alu_rs1}}
        add_wave -into rs1_2 {{/testbench_top/soc/pito/rv32_cap_alu_rs2}}
    add_wave_group -into pipeline harts
        add_wave_group -into harts hart_ids
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_cnt}}
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_fet_cnt}}
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_dec_cnt}}
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_ex_cnt}}
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_wb_cnt}}
            add_wave -into hart_ids {{/testbench_top/soc/pito/rv32_hart_wf_cnt}}
add_wave_group csr
    add_wave_group -into csr csr0
            add_wave -into csr0 {{/testbench_top/soc/pito/csr/\genblk1[0].csrfile }}
add_wave_group mems
    set_property display_limit 3000000 [current_wave_config]
    add_wave_group -into mems i_mem
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/clk_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/rst_ni}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/req_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/we_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/addr_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/wdata_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/be_i}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/rdata_o}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/sram}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/NumWords}}
        add_wave -into i_mem {{/testbench_top/soc/i_mem/ram/NumPorts}}
    add_wave_group -into mems d_mem
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/clk_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/rst_ni}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/req_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/we_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/addr_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/wdata_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/be_i}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/rdata_o}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/sram}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/NumWords}}
        add_wave -into d_mem {{/testbench_top/soc/d_mem/ram/NumPorts}}
        # add_wave -into d_mem {{/testbench_top/soc/pito/d_mem/altsyncram_component/mem_data}}


