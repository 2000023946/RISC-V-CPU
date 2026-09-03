module program_counter(
    input logic clk,
    input logic reset,
    input logic stall,

    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin

        if (reset)
            pc <= 32'b0;

        else if (!stall)
            pc <= next_pc;

        // If stall = 1, hold the current PC

    end

endmodule