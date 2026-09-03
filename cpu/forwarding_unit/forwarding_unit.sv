module forwarding_unit(
    input logic [4:0] id_ex_rs1,
    input logic [4:0] id_ex_rs2,

    input logic [4:0] ex_mem_rd,
    input logic       ex_mem_register_write_enable,

    input logic [4:0] mem_wb_rd,
    input logic       mem_wb_register_write_enable,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin

        // Default:
        // Use the values read from the register file.
        forward_a = 2'b00;
        forward_b = 2'b00;


        // ========================================================
        // ALU A
        // ========================================================

        // EX/MEM has the newest value, so it gets priority.
        if (ex_mem_register_write_enable &&
            (ex_mem_rd != 5'b0) &&
            (ex_mem_rd == id_ex_rs1)) begin

            forward_a = 2'b10;
        end

        // Otherwise check MEM/WB.
        else if (mem_wb_register_write_enable &&
                 (mem_wb_rd != 5'b0) &&
                 (mem_wb_rd == id_ex_rs1)) begin

            forward_a = 2'b01;
        end


        // ========================================================
        // ALU B
        // ========================================================

        if (ex_mem_register_write_enable &&
            (ex_mem_rd != 5'b0) &&
            (ex_mem_rd == id_ex_rs2)) begin

            forward_b = 2'b10;
        end

        else if (mem_wb_register_write_enable &&
                 (mem_wb_rd != 5'b0) &&
                 (mem_wb_rd == id_ex_rs2)) begin

            forward_b = 2'b01;
        end

    end

endmodule