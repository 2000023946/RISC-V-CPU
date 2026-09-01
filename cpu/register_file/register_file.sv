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

    // init the 32 registers of 32-bit wide
    logic [31:0] registers [0:31];

    // Reading from the register is combinational

    initial begin
        registers[0] = 0;
    end

    always_comb begin
        read_data_1 = registers[rs1];
        read_data_2 = registers[rs2];
    end

    // writing requires sequential logic write on the clock edge
    always_ff @(posedge clk) begin
        if (write_enable == 1) begin 
            // account for the x0 register. must always be 0

            if (rd != 0) registers[rd] = write_data;
            else registers[0] = 0;
        end
    end
endmodule