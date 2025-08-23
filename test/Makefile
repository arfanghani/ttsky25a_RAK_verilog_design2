# Makefile for tt_um_minirisc Cocotb simulation

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_minirisc.v

ifneq ($(GATES),yes)

# RTL simulation
SIM_BUILD = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS += -I$(SRC_DIR)

else

# Gate level simulation
SIM_BUILD = sim_build/gl
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUSE_POWER_PINS
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1

# Sky130 standard cells
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# Gate-level netlist
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include the testbench sources (tb.v handles VCD dump)
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# Python cocotb test file (without .py)
MODULE = test

# Include cocotb's make rules
include $(shell cocotb-config --makefiles)/Makefile.sim
