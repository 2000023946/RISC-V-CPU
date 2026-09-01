module mux_2_to_1_tb;
    logic a;
    logic b;
    logic sel;
    logic y;

    mux_2_to_1 dut(
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin

        // TESTING Selection A
        a = 0;
        b = 0;
        sel = 0;
        #10
        if (y == 0) $display("test 1A passed!");
        else $display("test 1A failed!");

        a = 1;
        b = 0;
        sel = 0;
        #10
        if (y == 1) $display("test 2A passed!");
        else $display("test 2A failed!");

        a = 0;
        b = 1;
        sel = 0;
        #10
        if (y == 0) $display("test 3A passed!");
        else $display("test 3A failed!");

        a = 1;
        b = 0;
        sel = 0;
        #10
        if (y == 1) $display("test 4A passed!");
        else $display("test 4A failed!");
            
        // TESTING Selection B
        a = 0;
        b = 0;
        sel = 1;
        #10
        if (y == 0) $display("test 1B passed!");
        else $display("test 1B failed!");

        a = 1;
        b = 0;
        sel = 1;
        #10
        if (y == 0) $display("test 2B passed!");
        else $display("test 2B failed!");

        a = 0;
        b = 1;
        sel = 1;
        #10
        if (y == 1) $display("test 3B passed!");
        else $display("test 3B failed!");

        a = 1;
        b = 0;
        sel = 1;
        #10
        if (y == 0) $display("test 4B passed!");
        else $display("test 4B failed!");
        $finish;
    end
endmodule