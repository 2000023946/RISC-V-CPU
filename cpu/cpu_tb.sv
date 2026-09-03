module cpu_tb;

    // ============================================================
    // CLOCK / RESET
    // ============================================================

    logic clk;
    logic reset;

    // ============================================================
    // INITIAL MEMORY
    // ============================================================

    logic [31:0] init_memory [0:255];


    // ============================================================
    // CPU
    // ============================================================

    cpu dut(
        .reset(reset),
        .clk(clk),
        .init_memory(init_memory)
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


        // --------------------------------------------------------
        // Clear memory
        // --------------------------------------------------------

        for (int i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end


        // --------------------------------------------------------
        // PROGRAM
        //
        // These instructions are intentionally independent.
        //
        // ADDI x1, x0, 5
        // ADDI x2, x0, 10
        // ADDI x3, x0, 20
        // ADDI x4, x0, 30
        //
        // We are NOT testing:
        //
        // ADD x3, x1, x2
        //
        // because that would create a RAW hazard.
        // --------------------------------------------------------

        init_memory[0] = 32'h00500093;  // addi x1, x0, 5
        init_memory[1] = 32'h00A00113;  // addi x2, x0, 10
        init_memory[2] = 32'h01400193;  // addi x3, x0, 20
        init_memory[3] = 32'h01E00213;  // addi x4, x0, 30

        // NOPs after program
        init_memory[4] = 32'h00000013;
        init_memory[5] = 32'h00000013;
        init_memory[6] = 32'h00000013;
        init_memory[7] = 32'h00000013;
        init_memory[8] = 32'h00000013;
        init_memory[9] = 32'h00000013;


        // --------------------------------------------------------
        // Hold reset for one clock
        // --------------------------------------------------------

        #10;

        reset = 0;


        // --------------------------------------------------------
        // Run the processor
        //
        // Five-stage pipeline needs several cycles to fill.
        // We give it plenty of cycles here.
        // --------------------------------------------------------

        repeat (12) begin
            @(posedge clk);

            #1;

            $display(
                "Cycle=%0t | PC=%h | IF/ID Instr=%h | ID/EX rd=%0d | EX/MEM rd=%0d | MEM/WB rd=%0d",
                $time,
                dut.current_pc,
                dut.if_id_instruction,
                dut.id_ex_rd,
                dut.ex_mem_rd,
                dut.mem_wb_rd
            );
        end


        // ========================================================
        // REGISTER CHECKS
        // ========================================================

        $display("");
        $display("========================================");
        $display("REGISTER RESULTS");
        $display("========================================");

        $display("x1 = %0d", dut.cpu_register_file.registers[1]);
        $display("x2 = %0d", dut.cpu_register_file.registers[2]);
        $display("x3 = %0d", dut.cpu_register_file.registers[3]);
        $display("x4 = %0d", dut.cpu_register_file.registers[4]);


        // --------------------------------------------------------
        // Check x1
        // --------------------------------------------------------

        if (dut.cpu_register_file.registers[1] == 32'd5) begin
            $display("x1 TEST: PASS");
        end
        else begin
            $display("x1 TEST: FAIL");
        end


        // --------------------------------------------------------
        // Check x2
        // --------------------------------------------------------

        if (dut.cpu_register_file.registers[2] == 32'd10) begin
            $display("x2 TEST: PASS");
        end
        else begin
            $display("x2 TEST: FAIL");
        end


        // --------------------------------------------------------
        // Check x3
        // --------------------------------------------------------

        if (dut.cpu_register_file.registers[3] == 32'd20) begin
            $display("x3 TEST: PASS");
        end
        else begin
            $display("x3 TEST: FAIL");
        end


        // --------------------------------------------------------
        // Check x4
        // --------------------------------------------------------

        if (dut.cpu_register_file.registers[4] == 32'd30) begin
            $display("x4 TEST: PASS");
        end
        else begin
            $display("x4 TEST: FAIL");
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        if (
            dut.cpu_register_file.registers[1] == 32'd5 &&
            dut.cpu_register_file.registers[2] == 32'd10 &&
            dut.cpu_register_file.registers[3] == 32'd20 &&
            dut.cpu_register_file.registers[4] == 32'd30
        ) begin

            $display("");
            $display("========================================");
            $display("PIPELINED CPU TEST: PASS");
            $display("All independent instructions executed.");
            $display("========================================");

        end
        else begin

            $display("");
            $display("========================================");
            $display("PIPELINED CPU TEST: FAIL");
            $display("========================================");

        end


        $finish;

    end

endmodule

