
# RISC-V CPU in SystemVerilog

A from-scratch **RV32I single-cycle RISC-V processor** implemented in SystemVerilog.

The CPU is built from modular components including the ALU, register file, decoder, immediate generator, program counter, memory, branching, jumps, and writeback logic. Each component has its own testbench.

The project also includes a Python runner for executing RISC-V assembly programs through the CPU.

## Run

```bash
source venv/bin/activate
pip install -r requirements.txt
python3 run.py program.s
```

The assembly file can have any name:

```bash
python3 run.py fibonacci.s
```

The runner assembles the program, generates `program.mem`, compiles the CPU, and runs the simulation.

## CPU Tests

From the `cpu/` directory:

```bash
./test.sh decoder
```

Test an individual module.

```bash
./test_all.sh
```

Run all module testbenches and the full CPU test.

```bash
./test_cpu.sh
```

Compile and run the full CPU testbench.

## Tools

* SystemVerilog
* RISC-V RV32I
* Icarus Verilog / VVP
* Python
* RISC-V assembler
