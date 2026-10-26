# Running the project in VS Code and WSL

Use the `wishbone` branch, open the folder through VS Code WSL, and run all
commands from the repository root.

## Check the tools

```bash
git branch --show-current
make --version
g++ --version
python3 --version
verilator --version
riscv64-unknown-elf-gcc --version
spike --help
```

Install the dependencies listed in the README and ensure they are available
on PATH. Record their versions when validating a new environment.
The Python scripts only use the standard library.

## Program memory

`make soc-program PROGRAM=name` assembles `tests/asm/name.S` with
`-march=rv32i -mabi=ilp32`, links it using `link_cpu.ld`, extracts `.text`,
and converts the binary into 32-bit hexadecimal words.

Outputs are `build/elf/name.elf`, `build/bin/name.bin`,
`build/program.mem`, and a `program.mem` copy at the repository root.
The wishbone RTL reads the root copy using `$readmemh`.

The Makefile's `program` target only updates `build/program.mem`.
Before `run` or `verify`, run `soc-program` for the same program to avoid
missing memory files or executing an older memory image.

## RV32I CPU and Spike

```bash
make soc-program PROGRAM=rv32i
make verify PROGRAM=rv32i
```

The historical result is 52/52 matches. Check both the comparison output and
the instruction counts: the current comparison script does not return a
failure exit status when differences are found.
Traces are written to `build/logs/rtl_trace.log` and `build/logs/spike.log`.
Spike uses a separate ELF linked at 0x80000000.

## SoC and peripherals

```bash
make soc-test PROGRAM=peripherals
```

The testbench checks LEDs and the display register using two switch values,
and checks transfer validity and stability while waiting for WISHBONE ACK.
This is not an exhaustive RAM, button, or VGA test.

## VGA

```bash
mkdir -p build/waves
make soc-program PROGRAM=vga_test
verilator --binary --trace --timing \
  --Mdir build/obj_vga --top-module vga_test_tb \
  rtl/*.sv tb/vga_test_tb.sv
./build/obj_vga/Vvga_test_tb
```

The test checks initialization completion, the 0x0000C0DE marker, selected
framebuffer values, and four VGA color samples.
The expected final message is `VGA SOC TEST PASSED`.

## Buttons and Snake

```bash
make soc-program PROGRAM=buttons_test
riscv64-unknown-elf-objdump -d -M no-aliases build/elf/buttons_test.elf

make soc-program PROGRAM=snake
riscv64-unknown-elf-objdump -d -M no-aliases build/elf/snake.elf
```

These commands generate software; they do not automatically validate gameplay.
To test the game on hardware, follow the Vivado guide and rebuild the bitstream.

## Other programs and waveforms

```bash
make soc-program PROGRAM=fibonacci
make run PROGRAM=fibonacci
make wave
```

Use this pattern for examples that reach the terminal loop detected by the
testbench. Continuously interactive programs need an appropriate testbench;
they should not be treated as tests that finish automatically.

The task in `.vscode/tasks.json` runs `make run`. Generate the root memory
image for the same program with `soc-program` first.
