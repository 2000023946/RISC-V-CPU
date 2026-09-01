
#!/bin/bash

iverilog -g2012 -o sim \
    cpu.sv \
    alu/alu.sv \
    alu_mux/alu_mux.sv \
    branch_decision/branch_decision.sv \
    branch_mux/branch_mux.sv \
    decoder/decoder.sv \
    immediate_generator/immediate_generator.sv \
    memory/memory.sv \
    memory_mux/memory_mux.sv \
    mux/mux.sv \
    pc_calculator/pc_calculator.sv \
    pc_mux/pc_mux.sv \
    program_counter/program_counter.sv \
    register_file/register_file.sv \
    writeback_mux/writeback_mux.sv \
    cpu_tb.sv

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed."
    exit 1
fi

vvp sim

