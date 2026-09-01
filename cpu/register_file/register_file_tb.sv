module register_file_tb;
    logic clk;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] write_data;
    logic write_enable;
    logic [31:0] read_data_1;
    logic [31:0] read_data_2;

    register_file dut(
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .write_enable(write_enable),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        
        // Test the write and read works
        rd = 1;
        write_data = 5;
        write_enable = 1;
        rs1 = 1;
        @(posedge clk);
        #1;
        if (read_data_1 == 5) $display("TEST 1 passed!");
        else $display("TEST 1 failed! output: %d", read_data_1);

        // test write works on write en = 1
        rd = 1;
        write_data = 10;
        write_enable = 0;
        rs1 = 1;
        @(posedge clk);
        #1;
        if (read_data_1 == 5) $display("TEST 2 passed!");
        else $display("TEST 2 failed! output: %d", read_data_1);

        // test 2 read on 
        rd = 2;
        write_data = 10;
        write_enable = 1;
        rs2 = 2;
        @(posedge clk);
        #1;
        if (read_data_1 == 5 && read_data_2 == 10) $display("TEST 3 passed!");
        else $display("TEST 3 failed! output: %d", read_data_2);

        // test reading x0 is 0
        rs1 = 0;
        #1;
        if (read_data_1 == 0) $display("TEST 4 passed!");
        else $display("TEST 4 failed! output: %d", read_data_1);

        // test wriging x0 is 0
        rd = 0;
        write_data = 10;
        write_enable = 1;
        rs1 = 0;
        @(posedge clk);
        if (read_data_1 == 0) $display("TEST 5 passed!");
        else $display("TEST 5 failed! output: %d", read_data_1);
        
        $finish;
    end
endmodule