# RISC-V CPU in SystemVerilog

A from-scratch **RV32I single-cycle RISC-V processor** implemented in SystemVerilog. The CPU is built from individual modules for the ALU, register file, instruction decoder, immediate generator, program counter, memory, branching, jumps, and writeback logic.

Each major component has its own testbench, and the components are integrated into a complete CPU capable of executing RISC-V assembly programs.

The project also includes a Python runner that automatically assembles an `.s` file into machine code, generates `program.mem`, compiles the SystemVerilog CPU, and runs the simulation with an instruction-by-instruction execution trace.

## Running

Activate the virtual environment:

```bash
source venv/bin/activate
```

Install the Python dependency:

```bash
pip install -r requirements.txt
```

Run an assembly program:

```bash
python3 run.py program.s
```

The assembly file can have any name:

```bash
python3 run.py program.s
```

The Python script automatically:

1. Assembles the RISC-V program.
2. Generates `program.mem`.
3. Compiles the SystemVerilog CPU using Icarus Verilog.
4. Runs the simulation with VVP.
5. Prints the CPU execution trace.

## Tools

* SystemVerilog
* Icarus Verilog / VVP
* Python
* RISC-V assembler
