
module pc_calculator_tb;

    logic [31:0] current_pc;
    logic [31:0] immediate;
    logic [31:0] rs1_value;

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;

    pc_calculator dut(
        .current_pc(current_pc),
        .immediate(immediate),
        .rs1_value(rs1_value),

        .pc_plus_4(pc_plus_4),
        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target)
    );

    initial begin

        // Test 1
        current_pc = 32'd100;
        immediate = 32'd20;
        rs1_value = 32'd200;

        #10;

        $display("Test 1:");
        $display("PC+4        = %0d", pc_plus_4);
        $display("Branch target = %0d", branch_target);
        $display("JAL target    = %0d", jal_target);
        $display("JALR target   = %0d", jalr_target);

        assert(pc_plus_4 == 104);
        assert(branch_target == 120);
        assert(jal_target == 120);
        assert(jalr_target == 220);


        // Test 2: negative immediate
        current_pc = 32'd100;
        immediate = -32'd20;
        rs1_value = 32'd200;

        #10;

        $display("Test 2:");
        $display("PC+4        = %0d", pc_plus_4);
        $display("Branch target = %0d", branch_target);
        $display("JAL target    = %0d", jal_target);
        $display("JALR target   = %0d", jalr_target);

        assert(pc_plus_4 == 80 + 24);
        assert(branch_target == 80);
        assert(jal_target == 80);
        assert(jalr_target == 180);


        // Test 3: JALR odd address should clear bit 0
        current_pc = 32'd100;
        immediate = 32'd20;
        rs1_value = 32'd201;

        #10;

        $display("Test 3:");
        $display("JALR target   = %0d", jalr_target);

        assert(jalr_target == 220);


        $display("All tests passed!");
        $finish;

    end

endmodule

