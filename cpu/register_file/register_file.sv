
module register_file(
    input logic clk,

    input logic [4:0] rs1,
    input logic [4:0] rs2,

    input logic [4:0] rd,
    input logic [31:0] write_data,
    input logic write_enable,

    output logic [31:0] read_data_1,
    output logic [31:0] read_data_2
);

    // ============================================================
    // REGISTER FILE
    // ============================================================
    // 32 registers, each 32 bits wide.
    //
    // x0 must ALWAYS be zero.
    // ============================================================

    logic [31:0] registers [0:31];


    // ============================================================
    // INITIALIZE REGISTER FILE
    // ============================================================

    initial begin

        for (int i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;

    end


    // ============================================================
    // COMBINATIONAL READ
    // ============================================================
    //
    // Normally:
    //
    //     rs1 -> registers[rs1]
    //     rs2 -> registers[rs2]
    //
    // But if the register file is being written and the
    // instruction is simultaneously reading that same register,
    // forward the new write_data directly.
    //
    // This prevents a read-after-write timing problem.
    // ============================================================

    always_comb begin

        // -------------------------
        // Read port 1
        // -------------------------

        if (rs1 == 5'b0) begin
            read_data_1 = 32'b0;
        end
        else if (write_enable && (rd == rs1)) begin
            read_data_1 = write_data;
        end
        else begin
            read_data_1 = registers[rs1];
        end


        // -------------------------
        // Read port 2
        // -------------------------

        if (rs2 == 5'b0) begin
            read_data_2 = 32'b0;
        end
        else if (write_enable && (rd == rs2)) begin
            read_data_2 = write_data;
        end
        else begin
            read_data_2 = registers[rs2];
        end

    end


    // ============================================================
    // SEQUENTIAL WRITE
    // ============================================================

    always_ff @(posedge clk) begin

        if (write_enable) begin

            // x0 cannot be written.

            if (rd != 5'b0)
                registers[rd] <= write_data;

        end

        // Keep x0 permanently zero.
        registers[0] <= 32'b0;

    end

endmodule

