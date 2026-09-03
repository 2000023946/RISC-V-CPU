module id_ex_register(
    input logic        clk,
    input logic        reset,
    input logic        stall,

    // Data from ID stage
    input logic [31:0] pc_in,
    input logic [31:0] register_value_1_in,
    input logic [31:0] register_value_2_in,
    input logic [31:0] immediate_in,

    // Register numbers
    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,
    input logic [4:0] rd_in,

    // Control signals
    input logic [3:0] alu_op_in,
    input logic [3:0] memory_op_in,
    input logic [2:0] branch_type_in,

    input logic       register_write_enable_in,
    input logic       alu_mux_select_in,
    input logic [1:0] pc_mux_select_in,
    input logic [1:0] writeback_select_in,

    // Outputs to EX stage
    output logic [31:0] pc_out,
    output logic [31:0] register_value_1_out,
    output logic [31:0] register_value_2_out,
    output logic [31:0] immediate_out,

    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out,

    output logic [3:0] alu_op_out,
    output logic [3:0] memory_op_out,
    output logic [2:0] branch_type_out,

    output logic       register_write_enable_out,
    output logic       alu_mux_select_out,
    output logic [1:0] pc_mux_select_out,
    output logic [1:0] writeback_select_out
);

    // Memory operation encoding
    localparam logic [3:0] MEM_NONE = 4'd8;

    always_ff @(posedge clk) begin

        if (reset) begin

            pc_out                    <= 32'b0;
            register_value_1_out      <= 32'b0;
            register_value_2_out      <= 32'b0;
            immediate_out             <= 32'b0;

            rs1_out                   <= 5'b0;
            rs2_out                   <= 5'b0;
            rd_out                    <= 5'b0;

            alu_op_out                <= 4'b0;
            memory_op_out             <= MEM_NONE;
            branch_type_out           <= 3'b0;

            register_write_enable_out <= 1'b0;
            alu_mux_select_out        <= 1'b0;
            pc_mux_select_out         <= 2'b0;
            writeback_select_out      <= 2'b0;

        end

        else if (stall) begin

            // Insert a bubble into ID/EX

            pc_out                    <= 32'b0;
            register_value_1_out      <= 32'b0;
            register_value_2_out      <= 32'b0;
            immediate_out             <= 32'b0;

            rs1_out                   <= 5'b0;
            rs2_out                   <= 5'b0;
            rd_out                    <= 5'b0;

            alu_op_out                <= 4'b0;
            memory_op_out             <= MEM_NONE;
            branch_type_out           <= 3'b0;

            register_write_enable_out <= 1'b0;
            alu_mux_select_out        <= 1'b0;
            pc_mux_select_out         <= 2'b0;
            writeback_select_out      <= 2'b0;

        end

        else begin

            // Normal operation: capture ID stage

            pc_out                    <= pc_in;
            register_value_1_out      <= register_value_1_in;
            register_value_2_out      <= register_value_2_in;
            immediate_out             <= immediate_in;

            rs1_out                   <= rs1_in;
            rs2_out                   <= rs2_in;
            rd_out                    <= rd_in;

            alu_op_out                <= alu_op_in;
            memory_op_out             <= memory_op_in;
            branch_type_out           <= branch_type_in;

            register_write_enable_out <= register_write_enable_in;
            alu_mux_select_out        <= alu_mux_select_in;
            pc_mux_select_out         <= pc_mux_select_in;
            writeback_select_out      <= writeback_select_in;

        end

    end

endmodule