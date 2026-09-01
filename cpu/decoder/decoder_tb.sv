
module decoder_tb;

    logic [31:0] instruction;

    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;

    logic [3:0] alu_op;
    logic [3:0] mem_op;
    logic register_write_enable;
    logic alu_mux_select;
    logic [1:0] pc_mux_select;
    logic memory_mux_select;
    logic [2:0] branch_type;
    logic [1:0] writeback_select;

    decoder dut(
        .instruction(instruction),

        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),

        .alu_op(alu_op),
        .mem_op(mem_op),
        .register_write_enable(register_write_enable),
        .alu_mux_select(alu_mux_select),
        .pc_mux_select(pc_mux_select),
        .memory_mux_select(memory_mux_select),
        .branch_type(branch_type),
        .writeback_select(writeback_select)
    );

    initial begin

        // ==========================================
        // TEST 1: ADD x5, x6, x7
        // ==========================================

        instruction = 32'b0000000_00111_00110_000_00101_0110011;

        #10;

        $display("Test 1: ADD");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);
        assert(rd == 5'd5);

        assert(alu_op == 4'd0);
        assert(alu_mux_select == 1'b0);

        assert(register_write_enable == 1'b1);

        // ALU writeback
        assert(writeback_select == 2'b00);


        // ==========================================
        // TEST 2: ADDI x5, x6, 10
        // ==========================================

        instruction = 32'b000000001010_00110_000_00101_0010011;

        #10;

        $display("Test 2: ADDI");

        assert(rs1 == 5'd6);
        assert(rd == 5'd5);

        assert(alu_op == 4'd0);
        assert(alu_mux_select == 1'b1);

        assert(register_write_enable == 1'b1);

        // ALU writeback
        assert(writeback_select == 2'b00);


        // ==========================================
        // TEST 3: LW x5, 8(x6)
        // ==========================================

        instruction = 32'b000000001000_00110_010_00101_0000011;

        #10;

        $display("Test 3: LW");

        assert(rs1 == 5'd6);
        assert(rd == 5'd5);

        assert(alu_op == 4'd0);
        assert(mem_op == 4'd4);

        assert(alu_mux_select == 1'b1);
        assert(memory_mux_select == 1'b1);

        assert(register_write_enable == 1'b1);

        // Memory writeback
        assert(writeback_select == 2'b01);


        // ==========================================
        // TEST 4: SW x7, 8(x6)
        // ==========================================

        instruction = 32'b0000000_00111_00110_010_01000_0100011;

        #10;

        $display("Test 4: SW");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd0);
        assert(mem_op == 4'd7);

        assert(alu_mux_select == 1'b1);
        assert(memory_mux_select == 1'b1);

        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 5: BEQ x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_000_00000_1100011;

        #10;

        $display("Test 5: BEQ");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd1);
        assert(branch_type == 3'b000);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 6: BNE x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_001_00000_1100011;

        #10;

        $display("Test 6: BNE");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd1);
        assert(branch_type == 3'b001);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 7: BLT x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_100_00000_1100011;

        #10;

        $display("Test 7: BLT");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd8);
        assert(branch_type == 3'b100);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 8: BGE x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_101_00000_1100011;

        #10;

        $display("Test 8: BGE");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd8);
        assert(branch_type == 3'b101);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 9: BLTU x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_110_00000_1100011;

        #10;

        $display("Test 9: BLTU");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd9);
        assert(branch_type == 3'b110);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 10: BGEU x6, x7, offset
        // ==========================================

        instruction = 32'b0000000_00111_00110_111_00000_1100011;

        #10;

        $display("Test 10: BGEU");

        assert(rs1 == 5'd6);
        assert(rs2 == 5'd7);

        assert(alu_op == 4'd9);
        assert(branch_type == 3'b111);

        assert(alu_mux_select == 1'b0);
        assert(register_write_enable == 1'b0);


        // ==========================================
        // TEST 11: JAL x1, offset
        // ==========================================

        instruction = 32'b000000000001_00000000_00001_1101111;

        #10;

        $display("Test 11: JAL");

        assert(rd == 5'd1);

        assert(pc_mux_select == 2'b10);

        assert(register_write_enable == 1'b1);

        // PC + 4 writeback
        assert(writeback_select == 2'b10);


        // ==========================================
        // TEST 12: JALR x5, 8(x6)
        // ==========================================

        instruction = 32'b000000001000_00110_000_00101_1100111;

        #10;

        $display("Test 12: JALR");

        assert(rs1 == 5'd6);
        assert(rd == 5'd5);

        assert(alu_op == 4'd0);
        assert(alu_mux_select == 1'b1);

        assert(pc_mux_select == 2'b11);

        assert(register_write_enable == 1'b1);

        // PC + 4 writeback
        assert(writeback_select == 2'b10);


        // ==========================================
        // FINAL RESULT
        // ==========================================

        $display("");
        $display("================================");
        $display("ALL DECODER TESTS PASSED!");
        $display("================================");

        $finish;

    end

endmodule
