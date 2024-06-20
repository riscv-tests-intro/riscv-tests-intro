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

# Disable warnings
VWARNINGS += -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM -Wno-PINMISSING \
	-Wno-GENUNNAMED -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT -Wno-INFINITELOOP -Wno-MULTIDRIVEN -Wno-INITIALDLY

# Compile options
VOPTS += +incdir+../tb/


# ------------------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------------------

# Submodule directory
submodule_dir = $(PWD)/../../../../submodules
export submodule_dir

# All Verilog / SystemVerilog files
verilog = $(shell sed 's+<submodule_dir>+$(submodule_dir)+g' tb.f > \
	tb.tmp && cat tb.tmp | tr '\n' ' ' && rm tb.tmp)

.PHONY: all
all: $(OUT)/verilator/run.log

# Run binary model
$(OUT)/verilator/run.log: $(OUT)/verilator/compile.log
	@echo "*** Running RTL simulation for program.hex (log at $@)"
	$(OUT)/verilator/V$(TOP) +bin=program.hex +dump=$(@D)/$(basename $(notdir $@))_waves.vcd &> $@

# Compile under verilator
$(OUT)/verilator/compile.log: $(verilog)
	@echo "*** Compiling RTL under Verilator (log at $@)"
	mkdir -p $(OUT)/verilator
	verilator $(VWARNINGS) -cc -O2 -j $(VPROCS) --threads $(VPROCS) --binary $(verilog) $(VOPTS) --trace --trace-params \
		--trace-structs --x-assign 0 -top-module $(TOP) -Mdir $(OUT)/verilator &> $(OUT)/verilator/compile.log

# Clean target
.PHONY: clean
clean:
	rm -rf $(OUT)
