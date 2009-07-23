# Makefile for AVR subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =					\
	avr_controller.sim.fun			\
	avr_controller_call.sim.fun		\
	avr_controller_memory_test.sim.fun	\
	avr_controller_dma_test.sim.fun		\

TOP_SRC_DIR = ..

VHDL_FILES =					\
	avr_controller.vhd			\
	avr_network_test.vhd			\
	avr_port.vhd				\
	pm_fetch_dec.vhd			\
	reg_file.vhd				\
	alu_avr.vhd				\
	avr_core.vhd				\
	bit_processor.vhd			\
	io_mux.vhd				\
	io_adr_dec.vhd				\
	io_reg_file.vhd				\

# Removed because of TOP_M4 dependencies
#	avr_controller_memory_test.vhd		\
#	avr_controller_dma_test.vhd		\
#	avr_network_test.vhd			\
#	avr_controller_timing_test.vhd		\

include ../Makefile.common

M4_INCLUDES += 	$(TOP_SRC_DIR)/avr.m4

AVR_COMPONENTS =				\
		pm_fetch_dec.m4			\
		reg_file.m4			\
		bit_processor.m4		\
		io_adr_dec.m4			\
		io_reg_file.m4			\
		alu_avr.m4			\

AVR_PERIPHERALS =				\
		io_mux.m4			\
		avr_port.m4			\

#avr_controller.sim.fun: 		sram_wb_slave.vwf                     \
#					sram_wb_slave.map.simgen
#	$(SIMFUN) --vector_source=$< sram_wb_slave

avr_controller.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		avr_controller.m4		\
		avr_port.vhd			\
		io_mux.vhd			\
		avr_core.vhd
	$(M4) $(M4_DIVERT)  avr_core.m4 $(AVR_PERIPHERALS) \
		$(M4_UNDIVERT) avr_controller.m4 > $@
	$(DOS2UNIX) $@

avr_core.vhd :					\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		avr_core.m4			\
		pm_fetch_dec.vhd		\
		reg_file.vhd			\
		bit_processor.vhd		\
		io_adr_dec.vhd			\
		io_reg_file.vhd			\
		alu_avr.vhd
	$(M4) $(M4_DIVERT) $(AVR_COMPONENTS) $(M4_UNDIVERT) avr_core.m4 > $@
	$(DOS2UNIX) $@

pm_fetch_dec.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		pm_fetch_dec.m4

alu_avr.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		alu_avr.m4

io_adr_dec.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		io_adr_dec.m4

bit_processor.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		bit_processor.m4

io_reg_file.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		io_reg_file.m4

io_mux.vhd :					\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		io_mux.m4

reg_file.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		reg_file.m4

avr_port.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		avr_port.m4

avr_controller_memory_test.vhd :				\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/test.m4				\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		avr_controller.vhd				\
		$(TOP_SRC_DIR)/memory_controller.vhd		\
		$(TOP_SRC_DIR)/memory_sizer.vhd			\
		avr_controller_memory_test.m4
	$(M4) $(M4_DIVERT)  avr_controller.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) avr_controller_memory_test.m4 > $@
	$(DOS2UNIX) $@

avr_controller_timing_test.vhd :				\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/test.m4				\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		avr_controller.vhd				\
		$(TOP_SRC_DIR)/memory_controller.vhd		\
		$(TOP_SRC_DIR)/memory_sizer.vhd			\
		avr_controller_timing_test.m4
	$(M4) $(M4_DIVERT)  avr_controller.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) avr_controller_timing_test.m4 > $@
	$(DOS2UNIX) $@

avr_controller_dma_test.vhd :				\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		avr_controller.vhd			\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		$(TOP_SRC_DIR)/memory_sizer.vhd		\
		$(TOP_SRC_DIR)/ptp/ptp_top.vhd		\
		$(TOP_SRC_DIR)/ptp/ptp_router.vhd	\
		avr_controller_dma_test.m4
	$(M4) $(TOP_SRC_DIR)/test.m4 $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) \
		avr_controller_dma_test.m4 > $@
	$(DOS2UNIX) $@

avr_network_test.vhd :                      		\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_VHDL)				\
		avr_controller.vhd			\
		avr_network_test.m4
	$(M4) $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) \
		avr_network_test.m4 > $@
	$(DOS2UNIX) $@

avr_controller_call.sim.fun:		avr_controller_call.vwf	      \
					avr_controller.map.simgen
	$(SIMFUN) --vector_source=$< avr_controller
	echo "blah" > $@
