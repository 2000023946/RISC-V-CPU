module memory_mux_tb;

    logic [31:0] pc;
    logic [31:0] alu_result;
    logic select;
    logic [31:0] memory_address;

    memory_mux dut(
        .pc(pc),
        .alu_result(alu_result),
        .select(select),
        .memory_address(memory_address)
    );

    initial begin

        // Give both inputs different addresses
        pc = 32'h00000004;
        alu_result = 32'h00000100;


        // Test 1: Select PC
        select = 1'b0;
        #1;

        if (memory_address == pc)
            $display("PC ADDRESS MUX test PASSED");
        else
            $display("PC ADDRESS MUX test FAILED: memory_address = %h",
                     memory_address);


        // Test 2: Select ALU result
        select = 1'b1;
        #1;

        if (memory_address == alu_result)
            $display("ALU ADDRESS MUX test PASSED");
        else
            $display("ALU ADDRESS MUX test FAILED: memory_address = %h",
                     memory_address);


        // Test 3: Change PC
        pc = 32'h00001000;
        select = 1'b0;
        #1;

        if (memory_address == 32'h00001000)
            $display("PC CHANGE test PASSED");
        else
            $display("PC CHANGE test FAILED: memory_address = %h",
                     memory_address);


        // Test 4: Change ALU result
        alu_result = 32'hDEADBEEF;
        select = 1'b1;
        #1;

        if (memory_address == 32'hDEADBEEF)
            $display("ALU RESULT CHANGE test PASSED");
        else
            $display("ALU RESULT CHANGE test FAILED: memory_address = %h",
                     memory_address);


        $display("--------------------------------");
        $display("ALL MEMORY MUX TESTS COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule