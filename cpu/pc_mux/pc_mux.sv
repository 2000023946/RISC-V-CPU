module pc_mux(
    input  logic [31:0] pc_plus_4,
    input  logic [31:0] branch_target,
    input  logic [31:0] jal_target,
    input  logic [31:0] jalr_target,
    input  logic [1:0]  select,
    output logic [31:0] next_pc
);

    always_comb begin
        case (select)
            2'b00: next_pc = pc_plus_4;
            2'b01: next_pc = branch_target;
            2'b10: next_pc = jal_target;
            2'b11: next_pc = jalr_target;
            default: next_pc = pc_plus_4;
        endcase
    end

endmodule