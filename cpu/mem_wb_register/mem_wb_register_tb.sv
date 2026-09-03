module mem_wb_register_tb;

    logic clk;
    logic reset;

    // Inputs
    logic [31:0] alu_result_in;
    logic [31:0] memory_data_in;

    logic [4:0] rd_in;

    logic        register_write_enable_in;
    logic [1:0]  writeback_select_in;

    // Outputs
    logic [31:0] alu_result_out;
    logic [31:0] memory_data_out;

    logic [4:0] rd_out;

    logic        register_write_enable_out;
    logic [1:0]  writeback_select_out;


    // ============================================================
    // DUT
    // ============================================================

    mem_wb_register dut(
        .clk(clk),
        .reset(reset),

        .alu_result_in(alu_result_in),
        .memory_data_in(memory_data_in),

        .rd_in(rd_in),

        .register_write_enable_in(register_write_enable_in),
        .writeback_select_in(writeback_select_in),

        .alu_result_out(alu_result_out),
        .memory_data_out(memory_data_out),

        .rd_out(rd_out),

        .register_write_enable_out(register_write_enable_out),
        .writeback_select_out(writeback_select_out)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        clk = 0;
        reset = 1;

        alu_result_in = 32'b0;
        memory_data_in = 32'b0;

        rd_in = 5'b0;

        register_write_enable_in = 1'b0;
        writeback_select_in = 2'b0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #10;

        reset = 0;


        // --------------------------------------------------------
        // TEST 1
        // --------------------------------------------------------

        alu_result_in = 32'h12345678;
        memory_data_in = 32'hABCDEF01;

        rd_in = 5'd10;

        register_write_enable_in = 1'b1;
        writeback_select_in = 2'b01;

        #10;


        if (
            alu_result_out == 32'h12345678 &&
            memory_data_out == 32'hABCDEF01 &&
            rd_out == 5'd10 &&
            register_write_enable_out == 1'b1 &&
            writeback_select_out == 2'b01
        ) begin
            $display("========================================");
            $display("MEM/WB TEST 1: PASS");
            $display("All values captured correctly.");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("MEM/WB TEST 1: FAIL");
            $display("========================================");
        end


        // --------------------------------------------------------
        // TEST 2
        // --------------------------------------------------------

        alu_result_in = 32'hDEADBEEF;
        memory_data_in = 32'hCAFEBABE;

        rd_in = 5'd20;

        register_write_enable_in = 1'b0;
        writeback_select_in = 2'b10;

        #10;


        if (
            alu_result_out == 32'hDEADBEEF &&
            memory_data_out == 32'hCAFEBABE &&
            rd_out == 5'd20 &&
            register_write_enable_out == 1'b0 &&
            writeback_select_out == 2'b10
        ) begin
            $display("========================================");
            $display("MEM/WB TEST 2: PASS");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("MEM/WB TEST 2: FAIL");
            $display("========================================");
        end


        // --------------------------------------------------------
        // FINISH
        // --------------------------------------------------------

        $finish;

    end

endmodule