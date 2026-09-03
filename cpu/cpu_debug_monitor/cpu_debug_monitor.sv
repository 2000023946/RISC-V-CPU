module cpu_debug_monitor(
    input logic clk,
    input logic reset,
    
    input logic [31:0] current_pc,
    input logic [31:0] if_id_pc,
    input logic [31:0] id_ex_pc,
    input logic [31:0] if_id_instruction,
    
    input logic if_id_valid,
    input logic id_ex_valid,
    input logic ex_mem_valid,
    input logic mem_wb_valid,
    
    input logic stall,
    input logic flush
);

    always @(posedge clk) begin
        if (!reset) begin
            $display(
                "PC=%h | IFID_PC=%h | IDEX_PC=%h | INST=%h | VALIDS=%b%b%b%b | STALL=%b | FLUSH=%b",
                current_pc,
                if_id_pc,
                id_ex_pc,
                if_id_instruction,
                if_id_valid, id_ex_valid, ex_mem_valid, mem_wb_valid,
                stall,
                flush
            );
        end
    end

endmodule