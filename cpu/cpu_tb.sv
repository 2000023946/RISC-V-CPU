

module cpu_tb;

    logic reset;
    logic clk;
    logic [31:0] init_memory [0:255];

    // ============================================================
    // CPU
    // ============================================================

    cpu dut (
        .reset(reset),
        .clk(clk),
        .init_memory(init_memory)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // TEST PROGRAM
    // ============================================================

    initial begin

        // Clear memory
        for (int i = 0; i < 256; i = i + 1)
            init_memory[i] = 32'b0;


        // ========================================================
        // INSTRUCTIONS
        // ========================================================

        // Address 0
        // ADDI x1, x0, 5
        // x1 = 5
        init_memory[0] = 32'h00500093;


        // Address 4
        // ADD x2, x1, x0
        // x2 = x1 + x0 = 5
        //
        // Tests RAW forwarding.
        init_memory[1] = 32'h00008133;


        // Address 8
        // LW x3, 16(x0)
        // x3 = memory[16] = 42
        init_memory[2] = 32'h01002183;


        // Address 12
        // ADD x4, x3, x0
        // x4 = x3 = 42
        //
        // Tests load-use stall + forwarding.
        init_memory[3] = 32'h00018233;


        // ========================================================
        // DATA
        // ========================================================

        // init_memory[4] corresponds to BYTE ADDRESS 16
        //
        // LW x3, 16(x0) should therefore load 42.
        init_memory[4] = 32'h0000002A;


        // ========================================================
        // RESET
        // ========================================================

        clk = 1'b0;
        reset = 1'b1;

        #12;

        reset = 1'b0;


        // Let CPU run
        #150;


        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("========================================");
        $display("CPU HAZARD TEST RESULTS");
        $display("========================================");

        $display("x1 = %0d", dut.cpu_register_file.registers[1]);
        $display("x2 = %0d", dut.cpu_register_file.registers[2]);
        $display("x3 = %0d", dut.cpu_register_file.registers[3]);
        $display("x4 = %0d", dut.cpu_register_file.registers[4]);


        // ========================================================
        // CHECK x1
        // ========================================================

        if (dut.cpu_register_file.registers[1] != 5) begin
            $display("FAIL: ADDI");
            $display("Expected x1 = 5");
            $display("Actual   x1 = %0d",
                     dut.cpu_register_file.registers[1]);
            $finish;
        end

        $display("PASS: ADDI");


        // ========================================================
        // CHECK x2
        // ========================================================

        if (dut.cpu_register_file.registers[2] != 5) begin
            $display("FAIL: RAW FORWARDING");
            $display("Expected x2 = 5");
            $display("Actual   x2 = %0d",
                     dut.cpu_register_file.registers[2]);
            $finish;
        end

        $display("PASS: RAW forwarding");


        // ========================================================
        // CHECK x3
        // ========================================================

        if (dut.cpu_register_file.registers[3] != 42) begin
            $display("FAIL: LW");
            $display("Expected x3 = 42");
            $display("Actual   x3 = %0d",
                     dut.cpu_register_file.registers[3]);
            $finish;
        end

        $display("PASS: LW");


        // ========================================================
        // CHECK x4
        // ========================================================

        if (dut.cpu_register_file.registers[4] != 42) begin
            $display("FAIL: LOAD-USE HAZARD");
            $display("Expected x4 = 42");
            $display("Actual   x4 = %0d",
                     dut.cpu_register_file.registers[4]);
            $finish;
        end

        $display("PASS: Load-use stall + forwarding");


        // ========================================================
        // FINAL RESULT
        // ========================================================

        $display("");
        $display("========================================");
        $display("ALL CPU HAZARD TESTS PASS");
        $display("========================================");

        $finish;

    end


    // ============================================================
    // PIPELINE DEBUG
    // ============================================================

    always @(posedge clk) begin

        if (!reset) begin

            $display(
                "Time=%0t | PC=%h | IF/ID=%h | ID/EX rd=%0d | EX/MEM rd=%0d | MEM/WB rd=%0d | Stall=%b | FwdA=%b | FwdB=%b",
                $time,
                dut.current_pc,
                dut.if_id_instruction,
                dut.id_ex_rd,
                dut.ex_mem_rd,
                dut.mem_wb_rd,
                dut.stall,
                dut.forward_a,
                dut.forward_b
            );

        end

    end

endmodule
