module if_id_register(
    input logic        clk,
    input logic        reset,

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
        else begin
            pc_out          <= pc_in;
            instruction_out <= instruction_in;
        end
    end

endmodule