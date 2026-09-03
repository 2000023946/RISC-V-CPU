`timescale 1ns/1ps

module if_id_register_tb;

    logic        clk;
    logic        reset;
    logic        stall;

    logic [31:0] pc_in;
    logic [31:0] instruction_in;

    logic [31:0] pc_out;
    logic [31:0] instruction_out;

    // DUT
    if_id_register dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_in(pc_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin

        $display("========================================");
        $display("IF/ID REGISTER STALL TEST");
        $display("========================================");

        // Initial values
        clk = 0;
        reset = 1;
        stall = 0;
        pc_in = 32'b0;
        instruction_in = 32'b0;

        // ------------------------------------------------
        // TEST 1: Reset
        // ------------------------------------------------

        #10;

        if (pc_out != 32'b0 || instruction_out != 32'b0) begin
            $display("FAIL: Reset did not clear IF/ID register");
            $display("PC OUT:          %h", pc_out);
            $display("INSTRUCTION OUT: %h", instruction_out);
            $finish;
        end

        $display("PASS: Reset clears IF/ID register");


        // ------------------------------------------------
        // TEST 2: Normal capture
        // ------------------------------------------------

        reset = 0;
        stall = 0;

        pc_in = 32'h00000004;
        instruction_in = 32'h00500093;

        #10;

        if (pc_out != 32'h00000004 ||
            instruction_out != 32'h00500093) begin

            $display("FAIL: IF/ID did not capture inputs");
            $display("Expected PC:          00000004");
            $display("Actual PC:            %h", pc_out);
            $display("Expected Instruction: 00500093");
            $display("Actual Instruction:   %h", instruction_out);
            $finish;
        end

        $display("PASS: IF/ID captures new instruction");


        // ------------------------------------------------
        // TEST 3: Stall holds current values
        // ------------------------------------------------

        stall = 1;

        // New instruction coming from IF
        pc_in = 32'h00000008;
        instruction_in = 32'h00700113;

        #10;

        if (pc_out != 32'h00000004 ||
            instruction_out != 32'h00500093) begin

            $display("FAIL: IF/ID changed during stall");
            $display("Expected PC:          00000004");
            $display("Actual PC:            %h", pc_out);
            $display("Expected Instruction: 00500093");
            $display("Actual Instruction:   %h", instruction_out);
            $finish;
        end

        $display("PASS: IF/ID holds values during stall");


        // ------------------------------------------------
        // TEST 4: Release stall
        // ------------------------------------------------

        stall = 0;

        #10;

        if (pc_out != 32'h00000008 ||
            instruction_out != 32'h00700113) begin

            $display("FAIL: IF/ID did not update after stall");
            $display("Expected PC:          00000008");
            $display("Actual PC:            %h", pc_out);
            $display("Expected Instruction: 00700113");
            $display("Actual Instruction:   %h", instruction_out);
            $finish;
        end

        $display("PASS: IF/ID updates after stall");


        // ------------------------------------------------
        // TEST 5: Stall again
        // ------------------------------------------------

        stall = 1;

        pc_in = 32'h0000000C;
        instruction_in = 32'h00A00193;

        #10;

        if (pc_out != 32'h00000008 ||
            instruction_out != 32'h00700113) begin

            $display("FAIL: IF/ID changed during second stall");
            $display("Expected PC:          00000008");
            $display("Actual PC:            %h", pc_out);
            $display("Expected Instruction: 00700113");
            $display("Actual Instruction:   %h", instruction_out);
            $finish;
        end

        $display("PASS: IF/ID holds values during second stall");


        // ------------------------------------------------
        // DONE
        // ------------------------------------------------

        $display("");
        $display("========================================");
        $display("ALL IF/ID STALL TESTS PASS");
        $display("========================================");

        $finish;

    end

endmodule