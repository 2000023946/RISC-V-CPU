`timescale 1ns/1ps

module if_id_register_tb;

    logic        clk;
    logic        reset;
    logic        stall;
    logic        flush;

    logic [31:0] pc_in;
    logic [31:0] instruction_in;

    logic [31:0] pc_out;
    logic [31:0] instruction_out;


    // DUT
    if_id_register dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),

        .pc_in(pc_in),
        .instruction_in(instruction_in),

        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );


    // Clock: 10 ns period
    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 0;
        stall = 0;
        flush = 0;

        pc_in = 32'b0;
        instruction_in = 32'b0;


        // ========================================
        // TEST 1: RESET
        // ========================================

        $display("========================================");
        $display("TEST 1: RESET");
        $display("========================================");

        reset = 1;

        @(posedge clk);
        #1;

        if (pc_out == 32'b0 &&
            instruction_out == 32'b0) begin
            $display("PASS: Reset clears IF/ID register");
        end
        else begin
            $display("FAIL: Reset did not clear IF/ID register");
        end

        reset = 0;


        // ========================================
        // TEST 2: NORMAL OPERATION
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 2: NORMAL OPERATION");
        $display("========================================");

        pc_in = 32'h00000010;
        instruction_in = 32'h00500093; // ADDI x1, x0, 5

        @(posedge clk);
        #1;

        if (pc_out == 32'h00000010 &&
            instruction_out == 32'h00500093) begin
            $display("PASS: Instruction passed into IF/ID");
        end
        else begin
            $display("FAIL: Normal instruction transfer");
        end


        // ========================================
        // TEST 3: STALL
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 3: STALL");
        $display("========================================");

        // Change inputs to a different instruction.
        // Because stall = 1, IF/ID should NOT change.
        stall = 1;

        pc_in = 32'h00000014;
        instruction_in = 32'h00700113; // ADDI x2, x0, 7

        @(posedge clk);
        #1;

        if (pc_out == 32'h00000010 &&
            instruction_out == 32'h00500093) begin
            $display("PASS: Stall holds IF/ID register");
        end
        else begin
            $display("FAIL: Stall did not hold IF/ID register");
        end

        stall = 0;


        // ========================================
        // TEST 4: FLUSH
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 4: FLUSH");
        $display("========================================");

        flush = 1;

        // These inputs should be ignored because flush
        // replaces the current IF/ID contents with a NOP.
        pc_in = 32'h00000018;
        instruction_in = 32'h00A00193; // ADDI x3, x0, 10

        @(posedge clk);
        #1;

        if (instruction_out == 32'h00000013) begin
            $display("PASS: Flush inserts NOP bubble");
        end
        else begin
            $display("FAIL: Flush did not insert NOP");
        end

        flush = 0;


        // ========================================
        // TEST 5: NORMAL OPERATION AFTER FLUSH
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 5: NORMAL OPERATION AFTER FLUSH");
        $display("========================================");

        pc_in = 32'h0000001C;
        instruction_in = 32'h01E00213; // ADDI x4, x0, 30

        @(posedge clk);
        #1;

        if (pc_out == 32'h0000001C &&
            instruction_out == 32'h01E00213) begin
            $display("PASS: Normal operation resumes after flush");
        end
        else begin
            $display("FAIL: Normal operation after flush");
        end


        // ========================================
        // TEST 6: FLUSH PRIORITY OVER STALL
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 6: FLUSH PRIORITY OVER STALL");
        $display("========================================");

        stall = 1;
        flush = 1;

        pc_in = 32'h00000020;
        instruction_in = 32'h12345678;

        @(posedge clk);
        #1;

        if (instruction_out == 32'h00000013) begin
            $display("PASS: Flush has priority over stall");
        end
        else begin
            $display("FAIL: Flush priority over stall");
        end

        stall = 0;
        flush = 0;


        // ========================================
        // FINAL RESULT
        // ========================================

        $display("");
        $display("========================================");
        $display("ALL IF/ID FLUSH TESTS COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule