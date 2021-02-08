# set_property display_limit 3000000 [current_wave_config]
set_property trace_limit   300000000 [current_sim]

add_wave_group csr_irq
    add_wave_group -into csr_irq csr0_irq
        add_wave_group -into csr0_irq irq
            add_wave -into irq  {{/irq_tester/core/clk}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /is_irq}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mip_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mip_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mie_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mie_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mstatus_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mstatus_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mcause_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mcause_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mtvec_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mtvec_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mepc_q}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mepc_d}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /csr_irq_evt}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mvu_irq_i}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /mvu_irq_valid}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /pc_i}}
            add_wave -into irq  {{/irq_tester/core/csr/\genblk1[0].csrfile /hart_valid}}
        add_wave_group -into csr0_irq mvu
            add_wave -into mvu  {{/irq_tester/core/csr/\genblk1[0].csrfile /mvu_start}}
            add_wave -into mvu  {{/irq_tester/core/csr/\genblk1[0].csrfile /csr_mvu_command}}
            add_wave -into mvu  {{/irq_tester/core/csr/\genblk1[0].csrfile /csr_mvu_precision}}

