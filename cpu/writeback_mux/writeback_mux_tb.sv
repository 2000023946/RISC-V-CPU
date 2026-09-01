module writeback_mux_tb;

    logic [31:0] alu_result;
    logic [31:0] memory_data;
    logic [31:0] pc_plus_4;

    logic [1:0] select;

    logic [31:0] write_data;

    writeback_mux dut(
        .alu_result(alu_result),
        .memory_data(memory_data),
        .pc_plus_4(pc_plus_4),
        .select(select),
        .write_data(write_data)
    );

    localparam logic [1:0] ALU    = 2'b00;
    localparam logic [1:0] MEMORY = 2'b01;
    localparam logic [1:0] PC_4   = 2'b10;

    initial begin

        // ALU result
        alu_result = 32'd100;
        memory_data = 32'd200;
        pc_plus_4 = 32'd300;
        select = ALU;

        #1;

        if (write_data == 32'd100)
            $display("ALU WRITEBACK TEST PASSED");
        else
            $display("ALU WRITEBACK TEST FAILED");


        // Memory data
        alu_result = 32'd100;
        memory_data = 32'd200;
        pc_plus_4 = 32'd300;
        select = MEMORY;

        #1;

        if (write_data == 32'd200)
            $display("MEMORY WRITEBACK TEST PASSED");
        else
            $display("MEMORY WRITEBACK TEST FAILED");


        // PC + 4
        alu_result = 32'd100;
        memory_data = 32'd200;
        pc_plus_4 = 32'd300;
        select = PC_4;

        #1;

        if (write_data == 32'd300)
            $display("PC+4 WRITEBACK TEST PASSED");
        else
            $display("PC+4 WRITEBACK TEST FAILED");


        // Invalid select
        alu_result = 32'd100;
        memory_data = 32'd200;
        pc_plus_4 = 32'd300;
        select = 2'b11;

        #1;

        if (write_data == 32'b0)
            $display("INVALID SELECT TEST PASSED");
        else
            $display("INVALID SELECT TEST FAILED");


        $display("--------------------------------");
        $display("ALL WRITEBACK MUX TESTS COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule