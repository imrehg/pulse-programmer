# Makefile for SRAM subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =					\
	sram_controller.sim.fun

TOP_SRC_DIR = ..

VHDL_FILES =					\
		sram_controller.vhd		\

# Removed because of TOP_M4 dependencies
#		sram_controller_test.vhd	\

include ../Makefile.common

sram_wb_slave.sim.fun: 			sram_wb_slave.vwf                     \
					sram_wb_slave.map.simgen
	$(SIMFUN) --vector_source=$< sram_wb_slave

sram_controller.vhd : $(M4_INCLUDES) sram_controller.m4 ../seqlib.vhd
	$(M4) $(M4_DIVERT) ../seqlib.m4 $(M4_UNDIVERT)	\
		 sram_controller.m4 > $@
	$(DOS2UNIX) $@

sram_controller_test.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_VHDL)		\
		sram_controller.vhd		\
		sram_controller_test.m4
	$(M4) $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) \
		sram_controller_test.m4 > $@
	$(DOS2UNIX) $@
