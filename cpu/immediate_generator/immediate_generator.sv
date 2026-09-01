module immediate_generator(
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

    always_comb begin

        // Default
        immediate = 32'b0;

        // I-type
        if (instruction[6:0] == 7'b0010011 ||
            instruction[6:0] == 7'b0000011 ||
            instruction[6:0] == 7'b1100111) begin

            immediate = {{20{instruction[31]}},
                         instruction[31:20]};
        end

        // S-type
        else if (instruction[6:0] == 7'b0100011) begin

            immediate = {{20{instruction[31]}},
                         instruction[31:25],
                         instruction[11:7]};
        end

        // B-type
        else if (instruction[6:0] == 7'b1100011) begin

            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};
        end

        // U-type
        else if (instruction[6:0] == 7'b0110111 ||
                 instruction[6:0] == 7'b0010111) begin

            immediate = {instruction[31:12],
                         12'b0};
        end

        // J-type
        else if (instruction[6:0] == 7'b1101111) begin

            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};
        end

    end

endmodule