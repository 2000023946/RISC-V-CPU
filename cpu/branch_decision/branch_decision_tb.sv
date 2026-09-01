
module branch_decision_tb;

    logic [31:0] alu_result;
    logic [2:0] branch_type;
    logic branch_taken;

    branch_decision dut(
        .alu_result(alu_result),
        .branch_type(branch_type),
        .branch_taken(branch_taken)
    );

    initial begin

        // Test 1: BEQ, ALU result = 0 -> TAKEN
        alu_result = 32'd0;
        branch_type = 3'b000;

        #10;

        $display("Test 1: BEQ taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        // Test 2: BEQ, ALU result != 0 -> NOT TAKEN
        alu_result = 32'd5;
        branch_type = 3'b000;

        #10;

        $display("Test 2: BEQ not taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b0);


        // Test 3: BNE, ALU result != 0 -> TAKEN
        alu_result = 32'd5;
        branch_type = 3'b001;

        #10;

        $display("Test 3: BNE taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        // Test 4: BNE, ALU result = 0 -> NOT TAKEN
        alu_result = 32'd0;
        branch_type = 3'b001;

        #10;

        $display("Test 4: BNE not taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b0);


        // Test 5: BLT, ALU result = 1 -> TAKEN
        alu_result = 32'd1;
        branch_type = 3'b100;

        #10;

        $display("Test 5: BLT taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        // Test 6: BGE, ALU result = 0 -> TAKEN
        alu_result = 32'd0;
        branch_type = 3'b101;

        #10;

        $display("Test 6: BGE taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        // Test 7: BLTU, ALU result = 1 -> TAKEN
        alu_result = 32'd1;
        branch_type = 3'b110;

        #10;

        $display("Test 7: BLTU taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        // Test 8: BGEU, ALU result = 0 -> TAKEN
        alu_result = 32'd0;
        branch_type = 3'b111;

        #10;

        $display("Test 8: BGEU taken");
        $display("branch_taken = %0d", branch_taken);

        assert(branch_taken == 1'b1);


        $display("All branch decision tests passed!");

        $finish;

    end

endmodule
