# WISHBONE Interface Datasheet

## Specification

WISHBONE Revision: B4

Interface Mode: Standard

Cycle Type: Classic

## Bus Configuration

Data Port Size: 32 bits

Port Granularity: 8 bits

Maximum Operand Size: 32 bits

Data Transfer Ordering: Little Endian

Address Bus: ADR[31:2]

Select Bus: SEL[3:0]

## Supported Transfers

Single read transfers

Single write transfers

Byte transfers

Halfword transfers

Word transfers

## Unsupported Features

Pipelined transfers are not supported.

Burst transfers are not supported.

ERR is not implemented.

RTY is not implemented.

STALL is not implemented.

LOCK is not implemented.

Tag signals are not implemented.

CTI and BTE are not implemented.

The interface operates as a pure WISHBONE Classic interface.

## Master

Module:

cpu_wishbone_master.sv

Signals:

CLK_I   -> clk

RST_I   -> reset

ADR_O   -> wb_adr_o[31:2]

DAT_O   -> wb_dat_o[31:0]

DAT_I   -> wb_dat_i[31:0]

WE_O    -> wb_we_o

SEL_O   -> wb_sel_o[3:0]

CYC_O   -> wb_cyc_o

STB_O   -> wb_stb_o

ACK_I   -> wb_ack_i

## Slaves

Implemented WISHBONE slaves:

- wishbone_ram.sv
- wishbone_leds.sv
- wishbone_switches.sv
- wishbone_seven_segment.sv

## Memory Map

| RISC-V byte address | WISHBONE ADR | Slave |
| 0x00000000 - 0x00000FFF | 0x00000000 - 0x000003FF | RAM |
| 0x10000000 | 0x04000000 | LEDs |
| 0x10000004 | 0x04000001 | Switches |
| 0x10001000 | 0x04000400 | Seven-segment |

## Byte Select Mapping

SEL[0] selects DAT[7:0].

SEL[1] selects DAT[15:8].

SEL[2] selects DAT[23:16].

SEL[3] selects DAT[31:24].

## Clock and Reset

All WISHBONE interfaces operate in the clk clock domain.

reset is the WISHBONE synchronous reset signal.

The master negates CYC_O and STB_O while reset is asserted.

## Unmapped Addresses

The interconnect acknowledges accesses to unmapped addresses.

Reads return 0x00000000.

Writes are discarded.