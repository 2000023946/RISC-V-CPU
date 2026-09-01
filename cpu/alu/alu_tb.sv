module alu_tb;
    logic [3:0] op;
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] result;

    alu dut(
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    initial begin

        // Test ADD
        op = 0;
        a = 4;
        b = 6;
        #10
        if (result == 10)
            $display("Test Add 1 Passed!");
        else
            $display("Test Add 1 Failed!");

        // Test SUB
        op = 1;
        a = 4;
        b = 6;
        #10
        if (result == -2)
            $display("Test Add 2 Passed!");
        else
            $display("Test Add 2 Failed!");
        
        // Test AND
        op = 2;
        a = 4;
        b = 6;
        #10
        if (result == 4)
            $display("Test Add 3 Passed!");
        else
            $display("Test Add 3 Failed! output: %d", result);

        // Test OR
        op = 3;
        a = 4;
        b = 6;
        #10
        if (result == 6)
            $display("Test Add 4 Passed!");
        else
            $display("Test Add 4 Failed! output: %d", result);

        // Test OR
        op = 4;
        a = 4;
        b = 6;
        #10
        if (result == 2)
            $display("Test Add 5 Passed!");
        else
            $display("Test Add 5 Failed! output: %d", result);
        
        // test sll
        op = 5;
        a = 4;
        b = 6;
        #10
        if (result == 256)
            $display("Test Add 6 Passed!");
        else
            $display("Test Add 6 Failed! output: %d", result);

        // test srl
        op = 6;
        a = 4;
        b = 2;
        #10
        if (result == 1)
            $display("Test Add 7 Passed!");
        else
            $display("Test Add 7 Failed! output: %d", result);

        // test sra
        op = 7;
        a = -4;
        b = 2;
        #10
        if (result == -1)
            $display("Test Add 8 Passed!");
        else
            $display("Test Add 8 Failed! output: %d", result);

        // test slt
        op = 8;
        a = -6;
        b = -2;
        #10
        if (result == 1)
            $display("Test Add 9 Passed!");
        else
            $display("Test Add 9 Failed! output: %d", result);

        // test sltu
        op = 9;
        a = 6;
        b = 2;
        #10
        if (result == 0)
            $display("Test Add 10 Passed!");
        else
            $display("Test Add 10 Failed! output: %d", result);
        $finish; 
    end
endmodule
