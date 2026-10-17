# RV32I Single-Cycle Processor

A custom 32-bit RISC-V single-cycle processor designed from scratch in
SystemVerilog for learning, verification, and future FPGA/SoC development.

## Current Status

- Custom single-cycle RV32I datapath and controller
- 37 RV32I instructions implemented
- Byte, halfword, and word load/store support
- Signed and unsigned branches and comparisons
- JAL and JALR support
- Self-checking module-level testbenches
- Differential verification against Spike
- 52/52 architectural events matched in the integration test

## Verification

The processor was validated using Verilator and compared instruction-by-
instruction against the Spike RISC-V ISA reference simulator.

Result:

`52/52 instructions match — ALL INSTRUCTIONS MATCH SPIKE`

## Project Structure

`rtl/` – processor RTL  
`tb/` – SystemVerilog testbenches  
`tests/` – RISC-V assembly test programs  
`scripts/` – verification utilities  
`docs/` – architecture documentation

## Tools

SystemVerilog · Verilator · Spike · GTKWave · RISC-V GCC · Git

## Roadmap

The next stages include FPGA implementation, memory-mapped peripherals,
pipelining, hardware accelerators, and fault-tolerant extensions.
