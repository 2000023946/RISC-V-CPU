`timescale 1ns/1ps

module stall_unit_tb;

    logic [4:0] rs1;
    logic [4:0] rs2;

    logic [4:0] id_ex_rd;
    logic [3:0] id_ex_memory_op;

    logic stall;

    // Memory operation encodings
    localparam logic [3:0] LB       = 4'd0;
    localparam logic [3:0] LBU      = 4'd1;
    localparam logic [3:0] LH       = 4'd2;
    localparam logic [3:0] LHU      = 4'd3;
    localparam logic [3:0] LW       = 4'd4;
    localparam logic [3:0] SB       = 4'd5;
    localparam logic [3:0] SH       = 4'd6;
    localparam logic [3:0] SW       = 4'd7;
    localparam logic [3:0] MEM_NONE = 4'd8;

    stall_unit dut (
        .rs1(rs1),
        .rs2(rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_memory_op(id_ex_memory_op),
        .stall(stall)
    );

    task check_stall(
        input logic expected,
        input string test_name
    );
        #1;

        if (stall === expected)
            $display("PASS: %s | stall=%b", test_name, stall);
        else
            $display("FAIL: %s | expected stall=%b, got stall=%b",
                     test_name, expected, stall);
    endtask

    initial begin

        $display("========================================");
        $display("HAZARD DETECTION UNIT TEST");
        $display("========================================");

        // ----------------------------------------
        // TEST 1
        // LW x1, 0(x2)
        // ADD x3, x1, x4
        //
        // Load writes x1.
        // Next instruction uses x1 as rs1.
        // Should stall.
        // ----------------------------------------

        rs1 = 5'd1;
        rs2 = 5'd4;

        id_ex_rd = 5'd1;
        id_ex_memory_op = LW;

        check_stall(1'b1, "LW -> dependency through rs1");


        // ----------------------------------------
        // TEST 2
        // LW x5, 0(x2)
        // ADD x3, x4, x5
        //
        // Load writes x5.
        // Next instruction uses x5 as rs2.
        // Should stall.
        // ----------------------------------------

        rs1 = 5'd4;
        rs2 = 5'd5;

        id_ex_rd = 5'd5;
        id_ex_memory_op = LW;

        check_stall(1'b1, "LW -> dependency through rs2");


        // ----------------------------------------
        // TEST 3
        // LW x1, 0(x2)
        // ADD x3, x4, x5
        //
        // Load writes x1.
        // ADD doesn't use x1.
        // Should NOT stall.
        // ----------------------------------------

        rs1 = 5'd4;
        rs2 = 5'd5;

        id_ex_rd = 5'd1;
        id_ex_memory_op = LW;

        check_stall(1'b0, "LW -> no dependency");


        // ----------------------------------------
        // TEST 4
        // ADD x1, x2, x3
        // ADD x4, x1, x5
        //
        // There is a RAW dependency,
        // but the older instruction is NOT a load.
        //
        // Forwarding handles this.
        // Stall should NOT happen.
        // ----------------------------------------

        rs1 = 5'd1;
        rs2 = 5'd5;

        id_ex_rd = 5'd1;
        id_ex_memory_op = MEM_NONE;

        check_stall(1'b0, "ALU dependency -> forwarding, no stall");


        // ----------------------------------------
        // TEST 5
        // LW x0, 0(x2)
        // ADD x3, x0, x4
        //
        // x0 is always zero.
        // A load writing x0 cannot create a real dependency.
        // Should NOT stall.
        // ----------------------------------------

        rs1 = 5'd0;
        rs2 = 5'd4;

        id_ex_rd = 5'd0;
        id_ex_memory_op = LW;

        check_stall(1'b0, "LW -> x0, no stall");


        // ----------------------------------------
        // TEST 6
        // LB x1, 0(x2)
        // ADD x3, x1, x4
        //
        // Test another load type.
        // Should stall.
        // ----------------------------------------

        rs1 = 5'd1;
        rs2 = 5'd4;

        id_ex_rd = 5'd1;
        id_ex_memory_op = LB;

        check_stall(1'b1, "LB -> dependency");


        // ----------------------------------------
        // TEST 7
        // LH x1, 0(x2)
        // ADD x3, x1, x4
        //
        // Should stall.
        // ----------------------------------------

        rs1 = 5'd1;
        rs2 = 5'd4;

        id_ex_rd = 5'd1;
        id_ex_memory_op = LH;

        check_stall(1'b1, "LH -> dependency");


        $display("========================================");
        $display("STALL UNIT TEST COMPLETE");
        $display("========================================");

        $finish;
    end

endmodule