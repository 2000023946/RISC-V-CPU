module pc_mux_tb;

    logic [31:0] pc_plus_4;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;
    logic [1:0]  select;
    logic [31:0] next_pc;

    pc_mux dut(
        .pc_plus_4(pc_plus_4),
        .branch_target(branch_target),
        .jal_target(jal_target),
        .jalr_target(jalr_target),
        .select(select),
        .next_pc(next_pc)
    );

    initial begin

        // Give each input a distinct value
        pc_plus_4     = 32'h00000004;
        branch_target = 32'h00000020;
        jal_target    = 32'h00000100;
        jalr_target   = 32'h00001000;

        // Select PC + 4
        select = 2'b00;
        #1;

        if (next_pc == pc_plus_4)
            $display("PC + 4 MUX test PASSED");
        else
            $display("PC + 4 MUX test FAILED: next_pc = %h", next_pc);


        // Select branch target
        select = 2'b01;
        #1;

        if (next_pc == branch_target)
            $display("BRANCH MUX test PASSED");
        else
            $display("BRANCH MUX test FAILED: next_pc = %h", next_pc);


        // Select JAL target
        select = 2'b10;
        #1;

        if (next_pc == jal_target)
            $display("JAL MUX test PASSED");
        else
            $display("JAL MUX test FAILED: next_pc = %h", next_pc);


        // Select JALR target
        select = 2'b11;
        #1;

        if (next_pc == jalr_target)
            $display("JALR MUX test PASSED");
        else
            $display("JALR MUX test FAILED: next_pc = %h", next_pc);


        $display("--------------------------------");
        $display("ALL PC MUX TESTS COMPLETE");
        $display("--------------------------------");

        $finish;
    end

endmodule