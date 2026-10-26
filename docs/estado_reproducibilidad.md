# Reproduction Status

Based on the `wishbone` sources at commit `1c00987` and the original Vivado ZIP.
This update prepares documentation and preserves files. It does not run
simulation, synthesis, or board programming.

## Available files

CPU, WISHBONE SoC, RAM, GPIO, buttons, VRAM, VGA, assembly tests, Snake,
linker scripts, memory converter, trace comparator, and testbenches.
The original Vivado ZIP is preserved and its XDC constraints are extracted.

## Known limitations

- `main` represents an earlier stage; use `wishbone`.
- `program` generates `build/program.mem`, but the wishbone RTL reads
  `program.mem` from the execution directory. Run `soc-program` before
  `run`/`verify` for the same program. This update does not change the Makefile.
- `compare_trace.py` does not fail with a nonzero exit status on mismatches
  and may accept two empty traces. Inspect counts and textual results.
- `instruction_memory_tb.sv` expects four specific words; reproducible setup
  for that standalone test data is missing.
- CPU, SoC, and VGA testbenches leave button inputs unconnected, which can
  produce Verilator warnings. This update does not fix those connections.
- `soc-program` does not create `build/waves`; the documented VGA recipe does.
- The Vivado ZIP omits RTL and memory and retains absolute WSL references.
- A portable project-creation Tcl script and exact simulation/toolchain
  version records are still missing.
- The archived bitstream still needs an explicit commit and memory association.
- `docs/architecture.md` and architecture images show an earlier CPU stage;
  they need a separate update to represent the complete SoC.

## Generated files

ELF files, binaries, waveforms, `build/`, and per-program memory images can
be regenerated from source and do not need to be uploaded.
Vivado caches and logs do not need to be tracked separately. The original ZIP
is preserved as a historical reference, not as a portable rebuild workflow.
