import sys
import subprocess
from pathlib import Path

from riscv_assembler.convert import AssemblyConverter


PROJECT_DIR = Path(__file__).parent
CPU_DIR = PROJECT_DIR / "cpu"
MEM_FILE = PROJECT_DIR / "program.mem"
SIM_FILE = PROJECT_DIR / "sim"


def assemble(source_file):
    print("=" * 50)
    print("STEP 1: ASSEMBLING")
    print("=" * 50)

    converter = AssemblyConverter(
        output_mode="a",
        nibble_mode=False,
        hex_mode=True
    )

    instructions = converter.convert(str(source_file))

    with open(MEM_FILE, "w") as f:
        
        for instruction in instructions:
            instruction = instruction.strip()

            if instruction.lower().startswith("0x"):
                instruction = instruction[2:]

            f.write(f"{int(instruction, 16):08x}\n")

    print(f"Assembly complete: {MEM_FILE}")
    print()

def compile_cpu():
    print("=" * 50)
    print("STEP 2: COMPILING CPU")
    print("=" * 50)

    sv_files = []

    for file in CPU_DIR.rglob("*.sv"):
        # Do not compile individual module testbenches
        if file.name.endswith("_tb.sv"):
            continue

        sv_files.append(file)

    testbench = CPU_DIR / "cpu_run_tb.sv"

    if not testbench.exists():
        print(f"ERROR: Could not find {testbench}")
        print()
        print("Create cpu/cpu_run_tb.sv for running arbitrary programs.")
        sys.exit(1)

    # Add the generic CPU testbench
    sv_files.append(testbench)

    command = [
        "iverilog",
        "-g2012",
        "-o",
        str(SIM_FILE)
    ]

    command += [str(file) for file in sv_files]

    print("Compiling:")
    for file in sv_files:
        print(f"  {file}")

    print()

    result = subprocess.run(command)

    if result.returncode != 0:
        print()
        print("ERROR: Verilog compilation failed.")
        sys.exit(result.returncode)

    print()
    print("Verilog compilation successful.")
    print()

def run_simulation():
    print("=" * 50)
    print("STEP 3: RUNNING CPU")
    print("=" * 50)

    result = subprocess.run(
        ["vvp", str(SIM_FILE)],
        cwd=PROJECT_DIR
    )

    if result.returncode != 0:
        print()
        print("ERROR: Simulation failed.")
        sys.exit(result.returncode)


def main():
    if len(sys.argv) != 2:
        print("Usage:")
        print("  python3 run.py program.s")
        sys.exit(1)

    source_file = Path(sys.argv[1])

    if not source_file.exists():
        print(f"ERROR: Program not found: {source_file}")
        sys.exit(1)

    assemble(source_file)
    compile_cpu()
    run_simulation()


if __name__ == "__main__":
    main()