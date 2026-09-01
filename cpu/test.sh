
#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: ./test.sh <directory>"
    exit 1
fi

dir="$1"

if [ ! -d "$dir" ]; then
    echo "Error: directory '$dir' does not exist."
    exit 1
fi

iverilog -g2012 -o "$dir/sim" \
    "$dir/$dir.sv" \
    "$dir/${dir}_tb.sv"

if [ $? -ne 0 ]; then
    echo "Compilation failed: $dir"
    exit 1
fi

vvp "$dir/sim"
