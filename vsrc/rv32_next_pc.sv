`timescale 1ns/1ps
module rv32_next_pc import rv32_pkg::*;import pito_pkg::*;(
    input  logic                       clk,
    input  logic                       rst_n,
    input  irq_evt_t [NUM_HARTS-1:0]   csr_irq_evt,
    input  rv32_hart_cnt_t             hart_id_i,
    input  rv32_register_t             rv32_alu_res,
    input  rv32_register_t             rv32_rs1,
    input  rv32_imm_t                  rv32_imm,         // decoded immediate value
    input  rv32_opcode_enum_t          rv32_instr_opcode,// decoded instruction
    input  rv32_pc_cnt_t               rv32_cur_pc,      // current PC counter
    output logic                       rv32_save_pc,     // indicates if pc needs to be saved in RF
    output logic                       rv32_has_new_pc,  // indicates if the pc has a new value (other than pc+4 )
    output rv32_register_t             rv32_reg_pc,      // pc val to save in RF
    output rv32_pc_cnt_t               rv32_next_pc_val  // calculated pc
);

// Interrupt queue:
// Each hart can receive interrupt independently. The processed 
// interrupts from CSR come in as a irq_evt. For each hart,
// we put the events in a queue which will be processed in order.
// We store only a certain number of IRQ requests per each hart.
    localparam IrqQueueDepth = pito_pkg::IRQ_Q_DEPTH;
    localparam QbWidth = $clog2(IrqQueueDepth);

    rv32_data_t [IrqQueueDepth-1:0] irq_queue_d[pito_pkg::NUM_HARTS-1:0];
    rv32_data_t [IrqQueueDepth-1:0] irq_queue_q[pito_pkg::NUM_HARTS-1:0];
    logic [QbWidth-1 :0] irq_data_ptr_d[pito_pkg::NUM_HARTS-1:0];
    logic [QbWidth-1 :0] irq_data_ptr_q[pito_pkg::NUM_HARTS-1:0];

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
                irq_data_ptr_q[hart_id] <= 0;
            end
        end else begin
            for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
                irq_queue_q[hart_id] <= irq_queue_d[hart_id];
                irq_data_ptr_q[hart_id] <= irq_data_ptr_d[hart_id];
            end
        end
    end


    rv32_pc_cnt_t      rv32_next_pc;
    logic              rv32_new_pc;
    always_comb begin
        for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
            irq_queue_d[hart_id] = irq_queue_q[hart_id];
            irq_data_ptr_d[hart_id] = irq_data_ptr_q[hart_id];
        end

        // Handling the incoming IRQ and Exceptions.
        for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
            if (csr_irq_evt[hart_id].valid==1) begin
                irq_data_ptr_d[hart_id] += 1;
                if (irq_data_ptr_q[hart_id] == IrqQueueDepth-1) begin
                    irq_data_ptr_d[hart_id] = 0;
                end
                irq_queue_d[hart_id][irq_data_ptr_q[hart_id]]= csr_irq_evt[hart_id].data;
            end
        end

        case (rv32_instr_opcode)
            rv32_pkg::RV32_AUIPC: begin
                // rv32_next_pc_val = rv32_cur_pc + rv32_imm; 
                rv32_reg_pc      = rv32_cur_pc + rv32_imm;
                rv32_new_pc      = 1'b0; 
                rv32_next_pc     = 0;
            end
            rv32_pkg::RV32_BEQ ,
            rv32_pkg::RV32_BNE ,
            rv32_pkg::RV32_BLT ,
            rv32_pkg::RV32_BGE ,
            rv32_pkg::RV32_BLTU,
            rv32_pkg::RV32_BGEU : begin
                rv32_next_pc     = (rv32_alu_res == 1) ? rv32_cur_pc + (rv32_imm<<1) : rv32_cur_pc; 
                rv32_new_pc      = (rv32_alu_res == 1) ? 1'b1 : 1'b0; 
            end
            rv32_pkg::RV32_JAL  : begin 
                rv32_next_pc     = rv32_cur_pc + (rv32_imm<<1); 
                rv32_reg_pc      = rv32_cur_pc + 4; 
                rv32_new_pc      = 1'b1; 
            end
            rv32_pkg::RV32_JALR : begin 
                rv32_next_pc     = rv32_rs1 + rv32_imm; 
                rv32_reg_pc      = rv32_cur_pc + 4; 
                rv32_new_pc      = 1'b1; 
            end
            rv32_pkg::RV32_MRET : begin
                rv32_next_pc     = irq_queue_q[hart_id_i][irq_data_ptr_q[hart_id_i]-1];
                rv32_new_pc      = 1'b1; 
                irq_data_ptr_d[hart_id_i] -= 1;
                if (irq_data_ptr_q[hart_id_i] == IrqQueueDepth-1) begin
                    irq_data_ptr_d[hart_id_i] = 0;
                end
            end
            default : begin
                rv32_reg_pc      = 0;
                rv32_next_pc     = rv32_cur_pc;
                rv32_new_pc      = 1'b0; 
            end
        endcase

        // Check irq queue and try to find if any IRQ has occured. If so, 
        // check if the current hart is responsible to take action. 
        rv32_next_pc_val = rv32_next_pc;
        rv32_has_new_pc = rv32_new_pc;
        for (int hart_id=0; hart_id<pito_pkg::NUM_HARTS; hart_id++) begin
            if (irq_data_ptr_q[hart_id] > 0 && rv32_instr_opcode!=rv32_pkg::RV32_MRET) begin
                if (hart_id==hart_id_i) begin
                    rv32_next_pc_val = irq_queue_q[hart_id][irq_data_ptr_q[hart_id]-1];
                    rv32_has_new_pc = 1'b1;
                    irq_data_ptr_d[hart_id] -= 1;
                    if (irq_data_ptr_q[hart_id] == IrqQueueDepth-1) begin
                        irq_data_ptr_d[hart_id] = 0;
                    end
                end
            end 
        end
        // Finally, check if we caught the irq right at this moment
        if (csr_irq_evt[hart_id_i].valid == 1'b1 && rv32_instr_opcode!=rv32_pkg::RV32_MRET) begin
            rv32_next_pc_val = csr_irq_evt[hart_id_i].data;
            rv32_has_new_pc = 1'b1;
            irq_data_ptr_d[hart_id_i] -= 1;
            if (irq_data_ptr_q[hart_id_i] == IrqQueueDepth-1) begin
                irq_data_ptr_d[hart_id_i] = 0;
            end
        end
        rv32_save_pc = (rv32_has_new_pc && ((rv32_instr_opcode == rv32_pkg::RV32_JAL) || (rv32_instr_opcode == rv32_pkg::RV32_JALR))) || (rv32_instr_opcode == rv32_pkg::RV32_AUIPC) ? 1'b1 : 1'b0;
    end

endmodule