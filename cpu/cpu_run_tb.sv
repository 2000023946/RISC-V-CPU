module cpu_run_tb;

    logic clk;
    logic reset;

    logic [31:0] init_memory [0:255];

    cpu dut(
        .reset(reset),
        .clk(clk),
        .init_memory(init_memory)
    );

    // ============================================================
    // CLOCK
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // REGISTER NAME
    // ============================================================

    function automatic string reg_name(input logic [4:0] reg_num);
        reg_name = $sformatf("x%0d", reg_num);
    endfunction


    // ============================================================
    // PRINT INSTRUCTION
    // ============================================================

    task automatic print_instruction(input logic [31:0] instruction);

        logic [6:0] opcode;
        logic [2:0] funct3;
        logic [6:0] funct7;

        logic [4:0] rs1;
        logic [4:0] rs2;
        logic [4:0] rd;

        logic signed [31:0] imm;

        begin

            opcode = instruction[6:0];
            funct3 = instruction[14:12];
            funct7 = instruction[31:25];

            rs1 = instruction[19:15];
            rs2 = instruction[24:20];
            rd  = instruction[11:7];

            case (opcode)

                // =================================================
                // R-TYPE
                // =================================================

                7'b0110011: begin

                    case ({funct7, funct3})

                        {7'b0000000, 3'b000}:
                            $display("    ADD  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0100000, 3'b000}:
                            $display("    SUB  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b111}:
                            $display("    AND  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b110}:
                            $display("    OR   %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b100}:
                            $display("    XOR  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b001}:
                            $display("    SLL  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b101}:
                            $display("    SRL  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0100000, 3'b101}:
                            $display("    SRA  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b010}:
                            $display("    SLT  %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        {7'b0000000, 3'b011}:
                            $display("    SLTU %s, %s, %s",
                                reg_name(rd),
                                reg_name(rs1),
                                reg_name(rs2));

                        default:
                            $display("    UNKNOWN R-TYPE");

                    endcase
                end


                // =================================================
                // I-TYPE ALU
                // =================================================

                7'b0010011: begin

                    imm = {
                        {20{instruction[31]}},
                        instruction[31:20]
                    };

                    case (funct3)

                        3'b000:
                            $display("    ADDI %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        3'b111:
                            $display("    ANDI %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        3'b110:
                            $display("    ORI  %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        3'b100:
                            $display("    XORI %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        3'b010:
                            $display("    SLTI %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        3'b011:
                            $display("    SLTIU %s, %s, %0d",
                                reg_name(rd),
                                reg_name(rs1),
                                imm);

                        default:
                            $display("    UNKNOWN I-TYPE");

                    endcase
                end


                // =================================================
                // LOAD
                // =================================================

                7'b0000011: begin

                    imm = {
                        {20{instruction[31]}},
                        instruction[31:20]
                    };

                    case (funct3)

                        3'b000:
                            $display("    LB   %s, %0d(%s)",
                                reg_name(rd),
                                imm,
                                reg_name(rs1));

                        3'b001:
                            $display("    LH   %s, %0d(%s)",
                                reg_name(rd),
                                imm,
                                reg_name(rs1));

                        3'b010:
                            $display("    LW   %s, %0d(%s)",
                                reg_name(rd),
                                imm,
                                reg_name(rs1));

                        3'b100:
                            $display("    LBU  %s, %0d(%s)",
                                reg_name(rd),
                                imm,
                                reg_name(rs1));

                        3'b101:
                            $display("    LHU  %s, %0d(%s)",
                                reg_name(rd),
                                imm,
                                reg_name(rs1));

                        default:
                            $display("    UNKNOWN LOAD");

                    endcase
                end


                // =================================================
                // STORE
                // =================================================

                7'b0100011: begin

                    imm = {
                        {20{instruction[31]}},
                        instruction[31:25],
                        instruction[11:7]
                    };

                    case (funct3)

                        3'b000:
                            $display("    SB   %s, %0d(%s)",
                                reg_name(rs2),
                                imm,
                                reg_name(rs1));

                        3'b001:
                            $display("    SH   %s, %0d(%s)",
                                reg_name(rs2),
                                imm,
                                reg_name(rs1));

                        3'b010:
                            $display("    SW   %s, %0d(%s)",
                                reg_name(rs2),
                                imm,
                                reg_name(rs1));

                        default:
                            $display("    UNKNOWN STORE");

                    endcase
                end


                // =================================================
                // BRANCH
                // =================================================

                7'b1100011: begin

                    imm = {
                        {19{instruction[31]}},
                        instruction[31],
                        instruction[7],
                        instruction[30:25],
                        instruction[11:8],
                        1'b0
                    };

                    case (funct3)

                        3'b000:
                            $display("    BEQ  %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        3'b001:
                            $display("    BNE  %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        3'b100:
                            $display("    BLT  %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        3'b101:
                            $display("    BGE  %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        3'b110:
                            $display("    BLTU %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        3'b111:
                            $display("    BGEU %s, %s, %0d",
                                reg_name(rs1),
                                reg_name(rs2),
                                imm);

                        default:
                            $display("    UNKNOWN BRANCH");

                    endcase
                end


                // =================================================
                // JAL
                // =================================================

                7'b1101111: begin

                    imm = {
                        {11{instruction[31]}},
                        instruction[31],
                        instruction[19:12],
                        instruction[20],
                        instruction[30:21],
                        1'b0
                    };

                    $display("    JAL  %s, %0d",
                        reg_name(rd),
                        imm);

                end


                // =================================================
                // JALR
                // =================================================

                7'b1100111: begin

                    imm = {
                        {20{instruction[31]}},
                        instruction[31:20]
                    };

                    $display("    JALR %s, %0d(%s)",
                        reg_name(rd),
                        imm,
                        reg_name(rs1));

                end


                // =================================================
                // LUI
                // =================================================

                7'b0110111: begin

                    $display("    LUI  %s, 0x%05h",
                        reg_name(rd),
                        instruction[31:12]);

                end


                // =================================================
                // AUIPC
                // =================================================

                7'b0010111: begin

                    $display("    AUIPC %s, 0x%05h",
                        reg_name(rd),
                        instruction[31:12]);

                end


                // =================================================
                // UNKNOWN
                // =================================================

                default: begin
                    $display("    UNKNOWN instruction (opcode = %07b)",
                        opcode);
                end

            endcase

        end
    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    integer i;
    integer instruction_count;

    logic [31:0] trace_pc;
    logic [31:0] trace_instruction;

    initial begin

        clk = 1'b0;
        reset = 1'b1;

        // Initialize memory array.
        for (i = 0; i < 256; i = i + 1) begin
            init_memory[i] = 32'b0;
        end

        // Load assembled program.
        $readmemh("program.mem", init_memory);

        // Give the CPU one reset clock edge.
        #10;
        reset = 1'b0;

        $display("");
        $display("==================================================");
        $display("             RISC-V CPU EXECUTION");
        $display("==================================================");
        $display("");

        instruction_count = 0;

        // ========================================================
        // Execute instructions
        // ========================================================

        while (instruction_count < 1000) begin

            #1;

            trace_pc = dut.current_pc;
            trace_instruction = dut.instruction;

            // 00000000 means we reached unused program memory.
            if (trace_instruction == 32'b0) begin
                break;
            end

            instruction_count = instruction_count + 1;

            $display("[%0d] PC = 0x%08h | INSTRUCTION = 0x%08h",
                instruction_count,
                trace_pc,
                trace_instruction);

            print_instruction(trace_instruction);

            // Execute instruction on clock edge.
            @(posedge clk);

            // Allow register writeback / sequential logic to settle.
            #1;

            // Print relevant result.
            case (trace_instruction[6:0])

                // R-type
                7'b0110011: begin
                    if (trace_instruction[11:7] != 5'd0)
                        $display("    Result: %s = 0x%08h",
                            reg_name(trace_instruction[11:7]),
                            dut.cpu_register_file.registers[
                                trace_instruction[11:7]
                            ]);
                end

                // I-type ALU
                7'b0010011: begin
                    if (trace_instruction[11:7] != 5'd0)
                        $display("    Result: %s = 0x%08h",
                            reg_name(trace_instruction[11:7]),
                            dut.cpu_register_file.registers[
                                trace_instruction[11:7]
                            ]);
                end

                // Loads
                7'b0000011: begin
                    if (trace_instruction[11:7] != 5'd0)
                        $display("    Loaded: %s = 0x%08h",
                            reg_name(trace_instruction[11:7]),
                            dut.cpu_register_file.registers[
                                trace_instruction[11:7]
                            ]);
                end

                // JAL/JALR
                7'b1101111,
                7'b1100111: begin
                    if (trace_instruction[11:7] != 5'd0)
                        $display("    Link: %s = 0x%08h",
                            reg_name(trace_instruction[11:7]),
                            dut.cpu_register_file.registers[
                                trace_instruction[11:7]
                            ]);
                end

                // Stores
                7'b0100011: begin
                    $display("    Store executed.");
                end

                // Branches
                7'b1100011: begin
                    if (dut.branch_taken)
                        $display("    Branch TAKEN.");
                    else
                        $display("    Branch NOT TAKEN.");
                end

                default: begin
                end

            endcase

            $display("");

        end


        // ========================================================
        // Finished
        // ========================================================

        if (instruction_count >= 1000) begin

            $display("==================================================");
            $display("WARNING: Reached 1000 instruction limit.");
            $display("Possible infinite loop.");
            $display("==================================================");

        end
        else begin

            $display("==================================================");
            $display("             PROGRAM FINISHED");
            $display("==================================================");
            $display("Instructions executed: %0d", instruction_count);
            $display("Final PC: 0x%08h", dut.current_pc);
            $display("==================================================");

        end

        $finish;

    end

endmodule