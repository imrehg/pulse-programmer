# Makefile for PTP subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =					\
	ptp_transmit.sim.fun			\
	ptp_receive.sim.fun			\
	ptp_daisy_transmit.sim.fun		\
	ptp_daisy_receive.sim.fun		\
	ptp_daisy_link.sim.fun			\
	ptp_buffer.sim.fun			\
	ptp_daisy_router.sim.fun		\
	ptp_status.sim.fun			\
	ptp_debug.sim.fun			\
	ptp_debug_mac.sim.fun			\
	ptp_discover.sim.fun			\
	ptp_memory.sim.fun			\
	ptp_start.sim.fun			\
	ptp_trigger.sim.fun			\
	ptp_i2c.sim.fun				\
	ptp_top.sim.fun				\
	ptp_daisy_link_test.sim.fun		\
# It's not worth anyone's time to maintain these tests for PCP32
#	ptp_top_test.sim.fun			\
#	ptp_memory_memory_test.sim.fun		\
#	ptp_router.sim.fun			\
#	ptp_top_memory_test.sim.fun		\
#	ptp_loopback_test.sim.fun		\
#	ptp_loopback_test_broadcast.sim.fun	\
#	ptp_loopback_test_discover.sim.fun	\
#	ptp_i2c_test.sim.fun			\

TOP_SRC_DIR = ..

VHDL_FILES =				\
	ptp_router.vhd			\
	ptp_top.vhd			\
	ptp_daisy_router.vhd		\
	ptp_transmit.vhd		\
	ptp_receive.vhd			\
	ptp_buffer.vhd			\
	ptp_daisy_link.vhd		\
	ptp_daisy_transmit.vhd		\
	ptp_daisy_receive.vhd		\
	ptp_start.vhd			\
	ptp_debug.vhd			\
	ptp_memory.vhd			\
	ptp_trigger.vhd			\
	ptp_i2c.vhd			\
	ptp_status.vhd			\
	ptp_discover.vhd		\
#	ptp_avr_interface.vhd		\

# Removed b/c of TOP_M4 dependencies.
#	ptp_top_test.vhd		\
#	ptp_daisy_link_test.vhd		\
#	ptp_top_memory_test.vhd		\
#	ptp_route_test.vhd		\
#	ptp_loopback_test.vhd		\

include ../Makefile.common

M4_INCLUDES +=	../network/receive.m4		\
		../network/network.m4		\
		../network/transmit.m4		\
		../network/buffer.m4		\
		$(TOP_SRC_DIR)/ptp.m4		\
		ptp.m4

# Irregularly-Named Tests
ptp_router_udp.sim.fun: 		ptp_router_udp.vwf                   \
					ptp_router.map.simgen
	$(SIMFUN) --vector_source=$< ptp_router
	echo "blah" > $@

ptp_debug_mac.sim.fun: 			ptp_debug_mac.vwf                   \
					ptp_debug.map.simgen
	$(SIMFUN) --vector_source=$< ptp_debug
	echo "blah" > $@

ptp_router_terminator.sim.fun: 		ptp_router_terminator.vwf            \
					ptp_router.map.simgen
	$(SIMFUN) --vector_source=$< ptp_router
	echo "blah" > $@

ptp_loopback_test_broadcast.sim.fun: 	ptp_loopback_test_broadcast.vwf      \
					ptp_loopback_test.map.simgen
	$(SIMFUN) --vector_source=$< ptp_loopback_test
	echo "blah" > $@

ptp_loopback_test_discover.sim.fun: 	ptp_loopback_test_discover.vwf      \
					ptp_loopback_test.map.simgen
	$(SIMFUN) --vector_source=$< ptp_loopback_test
	echo "blah" > $@

# VHDL Source File Dependencies

ptp_daisy_transmit.vhd:					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		ptp_daisy_transmit.m4

ptp_daisy_receive.vhd:					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		ptp_daisy_receive.m4

ptp_daisy_link.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_daisy_receive.vhd			\
		ptp_daisy_transmit.vhd			\
		ptp_daisy_link.m4
	$(M4) $(M4_DIVERT) ptp_daisy_receive.m4 ptp_daisy_transmit.m4	\
		$(M4_UNDIVERT) ptp_daisy_link.m4 > $@
	$(DOS2UNIX) $@

ptp_daisy_link_test.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_daisy_receive.vhd			\
		ptp_daisy_transmit.vhd			\
		ptp_daisy_link.vhd			\
		ptp_daisy_link_test.m4
	$(M4) $(M4_DIVERT) ptp_daisy_receive.m4 ptp_daisy_transmit.m4	\
		ptp_daisy_link.m4 $(M4_UNDIVERT) ptp_daisy_link_test.m4 > $@
	$(DOS2UNIX) $@

ptp_buffer.vhd:					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory.vhd		\
		$(TOP_SRC_DIR)/network/buffer.m4	\
		ptp_buffer.m4
	$(M4) $(M4_DIVERT) $(TOP_SRC_DIR)/network/buffer.m4	\
		$(M4_UNDIVERT) ptp_buffer.m4 > $@
	$(DOS2UNIX) $@

ptp_transmit.vhd:					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory.vhd		\
		$(TOP_SRC_DIR)/network/in_cksum.vhd	\
		ptp_transmit.m4

ptp_receive.vhd:					\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/network/in_cksum.vhd	\
		ptp_receive.m4

ptp_daisy_router.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_receive.vhd			\
		ptp_transmit.vhd		\
		ptp_daisy_link.vhd		\
		ptp_buffer.vhd			\
		ptp_daisy_router.m4
	$(M4) $(M4_DIVERT) ptp_receive.m4 ptp_transmit.m4 ptp_daisy_link.m4 \
		ptp_buffer.m4 $(M4_UNDIVERT) ptp_daisy_router.m4 > $@
	$(DOS2UNIX) $@

ptp_router.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_receive.vhd			\
		ptp_transmit.vhd		\
		ptp_daisy_link.vhd		\
		ptp_buffer.vhd			\
		ptp_daisy_router.vhd		\
		ptp_daisy_transmit.vhd		\
		ptp_daisy_receive.vhd		\
		ptp_daisy_link.vhd		\
		ptp_router.m4
	$(M4) $(M4_DIVERT) ptp_daisy_link.m4 ptp_daisy_router.m4 \
		$(M4_UNDIVERT) ptp_router.m4 > $@
	$(DOS2UNIX) $@

###############################################################################
# PTP Application Modules

ptp_status.vhd :                      		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_status.m4

ptp_debug.vhd :                      		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_debug.m4

ptp_discover.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_discover.m4

ptp_memory.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_memory.m4

ptp_start.vhd :                      		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_start.m4

ptp_trigger.vhd :                      		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_trigger.m4

ptp_i2c.vhd :                      		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_i2c.m4

PTP_MODULES_M4 =				\
		ptp_status.m4			\
		ptp_debug.m4			\
		ptp_discover.m4			\
		ptp_memory.m4			\
		ptp_start.m4			\
		ptp_trigger.m4			\
		ptp_i2c.m4			\

PTP_MODULES_VHDL = $(PTP_MODULES_M4:.m4=.vhd)

###############################################################################
# The top-level module
ptp_top.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(PTP_MODULES_VHDL)		\
		ptp_top.m4
	$(M4) $(M4_DIVERT) $(PTP_MODULES_M4) $(M4_UNDIVERT) ptp_top.m4 > $@
	$(DOS2UNIX) $@

ptp_avr_interface.vhd:				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/avr.m4		\
		$(TOP_SRC_DIR)/seqlib.vhd
	$(M4) $(TOP_SRC_DIR)/avr.m4 ptp_avr_interface.m4 > $@
	$(DOS2UNIX) $@

###############################################################################
# Simulation tests
ptp_top_test.vhd :                          		\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		ptp_router.vhd				\
		ptp_top.vhd				\
		ptp_top_test.m4
	$(M4) $(M4_DIVERT) ptp_router.m4 ptp_top.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) ptp_top_test.m4 > $@
	$(DOS2UNIX) $@

ptp_loopback_test.vhd :                        	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ptp_router.vhd			\
		ptp_top.vhd			\
		ptp_top_test.vhd		\
		ptp_loopback_test.m4		\
		$(TOP_SRC_DIR)/test.m4
	$(M4) $(TOP_SRC_DIR)/test.m4 $(M4_DIVERT) ptp_top_test.m4 \
		$(M4_UNDIVERT) ptp_loopback_test.m4 > $@
	$(DOS2UNIX) $@

ptp_top_memory_test.vhd :                        	\
		$(M4_INCLUDES)				\
		$(M4_TOP_INCLUDES)			\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		ptp_router.vhd				\
		ptp_top.vhd				\
		ptp_top_test.vhd			\
		ptp_top_memory_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT) ptp_top.m4 ptp_router.m4 \
		$(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) ptp_top_memory_test.m4 > $@
	$(DOS2UNIX) $@

ptp_memory_memory_test.vhd :                        	\
		$(M4_INCLUDES)				\
		$(M4_TOP_INCLUDES)			\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/async_read_write.vhd	\
		ptp_router.vhd				\
		ptp_top.vhd				\
		ptp_top_test.vhd			\
		ptp_memory_memory_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT) ptp_top.m4 ptp_router.m4 \
		 $(TOP_SRC_DIR)/async_read_write.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_UNDIVERT) ptp_memory_memory_test.m4 > $@
	$(DOS2UNIX) $@

ptp_i2c_test.vhd :                        			\
		$(M4_INCLUDES)					\
		$(M4_TOP_INCLUDES)				\
		$(TOP_SRC_DIR)/test.m4				\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		$(TOP_SRC_DIR)/i2c/i2c_controller.vhd		\
		$(TOP_SRC_DIR)/i2c/i2c_led_controller.vhd	\
		$(TOP_SRC_DIR)/wb_intercon.vhd			\
		ptp_router.vhd					\
		ptp_top.vhd					\
		ptp_i2c_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT) ptp_top.m4 ptp_router.m4 \
		$(TOP_SRC_DIR)/i2c/i2c_controller.m4		\
		$(TOP_SRC_DIR)/i2c/i2c_led_controller.m4	\
		 $(TOP_SRC_DIR)/test.m4 			\
		$(M4_UNDIVERT) ptp_i2c_test.m4 > $@
	$(DOS2UNIX) $@

###############################################################################
# SignalTap tests

ptp_wire_test.vhd :                        	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(M4_COMPONENTS)		\
		$(TOP_SRC_DIR)/boot_led.vhd	\
		ptp_daisy_link.vhd		\
		ptp_wire_test.m4
	$(M4) $(M4_DIVERT) $(TOP_COMPONENTS) ptp_daisy_link.m4	\
		$(M4_UNDIVERT) ptp_wire_test.m4 > $@
	$(DOS2UNIX) $@

ptp_wire_multi_test.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(M4_COMPONENTS)		\
		$(TOP_SRC_DIR)/boot_led.vhd	\
		ptp_daisy_link.vhd		\
		ptp_wire_multi_test.m4
	$(M4) $(M4_DIVERT) $(TOP_COMPONENTS) ptp_daisy_link.m4	\
		$(M4_UNDIVERT) ptp_wire_multi_test.m4 > $@
	$(DOS2UNIX) $@

ptp_route_test.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(M4_COMPONENTS)		\
		$(TOP_SRC_DIR)/boot_led.vhd	\
		ptp_daisy_link.vhd		\
		ptp_daisy_router.vhd		\
		ptp_route_test.m4
	$(M4) $(M4_DIVERT) $(TOP_COMPONENTS) ptp_daisy_link.m4	\
		ptp_daisy_router.m4 $(M4_UNDIVERT) ptp_route_test.m4 > $@
	$(DOS2UNIX) $@

ptp_network_test.vhd :                      	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_VHDL)		\
		$(TOP_SRC_DIR)/boot_led.vhd	\
		ptp_network_test.m4
	$(M4) $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) \
		ptp_network_test.m4 > $@
	$(DOS2UNIX) $@
