module password_detector_tb;
    logic [3:0] new_password;
    logic serial_in;
    logic en_renter;

    logic clk;
    logic reset;

    logic password_success;
    logic password_error;

    logic [2:0] state_out;
    logic [2:0] progress;
    logic [3:0] pass;

    password_detector dut(
        .new_password(new_password),
        .serial_in(serial_in),
        .en_renter(en_renter),
        .clk(clk),
        .reset(reset),
        .password_success(password_success),
        .password_error(password_error),
        .state_out(state_out),
        .progress(progress),
        .pass(pass)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 0 
            && progress == 0 && pass == 0) 
            $display("Test 1 passed!");
        else $display("Test 1 failed!");

        // idle state
        reset = 0;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 1 
            && progress == 0 && pass == 0) 
            $display("Test 2 passed!");
        else $display("Test 2 failed!");
        
        //configure the password
        new_password = 4'b0110;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2 
            && progress == 0 && pass == 4'b0110) 
            $display("Test 3 passed!");
        else $display("Test 3 failed! pass: %d", pass);
        
        // enter the password
        serial_in = 0;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 1 && pass == 4'b0110) 
            $display("Test 4 passed!");
        else $display("Test 4 failed!");

        serial_in = 1;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 2 && pass == 4'b0110) 
            $display("Test 5 passed!");
        else $display("Test 5 failed!");

        serial_in = 1;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 3 && pass == 4'b0110) 
            $display("Test 6 passed!");
        else $display("Test 6 failed! out: %d", state_out);

        serial_in = 0;
        @(posedge clk);
        #1;
        if (password_success == 1 && password_error == 0 && state_out == 4
            && progress == 3 && pass == 4'b0110) 
            $display("Test 7 passed!");
        else $display("Test 7 failed! out: %d", state_out);

        // Success wait 
        serial_in = 0;
        new_password = 3;
        @(posedge clk);
        #5;
        if (password_success == 1 && password_error == 0 && state_out == 4
            && progress == 3 && pass == 4'b0110) 
            $display("Test 8 passed!");
        else $display("Test 8 failed! out: %d", state_out);

        // go back to enter password
        en_renter = 1;
        serial_in = 0;
        new_password = 3;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 0 && pass == 4'b0110) 
            $display("Test 9 passed!");
        else $display("Test 9 failed! out: %d", state_out);
        

        // for fail case
        serial_in = 0;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 1 && pass == 4'b0110) 
            $display("Test 10 passed!");
        else $display("Test 10 failed!");

        // fail now 
        
        serial_in = 0;
        @(posedge clk);
        #1;
        if (password_success == 0 && password_error == 1 && state_out == 3
            && progress == 1 && pass == 4'b0110) 
            $display("Test 10 passed!");
        else $display("Test 10 failed! out: %d", state_out);
        
        en_renter = 0;
        // wait
        serial_in = 0;
        @(posedge clk);
        #4;
        if (password_success == 0 && password_error == 1 && state_out == 3
            && progress == 1 && pass == 4'b0110) 
            $display("Test 11 passed!");
        else $display("Test 11 failed! out: %d", state_out);
        
        // error -> re enter
        serial_in = 0;
        en_renter = 1;
        @(posedge clk);
        #4;
        if (password_success == 0 && password_error == 0 && state_out == 2
            && progress == 0 && pass == 4'b0110) 
            $display("Test 12 passed!");
        else $display("Test 12 failed! out: %d", state_out);

        $finish;
    end
endmodule