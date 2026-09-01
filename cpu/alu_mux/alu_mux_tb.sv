module alu_mux_tb;

    logic [31:0] rs2_value;
    logic [31:0] immediate;
    logic select;
    logic [31:0] alu_b;

    alu_mux dut(
        .rs2_value(rs2_value),
        .immediate(immediate),
        .select(select),
        .alu_b(alu_b)
    );

    initial begin

        // Give both inputs different values
        rs2_value = 32'h0000000A;
        immediate = 32'h00000100;


        // Test 1: select rs2
        select = 1'b0;
        #1;

        if (alu_b == rs2_value)
            $display("RS2 MUX test PASSED");
        else
            $display("RS2 MUX test FAILED: alu_b = %h", alu_b);


        // Test 2: select immediate
        select = 1'b1;
        #1;

        if (alu_b == immediate)
            $display("IMMEDIATE MUX test PASSED");
        else
            $display("IMMEDIATE MUX test FAILED: alu_b = %h", alu_b);


        // Test 3: change rs2 and make sure MUX follows it
        rs2_value = 32'hDEADBEEF;
        select = 1'b0;
        #1;

        if (alu_b == 32'hDEADBEEF)
            $display("RS2 CHANGE test PASSED");
        else
            $display("RS2 CHANGE test FAILED: alu_b = %h", alu_b);


        // Test 4: change immediate and make sure MUX follows it
        immediate = 32'h12345678;
        select = 1'b1;
        #1;

        if (alu_b == 32'h12345678)
            $display("IMMEDIATE CHANGE test PASSED");
        else
            $display("IMMEDIATE CHANGE test FAILED: alu_b = %h", alu_b);


        $display("--------------------------------");
        $display("ALL ALU MUX TESTS COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule