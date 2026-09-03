module ex_mem_register_tb;

    logic        clk;
    logic        reset;

    logic [31:0] alu_result_in;
    logic [31:0] register_value_2_in;

    logic [4:0] rd_in;

    logic [3:0] memory_op_in;
    logic       register_write_enable_in;
    logic [1:0] writeback_select_in;

    logic [31:0] alu_result_out;
    logic [31:0] register_value_2_out;

    logic [4:0] rd_out;

    logic [3:0] memory_op_out;
    logic       register_write_enable_out;
    logic [1:0] writeback_select_out;


    ex_mem_register dut(
        .clk(clk),
        .reset(reset),

        .alu_result_in(alu_result_in),
        .register_value_2_in(register_value_2_in),

        .rd_in(rd_in),

        .memory_op_in(memory_op_in),
        .register_write_enable_in(register_write_enable_in),
        .writeback_select_in(writeback_select_in),

        .alu_result_out(alu_result_out),
        .register_value_2_out(register_value_2_out),

        .rd_out(rd_out),

        .memory_op_out(memory_op_out),
        .register_write_enable_out(register_write_enable_out),
        .writeback_select_out(writeback_select_out)
    );


    // 10 time-unit clock
    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 1;

        alu_result_in = 0;
        register_value_2_in = 0;

        rd_in = 0;

        memory_op_in = 0;
        register_write_enable_in = 0;
        writeback_select_in = 0;


        // =====================================================
        // RESET
        // =====================================================

        #10;

        reset = 0;


        // =====================================================
        // TEST 1
        // =====================================================

        alu_result_in       = 32'h12345678;
        register_value_2_in = 32'hAAAAAAAA;

        rd_in = 5'd10;

        memory_op_in = 4'b0011;
        register_write_enable_in = 1'b1;
        writeback_select_in = 2'b01;


        // Wait for rising edge
        #10;


        // =====================================================
        // CHECK TEST 1
        // =====================================================

        if (
            alu_result_out == 32'h12345678 &&
            register_value_2_out == 32'hAAAAAAAA &&

            rd_out == 5'd10 &&

            memory_op_out == 4'b0011 &&
            register_write_enable_out == 1'b1 &&
            writeback_select_out == 2'b01
        ) begin

            $display("========================================");
            $display("EX/MEM TEST 1: PASS");
            $display("All values captured correctly.");
            $display("========================================");

        end
        else begin

            $display("========================================");
            $display("EX/MEM TEST 1: FAIL");
            $display("One or more values are incorrect.");
            $display("========================================");

        end


        // =====================================================
        // TEST 2
        // Verify it can capture a new set of values
        // =====================================================

        alu_result_in       = 32'hDEADBEEF;
        register_value_2_in = 32'h55555555;

        rd_in = 5'd20;

        memory_op_in = 4'b1010;
        register_write_enable_in = 1'b0;
        writeback_select_in = 2'b10;


        #10;


        // =====================================================
        // CHECK TEST 2
        // =====================================================

        if (
            alu_result_out == 32'hDEADBEEF &&
            register_value_2_out == 32'h55555555 &&

            rd_out == 5'd20 &&

            memory_op_out == 4'b1010 &&
            register_write_enable_out == 1'b0 &&
            writeback_select_out == 2'b10
        ) begin

            $display("EX/MEM TEST 2: PASS");

        end
        else begin

            $display("EX/MEM TEST 2: FAIL");

        end


        $finish;

    end

endmodule