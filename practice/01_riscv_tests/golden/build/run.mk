# ------------------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------------------

# Shell to run
SHELL := bash

# Define maximum number of threads
VPROCS = 1

# Top file to simulate
TOP = miriscv_tb_top

# Output directory
OUT = out
export OUT

# RISCV prefix
RISCVPREFIX = riscv32-unknown-elf

# Test timout in cycles
TIMEOUT = 10000

# Signature address
SIGNATURE_ADDR = 8ffffffc

# Memory debug switch
ifeq ($(MEM_DEBUG),1)
	VOPTS += +define+MEM_DEBUG
endif

# Disable warnings
VWARNINGS += -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM -Wno-PINMISSING \
	-Wno-GENUNNAMED -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT -Wno-INFINITELOOP -Wno-MULTIDRIVEN -Wno-INITIALDLY

# Compile options
VOPTS += +incdir+../tb/

# Print last lines form run log switch
RESULT_DEBUG = 0


# ------------------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------------------

# Submodule directory
submodule_dir = $(PWD)/../../../submodules
export submodule_dir

# All Verilog / SystemVerilog files
verilog = $(shell sed 's+<submodule_dir>+$(submodule_dir)+g' tb.f > \
	tb.tmp && cat tb.tmp | tr '\n' ' ' && rm tb.tmp)

# .elfs, binaries and .logs lists
elfs = $(wildcard $(ASM_DIR)/*.elf)
bins = $(elfs:.elf=.bin)
logs = $(elfs:.elf=.log)
ress = $(elfs:.elf=.res)

# Collect results
.PHONY: all
all: $(ress)

# Print test results
$(ress): $(ASM_DIR)/%.res: $(ASM_DIR)/%.log
	grep -q "Test done" "$<" && echo "*** Test $<: PASSED" > $@ || echo "*** Test $<: FAILED" > $@
	@echo "$$(cat $@)"

# Run binary model
$(logs): $(ASM_DIR)/%.log: $(ASM_DIR)/%.bin | $(OUT)/verilator/compile.log
	@echo "*** Running RTL simulation for $< (log at $(basename $@).log)"
	$(OUT)/verilator/V$(TOP) +bin=$< +timeout_in_cycles=$(TIMEOUT) \
		+signature_addr=$(SIGNATURE_ADDR) +dump=$(basename $@).vcd &> $(basename $@).log
ifeq ($(RESULT_DEBUG), 1)
	tail -5 $(basename $@).log
endif

# Compile under verilator
$(OUT)/verilator/compile.log: $(verilog)
	@echo "*** Compiling RTL under Verilator (log at $@)"
	mkdir -p $(OUT)/verilator
	verilator $(VWARNINGS) -cc -O2 -j $(VPROCS) --threads $(VPROCS) \
		--binary $(verilog) $(VOPTS) --trace --trace-params \
		--trace-structs --x-assign 0 -top-module $(TOP) -Mdir \
			$(OUT)/verilator &> $(OUT)/verilator/compile.log

# Convert test programs to binary
$(bins): $(ASM_DIR)/%.bin: $(ASM_DIR)/%.elf
	@echo "*** Translating $(notdir $@) to binary (log at $(basename $@).translate.log)"
	$(RISCVPREFIX)-objcopy -O binary $< $@ &>> $(basename $@).translate.log

# Clean target
.PHONY: clean
clean:
	rm -rf $(bins)
	rm -rf $(logs)
