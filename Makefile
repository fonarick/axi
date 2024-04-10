.SHELL: bash
.PHONY: help all sim_all clean

VSIM        ?= vsim
SYNOPSYS_DC ?= dc_shell

TBS         ?= axi_addr_test \
               axi_atop_filter \
               axi_cdc axi_delayer \
               axi_dw_downsizer \
               axi_dw_upsizer \
               axi_fifo \
               axi_isolate \
               axi_iw_converter \
               axi_lite_regs \
               axi_lite_to_apb \
               axi_lite_to_axi \
               axi_lite_mailbox \
               axi_lite_xbar \
               axi_modify_address \
               axi_serializer \
               axi_sim_mem \
               axi_to_axi_lite \
               axi_to_mem_banked \
               axi_xbar

SIM_TARGETS := $(addsuffix .log, $(addprefix sim-, $(TBS)))

help:
	@echo "compile.log:  compile files using Questasim"
	@echo "sim-#TB#.log: simulates a given testbench, available TBs are:"
	@echo "$(addprefix ###############-#,$(TBS))" | sed -e 's/ /\n/g' | sed -e 's/#/ /g'
	@echo "sim_all:      simulates all available testbenches"
	@echo "clean:        cleans generated files"

all: compile.log sim_all

sim_all: $(SIM_TARGETS)


build:
	mkdir -p $@

compile.log: Bender.yml | build
	export VSIM="$(VSIM)"; cd build && ../scripts/compile_vsim.sh | tee ../$@
	(! grep -n "Error:" $@)


sim-%.log: compile.log
	export VSIM="$(VSIM)"; cd build && ../scripts/run_vsim.sh --random-seed $* | tee ../$@
	(! grep -n "Error:" $@)
	(! grep -n "Fatal:" $@)

clean:
	rm -rf build
	rm -f  *.log