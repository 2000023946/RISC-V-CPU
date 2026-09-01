module pc_calculator(
    input logic [31:0] current_pc,
    input logic [31:0] immediate,
    input logic [31:0] rs1_value,

    output logic [31:0] pc_plus_4,
    output logic [31:0] branch_target,
    output logic [31:0] jal_target,
    output logic [31:0] jalr_target
);

    assign pc_plus_4    = current_pc + 32'd4;
    assign branch_target = current_pc + immediate;
    assign jal_target    = current_pc + immediate;
    assign jalr_target   = (rs1_value + immediate) & 32'hFFFFFFFE;

endmodule