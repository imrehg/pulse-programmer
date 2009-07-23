# Makefile for PCP subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =					\
	pcp_reg_file.sim.fun			\
	pcp_address_stack.sim.fun		\
	pcp_loop_reg_file.sim.fun		\
	pcp_phase_reg_file.sim.fun		\
	pcp1_decoder.sim.fun			\
	pcp1_core.sim.fun			\
	pcp1_core_nested_subs.sim.fun		\
	pcp1_core_phase.sim.fun			\
	pcp1_core_wait.sim.fun			\
	pcp1_core_nested_loops.sim.fun		\
#	pcp_core.sim.fun			\
#	pcp_decoder.sim.fun			\
#	pcp1_controller_test.sim.fun		\
#	pcp1_controller_test_read.sim.fun	\
#	pcp1_controller_test_phase.sim.fun	\
#	pcp_controller_iset.sim.fun		\
#	pcp_controller_one.sim.fun		\
#	pcp_controller_one_train.sim.fun	\
#	pcp_controller_two.sim.fun		\
#	pcp_controller_three.sim.fun		\
#	pcp_controller_reg.sim.fun		\
#	pcp_controller_test.sim.fun		\

TOP_SRC_DIR = ..

VHDL_FILES =				\
		pcplib.vhd		\
		pcp_reg_file.vhd	\
		pcp_address_stack.vhd	\
		pcp_loop_reg_file.vhd	\
		pcp_phase_reg_file.vhd	\
		pcp1_decoder.vhd	\
		pcp1_core.vhd		\
		pcp1_controller.vhd	\
		pcp_reg_file.vhd	\
		pcp2_decoder.vhd	\
		pcp2_core.vhd		\
		pcp2_controller.vhd	\
		pcp3_decoder.vhd	\
#		pcp_decoder.vhd		\
#		pcp_core.vhd		\
#		pcp_controller.vhd	\

include ../Makefile.common

M4_INCLUDES += $(TOP_SRC_DIR)/pcp.m4


# Irregularly-Named Tests
pcp_controller_iset.sim.fun: 		pcp_controller_iset.vwf              \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp_controller_one.sim.fun: 		pcp_controller_one.vwf              \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp_controller_one_train.sim.fun: 	pcp_controller_one_train.vwf        \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp_controller_two.sim.fun: 		pcp_controller_two.vwf        \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp_controller_three.sim.fun: 		pcp_controller_three.vwf        \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp_controller_reg.sim.fun: 		pcp_controller_reg.vwf        \
					pcp_controller.map.simgen
	$(SIMFUN) --vector_source=$< pcp_controller
	echo "blah" > $@

pcp1_core_nested_subs.sim.fun: 		pcp1_core_nested_subs.vwf        \
					pcp1_core.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_core
	echo "blah" > $@

pcp1_core_nested_loops.sim.fun: 	pcp1_core_nested_loops.vwf        \
					pcp1_core.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_core
	echo "blah" > $@

pcp1_core_wait.sim.fun: 		pcp1_core_wait.vwf        \
					pcp1_core.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_core
	echo "blah" > $@

pcp1_core_phase.sim.fun: 		pcp1_core_phase.vwf        \
					pcp1_core.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_core
	echo "blah" > $@

pcp1_controller_test_read.sim.fun: 	pcp1_controller_test_read.vwf        \
					pcp1_controller_test.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_controller_test
	echo "blah" > $@

pcp1_controller_test_phase.sim.fun: 	pcp1_controller_test_phase.vwf        \
					pcp1_controller_test.map.simgen
	$(SIMFUN) --vector_source=$< pcp1_controller_test
	echo "blah" > $@

# VHDL File Targets

pcplib.vhd:	$(M4_INCLUDES) pcplib.m4

pcp_decoder.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp_decoder.m4

pcp_reg_file.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_dual_controller.vhd	\
		pcplib.vhd				\
		pcp_reg_file.m4

pcp1_decoder.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp1_decoder.m4

pcp2_decoder.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp2_decoder.m4

pcp3_decoder.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp3_decoder.m4

pcp_trigger.vhd: 						\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		$(TOP_SRC_DIR)/clock_multiplier.vhd		\
		pcp_trigger.m4
	$(M4) $(M4_DIVERT) ../clock_multiplier.m4 \
		$(M4_UNDIVERT) pcp_trigger.m4 > $@
	$(DOS2UNIX) $@

pcp_core.vhd: 						\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp_decoder.vhd				\
		pcp_reg_file.vhd			\
		$(TOP_SRC_DIR)/timer.vhd		\
		pcp_core.m4
	$(M4) $(M4_DIVERT) pcp_reg_file.m4 pcp_decoder.m4 ../timer.m4 \
		$(M4_UNDIVERT) pcp_core.m4 > $@
	$(DOS2UNIX) $@

pcp1_core.vhd: 						\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp1_decoder.vhd			\
		pcp_phase_reg_file.vhd			\
		pcp_loop_reg_file.vhd			\
		pcp_address_stack.vhd			\
		$(TOP_SRC_DIR)/timer.vhd		\
		pcp1_core.m4
	$(M4) $(M4_DIVERT) pcp_phase_reg_file.m4 pcp1_decoder.m4 ../timer.m4 \
		pcp_loop_reg_file.m4 pcp_address_stack.m4 $(M4_UNDIVERT) \
		pcp1_core.m4 > $@
	$(DOS2UNIX) $@

pcp2_core.vhd: 						\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp2_decoder.vhd			\
		pcp_phase_reg_file.vhd			\
		pcp_reg_file.vhd			\
		pcp_address_stack.vhd			\
		$(TOP_SRC_DIR)/timer.vhd		\
		pcp2_core.m4
	$(M4) $(M4_DIVERT) pcp_phase_reg_file.m4 pcp2_decoder.m4 ../timer.m4 \
		../memory_dual_dc.m4 pcp_reg_file.m4 pcp_address_stack.m4 \
		$(M4_UNDIVERT) pcp2_core.m4 > $@
	$(DOS2UNIX) $@

pcp3_core.vhd: 						\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp3_decoder.vhd			\
		pcp_phase_reg_file.vhd			\
		pcp_reg_file.vhd			\
		pcp_address_stack.vhd			\
		$(TOP_SRC_DIR)/timer.vhd		\
		pcp3_core.m4
	$(M4) $(M4_DIVERT) pcp_phase_reg_file.m4 pcp3_decoder.m4 ../timer.m4 \
		../memory_dual_dc.m4 pcp_reg_file.m4 pcp_address_stack.m4 \
		$(M4_UNDIVERT) pcp3_core.m4 > $@
	$(DOS2UNIX) $@

pcp_controller.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp_core.vhd				\
		$(TOP_SRC_DIR)/async_fifo.vhd		\
		pcp_controller.m4
	$(M4) $(M4_DIVERT) pcp_core.m4 $(M4_UNDIVERT) pcp_controller.m4 > $@
	$(DOS2UNIX) $@

pcp1_controller.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp1_core.vhd				\
		pcp1_controller.m4
	$(M4) $(M4_DIVERT) pcp1_core.m4 $(M4_UNDIVERT) pcp1_controller.m4 > $@
	$(DOS2UNIX) $@

pcp2_controller.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp2_core.vhd				\
		pcp2_controller.m4
	$(M4) $(M4_DIVERT) pcp2_core.m4 $(M4_UNDIVERT) pcp2_controller.m4 > $@
	$(DOS2UNIX) $@

pcp3_controller.vhd: 					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		pcplib.vhd				\
		pcp3_core.vhd				\
		pcp3_controller.m4
	$(M4) $(M4_DIVERT) pcp3_core.m4 $(M4_UNDIVERT) pcp3_controller.m4 > $@
	$(DOS2UNIX) $@

pcp_controller_test.vhd :                        	\
		$(M4_INCLUDES)				\
		$(M4_TOP_INCLUDES)			\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/ptp/ptp_router.vhd	\
		$(TOP_SRC_DIR)/ptp/ptp_top.vhd		\
		pcp_controller.vhd			\
		pcp_controller_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT) ../ptp/ptp_top.m4 ../ptp/ptp_router.m4 \
		pcp_controller.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) pcp_controller_test.m4 > $@
	$(DOS2UNIX) $@

pcp1_controller_test.vhd :                        	\
		$(M4_INCLUDES)				\
		$(M4_TOP_INCLUDES)			\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/async_read_write.vhd	\
		$(TOP_SRC_DIR)/ptp/ptp_router.vhd	\
		$(TOP_SRC_DIR)/ptp/ptp_top.vhd		\
		pcp1_controller.vhd			\
		pcp1_controller_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT)		\
		$(TOP_SRC_DIR)/async_read_write.m4	\
		$(TOP_SRC_DIR)/ptp/ptp_top.m4		\
		$(TOP_SRC_DIR)/ptp/ptp_router.m4	\
		pcp1_controller.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) pcp1_controller_test.m4 > $@
	$(DOS2UNIX) $@
