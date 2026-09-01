
module program_counter_tb;

    logic clk;
    logic reset;
    logic [31:0] next_pc;
    logic [31:0] pc;


    // ============================================================
    // DUT
    // ============================================================

    program_counter dut(
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    // ============================================================
    // TESTS
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial values
        // --------------------------------------------------------

        reset = 1;
        next_pc = 32'b0;


        // --------------------------------------------------------
        // TEST 1: RESET
        // --------------------------------------------------------

        #2;

        if (pc == 32'b0)
            $display("RESET test PASSED");
        else
            $display("RESET test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // TEST 2: Reset is applied on clock edge
        // --------------------------------------------------------

        #8;

        if (pc == 32'b0)
            $display("RESET CLOCK test PASSED");
        else
            $display("RESET CLOCK test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // Release reset
        // --------------------------------------------------------

        reset = 0;


        // --------------------------------------------------------
        // TEST 3: PC updates to next_pc
        // --------------------------------------------------------

        next_pc = 32'h00000004;

        #10;

        if (pc == 32'h00000004)
            $display("PC = 4 test PASSED");
        else
            $display("PC = 4 test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // TEST 4: PC updates again
        // --------------------------------------------------------

        next_pc = 32'h00000008;

        #10;

        if (pc == 32'h00000008)
            $display("PC = 8 test PASSED");
        else
            $display("PC = 8 test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // TEST 5: PC updates to arbitrary address
        // --------------------------------------------------------

        next_pc = 32'h00000100;

        #10;

        if (pc == 32'h00000100)
            $display("PC = 0x100 test PASSED");
        else
            $display("PC = 0x100 test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // TEST 6: PC can hold a large address
        // --------------------------------------------------------

        next_pc = 32'hFFFF0000;

        #10;

        if (pc == 32'hFFFF0000)
            $display("PC large address test PASSED");
        else
            $display("PC large address test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // TEST 7: Reset PC back to zero
        // --------------------------------------------------------

        reset = 1;

        #10;

        if (pc == 32'b0)
            $display("RESET AGAIN test PASSED");
        else
            $display("RESET AGAIN test FAILED: pc = %h", pc);


        // --------------------------------------------------------
        // Finish
        // --------------------------------------------------------

        $display("--------------------------------");
        $display("ALL PROGRAM COUNTER TESTS COMPLETE");
        $display("--------------------------------");

        $finish;

    end

endmodule

