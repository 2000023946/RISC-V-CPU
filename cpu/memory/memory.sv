module memory(
    input logic clk,
    input logic reset,
    input logic [31:0] address,
    input logic [31:0] data_write,
    input logic [3:0] memory_op,

    // 0 = instruction fetch
    // 1 = data memory access
    input logic memory_mux_select,

    // Initial program memory
    input logic [31:0] init_memory [0:255],

    output logic [31:0] read_data
);

    // Load operations
    localparam logic [3:0] LB  = 4'b0000;
    localparam logic [3:0] LBU = 4'b0001;
    localparam logic [3:0] LH  = 4'b0010;
    localparam logic [3:0] LHU = 4'b0011;
    localparam logic [3:0] LW  = 4'b0100;

    // Store operations
    localparam logic [3:0] SB  = 4'b0101;
    localparam logic [3:0] SH  = 4'b0110;
    localparam logic [3:0] SW  = 4'b0111;

    // No memory operation
    localparam logic [3:0] NONE = 4'b1000;

    // 1 byte × 1024 locations = 1 KiB
    logic [7:0] memory [0:1023];

    integer i;


    // =========================
    // READ
    // =========================

    always_comb begin

        read_data = 32'b0;

        // ==========================================
        // INSTRUCTION FETCH
        //
        // When memory address comes from the PC,
        // always read a 32-bit instruction.
        // ==========================================

        if (memory_mux_select == 1'b0) begin

            read_data = {
                memory[address[9:0] + 3],
                memory[address[9:0] + 2],
                memory[address[9:0] + 1],
                memory[address[9:0]]
            };

        end

        // ==========================================
        // DATA MEMORY
        //
        // When memory address comes from ALU,
        // use memory_op to determine the operation.
        // ==========================================

        else begin

            case (memory_op)

                // Load Byte - signed
                LB: begin
                    read_data = {
                        {24{memory[address[9:0]][7]}},
                        memory[address[9:0]]
                    };
                end

                // Load Byte - unsigned
                LBU: begin
                    read_data = {
                        24'b0,
                        memory[address[9:0]]
                    };
                end

                // Load Halfword - signed
                LH: begin
                    read_data = {
                        {16{memory[address[9:0] + 1][7]}},
                        memory[address[9:0] + 1],
                        memory[address[9:0]]
                    };
                end

                // Load Halfword - unsigned
                LHU: begin
                    read_data = {
                        16'b0,
                        memory[address[9:0] + 1],
                        memory[address[9:0]]
                    };
                end

                // Load Word
                LW: begin
                    read_data = {
                        memory[address[9:0] + 3],
                        memory[address[9:0] + 2],
                        memory[address[9:0] + 1],
                        memory[address[9:0]]
                    };
                end

                default: begin
                    read_data = 32'b0;
                end

            endcase

        end

    end


    // =========================
    // STORE + INITIALIZATION
    // =========================

    always_ff @(posedge clk) begin

        // Initialize memory during reset
        if (reset) begin

            for (i = 0; i < 256; i = i + 1) begin
                memory[i*4]     <= init_memory[i][7:0];
                memory[i*4 + 1] <= init_memory[i][15:8];
                memory[i*4 + 2] <= init_memory[i][23:16];
                memory[i*4 + 3] <= init_memory[i][31:24];
            end

        end

        else begin

            case (memory_op)

                // Store Byte
                SB: begin
                    memory[address[9:0]] <= data_write[7:0];
                end

                // Store Halfword
                SH: begin
                    memory[address[9:0]]     <= data_write[7:0];
                    memory[address[9:0] + 1] <= data_write[15:8];
                end

                // Store Word
                SW: begin
                    memory[address[9:0]]     <= data_write[7:0];
                    memory[address[9:0] + 1] <= data_write[15:8];
                    memory[address[9:0] + 2] <= data_write[23:16];
                    memory[address[9:0] + 3] <= data_write[31:24];
                end

                default: begin
                    // Do nothing
                end

            endcase

        end

    end

endmodule