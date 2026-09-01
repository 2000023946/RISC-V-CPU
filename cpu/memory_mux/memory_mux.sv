module memory_mux(
    input logic [31:0] pc,
    input logic [31:0] alu_result,
    input logic select,
    output logic [31:0] memory_address
);

    always_comb begin
        case (select)
            1'b0: memory_address = pc;
            1'b1: memory_address = alu_result;
            default: memory_address = 32'b0;
        endcase
    end

endmodule