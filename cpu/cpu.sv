module cpu(
    input logic reset,
    input logic clk,
    input logic [31:0] init_memory [0:255]
);

    // ============================================================
    // PC
    // ============================================================

    logic [31:0] current_pc;
    logic [31:0] next_pc;

    program_counter cpu_pc(
        .reset(reset),
        .clk(clk),
        .next_pc(next_pc),
        .pc(current_pc)
    );


    // ============================================================
    // INSTRUCTION MEMORY
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
    // DECODER
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

    decoder cpu_decoder(
        .instruction(instruction),
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
        .instruction(instruction),
        .immediate(immediate)
    );


    // ============================================================
    // REGISTER FILE
    // ============================================================

    logic [31:0] register_value_1;
    logic [31:0] register_value_2;
    logic [31:0] writeback_write_data;

    register_file cpu_register_file(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .read_data_1(register_value_1),
        .read_data_2(register_value_2),
        .write_data(writeback_write_data),
        .write_enable(register_write_enable)
    );


    // ============================================================
    // ALU MUX
    // ============================================================

    logic [31:0] alu_b;

    alu_mux cpu_alu_mux(
        .rs2_value(register_value_2),
        .immediate(immediate),
        .select(alu_mux_select),
        .alu_b(alu_b)
    );


    // ============================================================
    // ALU
    // ============================================================

    logic [31:0] alu_result;

    alu cpu_alu(
        .a(register_value_1),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result)
    );


    // ============================================================
    // DATA MEMORY
    // ============================================================

    logic [31:0] data_memory_read;

    memory data_memory(
        .reset(reset),
        .clk(clk),
        .address(alu_result),
        .data_write(register_value_2),
        .memory_op(memory_op),
        .memory_mux_select(1'b1),
        .read_data(data_memory_read),
        .init_memory(init_memory)
    );


    // ============================================================
    // PC CALCULATOR
    // ============================================================

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;

    pc_calculator cpu_pc_calculator(
        .current_pc(current_pc),
        .immediate(immediate),
        .rs1_value(register_value_1),
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
        .branch_type(branch_type),
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
        .select(pc_mux_select)
    );


    // ============================================================
    // WRITEBACK
    // ============================================================

    writeback_mux cpu_write_back_mux(
        .alu_result(alu_result),
        .memory_data(data_memory_read),
        .pc_plus_4(pc_plus_4),
        .select(writeback_select),
        .write_data(writeback_write_data)
    );

endmodule