```bash
#!/bin/bash

for dir in */; do
    name="${dir%/}"

    # Skip directories that don't have a matching module/testbench
    if [[ -f "$dir$name.sv" && -f "$dir${name}_tb.sv" ]]; then

        echo "========================================"
        echo "TESTING: $name"
        echo "========================================"

        cd "$dir"

        iverilog -g2012 -o sim "$name.sv" "${name}_tb.sv"

        if [ $? -eq 0 ]; then
            vvp sim
        else
            echo "❌ COMPILE FAILED: $name"
        fi

        cd ..

        echo ""
    fi
done

echo "========================================"
echo "TESTING: FULL CPU"
echo "========================================"

./test_cpu.sh
```
