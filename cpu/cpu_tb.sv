
module cpu_tb;

    logic reset;
    logic clk;

    logic [31:0] init_memory [0:255];

    cpu dut(
        .reset(reset),
        .clk(clk),
        .init_memory(init_memory)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end


    // ============================================================
    // RESET
    // ============================================================

    task reset_cpu;
        begin
            reset = 1;
            #10;
            reset = 0;
            #10;
        end
    endtask


    // ============================================================
    // TRACE
    // ============================================================

    always @(posedge clk) begin
        #1;

        $display(
            "Time=%0t | PC=%h | Instruction=%h | ALU=%h",
            $time,
            dut.current_pc,
            dut.instruction,
            dut.alu_result
        );
    end


    // ============================================================
    // TESTS
    // ============================================================

    initial begin

        reset = 0;

        for (int i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end


        // ========================================================
        // PROGRAM 1: ALU TEST
        // ========================================================

        $display("");
        $display("========================================");
        $display("PROGRAM 1: ALU TEST");
        $display("========================================");

        init_memory[0] = 32'h00500093; // x1 = 5
        init_memory[1] = 32'h00700113; // x2 = 7
        init_memory[2] = 32'h002081B3; // x3 = x1 + x2 = 12
        init_memory[3] = 32'h40118233; // x4 = x3 - x1 = 7
        init_memory[4] = 32'h0041F2B3; // x5 = x3 & x4 = 4
        init_memory[5] = 32'h0011E333; // x6 = x3 | x1 = 13
        init_memory[6] = 32'h0011C3B3; // x7 = x3 ^ x1 = 9
        init_memory[7] = 32'h00209433; // x8 = x1 << x2 = 640
        init_memory[8] = 32'h001454B3; // x9 = x8 >> x1 = 20

        reset_cpu;

        #100;

        $display("");
        $display("REGISTER RESULTS:");
        $display("x1 = %h", dut.cpu_register_file.registers[1]);
        $display("x2 = %h", dut.cpu_register_file.registers[2]);
        $display("x3 = %h", dut.cpu_register_file.registers[3]);
        $display("x4 = %h", dut.cpu_register_file.registers[4]);
        $display("x5 = %h", dut.cpu_register_file.registers[5]);
        $display("x6 = %h", dut.cpu_register_file.registers[6]);
        $display("x7 = %h", dut.cpu_register_file.registers[7]);
        $display("x8 = %h", dut.cpu_register_file.registers[8]);
        $display("x9 = %h", dut.cpu_register_file.registers[9]);

        if (
            dut.cpu_register_file.registers[1] == 32'd5 &&
            dut.cpu_register_file.registers[2] == 32'd7 &&
            dut.cpu_register_file.registers[3] == 32'd12 &&
            dut.cpu_register_file.registers[4] == 32'd7 &&
            dut.cpu_register_file.registers[5] == 32'd4 &&
            dut.cpu_register_file.registers[6] == 32'd13 &&
            dut.cpu_register_file.registers[7] == 32'd9 &&
            dut.cpu_register_file.registers[8] == 32'd640 &&
            dut.cpu_register_file.registers[9] == 32'd20
        ) begin
            $display("PASS: PROGRAM 1");
        end
        else begin
            $display("FAIL: PROGRAM 1");
        end


        // ========================================================
        // PROGRAM 2: LOOP TEST
        // ========================================================

        $display("");
        $display("========================================");
        $display("PROGRAM 2: LOOP TEST");
        $display("========================================");

        for (int i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end

        init_memory[0] = 32'h00500093; // x1 = 5
        init_memory[1] = 32'h00000113; // x2 = 0
        init_memory[2] = 32'h00110133; // x2 = x2 + x1
        init_memory[3] = 32'hFFF08093; // x1 = x1 - 1
        init_memory[4] = 32'hFE009CE3; // BNE x1,x0,loop
        init_memory[5] = 32'h00010193; // x3 = x2

        reset_cpu;

        #200;

        $display("");
        $display("REGISTER RESULTS:");
        $display("x1 = %h", dut.cpu_register_file.registers[1]);
        $display("x2 = %h", dut.cpu_register_file.registers[2]);
        $display("x3 = %h", dut.cpu_register_file.registers[3]);

        if (
            dut.cpu_register_file.registers[1] == 32'd0 &&
            dut.cpu_register_file.registers[2] == 32'd15 &&
            dut.cpu_register_file.registers[3] == 32'd15
        ) begin
            $display("PASS: PROGRAM 2");
        end
        else begin
            $display("FAIL: PROGRAM 2");
        end


        // ========================================================
        // PROGRAM 3: MEMORY TEST
        // ========================================================

        $display("");
        $display("========================================");
        $display("PROGRAM 3: MEMORY TEST");
        $display("========================================");

        for (int i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end

        init_memory[0] = 32'h06400093; // x1 = 100
        init_memory[1] = 32'h12300113; // x2 = 0x123

        init_memory[2] = 32'h0020A023; // SH x2, 0(x1)

        init_memory[3] = 32'h0000C183; // LBU x3, 0(x1)
        init_memory[4] = 32'h00008203; // LB  x4, 0(x1)

        init_memory[5] = 32'h0000D283; // LHU x5, 0(x1)
        init_memory[6] = 32'h00009303; // LH  x6, 0(x1)

        reset_cpu;

        #100;


        // ========================================================
        // MEMORY RESULTS
        //
        // SH 0x123 at address 100 should produce:
        //
        // memory[100] = 0x23
        // memory[101] = 0x01
        // ========================================================

        $display("");
        $display("MEMORY RESULTS:");
        $display(
            "memory[100] = %h",
            dut.data_memory.memory[100]
        );

        $display(
            "memory[101] = %h",
            dut.data_memory.memory[101]
        );


        // ========================================================
        // REGISTER RESULTS
        // ========================================================

        $display("");
        $display("REGISTER RESULTS:");

        $display(
            "x3 = %h",
            dut.cpu_register_file.registers[3]
        );

        $display(
            "x4 = %h",
            dut.cpu_register_file.registers[4]
        );

        $display(
            "x5 = %h",
            dut.cpu_register_file.registers[5]
        );

        $display(
            "x6 = %h",
            dut.cpu_register_file.registers[6]
        );


        // ========================================================
        // PROGRAM 3 CHECK
        // ========================================================

        if (
            dut.data_memory.memory[100] == 8'h23 &&
            dut.data_memory.memory[101] == 8'h01 &&

            dut.cpu_register_file.registers[3] == 32'h00000023 &&
            dut.cpu_register_file.registers[4] == 32'h00000023 &&
            dut.cpu_register_file.registers[5] == 32'h00000123 &&
            dut.cpu_register_file.registers[6] == 32'h00000123
        ) begin
            $display("PASS: PROGRAM 3");
        end
        else begin
            $display("FAIL: PROGRAM 3");
        end


        // ========================================================
        // DONE
        // ========================================================

        $display("");
        $display("========================================");
        $display("ALL TESTS COMPLETE");
        $display("========================================");

        $finish;

    end

endmodule
