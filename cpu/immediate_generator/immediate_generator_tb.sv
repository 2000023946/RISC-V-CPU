module immediate_generator_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;

    immediate_generator dut(
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin

        // -------------------------
        // I-type: ADDI x5, x1, 10
        // -------------------------
        instruction = 32'h00A08293;
        #1;

        if (immediate == 32'd10)
            $display("Test I-type passed!");
        else
            $display("Test I-type failed! output = %d", immediate);


        // -------------------------
        // S-type: SW x5, 10(x1)
        // -------------------------
        instruction = 32'h0050A523;
        #1;

        if (immediate == 32'd10)
            $display("Test S-type passed!");
        else
            $display("Test S-type failed! output = %d", immediate);


        // -------------------------
        // B-type: BEQ x1, x2, 16
        // -------------------------
        instruction = 32'h00208863;
        #1;

        if (immediate == 32'd16)
            $display("Test B-type passed!");
        else
            $display("Test B-type failed! output = %d", immediate);


        // -------------------------
        // U-type: LUI x5, 0x12345
        // -------------------------
        instruction = 32'h123452B7;
        #1;

        if (immediate == 32'h12345000)
            $display("Test U-type passed!");
        else
            $display("Test U-type failed! output = %h", immediate);


        // -------------------------
        // J-type: JAL x5, 2048
        // -------------------------
        instruction = 32'h001000EF;
        #1;

        if (immediate == 32'd2048)
            $display("Test J-type passed!");
        else
            $display("Test J-type failed! output = %d", immediate);


        $finish;

    end

endmodule

