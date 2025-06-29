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
OUT = $(PWD)/out
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
	COMP_OPTS += +define+MEM_DEBUG
endif

# Step-and-compare logging switch
ifneq ($(COMPARE_LOG),)
	SIM_OPTS += +compare_log=$(OUT)/verilator/$(COMPARE_LOG)
endif

# Disable warnings
DWARNINGS += -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL \
	-Wno-UNUSEDPARAM -Wno-GENUNNAMED -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT \
		-Wno-INFINITELOOP -Wno-MULTIDRIVEN -Wno-INITIALDLY

# Compile options
COMP_OPTS += +incdir+../tb/ +define+BOOT_ADDR=2147483648

# Print last lines form run log switch
RESULT_DEBUG = 0


# ------------------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------------------

# Submodule directory
submodule_dir = $(PWD)/../../../../submodules
export submodule_dir

# Spike install directory
spike_install_dir = $(dir $(shell which spike))/..
ifeq ($(shell which spike),)
  $(error "Can't find Spike ISS!")
endif

# All Verilog / SystemVerilog files
verilog = $(shell sed 's+<submodule_dir>+$(submodule_dir)+g' tb.f > \
	tb.tmp && cat tb.tmp | tr '\n' ' ' && rm tb.tmp)

# DPI-C Hammer API verilog header
dpi_c_verilog_header = ../tb/miriscv_hammer_dpi.svh

# Run binary model
$(OUT)/verilator/run.log: $(OUT)/verilator/compile.log
	echo "*** Running RTL simulation (log at $@)"
	$(@D)/V$(TOP) +bin=$(OUT)/aapg/bin/$(BIN).bin +elf=$(OUT)/aapg/bin/$(BIN).riscv \
	    +timeout_in_cycles=$(TIMEOUT) +ibex_tracer_file_base=$(@D)/rtl_log $(SIM_OPTS) \
			+dump=$(basename $@).vcd +signature_addr=$(SIGNATURE_ADDR) &> $@
ifeq ($(RESULT_DEBUG), 1)
	tail -5 $@
endif

# Compile under verilator
$(OUT)/verilator/compile.log: $(OUT)/hammer/compile.log $(verilog) | $(OUT)
	echo "*** Compiling RTL under Verilator (log at $@)"
	mkdir -p $(@D)
	verilator $(dpi_c_verilog_header) -Mdir ./ --dpi-hdr-only
	verilator $(DWARNINGS) --relative-includes -j $(NPROCS) --threads $(NPROCS) \
		--binary $(verilog) $(PWD)/hammer_dpi.cpp $(COMP_OPTS) --trace --trace-params --trace-structs \
			--x-assign 0 -top-module $(TOP) -Mdir $(@D) -CFLAGS "-I./-I$(spike_install_dir)/include/softfloat \
				-I$(spike_install_dir)/include -I$(submodule_dir)/hammer-miriscv" -LDFLAGS "-L$(OUT)/hammer -l:libhammer.a \
					-L$(spike_install_dir)/lib -l:libriscv.so -Wl,-rpath,$(spike_install_dir)/lib" &> $@

# Build hammer
$(OUT)/hammer/compile.log: $(OUT)/aapg/gen.log | $(OUT)
	echo "*** Building Hammer with meson (log at $@)"
	mkdir -p $(@D)
	@echo "    - Configuring"
	meson setup $(OUT)/hammer $(submodule_dir)/hammer-miriscv \
		--native-file $(submodule_dir)/hammer-miriscv/native-file.txt \
			--buildtype release -Dspike_install_dir=$(spike_install_dir) &> $@
	@echo "    - Compiling"
	meson compile -C $(OUT)/hammer &>> $@

# Create random test program
$(OUT)/aapg/gen.log: $(OUT)/.stamps/SEED.$(SEED) $(OUT)/.stamps/INSTR.$(INSTR) | $(OUT)
# ------------------------------------------------------------------------------------------
	echo "*** Generating random program (log at $@)"
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
