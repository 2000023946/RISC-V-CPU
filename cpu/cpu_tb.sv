module cpu_tb;

    logic reset;
    logic clk;

    logic [31:0] init_memory [0:255];

    logic [31:0] beq_instruction;

    // Count actual stall cycles
    integer stall_count;


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
    // COUNT STALL CYCLES
    // ============================================================

    always @(posedge clk) begin

        if (!reset && dut.stall) begin

            stall_count = stall_count + 1;

            $display(
                "STALL DETECTED | PC=%h | IFID_PC=%h | IDEX_PC=%h | INST=%h",
                dut.current_pc,
                dut.if_id_pc,
                dut.id_ex_pc,
                dut.if_id_instruction
            );

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
    //
    // LW rd, imm(rs1)
    //
    // I-type:
    //
    // [31:20] immediate
    // [19:15] rs1
    // [14:12] funct3 = 010
    // [11:7]  rd
    // [6:0]   opcode = 0000011
    //
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
    //
    // B-type:
    //
    // [31]    = imm[12]
    // [30:25] = imm[10:5]
    // [24:20] = rs2
    // [19:15] = rs1
    // [14:12] = funct3
    // [11:8]  = imm[4:1]
    // [7]     = imm[11]
    // [6:0]   = opcode
    //
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
    //
    // This SINGLE program tests all 3 pipeline hazards.
    //
    //
    // PC       Instruction
    //
    // 0x00     ADDI x1, x0, 5
    // 0x04     ADD  x2, x1, x0
    //
    //          RAW DATA HAZARD
    //          x2 depends immediately on x1.
    //
    // 0x08     ADDI x10, x0, 100
    //
    // 0x0C     LW   x4, 0(x10)
    //
    // 0x10     ADD  x5, x4, x0
    //
    //          LOAD-USE HAZARD
    //          x5 immediately depends on loaded x4.
    //
    //          CPU MUST STALL.
    //
    // 0x14     BEQ  x5, x5, +12
    //
    //          CONTROL HAZARD
    //          Branch target = 0x20
    //
    // 0x18     ADDI x6, x0, 99
    //          WRONG PATH
    //
    // 0x1C     ADDI x7, x0, 88
    //          WRONG PATH
    //
    // 0x20     ADDI x8, x0, 42
    //          BRANCH TARGET
    //
    //
    // Data memory:
    //
    // address 100 = 42
    //
    // Since memory is word indexed:
    //
    // 100 / 4 = 25
    //
    // init_memory[25] = 42
    //
    //
    // Expected:
    //
    // x1  = 5
    // x2  = 5
    // x10 = 100
    // x4  = 42
    // x5  = 42
    // x6  = 0
    // x7  = 0
    // x8  = 42
    //
    // stall_count >= 1
    //
    // ============================================================


    initial begin

        // --------------------------------------------------------
        // Initial state
        // --------------------------------------------------------

        clk = 1'b0;
        reset = 1'b1;

        stall_count = 0;


        // --------------------------------------------------------
        // Clear memory
        // --------------------------------------------------------

        for (int i = 0; i < 256; i = i + 1)
            init_memory[i] = 32'b0;


        // ========================================================
        // DATA MEMORY
        // ========================================================
        //
        // LW x4, 0(x10)
        //
        // x10 = 100
        //
        // Therefore:
        //
        // memory address = 100
        //
        // Word index:
        //
        // 100 / 4 = 25
        //
        // ========================================================

        init_memory[25] = 32'd42;


        // ========================================================
        // PROGRAM
        // ========================================================


        // --------------------------------------------------------
        // 0x00
        //
        // ADDI x1, x0, 5
        //
        // x1 = 5
        // --------------------------------------------------------

        init_memory[0] =
            encode_addi(
                5'd1,
                5'd0,
                5
            );


        // --------------------------------------------------------
        // 0x04
        //
        // ADD x2, x1, x0
        //
        // x2 = x1 + x0
        //
        // RAW HAZARD
        //
        // ADD needs x1 immediately after ADDI produces x1.
        //
        // Forwarding should provide x1 = 5.
        // --------------------------------------------------------

        init_memory[1] =
            encode_add(
                5'd2,
                5'd1,
                5'd0
            );


        // --------------------------------------------------------
        // 0x08
        //
        // ADDI x10, x0, 100
        //
        // x10 = 100
        // --------------------------------------------------------

        init_memory[2] =
            encode_addi(
                5'd10,
                5'd0,
                100
            );


        // --------------------------------------------------------
        // 0x0C
        //
        // LW x4, 0(x10)
        //
        // x4 = memory[100]
        //
        // x4 = 42
        // --------------------------------------------------------

        init_memory[3] =
            encode_lw(
                5'd4,
                5'd10,
                0
            );


        // --------------------------------------------------------
        // 0x10
        //
        // ADD x5, x4, x0
        //
        // x5 = x4
        //
        // LOAD-USE HAZARD
        //
        // LW produces x4.
        //
        // The very next instruction needs x4.
        //
        // Therefore:
        //
        //             LW
        //              |
        //              v
        //            STALL
        //              |
        //              v
        //             ADD
        //
        // The CPU must hold PC and IF/ID and insert a bubble
        // into ID/EX.
        // --------------------------------------------------------

        init_memory[4] =
            encode_add(
                5'd5,
                5'd4,
                5'd0
            );


        // --------------------------------------------------------
        // 0x14
        //
        // BEQ x5, x5, +12
        //
        // x5 == x5
        //
        // Branch TAKEN.
        //
        // Target:
        //
        // 0x14 + 12 = 0x20
        // --------------------------------------------------------

        beq_instruction =
            encode_beq(
                5'd5,
                5'd5,
                12
            );

        init_memory[5] = beq_instruction;


        // --------------------------------------------------------
        // Verify BEQ
        // --------------------------------------------------------

        $display("");
        $display("========================================");
        $display("BEQ ENCODING CHECK");
        $display("========================================");

        $display(
            "Generated BEQ = %h",
            beq_instruction
        );


        // BEQ x5,x5,+12
        //
        // Expected encoding:
        //
        // 32'h00528663
        //

        $display(
            "Expected BEQ  = 00528663"
        );

        if (beq_instruction == 32'h00528663)
            $display("PASS: BEQ encoder");
        else
            $display("FAIL: BEQ encoder");


        // --------------------------------------------------------
        // 0x18
        //
        // WRONG PATH
        //
        // ADDI x6, x0, 99
        //
        // This MUST be flushed.
        // --------------------------------------------------------

        init_memory[6] =
            encode_addi(
                5'd6,
                5'd0,
                99
            );


        // --------------------------------------------------------
        // 0x1C
        //
        // WRONG PATH
        //
        // ADDI x7, x0, 88
        //
        // This MUST be flushed.
        // --------------------------------------------------------

        init_memory[7] =
            encode_addi(
                5'd7,
                5'd0,
                88
            );


        // --------------------------------------------------------
        // 0x20
        //
        // BRANCH TARGET
        //
        // ADDI x8, x0, 42
        //
        // This MUST execute.
        // --------------------------------------------------------

        init_memory[8] =
            encode_addi(
                5'd8,
                5'd0,
                42
            );


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
        // RELEASE RESET
        // ========================================================

        repeat (2)
            @(posedge clk);

        reset = 1'b0;


        // ========================================================
        // RUN CPU
        // ========================================================

        repeat (30)
            @(posedge clk);

        #1;


        // ========================================================
        // RESULTS
        // ========================================================

        $display("");
        $display("========================================");
        $display("PIPELINE HAZARD TEST RESULTS");
        $display("========================================");

        $display(
            "x1  = %0d",
            dut.cpu_register_file.registers[1]
        );

        $display(
            "x2  = %0d",
            dut.cpu_register_file.registers[2]
        );

        $display(
            "x10 = %0d",
            dut.cpu_register_file.registers[10]
        );

        $display(
            "x4  = %0d",
            dut.cpu_register_file.registers[4]
        );

        $display(
            "x5  = %0d",
            dut.cpu_register_file.registers[5]
        );

        $display(
            "x6  = %0d",
            dut.cpu_register_file.registers[6]
        );

        $display(
            "x7  = %0d",
            dut.cpu_register_file.registers[7]
        );

        $display(
            "x8  = %0d",
            dut.cpu_register_file.registers[8]
        );

        $display(
            "Stall cycles = %0d",
            stall_count
        );


        // ========================================================
        // TEST 1
        //
        // RAW FORWARDING
        // ========================================================

        if (dut.cpu_register_file.registers[1] == 5 &&
            dut.cpu_register_file.registers[2] == 5)

            $display(
                "PASS: RAW forwarding"
            );

        else

            $display(
                "FAIL: RAW forwarding"
            );


        // ========================================================
        // TEST 2
        //
        // LOAD
        // ========================================================

        if (dut.cpu_register_file.registers[10] == 100 &&
            dut.cpu_register_file.registers[4] == 42)

            $display(
                "PASS: Load instruction"
            );

        else

            $display(
                "FAIL: Load instruction"
            );


        // ========================================================
        // TEST 3
        //
        // LOAD-USE STALL
        // ========================================================

        if (stall_count >= 1 &&
            dut.cpu_register_file.registers[5] == 42)

            $display(
                "PASS: Load-use stall"
            );

        else begin

            $display(
                "FAIL: Load-use stall"
            );

            $display(
                "Expected stall_count >= 1 and x5 = 42"
            );

        end


        // ========================================================
        // TEST 4
        //
        // WRONG PATH 1
        // ========================================================

        if (dut.cpu_register_file.registers[6] == 0)

            $display(
                "PASS: Branch wrong-path instruction 1 flushed"
            );

        else

            $display(
                "FAIL: Branch wrong-path instruction 1 executed"
            );


        // ========================================================
        // TEST 5
        //
        // WRONG PATH 2
        // ========================================================

        if (dut.cpu_register_file.registers[7] == 0)

            $display(
                "PASS: Branch wrong-path instruction 2 flushed"
            );

        else

            $display(
                "FAIL: Branch wrong-path instruction 2 executed"
            );


        // ========================================================
        // TEST 6
        //
        // BRANCH TARGET
        // ========================================================

        if (dut.cpu_register_file.registers[8] == 42)

            $display(
                "PASS: Branch redirected to target"
            );

        else

            $display(
                "FAIL: Branch target did not execute"
            );


        // ========================================================
        // FINAL RESULT
        // ========================================================

        if ((dut.cpu_register_file.registers[1] == 5)  &&
            (dut.cpu_register_file.registers[2] == 5)  &&
            (dut.cpu_register_file.registers[10] == 100) &&
            (dut.cpu_register_file.registers[4] == 42) &&
            (dut.cpu_register_file.registers[5] == 42) &&
            (stall_count >= 1) &&
            (dut.cpu_register_file.registers[6] == 0) &&
            (dut.cpu_register_file.registers[7] == 0) &&
            (dut.cpu_register_file.registers[8] == 42)) begin


            $display("");
            $display("========================================");
            $display("ALL PIPELINE HAZARD TESTS: PASS");
            $display("========================================");

            $display(
                "1. RAW forwarding        : PASS"
            );

            $display(
                "2. Load instruction      : PASS"
            );

            $display(
                "3. Load-use stall        : PASS"
            );

            $display(
                "4. Branch flush          : PASS"
            );

            $display(
                "5. Branch redirect       : PASS"
            );

            $display("");
            $display(
                "The CPU successfully handles"
            );

            $display(
                "data and control hazards."
            );

            $display("========================================");

        end

        else begin

            $display("");
            $display("========================================");
            $display("PIPELINE HAZARD TESTS: FAIL");
            $display("========================================");

        end


        $finish;

    end

endmodule