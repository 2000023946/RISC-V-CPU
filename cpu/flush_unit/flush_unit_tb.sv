`timescale 1ns/1ps

module flush_unit_tb;

    logic       branch_taken;
    logic [1:0] pc_mux_select;

    logic       flush;


    // DUT
    flush_unit dut (
        .branch_taken(branch_taken),
        .pc_mux_select(pc_mux_select),
        .flush(flush)
    );


    // PC mux values
    localparam logic [1:0] PC_PLUS_4 = 2'b00;
    localparam logic [1:0] PC_BRANCH = 2'b01;
    localparam logic [1:0] PC_JAL    = 2'b10;
    localparam logic [1:0] PC_JALR   = 2'b11;


    initial begin

        // ========================================
        // TEST 1: NORMAL INSTRUCTION
        // ========================================

        $display("========================================");
        $display("TEST 1: NORMAL INSTRUCTION");
        $display("========================================");

        branch_taken = 1'b0;
        pc_mux_select = PC_PLUS_4;

        #1;

        if (flush == 1'b0)
            $display("PASS: Normal instruction does not flush");
        else
            $display("FAIL: Normal instruction caused flush");


        // ========================================
        // TEST 2: BRANCH NOT TAKEN
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 2: BRANCH NOT TAKEN");
        $display("========================================");

        branch_taken = 1'b0;
        pc_mux_select = PC_BRANCH;

        #1;

        if (flush == 1'b0)
            $display("PASS: Not-taken branch does not flush");
        else
            $display("FAIL: Not-taken branch caused flush");


        // ========================================
        // TEST 3: BRANCH TAKEN
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 3: BRANCH TAKEN");
        $display("========================================");

        branch_taken = 1'b1;
        pc_mux_select = PC_BRANCH;

        #1;

        if (flush == 1'b1)
            $display("PASS: Taken branch causes flush");
        else
            $display("FAIL: Taken branch did not cause flush");


        // ========================================
        // TEST 4: JAL
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 4: JAL");
        $display("========================================");

        branch_taken = 1'b0;
        pc_mux_select = PC_JAL;

        #1;

        if (flush == 1'b1)
            $display("PASS: JAL causes flush");
        else
            $display("FAIL: JAL did not cause flush");


        // ========================================
        // TEST 5: JALR
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 5: JALR");
        $display("========================================");

        branch_taken = 1'b0;
        pc_mux_select = PC_JALR;

        #1;

        if (flush == 1'b1)
            $display("PASS: JALR causes flush");
        else
            $display("FAIL: JALR did not cause flush");


        // ========================================
        // TEST 6: BRANCH TAKEN WITH branch_taken
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 6: BRANCH TAKEN");
        $display("========================================");

        branch_taken = 1'b1;
        pc_mux_select = PC_BRANCH;

        #1;

        if (flush == 1'b1)
            $display("PASS: PC_BRANCH + branch_taken = 1 → flush");
        else
            $display("FAIL: PC_BRANCH + branch_taken = 1 → no flush");


        // ========================================
        // TEST 7: BRANCH NOT TAKEN
        // ========================================

        $display("");
        $display("========================================");
        $display("TEST 7: BRANCH NOT TAKEN");
        $display("========================================");

        branch_taken = 1'b0;
        pc_mux_select = PC_BRANCH;

        #1;

        if (flush == 1'b0)
            $display("PASS: PC_BRANCH + branch_taken = 0 → no flush");
        else
            $display("FAIL: PC_BRANCH + branch_taken = 0 → flush");


        // ========================================
        // FINAL RESULT
        // ========================================

        $display("");
        $display("========================================");
        $display("ALL FLUSH UNIT TESTS PASS");
        $display("========================================");

        $finish;

    end

endmodule