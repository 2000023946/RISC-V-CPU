`timescale 1ns/1ps

module id_ex_register_tb;

    logic        clk;
    logic        reset;
    logic        stall;

    logic [31:0] pc_in;
    logic [31:0] register_value_1_in;
    logic [31:0] register_value_2_in;
    logic [31:0] immediate_in;

    logic [4:0] rs1_in;
    logic [4:0] rs2_in;
    logic [4:0] rd_in;

    logic [3:0] alu_op_in;
    logic [3:0] memory_op_in;
    logic [2:0] branch_type_in;

    logic       register_write_enable_in;
    logic       alu_mux_select_in;
    logic [1:0] pc_mux_select_in;
    logic [1:0] writeback_select_in;

    logic [31:0] pc_out;
    logic [31:0] register_value_1_out;
    logic [31:0] register_value_2_out;
    logic [31:0] immediate_out;

    logic [4:0] rs1_out;
    logic [4:0] rs2_out;
    logic [4:0] rd_out;

    logic [3:0] alu_op_out;
    logic [3:0] memory_op_out;
    logic [2:0] branch_type_out;

    logic       register_write_enable_out;
    logic       alu_mux_select_out;
    logic [1:0] pc_mux_select_out;
    logic [1:0] writeback_select_out;


    id_ex_register dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),

        .pc_in(pc_in),
        .register_value_1_in(register_value_1_in),
        .register_value_2_in(register_value_2_in),
        .immediate_in(immediate_in),

        .rs1_in(rs1_in),
        .rs2_in(rs2_in),
        .rd_in(rd_in),

        .alu_op_in(alu_op_in),
        .memory_op_in(memory_op_in),
        .branch_type_in(branch_type_in),

        .register_write_enable_in(register_write_enable_in),
        .alu_mux_select_in(alu_mux_select_in),
        .pc_mux_select_in(pc_mux_select_in),
        .writeback_select_in(writeback_select_in),

        .pc_out(pc_out),
        .register_value_1_out(register_value_1_out),
        .register_value_2_out(register_value_2_out),
        .immediate_out(immediate_out),

        .rs1_out(rs1_out),
        .rs2_out(rs2_out),
        .rd_out(rd_out),

        .alu_op_out(alu_op_out),
        .memory_op_out(memory_op_out),
        .branch_type_out(branch_type_out),

        .register_write_enable_out(register_write_enable_out),
        .alu_mux_select_out(alu_mux_select_out),
        .pc_mux_select_out(pc_mux_select_out),
        .writeback_select_out(writeback_select_out)
    );


    always #5 clk = ~clk;


    initial begin

        $display("========================================");
        $display("ID/EX REGISTER TEST");
        $display("========================================");

        clk = 0;
        reset = 1;
        stall = 0;

        pc_in = 32'b0;
        register_value_1_in = 32'b0;
        register_value_2_in = 32'b0;
        immediate_in = 32'b0;

        rs1_in = 5'b0;
        rs2_in = 5'b0;
        rd_in = 5'b0;

        alu_op_in = 4'b0;
        memory_op_in = 4'd8;
        branch_type_in = 3'b0;

        register_write_enable_in = 0;
        alu_mux_select_in = 0;
        pc_mux_select_in = 0;
        writeback_select_in = 0;


        // ------------------------------------------------
        // TEST 1: Reset
        // ------------------------------------------------

        #10;

        if (pc_out != 0 ||
            register_value_1_out != 0 ||
            register_value_2_out != 0 ||
            immediate_out != 0 ||
            rs1_out != 0 ||
            rs2_out != 0 ||
            rd_out != 0 ||
            register_write_enable_out != 0) begin

            $display("FAIL: Reset");
            $finish;
        end

        $display("PASS: Reset");


        // ------------------------------------------------
        // TEST 2: Normal capture
        // ------------------------------------------------

        reset = 0;
        stall = 0;

        pc_in = 32'h00000004;
        register_value_1_in = 32'h00000005;
        register_value_2_in = 32'h00000007;
        immediate_in = 32'h00000010;

        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in = 5'd3;

        alu_op_in = 4'd0;
        memory_op_in = 4'd8;
        branch_type_in = 3'b000;

        register_write_enable_in = 1'b1;
        alu_mux_select_in = 1'b0;
        pc_mux_select_in = 2'b00;
        writeback_select_in = 2'b00;

        #10;

        if (pc_out != 32'h00000004 ||
            register_value_1_out != 32'h00000005 ||
            register_value_2_out != 32'h00000007 ||
            immediate_out != 32'h00000010 ||
            rs1_out != 5'd1 ||
            rs2_out != 5'd2 ||
            rd_out != 5'd3 ||
            register_write_enable_out != 1'b1) begin

            $display("FAIL: Normal capture");
            $finish;
        end

        $display("PASS: Normal capture");


        // ------------------------------------------------
        // TEST 3: Stall creates bubble
        // ------------------------------------------------

        stall = 1;

        // New instruction attempting to enter ID/EX
        pc_in = 32'h00000008;
        register_value_1_in = 32'h000000AA;
        register_value_2_in = 32'h000000BB;
        immediate_in = 32'h000000CC;

        rs1_in = 5'd4;
        rs2_in = 5'd5;
        rd_in = 5'd6;

        alu_op_in = 4'd1;
        memory_op_in = 4'd4;
        branch_type_in = 3'b000;

        register_write_enable_in = 1'b1;
        alu_mux_select_in = 1'b1;
        pc_mux_select_in = 2'b01;
        writeback_select_in = 2'b01;

        #10;

        if (pc_out != 0 ||
            register_value_1_out != 0 ||
            register_value_2_out != 0 ||
            immediate_out != 0 ||
            rs1_out != 0 ||
            rs2_out != 0 ||
            rd_out != 0 ||
            register_write_enable_out != 0 ||
            memory_op_out != 4'd8) begin

            $display("FAIL: ID/EX did not insert bubble");
            $display("PC:             %h", pc_out);
            $display("RD:             %d", rd_out);
            $display("RegWrite:       %b", register_write_enable_out);
            $display("MemoryOp:       %d", memory_op_out);
            $finish;
        end

        $display("PASS: Stall inserts bubble");


        // ------------------------------------------------
        // TEST 4: Release stall
        // ------------------------------------------------

        stall = 0;

        #10;

        if (pc_out != 32'h00000008 ||
            register_value_1_out != 32'h000000AA ||
            register_value_2_out != 32'h000000BB ||
            immediate_out != 32'h000000CC ||
            rs1_out != 5'd4 ||
            rs2_out != 5'd5 ||
            rd_out != 5'd6 ||
            register_write_enable_out != 1'b1) begin

            $display("FAIL: ID/EX did not resume after stall");
            $finish;
        end

        $display("PASS: ID/EX resumes after stall");


        // ------------------------------------------------
        // DONE
        // ------------------------------------------------

        $display("");
        $display("========================================");
        $display("ALL ID/EX REGISTER TESTS PASS");
        $display("========================================");

        $finish;

    end

endmodule