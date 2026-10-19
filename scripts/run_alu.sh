#!/bin/bash

verilator --binary --trace --timing --top-module alu_tb rtl/alu.sv tb/alu_tb.sv
./obj_dir/Valu_tb
gtkwave alu.vcd &
