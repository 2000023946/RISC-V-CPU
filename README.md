

# RISC-V RV32I Pipelined CPU

A 5-stage pipelined RV32I RISC-V processor implemented from scratch in SystemVerilog. 

Upgraded from a single-cycle architecture, this CPU features full data forwarding, load-use hazard detection (stalling), and control hazard mitigation (flushing). The project includes a custom Python runner for assembling and executing standard RISC-V assembly programs directly on the simulated hardware, complete with cycle-accurate benchmark tracking.

## Example Execution

Given a simple RISC-V assembly program (`program.s`):

```assembly
addi x1, x0, 5
addi x2, x0, 7
add  x3, x1, x2

```

Running the program through the Python orchestrator tracks the pipeline state on every clock edge and outputs architectural performance metrics:

```text
==================================================
             RISC-V CPU EXECUTION
==================================================

[1] PC = 0x00000000 | INSTRUCTION = 0x00500093
    ADDI x1, x0, 5
PC=00000000 | IFID_PC=00000000 | IDEX_PC=00000000 | INST=00000000 | VALIDS=0000 | STALL=0 | FLUSH=0
    Result: x1 = 0x00000000

[2] PC = 0x00000004 | INSTRUCTION = 0x00700113
    ADDI x2, x0, 7
PC=00000004 | IFID_PC=00000000 | IDEX_PC=00000000 | INST=00500093 | VALIDS=1000 | STALL=0 | FLUSH=0
    Result: x2 = 0x00000000

[3] PC = 0x00000008 | INSTRUCTION = 0x002081b3
    ADD  x3, x1, x2
PC=00000008 | IFID_PC=00000004 | IDEX_PC=00000000 | INST=00700113 | VALIDS=1100 | STALL=0 | FLUSH=0
    Result: x3 = 0x00000000

PC=0000000c | IFID_PC=00000008 | IDEX_PC=00000004 | INST=002081b3 | VALIDS=1110 | STALL=0 | FLUSH=0
PC=00000010 | IFID_PC=0000000c | IDEX_PC=00000008 | INST=00000000 | VALIDS=1111 | STALL=0 | FLUSH=0
PC=00000014 | IFID_PC=00000010 | IDEX_PC=0000000c | INST=00000000 | VALIDS=1111 | STALL=0 | FLUSH=0
PC=00000018 | IFID_PC=00000014 | IDEX_PC=00000010 | INST=00000000 | VALIDS=1111 | STALL=0 | FLUSH=0
PC=0000001c | IFID_PC=00000018 | IDEX_PC=00000014 | INST=00000000 | VALIDS=1111 | STALL=0 | FLUSH=0

==================================================
             PROGRAM FINISHED
==================================================
Instructions Fetched: 3
Final PC: 0x00000020

========================================
           BENCHMARK RESULTS            
========================================
Cycles Executed:       8
Instructions Retired:  4
Pipeline Stalls:       0
Pipeline Flushes:      0
CPI (Cycles/Inst):     2.000000
========================================

```

## Repository Structure

* `run.py` — Python execution script. Assembles `.s` code, generates memory, and runs the CPU simulation.
* `program.s` — Your RISC-V assembly source code.
* `cpu/` — The SystemVerilog hardware source code.
* `cpu.sv` — Top-level CPU wiring all 5 pipeline stages.
* `cpu_tb.sv` & `cpu_run_tb.sv` — System-level testbenches and performance monitors.
* **Hazard & Control:** `stall_unit/`, `flush_unit/`, `forwarding_unit/`
* **Pipeline Registers:** `if_id_register/`, `id_ex_register/`, `ex_mem_register/`, `mem_wb_register/`
* **Execution Core:** `alu/`, `decoder/`, `register_file/`, `pc_calculator/`



## Quick Start

```bash
# Setup Python environment
source venv/bin/activate
pip install -r requirements.txt

# Run any assembly program
python3 run.py program.s

```

## Testing & Verification

The CPU is built with modularity in mind. Every hardware component has its own isolated testbench. You can run these from inside the `cpu/` directory:

```bash
./test.sh decoder      # Test an individual hardware module
./test_cpu.sh          # Run the full pipeline hazard test suite
./test_all.sh          # Run all module unit tests across the entire CPU

```

## Tools

* **SystemVerilog** (Hardware design)
* **Icarus Verilog / VVP** (Simulation)
* **Python** (Assembler & test orchestration)

