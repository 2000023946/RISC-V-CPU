module forwarding_mux(
    input  logic [31:0] register_value,
    input  logic [31:0] ex_mem_value,
    input  logic [31:0] mem_wb_value,

    input  logic [1:0] forward_select,

    output logic [31:0] selected_value
);

    always_comb begin
        case (forward_select)
            2'b00: selected_value = register_value;
            2'b01: selected_value = mem_wb_value;
            2'b10: selected_value = ex_mem_value;
            default: selected_value = register_value;
        endcase
    end

endmodule