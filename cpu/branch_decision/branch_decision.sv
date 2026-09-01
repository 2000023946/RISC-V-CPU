
module branch_decision(
    input logic [31:0] alu_result,
    input logic [2:0] branch_type,
    output logic branch_taken
);

    always_comb begin

        case (branch_type)

            // BEQ
            3'b000:
                branch_taken = (alu_result == 32'b0);

            // BNE
            3'b001:
                branch_taken = (alu_result != 32'b0);

            // BLT
            3'b100:
                branch_taken = (alu_result == 32'd1);

            // BGE
            3'b101:
                branch_taken = (alu_result == 32'b0);

            // BLTU
            3'b110:
                branch_taken = (alu_result == 32'd1);

            // BGEU
            3'b111:
                branch_taken = (alu_result == 32'b0);

            default:
                branch_taken = 1'b0;

        endcase

    end

endmodule

