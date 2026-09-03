module flush_unit(
    input logic       branch_taken,
    input logic [1:0] pc_mux_select,

    output logic      flush
);

    localparam logic [1:0] PC_PLUS_4 = 2'b00;
    localparam logic [1:0] PC_BRANCH = 2'b01;
    localparam logic [1:0] PC_JAL    = 2'b10;
    localparam logic [1:0] PC_JALR   = 2'b11;

    always_comb begin

        flush = 1'b0;

        // Taken conditional branch
        if ((pc_mux_select == PC_BRANCH) && branch_taken) begin
            flush = 1'b1;
        end

        // JAL is always taken
        else if (pc_mux_select == PC_JAL) begin
            flush = 1'b1;
        end

        // JALR is always taken
        else if (pc_mux_select == PC_JALR) begin
            flush = 1'b1;
        end

    end

endmodule