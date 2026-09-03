module if_id_register_tb;

    logic        clk;
    logic        reset;

    logic [31:0] pc_in;
    logic [31:0] instruction_in;

    logic [31:0] pc_out;
    logic [31:0] instruction_out;

    if_id_register dut(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    // Clock: 10 time units per cycle
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        pc_in = 32'b0;
        instruction_in = 32'b0;

        // Reset
        #10;

        reset = 0;

        // Instruction 1
        pc_in = 32'h00000000;
        instruction_in = 32'h00500093;

        #10;

        $display("PC = %h | Instruction = %h",
                 pc_out, instruction_out);

        // Instruction 2
        pc_in = 32'h00000004;
        instruction_in = 32'h00700113;

        #10;

        $display("PC = %h | Instruction = %h",
                 pc_out, instruction_out);

        // Instruction 3
        pc_in = 32'h00000008;
        instruction_in = 32'h002081B3;

        #10;

        $display("PC = %h | Instruction = %h",
                 pc_out, instruction_out);

        $finish;

//        Expected:
//PC = 00000000 | Instruction = 00500093
// PC = 00000004 | Instruction = 00700113
// PC = 00000008 | Instruction = 002081B3
    end

endmodule