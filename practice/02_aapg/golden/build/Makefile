# ------------------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------------------

# Shell to run
SHELL := bash

# Define maximum number of threads
NPROCS = 1

# Top file to simulate
TOP = miriscv_tb_top

# Output directory
OUT = out
export OUT

# RISCV prefix
RISCVPREFIX = riscv32-unknown-elf

# Test program binary name
BIN = program

# Random seed
SEED := $$RANDOM

# Instructions amount
INSTR = 1000

# Test timout in cycles
TIMEOUT = $(INSTR)00

# Signature address
SIGNATURE_ADDR = 80100000

# Memory debug switch
ifeq ($(MEM_DEBUG),1)
	OPTS += +define+MEM_DEBUG
endif

# Disable warnings
DWARNINGS += -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL \
	-Wno-UNUSEDPARAM -Wno-GENUNNAMED -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT \
		-Wno-INFINITELOOP -Wno-MULTIDRIVEN -Wno-INITIALDLY

# Compile options
OPTS += +incdir+../tb/ +define+BOOT_ADDR=2147483648

# Print last lines form run log switch
RESULT_DEBUG = 0


# ------------------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------------------

# Submodule directory
submodule_dir = $(PWD)/../../../../submodules
export submodule_dir

# All Verilog / SystemVerilog files
verilog = $(shell sed 's+<submodule_dir>+$(submodule_dir)+g' tb.f > \
	tb.tmp && cat tb.tmp | tr '\n' ' ' && rm tb.tmp)

# Pythonpath
pythonpath = $(submodule_dir)/ibex/dv/uvm/core_ibex/riscv_dv_extension:$\
				$(submodule_dir)/ibex/vendor/google_riscv-dv/scripts:$\
					$(submodule_dir)/ibex/dv/uvm/core_ibex/scripts

# Compare ISS and RTL
$(OUT)/compare.log: $(OUT)/spike/iss_log.log
	echo "*** Comparing ISS and RTL simulation results (log at $@)"
	@echo "*** $$(PYTHONPATH=$(pythonpath) python3 compare.py \
		--rtl_log=$(OUT)/verilator/rtl_log_00000000.log \
			--iss_log=$(OUT)/spike/iss_log.log --out=$(OUT)/compare.log)"

# Run ISS
$(OUT)/spike/iss_log.log: $(OUT)/verilator/run.log
	echo "*** Running Spike ISS (log at $@)"
	mkdir -p $(@D)
	spike --log-commits --isa=rv32im_zicsr -l $(OUT)/aapg/bin/$(BIN).riscv &> $(@D)/iss_log.log

# Run binary model
$(OUT)/verilator/run.log: $(OUT)/verilator/compile.log
	echo "*** Running RTL simulation (log at $@)"
	$(@D)/V$(TOP) +bin=$(OUT)/aapg/bin/$(BIN).bin +timeout_in_cycles=$(TIMEOUT) \
		+ibex_tracer_file_base=$(@D)/rtl_log +dump=$(basename $@).vcd \
			+signature_addr=$(SIGNATURE_ADDR) &> $@
ifeq ($(RESULT_DEBUG), 1)
	tail -5 $@
endif

# Compile under verilator
$(OUT)/verilator/compile.log: $(OUT)/aapg/gen.log $(verilog) | $(OUT)
	echo "*** Compiling RTL under Verilator (log at $@)"
	mkdir -p $(@D)
	verilator $(DWARNINGS) -j $(NPROCS) --threads $(NPROCS) --binary $(verilog) $(OPTS) \
		--trace --trace-params --trace-structs --x-assign 0 -top-module $(TOP) -Mdir $(@D) &> $@

# Create random test program
$(OUT)/aapg/gen.log: $(OUT)/.stamps/SEED.$(SEED) $(OUT)/.stamps/INSTR.$(INSTR) | $(OUT)\
# ------------------------------------------------------------------------------------------
	echo "*** Generating random program (log at $@)"
	echo $(submodule_dir)
	mkdir -p $(@D)
# ------------------------------------------------------------------------------------------
	@echo "    - Setting instructions amount in config.yaml"
	cp config.yaml config.backup
	sed -i 's/total_instructions:.*/total_instructions: $(INSTR)/' config.yaml
# ------------------------------------------------------------------------------------------
	@echo "    - Generating program"
	aapg setup --setup_dir $(@D) &> $@
	aapg gen --config_file config.yaml --setup_dir $(@D) --output_dir \
		$(@D)/asm --asm_name $(BIN) --seed $(SEED) &>> $@
# ------------------------------------------------------------------------------------------
	@echo "    - Compiling and translating program"
	$(MAKE) -C $(@D) build objdump RISCVPREFIX=$(RISCVPREFIX) ISA=rv32im_zicsr &>> $@
	$(RISCVPREFIX)-objcopy -O binary $(@D)/bin/$(BIN).riscv $(@D)/bin/$(BIN).bin &>> $@
# ------------------------------------------------------------------------------------------
	@echo "    - Restoring config.yaml"
	mv config.backup config.yaml

# Output seed file stamp
$(OUT)/.stamps/SEED.$(SEED): | $(OUT)
	rm -f $(OUT)/.stamps/SEED.*
	touch $@

# Total instructions file stamp
$(OUT)/.stamps/INSTR.$(INSTR): | $(OUT)
	rm -f $(OUT)/.stamps/INSTR.*
	touch $@

# Create output directory if neccessary
$(OUT):
	mkdir -p $(OUT)
	mkdir -p $(OUT)/.stamps

# Clean target
.PHONY: clean
clean:
	rm -rf $(OUT)
