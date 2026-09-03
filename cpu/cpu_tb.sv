module cpu_tb;

    logic reset;
    logic clk;

    logic [31:0] init_memory [0:255];

    logic [31:0] beq_instruction;

    // ============================================================
    // BENCHMARK COUNTERS
    // ============================================================
    integer stall_count;
    integer flush_count;
    integer cycles_count;
    integer inst_count;


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
    // PERFORMANCE MONITORING BLOCK
    // ============================================================

    always @(posedge clk) begin

        if (!reset) begin
            // 1. Count every active clock cycle
            cycles_count = cycles_count + 1;

            // 2. Count Stalls
            if (dut.stall) begin
                stall_count = stall_count + 1;
                $display(
                    "STALL DETECTED | PC=%h | IFID_PC=%h | IDEX_PC=%h | INST=%h",
                    dut.current_pc,
                    dut.if_id_pc,
                    dut.id_ex_pc,
                    dut.if_id_instruction
                );
            end

            // 3. Count Flushes
            if (dut.flush) begin
                flush_count = flush_count + 1;
            end

            // 4. Count Instructions Retired Dynamically!
            // We use the new mem_wb_valid bit from the CPU pipeline
            if (dut.mem_wb_valid) begin
                inst_count = inst_count + 1;
            end
        end

    end


    // ============================================================
    // INSTRUCTION ENCODERS
    // ============================================================


    // ------------------------------------------------------------
    // ADDI
    // ------------------------------------------------------------

    function automatic [31:0] encode_addi(
        input [4:0] rd,
        input [4:0] rs1,
        input integer imm
    );

        encode_addi =
            {imm[11:0],
             rs1,
             3'b000,
             rd,
             7'b0010011};

    endfunction


    // ------------------------------------------------------------
    // ADD
    // ------------------------------------------------------------

    function automatic [31:0] encode_add(
        input [4:0] rd,
        input [4:0] rs1,
        input [4:0] rs2
    );

        encode_add =
            {7'b0000000,
             rs2,
             rs1,
             3'b000,
             rd,
             7'b0110011};

    endfunction


    // ------------------------------------------------------------
    // LW
    // ------------------------------------------------------------

    function automatic [31:0] encode_lw(
        input [4:0] rd,
        input [4:0] rs1,
        input integer imm
    );

        encode_lw =
            {imm[11:0],
             rs1,
             3'b010,
             rd,
             7'b0000011};

    endfunction


    // ------------------------------------------------------------
    // BEQ
    // ------------------------------------------------------------

    function automatic [31:0] encode_beq(
        input [4:0] rs1,
        input [4:0] rs2,
        input integer imm
    );

        logic [12:0] branch_imm;

        begin

            branch_imm = imm[12:0];

            encode_beq = {
                branch_imm[12],
                branch_imm[10:5],
                rs2,
                rs1,
                3'b000,
                branch_imm[4:1],
                branch_imm[11],
                7'b1100011
            };

        end

    endfunction


    // ============================================================
    // TEST PROGRAM
    // ============================================================

    initial begin

        // --------------------------------------------------------
        // Initial state
        // --------------------------------------------------------

        clk = 1'b0;
        reset = 1'b1;

        stall_count = 0;
        flush_count = 0;
        cycles_count = 0;
        inst_count = 0;

        // --------------------------------------------------------
        // Clear memory
        // --------------------------------------------------------

        for (int i = 0; i < 256; i = i + 1)
            init_memory[i] = 32'b0;


        // ========================================================
        // DATA MEMORY
        // ========================================================

        init_memory[25] = 32'd42;


        // ========================================================
        // PROGRAM
        // ========================================================

        // 0x00: ADDI x1, x0, 5
        init_memory[0] = encode_addi(5'd1, 5'd0, 5);

        // 0x04: ADD x2, x1, x0 (RAW HAZARD)
        init_memory[1] = encode_add(5'd2, 5'd1, 5'd0);

        // 0x08: ADDI x10, x0, 100
        init_memory[2] = encode_addi(5'd10, 5'd0, 100);

        // 0x0C: LW x4, 0(x10)
        init_memory[3] = encode_lw(5'd4, 5'd10, 0);

        // 0x10: ADD x5, x4, x0 (LOAD-USE HAZARD -> STALL)
        init_memory[4] = encode_add(5'd5, 5'd4, 5'd0);

        // 0x14: BEQ x5, x5, +12 (BRANCH TAKEN -> FLUSH)
        beq_instruction = encode_beq(5'd5, 5'd5, 12);
        init_memory[5] = beq_instruction;

        // 0x18: WRONG PATH
        init_memory[6] = encode_addi(5'd6, 5'd0, 99);

        // 0x1C: WRONG PATH
        init_memory[7] = encode_addi(5'd7, 5'd0, 88);

        // 0x20: BRANCH TARGET
        init_memory[8] = encode_addi(5'd8, 5'd0, 42);


        // ========================================================
        // PRINT PROGRAM
        // ========================================================

        $display("");
        $display("========================================");
        $display("PROGRAM MEMORY");
        $display("========================================");

        $display("0x00 : %h", init_memory[0]);
        $display("0x04 : %h", init_memory[1]);
        $display("0x08 : %h", init_memory[2]);
        $display("0x0C : %h", init_memory[3]);
        $display("0x10 : %h", init_memory[4]);
        $display("0x14 : %h", init_memory[5]);
        $display("0x18 : %h", init_memory[6]);
        $display("0x1C : %h", init_memory[7]);
        $display("0x20 : %h", init_memory[8]);

        $display("");
        $display("Data memory:");
        $display("address 100 -> %0d", init_memory[25]);


        // ========================================================
        // RELEASE RESET & RUN CPU
        // ========================================================

        repeat (2) @(posedge clk);
        reset = 1'b0;

        // Smart execution loop: Wait dynamically for the 7 valid instructions
        // (with a small timeout safeguard to prevent infinite loops if something breaks)
        while (inst_count < 7 && cycles_count < 100) begin
            @(posedge clk);
        end
        
        // Let the final instruction fully drain out of the pipeline
        repeat (2) @(posedge clk);
        
        #1;


        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("========================================");
        $display("PIPELINE HAZARD TEST RESULTS");
        $display("========================================");

        if ((dut.cpu_register_file.registers[1] == 5)  &&
            (dut.cpu_register_file.registers[2] == 5)  &&
            (dut.cpu_register_file.registers[10] == 100) &&
            (dut.cpu_register_file.registers[4] == 42) &&
            (dut.cpu_register_file.registers[5] == 42) &&
            (stall_count >= 1) &&
            (dut.cpu_register_file.registers[6] == 0) &&
            (dut.cpu_register_file.registers[7] == 0) &&
            (dut.cpu_register_file.registers[8] == 42)) begin

            $display("ALL PIPELINE HAZARD TESTS: PASS");

        end else begin

            $display("PIPELINE HAZARD TESTS: FAIL");

        end

        // ========================================================
        // BENCHMARK METRICS
        // ========================================================

        $display("");
        $display("========================================");
        $display("           BENCHMARK RESULTS            ");
        $display("========================================");
        $display("Cycles Executed:       %0d", cycles_count);
        $display("Instructions Retired:  %0d", inst_count);
        $display("Pipeline Stalls:       %0d", stall_count);
        $display("Pipeline Flushes:      %0d", flush_count);
        
        if (inst_count > 0) begin
            // Multiply by 1.0 to force floating point division for CPI
            $display("CPI (Cycles/Inst):     %f", (cycles_count * 1.0) / inst_count);
        end
        $display("========================================");

        $finish;

    end

endmodule