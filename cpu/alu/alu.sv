module alu(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] op,
    output logic [31:0] result
);

    // Define the operations of ALU
    localparam logic [3:0] ADD = 0;
    localparam logic [3:0] SUB = 1;
    localparam logic [3:0] AND = 2;
    localparam logic [3:0] OR = 3;
    localparam logic [3:0] XOR = 4;
    localparam logic [3:0] SLL = 5;
    localparam logic [3:0] SRL = 6;
    localparam logic [3:0] SRA = 7;
    localparam logic [3:0] SLT = 8;
    localparam logic [3:0] SLTU = 9;
    localparam logic [3:0] NONE = 10;

    
    always_comb begin 
        case(op)
            ADD:  result = a + b;
            SUB:  result = a - b;
            AND:  result = a & b;
            OR:   result = a | b;
            XOR:  result = a ^ b;
            SLL:  result = a << b[4:0];
            SRL:  result = a >> b[4:0];
            SRA:  result = $signed(a) >>> b[4:0];
            SLT:  result = $signed(a) < $signed(b) ? 1 : 0;
            SLTU: result = a < b ? 1 : 0;
            NONE: result = 32'b0;
            default: result = 32'b0;
        endcase
    end
endmodule