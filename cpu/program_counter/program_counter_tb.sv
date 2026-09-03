`timescale 1ns/1ps

module program_counter_tb;

    logic clk;
    logic reset;
    logic stall;

    logic [31:0] next_pc;
    logic [31:0] pc;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin

        $display("========================================");
        $display("PROGRAM COUNTER STALL TEST");
        $display("========================================");

        // Initial values
        clk     = 0;
        reset   = 1;
        stall   = 0;
        next_pc = 32'h00000004;

        // Reset
        #10;

        if (pc != 32'h00000000) begin
            $display("FAIL: Reset did not set PC to 0");
            $finish;
        end

        $display("PASS: Reset sets PC to 0");


        // ------------------------------------------------
        // TEST 1: Normal PC update
        // ------------------------------------------------

        reset   = 0;
        stall   = 0;
        next_pc = 32'h00000004;

        #10;

        if (pc != 32'h00000004) begin
            $display("FAIL: PC did not update normally");
            $display("Expected: 00000004");
            $display("Actual:   %h", pc);
            $finish;
        end

        $display("PASS: PC updates normally");


        // ------------------------------------------------
        // TEST 2: Another normal update
        // ------------------------------------------------

        next_pc = 32'h00000008;

        #10;

        if (pc != 32'h00000008) begin
            $display("FAIL: PC did not update to 8");
            $display("Expected: 00000008");
            $display("Actual:   %h", pc);
            $finish;
        end

        $display("PASS: PC updated to 8");


        // ------------------------------------------------
        // TEST 3: Stall
        // ------------------------------------------------

        stall   = 1;
        next_pc = 32'h0000000C;

        #10;

        if (pc != 32'h00000008) begin
            $display("FAIL: PC changed during stall");
            $display("Expected: 00000008");
            $display("Actual:   %h", pc);
            $finish;
        end

        $display("PASS: PC holds during stall");


        // ------------------------------------------------
        // TEST 4: Release stall
        // ------------------------------------------------

        stall   = 0;
        next_pc = 32'h0000000C;

        #10;

        if (pc != 32'h0000000C) begin
            $display("FAIL: PC did not resume after stall");
            $display("Expected: 0000000C");
            $display("Actual:   %h", pc);
            $finish;
        end

        $display("PASS: PC resumes after stall");


        // ------------------------------------------------
        // TEST 5: Stall again
        // ------------------------------------------------

        stall   = 1;
        next_pc = 32'h00000010;

        #10;

        if (pc != 32'h0000000C) begin
            $display("FAIL: PC changed during second stall");
            $display("Expected: 0000000C");
            $display("Actual:   %h", pc);
            $finish;
        end

        $display("PASS: PC holds during second stall");


        // ------------------------------------------------
        // DONE
        // ------------------------------------------------

        $display("");
        $display("========================================");
        $display("ALL PROGRAM COUNTER STALL TESTS PASS");
        $display("========================================");

        $finish;

    end

endmodule