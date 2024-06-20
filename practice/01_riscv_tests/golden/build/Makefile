# ------------------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------------------

# Shell to run
SHELL := bash

# Output directory
OUT = out
export OUT

# RISCV prefix
RISCVPREFIX = riscv32-unknown-elf

# GCC options
GCC_OPTS = -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles

# Signature address
SIGNATURE_ADDR = 8ffffffc


# ------------------------------------------------------------------------------------------
# Targets
# ------------------------------------------------------------------------------------------

# Submodule directory
submodule_dir = $(PWD)/../../../../submodules
export submodule_dir

# Convert and run test programs
.PHONY: run
run: $(OUT)/riscv-tests/riscv-tests.gen.log
	$(MAKE) -f run.mk ASM_DIR=$(OUT)/riscv-tests OUT=$(OUT) SIGNATURE_ADDR=$(SIGNATURE_ADDR) \
		submodule_dir=$(submodule_dir) RISCVPREFIX=$(RISCVPREFIX)

# Create test programs
$(OUT)/riscv-tests/riscv-tests.gen.log: | $(OUT)
	@echo "*** Generating programs from riscv-tests (log at $@)"
	mkdir -p $(OUT)/riscv-tests
	@echo "    - Generating programs"
	$(MAKE) -C $(submodule_dir)/riscv-tests-miriscv/isa/ rv32ui rv32um XLEN=32 \
		RISCV_PREFIX=$(RISCVPREFIX)- RISCV_GCC_OPTS="$(GCC_OPTS)" rv32ui_v_tests="" &> $@
	@echo "    - Adding prefixes to .elfs"
	mv $(submodule_dir)/riscv-tests-miriscv/isa/rv32ui-p-* $(OUT)/riscv-tests/
	mv $(submodule_dir)/riscv-tests-miriscv/isa/rv32um-p-* $(OUT)/riscv-tests/
	find $(OUT)/ -type f -not -name "*.dump" -not -name "*.log" -exec mv '{}' '{}'.elf \;

# Create output directory if neccessary
$(OUT):
	mkdir -p $(OUT)

# Clean target
.PHONY: clean
clean:
	rm -rf $(OUT)
