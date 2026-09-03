module forwarding_mux_tb;

    logic [31:0] register_value;
    logic [31:0] ex_mem_value;
    logic [31:0] mem_wb_value;

    logic [1:0] forward_select;

    logic [31:0] selected_value;

    forwarding_mux dut (
        .register_value(register_value),
        .ex_mem_value(ex_mem_value),
        .mem_wb_value(mem_wb_value),
        .forward_select(forward_select),
        .selected_value(selected_value)
    );

    initial begin

        $display("========================================");
        $display("FORWARDING MUX TEST");
        $display("========================================");

        register_value = 32'd10;
        ex_mem_value   = 32'd20;
        mem_wb_value   = 32'd30;

        // Test 1: Normal register value
        forward_select = 2'b00;
        #10;

        if (selected_value == 32'd10)
            $display("TEST 1 PASS: Register value selected");
        else
            $display("TEST 1 FAIL: Expected 10, got %0d", selected_value);


        // Test 2: EX/MEM forwarding
        forward_select = 2'b10;
        #10;

        if (selected_value == 32'd20)
            $display("TEST 2 PASS: EX/MEM value selected");
        else
            $display("TEST 2 FAIL: Expected 20, got %0d", selected_value);


        // Test 3: MEM/WB forwarding
        forward_select = 2'b01;
        #10;

        if (selected_value == 32'd30)
            $display("TEST 3 PASS: MEM/WB value selected");
        else
            $display("TEST 3 FAIL: Expected 30, got %0d", selected_value);


        // Test 4: Invalid select
        forward_select = 2'b11;
        #10;

        if (selected_value == 32'd10)
            $display("TEST 4 PASS: Invalid select defaults to register value");
        else
            $display("TEST 4 FAIL: Expected 10, got %0d", selected_value);


        $display("========================================");
        $display("FORWARDING MUX TEST COMPLETE");
        $display("========================================");

        $finish;
    end

endmodule