# SoC WISHBONE Interface

## Configuration

The interface is declared as WISHBONE B4, Standard mode, Classic cycles.
Data width is 32 bits with 8-bit granularity and little-endian ordering.
The word address is `ADR[31:2]`; `SEL[3:0]` selects individual bytes.
Single byte, halfword, and word accesses are supported.
Burst, pipelined transfers, ERR, RTY, LOCK, tags, CTI, and BTE are not implemented.
The master uses CYC/STB/ACK; there is no WISHBONE STALL signal.
The CPU's internal stall signal is distinct from a bus STALL signal.

## Modules

- `cpu_wishbone_master.sv`: adapts CPU accesses and waits for ACK.
- `wishbone_interconnect.sv`: selects and multiplexes slaves.
- `wishbone_ram.sv`: data RAM.
- `wishbone_leds.sv`, `wishbone_switches.sv`: GPIO.
- `wishbone_seven_segment.sv`: display register and multiplexing.
- `wishbone_buttons.sv`: button input.
- `wishbone_vram.sv`: framebuffer with a VGA read port.

## Memory map

| CPU byte address | WISHBONE ADR | Target |
| --- | --- | --- |
| 0x00000000-0x00000FFF | 0x00000000-0x000003FF | RAM, 4 KiB |
| 0x10000000 | 0x04000000 | LEDs |
| 0x10000004 | 0x04000001 | Switches |
| 0x10000008 | 0x04000002 | Buttons |
| 0x10001000 | 0x04000400 | Seven-segment display |
| 0x20000000-0x20012BFF | 0x08000000-0x08004AFF | VRAM, 76,800 bytes |

Button bits: 0=UP, 1=DOWN, 2=LEFT, 3=RIGHT, 4=CENTER.
VRAM stores 320x240 8-bit RRRGGGBB pixels, four pixels per word.
`vga_controller.sv` displays each pixel as a 2x2 block in 640x480 output.
Instruction ROM is separate from this data memory map.

## Byte selection

SEL[0] selects DAT[7:0], SEL[1] selects DAT[15:8],
SEL[2] selects DAT[23:16], and SEL[3] selects DAT[31:24].
Register-specific behavior is defined by each slave's RTL.

## Clock, reset, and unmapped addresses

Interfaces operate in the `clk` domain with an internal synchronous reset.
The master deasserts CYC and STB during reset.
The interconnect acknowledges unmapped accesses: reads return zero and
writes are discarded.

## Available verification

`soc_top_tb.sv` checks ACK/CYC/STB, transfer stability while waiting, and
LED/display updates when switches change. `vga_test_tb.sv` checks framebuffer
initialization, memory samples, and colors. These tests are not an exhaustive
WISHBONE compliance certification.
