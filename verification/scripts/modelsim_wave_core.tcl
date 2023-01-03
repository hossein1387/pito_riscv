# Tcl script that structures the internal signals into different groups.
# This file has been tested with Modelsim and Questasim simulator.

        add wave -noupdate -group soc -group pito_inf /testbench_top/pito_inf/*
        add wave -noupdate -group soc -group apb_master /testbench_top/apb_master/*
        add wave -noupdate -group soc -group axi_master /testbench_top/axi_master/*
        add wave -noupdate -group soc -group axi_master_dv /testbench_top/axi_master_dv/*
        add wave -noupdate -group soc -group uart /testbench_top/soc/uart/rst_n
        add wave -noupdate -group soc -group uart /testbench_top/soc/io_read
        add wave -noupdate -group soc -group uart /testbench_top/soc/io_val
        add wave -noupdate -group soc -group uart sim:/testbench_top/soc/uart/*

        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/mem_out_bound
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_wdata
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_rdata
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_addr
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_req
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_we
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/imem_be
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_wdata
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_rdata
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_addr
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_req
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_we
        add wave -noupdate -group soc -group pito -group top /testbench_top/soc/pito/dmem_be 

    add wave -noupdate -group soc -group pito -group core /testbench_top/soc/pito/clk
    add wave -noupdate -group soc -group pito -group core /testbench_top/soc/pito/rst_n
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/rv32_pc
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_wdata
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_rdata
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_addr
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_req
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_we
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/imem_be
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_wdata
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_rdata
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_addr
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_req
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_we
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/dmem_be
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/rv32_instr
        add wave -noupdate -group soc -group pito -group core -group FetchStage /testbench_top/soc/pito/pc_sel

            add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile /testbench_top/soc/pito/regfile/clk
            add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile /testbench_top/soc/pito/regfile/rsa_hart
            add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile /testbench_top/soc/pito/regfile/rsd_hart
            add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile /testbench_top/soc/pito/regfile/rd_hart
                add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile -group RegFileTop /testbench_top/soc/pito/regfile/*
                for {set hart 0}  {$hart < [examine -radix dec pito_pkg::NUM_HARTS]} {incr hart} {
                    add wave -noupdate -group soc -group pito -group core -group DecStage -group RegFile -group RegFile_[$hart] /testbench_top/soc/pito/regfile/\genblk1[$hart].regfile/*
                }
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_pc
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_rs1
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_rd
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_rs2
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_shamt
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_imm
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_rd1
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_rd2
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_fence_succ
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_fence_pred
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_csr
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_instr_trap
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_alu_op
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_opcode
            add wave -noupdate -group soc -group pito -group core -group DecStage -group Decoder /testbench_top/soc/pito/rv32_dec_instr

            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/alu_src
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_alu_rs1
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_alu_rs2
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_ex_rd
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_alu_res
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_alu_op
            add wave -noupdate -group soc -group pito -group core -group EXStage -group Alu /testbench_top/soc/pito/rv32_alu_z

        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_instr
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_rd
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_rs1
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_opcode
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_pc
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_imm
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_rs2_skip
        add wave -noupdate -group soc -group pito -group core -group EXStage /testbench_top/soc/pito/rv32_ex_dmem_addr


        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_opcode
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_rd
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_out
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_pc
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/is_store
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/is_load
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_is_load
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_wb_instr
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_alu_res
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_dmem_addr
        add wave -noupdate -group soc -group pito -group core -group WBStage /testbench_top/soc/pito/rv32_dmem_data


        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_opcode
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_pc
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/pc_sel
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/alu_src
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_i_addr
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wb_dmem_addr
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_dmem_data
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_dmem_w_en
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_dr_data
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_instr
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_load_val
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_regf_wd
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_skip
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_regf_wen
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_regf_wa
        add wave -noupdate -group soc -group pito -group core -group WFStage /testbench_top/soc/pito/rv32_wf_is_load


            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/csr_irq_evt
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_alu_res
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_rs1
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_imm
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_instr_opcode
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_cur_pc
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_save_pc
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_has_new_pc
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_reg_pc
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_next_pc_val
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_next_pc
            add wave -noupdate -group soc -group pito -group core -group WFStage -group Next_PC /testbench_top/soc/pito/rv32_next_pc_cal/rv32_new_pc



    add wave -noupdate -group soc -group pito -group core -group decoder /testbench_top/soc/pito/decoder/*
    add wave -noupdate -group soc -group pito -group core -group regfile /testbench_top/soc/pito/regfile/*
    add wave -noupdate -group soc -group pito -group core -group alu /testbench_top/soc/pito/alu/*

        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/pc_sel
        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/rv32_pc
        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/rv32_dec_pc
        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/rv32_ex_pc
        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/rv32_wb_pc
        add wave -noupdate -group soc -group pito -group core -group pipeline -group pc_counters /testbench_top/soc/pito/rv32_wf_pc

        add wave -noupdate -group soc -group pito -group core -group pipeline -group instructions /testbench_top/soc/pito/rv32_instr
        add wave -noupdate -group soc -group pito -group core -group pipeline -group instructions /testbench_top/soc/pito/rv32_dec_instr
        add wave -noupdate -group soc -group pito -group core -group pipeline -group instructions /testbench_top/soc/pito/rv32_ex_instr
        add wave -noupdate -group soc -group pito -group core -group pipeline -group instructions /testbench_top/soc/pito/rv32_wb_instr
        add wave -noupdate -group soc -group pito -group core -group pipeline -group instructions /testbench_top/soc/pito/rv32_wf_instr

        add wave -noupdate -group soc -group pito -group core -group pipeline -group opcodes /testbench_top/soc/pito/rv32_instr
        add wave -noupdate -group soc -group pito -group core -group pipeline -group opcodes /testbench_top/soc/pito/rv32_dec_opcode
        add wave -noupdate -group soc -group pito -group core -group pipeline -group opcodes /testbench_top/soc/pito/rv32_ex_opcode
        add wave -noupdate -group soc -group pito -group core -group pipeline -group opcodes /testbench_top/soc/pito/rv32_wb_opcode
        add wave -noupdate -group soc -group pito -group core -group pipeline -group opcodes /testbench_top/soc/pito/rv32_wf_opcode

        add wave -noupdate -group soc -group pito -group core -group pipeline -group rs1_2 /testbench_top/soc/pito/rv32_alu_rs1
        add wave -noupdate -group soc -group pito -group core -group pipeline -group rs1_2 /testbench_top/soc/pito/rv32_alu_rs2


            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_cnt
            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_fet_cnt
            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_dec_cnt
            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_ex_cnt
            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_wb_cnt
            add wave -noupdate -group soc -group pito -group core -group pipeline -group harts -group hart_ids /testbench_top/soc/pito/rv32_hart_wf_cnt

            add wave -noupdate -group soc -group pito -group core -group csr -group csr0 /testbench_top/soc/pito/csr/\genblk1[0].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr1 /testbench_top/soc/pito/csr/\genblk1[1].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr2 /testbench_top/soc/pito/csr/\genblk1[2].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr3 /testbench_top/soc/pito/csr/\genblk1[3].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr4 /testbench_top/soc/pito/csr/\genblk1[4].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr5 /testbench_top/soc/pito/csr/\genblk1[5].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr6 /testbench_top/soc/pito/csr/\genblk1[6].csrfile/* 
            add wave -noupdate -group soc -group pito -group core -group csr -group csr7 /testbench_top/soc/pito/csr/\genblk1[7].csrfile/* 

        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/clk_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/rst_ni
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/req_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/we_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/addr_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/wdata_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/be_i
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/rdata_o
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/sram
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/NumWords
        add wave -noupdate -group soc -group mems -group i_mem /testbench_top/soc/i_mem/ram/NumPorts

        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/clk_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/rst_ni
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/req_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/we_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/addr_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/wdata_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/be_i
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/rdata_o
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/sram
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/NumWords
        add wave -noupdate -group soc -group mems -group d_mem /testbench_top/soc/d_mem/ram/NumPorts
        # add_wave -into d_mem /testbench_top/soc/pito/d_mem/altsyncram_component/mem_data

        add wave -noupdate -group soc -group mem_subsystem -group i_soc_xbar /testbench_top/soc/pito_mem_subsystem_inst/i_soc_xbar/*
        add wave -noupdate -group soc -group mem_subsystem -group i_axi_to_mem /testbench_top/soc/pito_mem_subsystem_inst/i_axi_to_mem/*
        add wave -noupdate -group soc -group mem_subsystem -group d_axi_to_mem /testbench_top/soc/pito_mem_subsystem_inst/d_axi_to_mem/*
