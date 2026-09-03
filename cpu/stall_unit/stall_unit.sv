module stall_unit(
    // Current instruction in ID
    input logic [4:0] rs1,
    input logic [4:0] rs2,

    // Older instruction currently in EX
    input logic [4:0] id_ex_rd,
    input logic [3:0] id_ex_memory_op,

    output logic stall
);

    // Memory operation encoding
    localparam logic [3:0] LB  = 4'd0;
    localparam logic [3:0] LBU = 4'd1;
    localparam logic [3:0] LH  = 4'd2;
    localparam logic [3:0] LHU = 4'd3;
    localparam logic [3:0] LW  = 4'd4;

    always_comb begin
        stall = 1'b0;

        // Is the instruction in ID/EX a load?
        if ((id_ex_memory_op == LB)  ||
            (id_ex_memory_op == LBU) ||
            (id_ex_memory_op == LH)  ||
            (id_ex_memory_op == LHU) ||
            (id_ex_memory_op == LW)) begin

            // Does the instruction in ID need
            // the register that the load will produce?
            if ((id_ex_rd != 5'b00000) &&
                ((id_ex_rd == rs1) ||
                 (id_ex_rd == rs2))) begin

                stall = 1'b1;
            end
        end
    end

endmodule