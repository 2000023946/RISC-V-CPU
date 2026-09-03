module id_ex_register_tb;

    logic        clk;
    logic        reset;

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


    id_ex_register dut(
        .clk(clk),
        .reset(reset),

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

        clk = 0;
        reset = 1;

        // Initial values
        pc_in = 0;
        register_value_1_in = 0;
        register_value_2_in = 0;
        immediate_in = 0;

        rs1_in = 0;
        rs2_in = 0;
        rd_in = 0;

        alu_op_in = 0;
        memory_op_in = 0;
        branch_type_in = 0;

        register_write_enable_in = 0;
        alu_mux_select_in = 0;
        pc_mux_select_in = 0;
        writeback_select_in = 0;

        // Reset
        #10;
        reset = 0;


        // =====================================================
        // TEST 1
        // =====================================================

        pc_in = 32'h00001000;
        register_value_1_in = 32'h11111111;
        register_value_2_in = 32'h22222222;
        immediate_in = 32'h33333333;

        rs1_in = 5'd1;
        rs2_in = 5'd2;
        rd_in = 5'd3;

        alu_op_in = 4'd5;
        memory_op_in = 4'd6;
        branch_type_in = 3'd3;

        register_write_enable_in = 1;
        alu_mux_select_in = 1;
        pc_mux_select_in = 2'b10;
        writeback_select_in = 2'b01;


        // Wait for rising edge
        #10;


        // =====================================================
        // CHECK
        // =====================================================

        if (
            pc_out == 32'h00001000 &&
            register_value_1_out == 32'h11111111 &&
            register_value_2_out == 32'h22222222 &&
            immediate_out == 32'h33333333 &&

            rs1_out == 5'd1 &&
            rs2_out == 5'd2 &&
            rd_out == 5'd3 &&

            alu_op_out == 4'd5 &&
            memory_op_out == 4'd6 &&
            branch_type_out == 3'd3 &&

            register_write_enable_out == 1 &&
            alu_mux_select_out == 1 &&
            pc_mux_select_out == 2'b10 &&
            writeback_select_out == 2'b01
        ) begin

            $display("========================================");
            $display("ID/EX REGISTER TEST: PASS");
            $display("All values were captured correctly.");
            $display("========================================");

        end
        else begin

            $display("========================================");
            $display("ID/EX REGISTER TEST: FAIL");
            $display("One or more values were incorrect.");
            $display("========================================");

        end


        // =====================================================
        // TEST 2
        // Make sure it can capture a NEW set of values
        // =====================================================

        pc_in = 32'h00002000;
        register_value_1_in = 32'hAAAAAAAA;
        register_value_2_in = 32'hBBBBBBBB;
        immediate_in = 32'hCCCCCCCC;

        rs1_in = 5'd10;
        rs2_in = 5'd11;
        rd_in = 5'd12;

        alu_op_in = 4'd9;
        memory_op_in = 4'd10;
        branch_type_in = 3'd5;

        register_write_enable_in = 0;
        alu_mux_select_in = 0;
        pc_mux_select_in = 2'b01;
        writeback_select_in = 2'b11;


        #10;


        if (
            pc_out == 32'h00002000 &&
            register_value_1_out == 32'hAAAAAAAA &&
            register_value_2_out == 32'hBBBBBBBB &&
            immediate_out == 32'hCCCCCCCC &&

            rs1_out == 5'd10 &&
            rs2_out == 5'd11 &&
            rd_out == 5'd12 &&

            alu_op_out == 4'd9 &&
            memory_op_out == 4'd10 &&
            branch_type_out == 3'd5 &&

            register_write_enable_out == 0 &&
            alu_mux_select_out == 0 &&
            pc_mux_select_out == 2'b01 &&
            writeback_select_out == 2'b11
        ) begin

            $display("ID/EX SECOND TEST: PASS");
        end
        else begin
            $display("ID/EX SECOND TEST: FAIL");
        end


        $finish;

    end

endmodule