module alu_mux(
    input logic [31:0] rs2_value,
    input logic [31:0] immediate,
    input logic select,
    output logic [31:0] alu_b
);

    always_comb begin
        case (select)
            1'b0: alu_b = rs2_value;
            1'b1: alu_b = immediate;
            default: alu_b = 32'b0;
        endcase
    end

endmodule