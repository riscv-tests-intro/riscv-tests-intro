# Verilator options
VERILATOR_NO_WARN_OPTS = -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM \
-Wno-PINMISSING -Wno-GENUNNAMED -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT -Wno-INFINITELOOP \
-Wno-MULTIDRIVEN -Wno-INITIALDLY \

VERILATOR_COMPILE_OPTS = -cc -O2 -j 1 --threads 1 --binary

VERILATOR_TRACING_OPTS = --trace --trace-params --trace-structs



SV_FILES = $(wildcard $(INC_PATH)/*.sv $(RTL_PATH)/*.sv $(TB_PATH)/$(SV_TOP).sv)

.PHONY: all clean compile sim view gtkwaverc_symbolic_link

all: compile sim gtkwaverc_symbolic_link view

clean:
	rm -rf $(OUTPUT_PATH)/*

compile: $(SV_FILES)
	verilator \
	$(VERILATOR_NO_WARN_OPTS) \
	$(VERILATOR_COMPILE_OPTS) \
	$(INC_PATH)/*.sv \
	$(RTL_PATH)/*.sv \
	$(TB_PATH)/$(SV_TOP).sv \
 	+incdir+$(TB_PATH)/ \
	$(VERILATOR_TRACING_OPTS) \
	--x-assign 0 \
	-top-module $(SV_TOP) \
	-Mdir $(OUTPUT_PATH) | tee $(OUTPUT_PATH)/$(COMPILE_LOG)
    # -Mdir $(OUTPUT_PATH) &> $(OUTPUT_PATH)/$(COMPILE_LOG)

sim: $(OUTPUT_PATH)/$(COMPILE_LOG)
	$(OUTPUT_PATH)/V$(SV_TOP) \
	+bin=$(TEST_PROG) \
  	+dump=$(OUTPUT_PATH)/$(WAVEFORM) | tee $(OUTPUT_PATH)/$(RUN_LOG)
  	# +dump=$(OUTPUT_PATH)/run_waves.vcd &> $(OUTPUT_PATH)/run.log

view: $(OUTPUT_PATH)/$(RUN_LOG)
	gtkwave $(OUTPUT_PATH)/$(WAVEFORM)

gtkwaverc_symbolic_link:
	ln -sf ../../.gtkwaverc .gtkwaverc