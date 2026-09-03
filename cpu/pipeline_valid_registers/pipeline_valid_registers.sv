module pipeline_valid_registers(
    input logic clk,
    input logic reset,
    input logic stall,
    input logic flush,
    
    output logic if_id_valid,
    output logic id_ex_valid,
    output logic ex_mem_valid,
    output logic mem_wb_valid
);

    always_ff @(posedge clk) begin
        if (reset) begin
            if_id_valid  <= 1'b0;
            id_ex_valid  <= 1'b0;
            ex_mem_valid <= 1'b0;
            mem_wb_valid <= 1'b0;
        end else begin
            
            // IF/ID Stage
            if (flush) begin
                if_id_valid <= 1'b0;
            end else if (!stall) begin
                if_id_valid <= 1'b1;
            end
            
            // ID/EX Stage
            if (stall || flush) begin
                id_ex_valid <= 1'b0;
            end else begin
                id_ex_valid <= if_id_valid;
            end
            
            // EX/MEM Stage
            ex_mem_valid <= id_ex_valid;
            
            // MEM/WB Stage
            mem_wb_valid <= ex_mem_valid;
            
        end
    end

endmodule