#!/bin/bash

iverilog -g2012 -o sim \
    cpu.sv \
    $(find . -mindepth 2 -name "*.sv" ! -name "*_tb.sv") \
    cpu_tb.sv

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed."
    exit 1
fi

echo "✅ Compilation successful."
echo ""

vvp sim