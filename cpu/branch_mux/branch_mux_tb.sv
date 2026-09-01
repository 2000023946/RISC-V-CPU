
module branch_mux_tb;

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic branch_taken;

    logic [31:0] next_pc;

    branch_mux dut(
        .pc_plus_4(pc_plus_4),
        .branch_target(branch_target),
        .branch_taken(branch_taken),
        .next_pc(next_pc)
    );

    initial begin

        // Test 1: Branch NOT taken
        pc_plus_4 = 32'd104;
        branch_target = 32'd120;
        branch_taken = 1'b0;

        #10;

        $display("Test 1: Branch NOT taken");
        $display("next_pc = %0d", next_pc);

        assert(next_pc == 104);


        // Test 2: Branch TAKEN
        pc_plus_4 = 32'd104;
        branch_target = 32'd120;
        branch_taken = 1'b1;

        #10;

        $display("Test 2: Branch TAKEN");
        $display("next_pc = %0d", next_pc);

        assert(next_pc == 120);


        // Test 3: Different addresses, branch not taken
        pc_plus_4 = 32'd204;
        branch_target = 32'd180;
        branch_taken = 1'b0;

        #10;

        $display("Test 3: Branch NOT taken");
        $display("next_pc = %0d", next_pc);

        assert(next_pc == 204);


        // Test 4: Different addresses, branch taken
        pc_plus_4 = 32'd204;
        branch_target = 32'd180;
        branch_taken = 1'b1;

        #10;

        $display("Test 4: Branch TAKEN");
        $display("next_pc = %0d", next_pc);

        assert(next_pc == 180);


        $display("All branch mux tests passed!");

        $finish;

    end

endmodule

