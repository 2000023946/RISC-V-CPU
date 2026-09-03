module ex_mem_register(
    input logic        clk,
    input logic        reset,

    // Data from EX stage
    input logic [31:0] alu_result_in,
    input logic [31:0] register_value_2_in,

    // Destination register
    input logic [4:0] rd_in,

    // Control signals
    input logic [3:0] memory_op_in,
    input logic       register_write_enable_in,
    input logic [1:0] writeback_select_in,

    // Outputs to MEM stage
    output logic [31:0] alu_result_out,
    output logic [31:0] register_value_2_out,

    output logic [4:0] rd_out,

    output logic [3:0] memory_op_out,
    output logic       register_write_enable_out,
    output logic [1:0] writeback_select_out
);

    always_ff @(posedge clk) begin

        if (reset) begin
            alu_result_out           <= 32'b0;
            register_value_2_out     <= 32'b0;

            rd_out                   <= 5'b0;

            memory_op_out            <= 4'b0;
            register_write_enable_out <= 1'b0;
            writeback_select_out     <= 2'b0;
        end

        else begin
            alu_result_out           <= alu_result_in;
            register_value_2_out     <= register_value_2_in;

            rd_out                   <= rd_in;

            memory_op_out            <= memory_op_in;
            register_write_enable_out <= register_write_enable_in;
            writeback_select_out     <= writeback_select_in;
        end

    end

endmodule