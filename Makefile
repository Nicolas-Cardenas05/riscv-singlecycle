PROGRAM ?= fibonacci


# ------------------------------------------------------------
# Project paths
# ------------------------------------------------------------

ASM_DIR     := tests/asm
LINKER_DIR  := tests/linker

BUILD_DIR   := build
ELF_DIR     := $(BUILD_DIR)/elf
BIN_DIR     := $(BUILD_DIR)/bin
LOG_DIR     := $(BUILD_DIR)/logs
WAVE_DIR    := $(BUILD_DIR)/waves
OBJ_DIR     := $(BUILD_DIR)/obj_dir


# ------------------------------------------------------------
# Program files
# ------------------------------------------------------------

ASM         := $(ASM_DIR)/$(PROGRAM).S

ELF         := $(ELF_DIR)/$(PROGRAM).elf
BIN         := $(BIN_DIR)/$(PROGRAM).bin
MEM         := $(BUILD_DIR)/program.mem

LINKER      := $(LINKER_DIR)/link_cpu.ld


# ------------------------------------------------------------
# Spike files
# ------------------------------------------------------------

SPIKE_ELF    := $(ELF_DIR)/$(PROGRAM)_spike.elf
SPIKE_LINKER := $(LINKER_DIR)/link_spike.ld

RTL_LOG      := $(LOG_DIR)/rtl_trace.log
SPIKE_LOG    := $(LOG_DIR)/spike.log


# ------------------------------------------------------------
# RTL simulation
# ------------------------------------------------------------

TOP         := single_cycle_cpu_tb
SIM         := $(OBJ_DIR)/V$(TOP)

VCD         := $(WAVE_DIR)/single_cycle_cpu.vcd


# ------------------------------------------------------------
# RISC-V toolchain
# ------------------------------------------------------------

RISCV_GCC     := riscv64-unknown-elf-gcc
RISCV_OBJCOPY := riscv64-unknown-elf-objcopy
RISCV_OBJDUMP := riscv64-unknown-elf-objdump


# ------------------------------------------------------------
# Avoid TAB problems in Makefile recipes
# ------------------------------------------------------------

.RECIPEPREFIX := >


# ------------------------------------------------------------
# Phony targets
# ------------------------------------------------------------

.PHONY: all \
        dirs \
        program \
        sim \
        run \
        disasm \
        wave \
        spike_program \
        rtl_test \
        spike_test \
        verify \
        clean \
        help


# ------------------------------------------------------------
# Default target
# ------------------------------------------------------------

all: run


# ------------------------------------------------------------
# Create generated-file directories
# ------------------------------------------------------------

dirs:
>mkdir -p $(ELF_DIR)
>mkdir -p $(BIN_DIR)
>mkdir -p $(LOG_DIR)
>mkdir -p $(WAVE_DIR)
>mkdir -p $(OBJ_DIR)


# ------------------------------------------------------------
# Build RISC-V program for the RTL CPU
# ------------------------------------------------------------

program: dirs
>@echo ""
>@echo "========================================"
>@echo " Building RISC-V program: $(PROGRAM)"
>@echo "========================================"

>@if [ ! -f "$(ASM)" ]; then \
>	echo "ERROR: Program not found: $(ASM)"; \
>	exit 1; \
>fi

>$(RISCV_GCC) \
>	-march=rv32i \
>	-mabi=ilp32 \
>	-nostdlib \
>	-nostartfiles \
>	-Wl,--no-relax \
>	-Wl,--build-id=none \
>	-T $(LINKER) \
>	-o $(ELF) \
>	$(ASM)

>$(RISCV_OBJCOPY) \
>	-O binary \
>	-j .text \
>	$(ELF) \
>	$(BIN)

>python3 scripts/bin_to_mem.py \
>	$(BIN) \
>	$(MEM)


# ------------------------------------------------------------
# Build RTL simulator
# ------------------------------------------------------------

sim: dirs
>@echo ""
>@echo "========================================"
>@echo " Building RTL simulator"
>@echo "========================================"

>verilator \
>	--binary \
>	--trace \
>	--timing \
>	--Mdir $(OBJ_DIR) \
>	--top-module $(TOP) \
>	rtl/*.sv \
>	tb/$(TOP).sv


# ------------------------------------------------------------
# Run program on the RTL CPU
# ------------------------------------------------------------

run: program sim
>@echo ""
>@echo "========================================"
>@echo " Running $(PROGRAM) on RISC-V CPU"
>@echo "========================================"
>@echo ""

>./$(SIM)


# ------------------------------------------------------------
# Show program disassembly
# ------------------------------------------------------------

disasm: program
>@echo ""
>@echo "========================================"
>@echo " Disassembly: $(PROGRAM)"
>@echo "========================================"
>@echo ""

>$(RISCV_OBJDUMP) \
>	-d \
>	-M numeric,no-aliases \
>	$(ELF)


# ------------------------------------------------------------
# Open waveform
# ------------------------------------------------------------

wave:
>@if [ ! -f "$(VCD)" ]; then \
>	echo "ERROR: Waveform not found: $(VCD)"; \
>	echo "Run a simulation first."; \
>	exit 1; \
>fi

>gtkwave $(VCD)


# ------------------------------------------------------------
# Build program for Spike
# ------------------------------------------------------------

spike_program: dirs
>@echo ""
>@echo "========================================"
>@echo " Building Spike program: $(PROGRAM)"
>@echo "========================================"

>@if [ ! -f "$(ASM)" ]; then \
>	echo "ERROR: Program not found: $(ASM)"; \
>	exit 1; \
>fi

>@if [ ! -f "$(SPIKE_LINKER)" ]; then \
>	echo "ERROR: Spike linker not found: $(SPIKE_LINKER)"; \
>	exit 1; \
>fi

>$(RISCV_GCC) \
>	-march=rv32i \
>	-mabi=ilp32 \
>	-nostdlib \
>	-nostartfiles \
>	-Wl,--no-relax \
>	-Wl,--build-id=none \
>	-T $(SPIKE_LINKER) \
>	-o $(SPIKE_ELF) \
>	$(ASM)


# ------------------------------------------------------------
# Generate RTL execution trace
# ------------------------------------------------------------

rtl_test: program sim
>@echo ""
>@echo "========================================"
>@echo " Running RTL test: $(PROGRAM)"
>@echo "========================================"
>@echo ""

>./$(SIM)


# ------------------------------------------------------------
# Run Spike reference model
# ------------------------------------------------------------

spike_test: rtl_test spike_program
>@echo ""
>@echo "========================================"
>@echo " Running Spike reference model"
>@echo "========================================"
>@echo ""

>@if [ ! -f "$(RTL_LOG)" ]; then \
>	echo "ERROR: RTL trace not found: $(RTL_LOG)"; \
>	exit 1; \
>fi

>@COUNT=$$(wc -l < $(RTL_LOG)); \
>echo "Instructions to execute: $$COUNT"; \
>spike \
>	--isa=rv32i \
>	--priv=m \
>	--pcs=0:0x80000000 \
>	--instructions=$$COUNT \
>	-l \
>	--log-commits \
>	$(SPIKE_ELF) \
>	2> $(SPIKE_LOG)


# ------------------------------------------------------------
# Differential verification
# ------------------------------------------------------------

verify: spike_test
>@echo ""
>@echo "========================================"
>@echo " RTL vs Spike differential verification"
>@echo "========================================"
>@echo ""

>python3 scripts/compare_trace.py


# ------------------------------------------------------------
# Clean generated files
# ------------------------------------------------------------

clean:
>@echo ""
>@echo "Removing generated files..."
>rm -rf $(BUILD_DIR)


# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

help:
>@echo ""
>@echo "Available commands:"
>@echo ""
>@echo "Run programs:"
>@echo "  make run PROGRAM=fibonacci"
>@echo "  make run PROGRAM=bubble_sort"
>@echo "  make run PROGRAM=matrix_mul"
>@echo "  make run PROGRAM=seven_segment"
>@echo ""
>@echo "Verification:"
>@echo "  make verify PROGRAM=rv32i"
>@echo ""
>@echo "Other commands:"
>@echo "  make disasm PROGRAM=fibonacci"
>@echo "  make wave"
>@echo "  make clean"
>@echo ""

.PHONY: soc-test soc-program soc-sim


soc-program:
>@mkdir -p build/elf
>@mkdir -p build/bin
>@echo ""
>@echo "========================================"
>@echo " Building SoC program: $(PROGRAM)"
>@echo "========================================"
>$(RISCV_GCC) \
>	-march=rv32i \
>	-mabi=ilp32 \
>	-nostdlib \
>	-nostartfiles \
>	-Wl,--no-relax \
>	-Wl,--build-id=none \
>	-T $(LINKER) \
>	-o $(ELF) \
>	$(ASM)

>$(RISCV_OBJCOPY) \
>	-O binary \
>	-j .text \
>	$(ELF) \
>	$(BIN)

>python3 scripts/bin_to_mem.py \
>	$(BIN) \
>	$(MEM)

>cp $(MEM) program.mem


soc-sim:
>@mkdir -p build/obj_soc
>@echo ""
>@echo "========================================"
>@echo " Building SoC simulator"
>@echo "========================================"

>verilator \
>	--binary \
>	--trace \
>	--timing \
>	--Mdir build/obj_soc \
>	--top-module soc_top_tb \
>	rtl/*.sv \
>	tb/soc_top_tb.sv


soc-test: soc-program soc-sim
>@echo ""
>@echo "========================================"
>@echo " Running WISHBONE SoC test"
>@echo "========================================"
>@echo ""

>./build/obj_soc/Vsoc_top_tb