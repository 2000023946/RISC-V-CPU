module forwarding_unit_tb;

    logic [4:0] id_ex_rs1;
    logic [4:0] id_ex_rs2;

    logic [4:0] ex_mem_rd;
    logic       ex_mem_register_write_enable;

    logic [4:0] mem_wb_rd;
    logic       mem_wb_register_write_enable;

    logic [1:0] forward_a;
    logic [1:0] forward_b;


    forwarding_unit dut(
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),

        .ex_mem_rd(ex_mem_rd),
        .ex_mem_register_write_enable(ex_mem_register_write_enable),

        .mem_wb_rd(mem_wb_rd),
        .mem_wb_register_write_enable(mem_wb_register_write_enable),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );


    initial begin

        $display("========================================");
        $display("FORWARDING UNIT TEST");
        $display("========================================");


        // ========================================================
        // TEST 1
        // No hazards
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd3;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd4;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b00 && forward_b == 2'b00)
            $display("TEST 1 PASS: No forwarding");
        else
            $display("TEST 1 FAIL");


        // ========================================================
        // TEST 2
        // EX/MEM hazard on rs1
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd1;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd4;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b10 && forward_b == 2'b00)
            $display("TEST 2 PASS: EX/MEM forwarding to A");
        else
            $display("TEST 2 FAIL");


        // ========================================================
        // TEST 3
        // EX/MEM hazard on rs2
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd2;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd4;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b00 && forward_b == 2'b10)
            $display("TEST 3 PASS: EX/MEM forwarding to B");
        else
            $display("TEST 3 FAIL");


        // ========================================================
        // TEST 4
        // MEM/WB hazard on rs1
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd3;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd1;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b01 && forward_b == 2'b00)
            $display("TEST 4 PASS: MEM/WB forwarding to A");
        else
            $display("TEST 4 FAIL");


        // ========================================================
        // TEST 5
        // Both operands forwarded
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd1;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd2;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b10 && forward_b == 2'b01)
            $display("TEST 5 PASS: Both operands forwarded");
        else
            $display("TEST 5 FAIL");


        // ========================================================
        // TEST 6
        // EX/MEM takes priority over MEM/WB
        // ========================================================

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;

        ex_mem_rd = 5'd1;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd1;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b10)
            $display("TEST 6 PASS: EX/MEM has priority");
        else
            $display("TEST 6 FAIL");


        // ========================================================
        // TEST 7
        // x0 should never be forwarded
        // ========================================================

        id_ex_rs1 = 5'd0;
        id_ex_rs2 = 5'd0;

        ex_mem_rd = 5'd0;
        ex_mem_register_write_enable = 1'b1;

        mem_wb_rd = 5'd0;
        mem_wb_register_write_enable = 1'b1;

        #10;

        if (forward_a == 2'b00 && forward_b == 2'b00)
            $display("TEST 7 PASS: x0 is not forwarded");
        else
            $display("TEST 7 FAIL");


        $display("========================================");
        $display("FORWARDING UNIT TEST COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule