module memory_tb;

    logic clk;
    logic reset;

    logic [31:0] address;
    logic [31:0] data_write;
    logic [3:0] memory_op;
    logic memory_mux_select;

    logic [31:0] init_memory [0:255];

    logic [31:0] read_data;

    memory dut(
        .clk(clk),
        .reset(reset),
        .address(address),
        .data_write(data_write),
        .memory_op(memory_op),
        .memory_mux_select(memory_mux_select),
        .init_memory(init_memory),
        .read_data(read_data)
    );


    // ============================================================
    // CLOCK
    // ============================================================

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        // Initialize all program memory to 0
        for (int i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end


        // ========================================================
        // PROGRAM
        // ========================================================

        // Address 0
        init_memory[0] = 32'h00500093;

        // Address 4
        init_memory[1] = 32'h00A00113;


        // ========================================================
        // RESET
        // ========================================================

        reset = 1;

        // Other inputs
        address = 0;
        data_write = 0;
        memory_op = 4'b1000;
        memory_mux_select = 0;

        #10;

        reset = 0;


        // ========================================================
        // TEST 1: INSTRUCTION FETCH
        // ========================================================

        address = 32'd0;

        // 0 = instruction fetch
        memory_mux_select = 0;

        #1;

        $display("");
        $display("TEST 1: Instruction Fetch");
        $display("Address = %h", address);
        $display("Read    = %h", read_data);

        if (read_data == 32'h00500093)
            $display("PASS: Instruction fetch");
        else
            $display("FAIL: Instruction fetch");


        // ========================================================
        // TEST 2: SECOND INSTRUCTION
        // ========================================================

        address = 32'd4;

        #1;

        $display("");
        $display("TEST 2: Second Instruction Fetch");
        $display("Address = %h", address);
        $display("Read    = %h", read_data);

        if (read_data == 32'h00A00113)
            $display("PASS: Second instruction fetch");
        else
            $display("FAIL: Second instruction fetch");


        // ========================================================
        // TEST 3: STORE WORD
        // ========================================================

        // Switch to data memory
        memory_mux_select = 1;

        address = 32'd100;
        data_write = 32'hDEADBEEF;
        memory_op = 4'b0111; // SW

        // Store happens on rising edge
        #9;

        $display("");
        $display("TEST 3: Store Word");
        $display("Address = %h", address);
        $display("Data    = %h", data_write);

        if (dut.memory[100] == 8'hEF &&
            dut.memory[101] == 8'hBE &&
            dut.memory[102] == 8'hAD &&
            dut.memory[103] == 8'hDE)
            $display("PASS: Store Word");
        else
            $display("FAIL: Store Word");


        // ========================================================
        // TEST 4: LOAD WORD
        // ========================================================

        address = 32'd100;
        memory_op = 4'b0100; // LW

        #1;

        $display("");
        $display("TEST 4: Load Word");
        $display("Address = %h", address);
        $display("Read    = %h", read_data);

        if (read_data == 32'hDEADBEEF)
            $display("PASS: Load Word");
        else
            $display("FAIL: Load Word");


        // ========================================================
        // TEST 5: LOAD BYTE SIGNED
        // ========================================================

        address = 32'd100;
        memory_op = 4'b0000; // LB

        #1;

        $display("");
        $display("TEST 5: Load Byte Signed");
        $display("Read = %h", read_data);

        // EF has bit 7 = 1
        // Therefore sign extend to FFFFFFEF
        if (read_data == 32'hFFFFFFEF)
            $display("PASS: LB");
        else
            $display("FAIL: LB");


        // ========================================================
        // TEST 6: LOAD BYTE UNSIGNED
        // ========================================================

        memory_op = 4'b0001; // LBU

        #1;

        $display("");
        $display("TEST 6: Load Byte Unsigned");
        $display("Read = %h", read_data);

        if (read_data == 32'h000000EF)
            $display("PASS: LBU");
        else
            $display("FAIL: LBU");


        // ========================================================
        // TEST 7: LOAD HALFWORD
        // ========================================================

        memory_op = 4'b0010; // LH

        #1;

        $display("");
        $display("TEST 7: Load Halfword Signed");
        $display("Read = %h", read_data);

        // Bytes:
        // EF BE
        // Halfword = BEEF
        // Sign bit = 1
        if (read_data == 32'hFFFFBEEF)
            $display("PASS: LH");
        else
            $display("FAIL: LH");


        // ========================================================
        // TEST 8: LOAD HALFWORD UNSIGNED
        // ========================================================

        memory_op = 4'b0011; // LHU

        #1;

        $display("");
        $display("TEST 8: Load Halfword Unsigned");
        $display("Read = %h", read_data);

        if (read_data == 32'h0000BEEF)
            $display("PASS: LHU");
        else
            $display("FAIL: LHU");


        // ========================================================
        // FINISHED
        // ========================================================

        $display("");
        $display("==============================");
        $display("MEMORY TEST COMPLETED");
        $display("==============================");

        $finish;

    end

endmodule

