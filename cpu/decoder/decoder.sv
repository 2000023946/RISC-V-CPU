
module decoder(
    input logic [31:0] instruction,

    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,

    output logic [3:0] alu_op,
    output logic [3:0] mem_op,
    output logic register_write_enable,
    output logic alu_mux_select,
    output logic [1:0] pc_mux_select,
    output logic memory_mux_select,
    output logic [2:0] branch_type,
    output logic [1:0] writeback_select
);

    // ALU operations
    localparam logic [3:0] ADD  = 4'd0;
    localparam logic [3:0] SUB  = 4'd1;
    localparam logic [3:0] AND  = 4'd2;
    localparam logic [3:0] OR   = 4'd3;
    localparam logic [3:0] XOR  = 4'd4;
    localparam logic [3:0] SLL  = 4'd5;
    localparam logic [3:0] SRL  = 4'd6;
    localparam logic [3:0] SRA  = 4'd7;
    localparam logic [3:0] SLT  = 4'd8;
    localparam logic [3:0] SLTU = 4'd9;
    localparam logic [3:0] NONE = 4'd10;

    // Memory operations
    localparam logic [3:0] LB       = 4'd0;
    localparam logic [3:0] LBU      = 4'd1;
    localparam logic [3:0] LH       = 4'd2;
    localparam logic [3:0] LHU      = 4'd3;
    localparam logic [3:0] LW       = 4'd4;
    localparam logic [3:0] SB       = 4'd5;
    localparam logic [3:0] SH       = 4'd6;
    localparam logic [3:0] SW       = 4'd7;
    localparam logic [3:0] MEM_NONE = 4'd8;

    // Opcodes
    localparam logic [6:0] R_TYPE = 7'b0110011;
    localparam logic [6:0] I_TYPE = 7'b0010011;
    localparam logic [6:0] LOAD   = 7'b0000011;
    localparam logic [6:0] STORE  = 7'b0100011;
    localparam logic [6:0] BRANCH = 7'b1100011;
    localparam logic [6:0] LUI    = 7'b0110111;
    localparam logic [6:0] AUIPC  = 7'b0010111;
    localparam logic [6:0] JAL    = 7'b1101111;
    localparam logic [6:0] JALR   = 7'b1100111;

    // PC MUX selections
    localparam logic [1:0] PC_PLUS_4 = 2'b00;
    localparam logic [1:0] PC_BRANCH = 2'b01;
    localparam logic [1:0] PC_JAL    = 2'b10;
    localparam logic [1:0] PC_JALR   = 2'b11;

    // Branch types
    localparam logic [2:0] BEQ  = 3'b000;
    localparam logic [2:0] BNE  = 3'b001;
    localparam logic [2:0] BLT  = 3'b100;
    localparam logic [2:0] BGE  = 3'b101;
    localparam logic [2:0] BLTU = 3'b110;
    localparam logic [2:0] BGEU = 3'b111;

    // Writeback selections
    localparam logic [1:0] WB_ALU    = 2'b00;
    localparam logic [1:0] WB_MEMORY = 2'b01;
    localparam logic [1:0] WB_PC_4   = 2'b10;

    always_comb begin

        // Default values
        rs1 = 5'b0;
        rs2 = 5'b0;
        rd  = 5'b0;

        alu_op = NONE;
        mem_op = MEM_NONE;

        register_write_enable = 1'b0;
        alu_mux_select = 1'b0;
        pc_mux_select = PC_PLUS_4;
        memory_mux_select = 1'b0;
        branch_type = 3'b000;

        writeback_select = WB_ALU;


        // R-TYPE
        if (instruction[6:0] == R_TYPE) begin

            rd  = instruction[11:7];
            rs1 = instruction[19:15];
            rs2 = instruction[24:20];

            register_write_enable = 1'b1;
            alu_mux_select = 1'b0;
            writeback_select = WB_ALU;

            if (instruction[31:25] == 7'b0000000) begin

                case (instruction[14:12])

                    3'b000: alu_op = ADD;
                    3'b111: alu_op = AND;
                    3'b110: alu_op = OR;
                    3'b100: alu_op = XOR;
                    3'b001: alu_op = SLL;
                    3'b101: alu_op = SRL;
                    3'b010: alu_op = SLT;
                    3'b011: alu_op = SLTU;

                    default: begin
                        alu_op = NONE;
                        register_write_enable = 1'b0;
                    end

                endcase

            end

            else if (instruction[31:25] == 7'b0100000) begin

                case (instruction[14:12])

                    3'b000: alu_op = SUB;
                    3'b101: alu_op = SRA;

                    default: begin
                        alu_op = NONE;
                        register_write_enable = 1'b0;
                    end

                endcase

            end

            else begin
                alu_op = NONE;
                register_write_enable = 1'b0;
            end

        end


        // I-TYPE ALU
        else if (instruction[6:0] == I_TYPE) begin

            rd  = instruction[11:7];
            rs1 = instruction[19:15];

            register_write_enable = 1'b1;
            alu_mux_select = 1'b1;
            writeback_select = WB_ALU;

            case (instruction[14:12])

                3'b000: alu_op = ADD;   // ADDI
                3'b010: alu_op = SLT;   // SLTI
                3'b011: alu_op = SLTU;  // SLTIU
                3'b100: alu_op = XOR;   // XORI
                3'b110: alu_op = OR;    // ORI
                3'b111: alu_op = AND;   // ANDI
                3'b001: alu_op = SLL;   // SLLI

                3'b101: begin

                    if (instruction[31:25] == 7'b0000000)
                        alu_op = SRL;

                    else if (instruction[31:25] == 7'b0100000)
                        alu_op = SRA;

                    else begin
                        alu_op = NONE;
                        register_write_enable = 1'b0;
                    end

                end

                default: begin
                    alu_op = NONE;
                    register_write_enable = 1'b0;
                end

            endcase

        end


        // LOAD
        else if (instruction[6:0] == LOAD) begin

            rd  = instruction[11:7];
            rs1 = instruction[19:15];

            alu_op = ADD;
            alu_mux_select = 1'b1;

            memory_mux_select = 1'b1;

            register_write_enable = 1'b1;
            writeback_select = WB_MEMORY;

            case (instruction[14:12])

                3'b000: mem_op = LB;
                3'b001: mem_op = LH;
                3'b010: mem_op = LW;
                3'b100: mem_op = LBU;
                3'b101: mem_op = LHU;

                default: begin
                    mem_op = MEM_NONE;
                    register_write_enable = 1'b0;
                end

            endcase

        end


        // STORE
        else if (instruction[6:0] == STORE) begin

            rs1 = instruction[19:15];
            rs2 = instruction[24:20];

            alu_op = ADD;
            alu_mux_select = 1'b1;

            memory_mux_select = 1'b1;

            register_write_enable = 1'b0;

            case (instruction[14:12])

                3'b000: mem_op = SB;
                3'b001: mem_op = SH;
                3'b010: mem_op = SW;

                default:
                    mem_op = MEM_NONE;

            endcase

        end


        // BRANCH
        else if (instruction[6:0] == BRANCH) begin

            rs1 = instruction[19:15];
            rs2 = instruction[24:20];

            alu_mux_select = 1'b0;
            pc_mux_select = PC_BRANCH;
            branch_type = instruction[14:12];

            register_write_enable = 1'b0;

            case (instruction[14:12])

                BEQ: begin
                    alu_op = SUB;
                end

                BNE: begin
                    alu_op = SUB;
                end

                BLT: begin
                    alu_op = SLT;
                end

                BGE: begin
                    alu_op = SLT;
                end

                BLTU: begin
                    alu_op = SLTU;
                end

                BGEU: begin
                    alu_op = SLTU;
                end

                default: begin
                    alu_op = NONE;
                    branch_type = 3'b000;
                end

            endcase

        end


        // LUI
        else if (instruction[6:0] == LUI) begin

            rd = instruction[11:7];

            alu_op = ADD;
            alu_mux_select = 1'b1;

            register_write_enable = 1'b1;
            writeback_select = WB_ALU;

        end


        // AUIPC
        else if (instruction[6:0] == AUIPC) begin

            rd = instruction[11:7];

            alu_op = ADD;
            alu_mux_select = 1'b1;

            register_write_enable = 1'b1;
            writeback_select = WB_ALU;

        end


        // JAL
        else if (instruction[6:0] == JAL) begin

            rd = instruction[11:7];

            pc_mux_select = PC_JAL;

            register_write_enable = 1'b1;

            writeback_select = WB_PC_4;

            alu_op = NONE;

        end


        // JALR
        else if (instruction[6:0] == JALR) begin

            rd  = instruction[11:7];
            rs1 = instruction[19:15];

            alu_op = ADD;
            alu_mux_select = 1'b1;

            pc_mux_select = PC_JALR;

            register_write_enable = 1'b1;
            writeback_select = WB_PC_4;

        end

    end

endmodule

