# RV32I Single-Cycle Processor and WISHBONE SoC

A custom 32-bit processor written in SystemVerilog, extended with a WISHBONE
SoC, memory-mapped peripherals, VGA output, and an assembly Snake demo for
the Nexys A7-100T FPGA board.

## Project version

The `wishbone` branch contains the buttons, VGA, and Snake integration.
The `wishbone-snake-v1` tag identifies the published demo version.
`main` preserves an earlier MMIO peripheral implementation.

```bash
git clone --branch wishbone https://github.com/Nicolas-Cardenas05/riscv-singlecycle.git
cd riscv-singlecycle
code .
```

Run build commands from the repository root in a Linux/WSL terminal.
Open the folder through the VS Code WSL extension.

## Current features

- RV32I processor with 37 implemented instructions.
- Byte, halfword, and word loads/stores; comparisons and jumps.
- Differential verification against Spike; historical result: 52/52 matches.
- WISHBONE Classic master, interconnect, RAM, and peripherals.
- LEDs, switches, an eight-digit hexadecimal display, and five buttons.
- A 320x240 RRRGGGBB framebuffer displayed through 640x480 VGA output.
- Snake written in RV32I assembly.

The historical verification result does not replace a fresh test run.
Single-cycle describes the datapath; WISHBONE accesses can stall the CPU.

## Repository layout

| Directory | Contents |
| --- | --- |
| `rtl/` | Processor, SoC, WISHBONE, memories, and peripherals |
| `tb/` | Module, CPU, SoC, and VGA testbenches |
| `tests/asm/` | Assembly test programs and Snake |
| `tests/linker/` | RTL and Spike linker scripts |
| `scripts/` | Binary-to-memory conversion and trace comparison |
| `.vscode/` | VS Code program execution task |
| `docs/` | Reproduction, architecture, and WISHBONE documentation |
| `fpga/nexys_a7/` | Constraints and Vivado instructions |
| `fpga/archive/` | Original Vivado project ZIP |
| `build/` | Generated files, excluded from Git |

## Dependencies

Linux/WSL with Bash, GNU Make, a C++ compiler, Python 3, and Git.
Verilator must support `--binary --timing --trace`.
The RISC-V toolchain must provide `riscv64-unknown-elf-gcc`,
`riscv64-unknown-elf-objcopy`, and `riscv64-unknown-elf-objdump`, with
RV32I/ILP32 support.
Differential verification requires Spike with commit logging and support for
the options used in the Makefile. GTKWave is optional for viewing waveforms.

The supplied FPGA project was created with Vivado 2026.1 for
`xc7a100tcsg324-1` (Nexys A7-100T). Simulation and toolchain versions still
need to be recorded; dependencies are not pinned.

## Main commands

```bash
# CPU verification against Spike: also prepare the memory read by the RTL.
make soc-program PROGRAM=rv32i
make verify PROGRAM=rv32i

# WISHBONE SoC and peripheral test.
make soc-test PROGRAM=peripherals

# Generate button test or Snake software.
make soc-program PROGRAM=buttons_test
make soc-program PROGRAM=snake
```

Memory files are generated from source. There is no need to track
`program.mem`, ELF files, binaries, or waveforms.
Regenerate Snake memory before synthesis: each program replaces the previous
memory image.

## Documentation

- [WSL execution and tests](docs/reproduccion.md)
- [Vivado and Nexys A7-100T](fpga/nexys_a7/README.md)
- [WISHBONE interface and memory map](docs/wishbone_datasheet.md)
- [CPU architecture](docs/architecture.md): an earlier diagram that does not
  represent the complete WISHBONE/VGA integration.
- [Known reproduction limitations](docs/estado_reproducibilidad.md)

## Roadmap

Pipeline, memory/cache, more advanced software support, accelerators, and
reliability research. The current system does not implement Linux support.
