
# RISC-V RV32I Pipelined CPU

A 5-stage pipelined RV32I RISC-V processor implemented from scratch in SystemVerilog. 

Upgraded from a single-cycle architecture, this CPU features full data forwarding, load-use hazard detection (stalling), and control hazard mitigation (flushing). The project includes a custom Python runner for assembling and executing standard RISC-V assembly programs directly on the simulated hardware, complete with cycle-accurate benchmark tracking.

## Repository Structure

* `run.py` — Python execution script. Assembles `.s` code, generates memory, and runs the CPU simulation.
* `program.s` — Your RISC-V assembly source code.
* `cpu/` — The SystemVerilog hardware source code.
  * `cpu.sv` — Top-level CPU wiring all 5 pipeline stages.
  * `cpu_tb.sv` & `cpu_run_tb.sv` — System-level testbenches and performance monitors.
  * **Hazard & Control:** `stall_unit/`, `flush_unit/`, `forwarding_unit/`
  * **Pipeline Registers:** `if_id_register/`, `id_ex_register/`, `ex_mem_register/`, `mem_wb_register/`
  * **Execution Core:** `alu/`, `decoder/`, `register_file/`, `pc_calculator/`
  * Every sub-directory contains its modular `.sv` design file and a dedicated `_tb.sv` unit test.

## Quick Start

Write your RISC-V assembly in any `.s` file, then use the Python runner to execute it. The runner handles compilation, memory loading, and outputs a cycle-by-cycle execution trace alongside final benchmark metrics (CPI, Stalls, Flushes).

```bash
# Setup Python environment
source venv/bin/activate
pip install -r requirements.txt

# Run an assembly program
python3 run.py program.s

```

## Testing & Verification

The CPU is built with modularity in mind. Every hardware component has its own isolated testbench. You can run these from inside the `cpu/` directory:

**Test an individual hardware module:**

```bash
./test.sh decoder
./test.sh forwarding_unit

```

**Run the full pipeline hazard test suite:**

```bash
./test_cpu.sh

```

**Run all module unit tests across the entire CPU:**

```bash
./test_all.sh

```

## Tools

* **SystemVerilog** (Hardware design)
* **Icarus Verilog / VVP** (Simulation)
* **Python** (Assembler & test orchestration)

