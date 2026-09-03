module if_id_register(
    input logic        clk,
    input logic        reset,
    input logic        stall,
    input logic        flush,

    input logic [31:0] pc_in,
    input logic [31:0] instruction_in,

    output logic [31:0] pc_out,
    output logic [31:0] instruction_out
);

    always_ff @(posedge clk) begin

        if (reset) begin
            pc_out          <= 32'b0;
            instruction_out <= 32'b0;
        end

        else if (flush) begin
            // Flush wrong-path instruction
            pc_out          <= 32'b0;
            instruction_out <= 32'h00000013; // RISC-V NOP
        end

        else if (!stall) begin
            pc_out          <= pc_in;
            instruction_out <= instruction_in;
        end

        // stall = 1 → hold current IF/ID values

    end

endmodule