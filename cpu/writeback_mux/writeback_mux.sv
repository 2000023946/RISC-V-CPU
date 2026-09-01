module writeback_mux(
    input logic [31:0] alu_result,
    input logic [31:0] memory_data,
    input logic [31:0] pc_plus_4,

    input logic [1:0] select,

    output logic [31:0] write_data
);

    localparam logic [1:0] ALU    = 2'b00;
    localparam logic [1:0] MEMORY = 2'b01;
    localparam logic [1:0] PC_4   = 2'b10;

    always_comb begin
        case (select)
            ALU:    write_data = alu_result;
            MEMORY: write_data = memory_data;
            PC_4:   write_data = pc_plus_4;
            default: write_data = 32'b0;
        endcase
    end

endmodule