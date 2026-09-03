module cpu(
    input logic reset,
    input logic clk,
    input logic [31:0] init_memory [0:255]
);

    // ============================================================
    // STALL CONTROL
    // ============================================================

    logic stall;


    // ============================================================
    // PC
    // ============================================================

    logic [31:0] current_pc;
    logic [31:0] next_pc;

    program_counter cpu_pc(
        .reset(reset),
        .clk(clk),
        .stall(stall),
        .next_pc(next_pc),
        .pc(current_pc)
    );


    // ============================================================
    // IF STAGE
    // ============================================================

    logic [31:0] instruction;
    logic [31:0] instruction_memory_read;

    memory instruction_memory(
        .reset(reset),
        .clk(clk),
        .address(current_pc),
        .data_write(32'b0),
        .memory_op(4'b1000),
        .memory_mux_select(1'b0),
        .read_data(instruction_memory_read),
        .init_memory(init_memory)
    );

    assign instruction = instruction_memory_read;


    // ============================================================
    // IF/ID PIPELINE REGISTER
    // ============================================================

    logic [31:0] if_id_pc;
    logic [31:0] if_id_instruction;

    if_id_register cpu_if_id(
        .clk(clk),
        .reset(reset),
        .stall(stall),

        .pc_in(current_pc),
        .instruction_in(instruction),

        .pc_out(if_id_pc),
        .instruction_out(if_id_instruction)
    );


    // ============================================================
    // ID STAGE
    // ============================================================

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [3:0] alu_op;
    logic [3:0] memory_op;
    logic [2:0] branch_type;

    logic register_write_enable;
    logic alu_mux_select;
    logic [1:0] pc_mux_select;
    logic [1:0] writeback_select;


    // ============================================================
    // DECODER
    // ============================================================

    decoder cpu_decoder(
        .instruction(if_id_instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .alu_op(alu_op),
        .mem_op(memory_op),

        .register_write_enable(register_write_enable),
        .alu_mux_select(alu_mux_select),

        .pc_mux_select(pc_mux_select),

        .memory_mux_select(),

        .branch_type(branch_type),

        .writeback_select(writeback_select)
    );


    // ============================================================
    // IMMEDIATE
    // ============================================================

    logic [31:0] immediate;

    immediate_generator cpu_immediate_generator(
        .instruction(if_id_instruction),
        .immediate(immediate)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    logic [31:0] register_value_1;
    logic [31:0] register_value_2;

    logic [31:0] writeback_write_data;

    // MEM/WB destination register
    logic [4:0] mem_wb_rd;

    // MEM/WB register write enable
    logic mem_wb_register_write_enable;


    register_file cpu_register_file(
        .clk(clk),

        .rs1(rs1),
        .rs2(rs2),

        .rd(mem_wb_rd),

        .read_data_1(register_value_1),
        .read_data_2(register_value_2),

        .write_data(writeback_write_data),

        .write_enable(mem_wb_register_write_enable)
    );


    // ============================================================
    // ID/EX PIPELINE SIGNALS
    // ============================================================

    logic [31:0] id_ex_pc;
    logic [31:0] id_ex_register_value_1;
    logic [31:0] id_ex_register_value_2;
    logic [31:0] id_ex_immediate;

    logic [4:0] id_ex_rs1;
    logic [4:0] id_ex_rs2;
    logic [4:0] id_ex_rd;

    logic [3:0] id_ex_alu_op;
    logic [3:0] id_ex_memory_op;
    logic [2:0] id_ex_branch_type;

    logic id_ex_register_write_enable;
    logic id_ex_alu_mux_select;
    logic [1:0] id_ex_pc_mux_select;
    logic [1:0] id_ex_writeback_select;


    // ============================================================
    // STALL / LOAD-USE HAZARD DETECTION
    // ============================================================
    //
    // Current instruction:
    //     rs1 / rs2
    //
    // Previous instruction in ID/EX:
    //     id_ex_rd
    //     id_ex_memory_op
    //
    // If the ID/EX instruction is a load and the current
    // instruction needs the value being loaded:
    //
    //     stall = 1
    //
    // This causes:
    //
    //     PC      -> HOLD
    //     IF/ID   -> HOLD
    //     ID/EX   -> BUBBLE
    //
    // ============================================================

    stall_unit cpu_stall_unit(
        .rs1(rs1),
        .rs2(rs2),

        .id_ex_rd(id_ex_rd),
        .id_ex_memory_op(id_ex_memory_op),

        .stall(stall)
    );


    // ============================================================
    // ID/EX PIPELINE REGISTER
    // ============================================================

    id_ex_register cpu_id_ex(
        .clk(clk),
        .reset(reset),
        .stall(stall),

        .pc_in(if_id_pc),

        .register_value_1_in(register_value_1),
        .register_value_2_in(register_value_2),

        .immediate_in(immediate),

        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),

        .alu_op_in(alu_op),
        .memory_op_in(memory_op),
        .branch_type_in(branch_type),

        .register_write_enable_in(register_write_enable),
        .alu_mux_select_in(alu_mux_select),
        .pc_mux_select_in(pc_mux_select),
        .writeback_select_in(writeback_select),

        .pc_out(id_ex_pc),

        .register_value_1_out(id_ex_register_value_1),
        .register_value_2_out(id_ex_register_value_2),

        .immediate_out(id_ex_immediate),

        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),

        .alu_op_out(id_ex_alu_op),
        .memory_op_out(id_ex_memory_op),
        .branch_type_out(id_ex_branch_type),

        .register_write_enable_out(id_ex_register_write_enable),
        .alu_mux_select_out(id_ex_alu_mux_select),
        .pc_mux_select_out(id_ex_pc_mux_select),
        .writeback_select_out(id_ex_writeback_select)
    );


    // ============================================================
    // EX STAGE
    // ============================================================


    // ============================================================
    // EX/MEM SIGNALS
    // ============================================================

    logic [31:0] ex_mem_alu_result;
    logic [31:0] ex_mem_register_value_2;

    logic [4:0] ex_mem_rd;

    logic [3:0] ex_mem_memory_op;
    logic ex_mem_register_write_enable;
    logic [1:0] ex_mem_writeback_select;


    // ============================================================
    // MEM/WB SIGNALS
    // ============================================================

    logic [31:0] mem_wb_alu_result;
    logic [31:0] mem_wb_memory_data;

    logic [1:0] mem_wb_writeback_select;


    // ============================================================
    // FORWARDING CONTROL
    // ============================================================

    logic [1:0] forward_a;
    logic [1:0] forward_b;


    forwarding_unit cpu_forwarding_unit(
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),

        .ex_mem_rd(ex_mem_rd),
        .ex_mem_register_write_enable(
            ex_mem_register_write_enable
        ),

        .mem_wb_rd(mem_wb_rd),
        .mem_wb_register_write_enable(
            mem_wb_register_write_enable
        ),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );


    // ============================================================
    // FORWARDING MUX INPUTS
    // ============================================================

    logic [31:0] alu_a_forwarded;
    logic [31:0] alu_b_register_forwarded;


    // ============================================================
    // ALU A FORWARDING MUX
    // ============================================================

    forwarding_mux cpu_forwarding_mux_a(
        .register_value(id_ex_register_value_1),

        .ex_mem_value(ex_mem_alu_result),

        .mem_wb_value(writeback_write_data),

        .forward_select(forward_a),

        .selected_value(alu_a_forwarded)
    );


    // ============================================================
    // ALU B FORWARDING MUX
    // ============================================================

    forwarding_mux cpu_forwarding_mux_b(
        .register_value(id_ex_register_value_2),

        .ex_mem_value(ex_mem_alu_result),

        .mem_wb_value(writeback_write_data),

        .forward_select(forward_b),

        .selected_value(alu_b_register_forwarded)
    );


    // ============================================================
    // ALU B MUX
    // ============================================================

    logic [31:0] alu_b;
    logic [31:0] alu_result;


    alu_mux cpu_alu_mux(
        .rs2_value(alu_b_register_forwarded),

        .immediate(id_ex_immediate),

        .select(id_ex_alu_mux_select),

        .alu_b(alu_b)
    );


    // ============================================================
    // ALU
    // ============================================================

    alu cpu_alu(
        .a(alu_a_forwarded),

        .b(alu_b),

        .op(id_ex_alu_op),

        .result(alu_result)
    );


    // ============================================================
    // PC CALCULATOR
    // ============================================================

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;


    pc_calculator cpu_pc_calculator(
        .current_pc(id_ex_pc),

        .immediate(id_ex_immediate),

        .rs1_value(alu_a_forwarded),

        .pc_plus_4(pc_plus_4),

        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target)
    );


    // ============================================================
    // BRANCH DECISION
    // ============================================================

    logic branch_taken;


    branch_decision cpu_branch_decision(
        .alu_result(alu_result),

        .branch_type(id_ex_branch_type),

        .branch_taken(branch_taken)
    );


    // ============================================================
    // BRANCH MUX
    // ============================================================

    logic [31:0] branch_next_pc;


    branch_mux cpu_branch_mux(
        .pc_plus_4(pc_plus_4),

        .branch_target(branch_target),

        .branch_taken(branch_taken),

        .next_pc(branch_next_pc)
    );


    // ============================================================
    // PC MUX
    // ============================================================

    pc_mux cpu_pc_mux(
        .pc_plus_4(pc_plus_4),

        .branch_target(branch_next_pc),

        .jal_target(jal_target),

        .jalr_target(jalr_target),

        .next_pc(next_pc),

        .select(id_ex_pc_mux_select)
    );


    // ============================================================
    // EX/MEM PIPELINE REGISTER
    // ============================================================

    ex_mem_register cpu_ex_mem(
        .clk(clk),
        .reset(reset),

        .alu_result_in(alu_result),

        .register_value_2_in(id_ex_register_value_2),

        .rd_in(id_ex_rd),

        .memory_op_in(id_ex_memory_op),

        .register_write_enable_in(
            id_ex_register_write_enable
        ),

        .writeback_select_in(
            id_ex_writeback_select
        ),

        .alu_result_out(ex_mem_alu_result),

        .register_value_2_out(ex_mem_register_value_2),

        .rd_out(ex_mem_rd),

        .memory_op_out(ex_mem_memory_op),

        .register_write_enable_out(
            ex_mem_register_write_enable
        ),

        .writeback_select_out(
            ex_mem_writeback_select
        )
    );


    // ============================================================
    // MEM STAGE
    // ============================================================

    logic [31:0] data_memory_read;


    memory data_memory(
        .reset(reset),

        .clk(clk),

        .address(ex_mem_alu_result),

        .data_write(ex_mem_register_value_2),

        .memory_op(ex_mem_memory_op),

        .memory_mux_select(1'b1),

        .read_data(data_memory_read),

        .init_memory(init_memory)
    );


    // ============================================================
    // MEM/WB PIPELINE REGISTER
    // ============================================================

    mem_wb_register cpu_mem_wb(
        .clk(clk),
        .reset(reset),

        .alu_result_in(ex_mem_alu_result),

        .memory_data_in(data_memory_read),

        .rd_in(ex_mem_rd),

        .register_write_enable_in(
            ex_mem_register_write_enable
        ),

        .writeback_select_in(
            ex_mem_writeback_select
        ),

        .alu_result_out(mem_wb_alu_result),

        .memory_data_out(mem_wb_memory_data),

        .rd_out(mem_wb_rd),

        .register_write_enable_out(
            mem_wb_register_write_enable
        ),

        .writeback_select_out(
            mem_wb_writeback_select
        )
    );


    // ============================================================
    // WB STAGE
    // ============================================================

    writeback_mux cpu_write_back_mux(
        .alu_result(mem_wb_alu_result),

        .memory_data(mem_wb_memory_data),

        .pc_plus_4(32'b0),

        .select(mem_wb_writeback_select),

        .write_data(writeback_write_data)
    );

endmodule