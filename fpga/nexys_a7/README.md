# Vivado: Nexys A7-100T

## Configuration identified in the original ZIP

- Vivado 2026.1.
- FPGA part: `xc7a100tcsg324-1`.
- Original board part: `digilentinc.com:nexys-a7-100t:part0:1.3`.
- Top module: `fpga_top`.
- Input clock: `CLK100MHZ`, 100 MHz; XDC period: 10 ns.
- Reset: `CPU_RESETN`, active low; the top module inverts it for the SoC.
- Original constraints: [constraints/nexys_a7.xdc](constraints/nexys_a7.xdc).

## Original archive contents

`../archive/riscv_singlecycle_nexys_a7.zip` preserves the `.xpr` project,
XDC constraints, synthesis/implementation results, and `fpga_top.bit`.

The ZIP is not self-contained. Its `.xpr` references RTL and `program.mem` at
`//wsl.localhost/Ubuntu-24.04/home/nicolas/projects/riscv-singlecycle/`.
Those files are not included. On another machine, update the references or
create a new project using the sources tracked in Git.
The presence of a bitstream does not prove that it matches the selected commit
or program; that association still needs to be recorded.

## Rebuild from repository sources

1. In WSL, select `wishbone` and run from the repository root:

   ```bash
   make soc-program PROGRAM=snake
   ```

2. Open Vivado and create an RTL project for `xc7a100tcsg324-1`.
   Selecting the board by name requires its board files. Selecting the device
   directly allows the supplied XDC constraints to be used.
3. Add the SystemVerilog files in `rtl/` as design sources and select
   `fpga_top` as the top module. Do not add `tb/` as synthesis sources.
4. Add the newly generated `program.mem` as a memory source. Ensure that
   `$readmemh("program.mem", ...)` resolves to this image. Windows can access
   the WSL repository through its WSL network path, adjusted for the local
   distribution and username.
5. Add `fpga/nexys_a7/constraints/nexys_a7.xdc` as constraints.
6. Run synthesis and implementation. Review errors, DRC, and timing before
   generating the bitstream. This workflow has not been rerun as part of
   this documentation update.
7. Generate the bitstream, connect the board, open Hardware Manager, connect
   to the target, and program the newly generated `fpga_top.bit`.

Every software change requires regenerating memory and rebuilding the
bitstream. Changing `program.mem` after programming the FPGA is insufficient.

## Program the archived bitstream

Extract the ZIP outside the source tree. In Hardware Manager, select:

```text
riscv_singlecycle_nexys_a7/
  riscv_singlecycle_nexys_a7.runs/impl_1/fpga_top.bit
```

This uses the archived build; it does not recompile the current RTL.

## Snake controls

BTNU, BTND, BTNL, and BTNR select direction; BTNC restarts the game.
CPU_RESETN resets the SoC. Connect a monitor to VGA.
The software uses a 40x30-cell board and a 320x240 framebuffer, scaled to
640x480 VGA output.

## Files to preserve

Track RTL, assembly, linker scripts, XDC constraints, and documentation.
The original ZIP is kept as a historical archive. Its caches, logs, and
Vivado run directories do not need to be tracked separately.
A portable Tcl script to recreate the project is still missing.
