# Makefile for network subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =					\
	crc32_check.sim.fun			\
	crc32_zero.sim.fun			\
	ethernet_receive.sim.fun		\
	ethernet_receive_broadcast.sim.fun	\
	ethernet_receive_bad_address.sim.fun	\
	ethernet_transmit.sim.fun		\
	ethernet.sim.fun			\
	ring_buffer.sim.fun			\
        lookup_table.sim.fun			\
	arp_transmit.sim.fun			\
	arp_transmit_delay.sim.fun		\
	arp_transmit_reset.sim.fun		\
	arp_receive.sim.fun			\
	arp_receive_error.sim.fun		\
	arp.sim.fun				\
	arp_gateway.sim.fun			\
	arp_nomerge.sim.fun			\
	in_cksum.sim.fun			\
	ip_transmit.sim.fun			\
	ip_receive.sim.fun			\
	ip_buffer.sim.fun			\
	ip_transport.sim.fun			\
	ip.sim.fun				\
	icmp_transmit.sim.fun			\
	icmp_receive.sim.fun			\
	icmp.sim.fun				\
	network_controller.sim.fun		\
	network_controller_udp.sim.fun		\
	network_controller_arp.sim.fun		\
	udp_transmit.sim.fun			\
	udp_receive.sim.fun			\
	dhcp_transmit.sim.fun			\
	dhcp_receive.sim.fun			\
	dhcp.sim.fun				\
	dhcp_overlap.sim.fun			\
	dhcp_static.sim.fun			\
#	fast_buffer.sim.fun			\
#	ethernet_transmit_long.sim.fun		\
#	network_controller_dma_test.sim.fun	\
#	network_controller_tcp.sim.fun		\

TOP_SRC_DIR = ..

VHDL_FILES =						\
		network_controller.vhd			\
		dhcp.vhd				\
		dhcp_transmit.vhd			\
		dhcp_receive.vhd			\
		udp_transmit.vhd			\
		udp_receive.vhd				\
		icmp_transmit.vhd			\
		icmp_receive.vhd			\
		icmp.vhd				\
		lookup_table.vhd			\
		ring_buffer.vhd				\
		arp_transmit.vhd			\
		arp_receive.vhd				\
		arp.vhd					\
		ip_transmit.vhd				\
		ip_transport.vhd			\
		ip_receive.vhd				\
		ip_buffer.vhd				\
		ip.vhd					\
		ethernet_transmit.vhd			\
		ethernet_receive.vhd			\
		ethernet.vhd				\
		in_cksum.vhd				\
		crc32.vhd				\
#		fast_buffer.vhd				\
#		network_controller_dma_test.vhd		\
#		tcp_avr_interface.vhd			\

include ../Makefile.common

M4_INCLUDES += receive.m4 transmit.m4 buffer.m4 network.m4 \
		$(TOP_SRC_DIR)/network.m4

# Irregularly-named tests

crc32_check.sim.fun: 			crc32_check.vwf                       \
					crc32.map.simgen
	$(SIMFUN) --vector_source=$< crc32
	echo "blah" > $@

crc32_zero.sim.fun: 			crc32_zero.vwf                        \
					crc32.map.simgen
	$(SIMFUN) --vector_source=$< crc32
	echo "blah" > $@

ethernet_receive_broadcast.sim.fun:     ethernet_receive_broadcast.vwf        \
					ethernet_receive.map.simgen
	$(SIMFUN) --vector_source=$< ethernet_receive
	echo "blah" > $@

ethernet_receive_bad_address.sim.fun:   ethernet_receive_bad_address.vwf      \
					ethernet_receive.map.simgen
	$(SIMFUN) --vector_source=$< ethernet_receive
	echo "blah" > $@

ethernet_transmit_long.sim.fun:		ethernet_transmit_long.vwf            \
					ethernet_transmit.map.simgen
	$(SIMFUN) --vector_source=$< ethernet_transmit
	echo "blah" > $@

arp_transmit_reset.sim.fun:		arp_transmit_reset.vwf                \
					arp_transmit.map.simgen
	$(SIMFUN) --vector_source=$< arp_transmit
	echo "blah" > $@

arp_transmit_delay.sim.fun:		arp_transmit_delay.vwf                \
					arp_transmit.map.simgen
	$(SIMFUN) --vector_source=$< arp_transmit
	echo "blah" > $@

arp_receive_error.sim.fun:		arp_receive_error.vwf                 \
					arp_receive.map.simgen
	$(SIMFUN) --vector_source=$< arp_receive
	echo "blah" > $@

arp_nomerge.sim.fun:			arp_nomerge.vwf                       \
					arp.map.simgen
	$(SIMFUN) --vector_source=$< arp
	echo "blah" > $@

arp_gateway.sim.fun:			arp_gateway.vwf                       \
					arp.map.simgen
	$(SIMFUN) --vector_source=$< arp
	echo "blah" > $@

network_controller_udp.sim.fun:		network_controller_udp.vwf	      \
					network_controller.map.simgen
	$(SIMFUN) --vector_source=$< network_controller
	echo "blah" > $@

network_controller_arp.sim.fun:		network_controller_arp.vwf	      \
					network_controller.map.simgen
	$(SIMFUN) --vector_source=$< network_controller
	echo "blah" > $@

network_controller_tcp.sim.fun:		network_controller_tcp.vwf	      \
					network_controller.map.simgen
	$(SIMFUN) --vector_source=$< network_controller
	echo "blah" > $@

dhcp_overlap.sim.fun:			dhcp_overlap.vwf	      	      \
					dhcp.map.simgen
	$(SIMFUN) --vector_source=$< dhcp
	echo "blah" > $@

dhcp_static.sim.fun:			dhcp_static.vwf	      	      \
					dhcp.map.simgen
	$(SIMFUN) --vector_source=$< dhcp
	echo "blah" > $@

# Source file dependencies

crc32.vhd :					\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		crc32.m4

ethernet_receive.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		crc32.vhd			\
		ethernet_receive.m4

ethernet_transmit.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		crc32.vhd			\
		ethernet_transmit.m4

ethernet.vhd :                          	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_SRC_DIR)/async_fifo.vhd	\
		$(TOP_SRC_DIR)/memory_dual_dc.vhd	\
		ethernet_receive.vhd		\
		ethernet_transmit.vhd		\
		ethernet.m4
	$(M4) $(M4_DIVERT) ethernet_receive.m4 ethernet_transmit.m4	      \
		../async_fifo.m4 ../memory_dual_dc.m4 $(M4_UNDIVERT) ethernet.m4 > $@
	$(DOS2UNIX) $@

arp_transmit.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		arp_transmit.m4

arp_receive.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		arp_receive.m4

ring_buffer.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ring_buffer.m4

lookup_table.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ring_buffer.vhd			\
		lookup_table.m4

arp.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		arp_receive.vhd			\
		arp_transmit.vhd		\
		lookup_table.vhd		\
		arp.m4
	$(M4) $(M4_DIVERT) arp_receive.m4 arp_transmit.m4 lookup_table.m4\
		$(M4_UNDIVERT) arp.m4 > $@
	$(DOS2UNIX) $@

ip_transmit.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		in_cksum.vhd			\
		ip_transmit.m4

ip_receive.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ip_receive.m4

ip_buffer.vhd :						\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_controller.vhd		\
		ip_buffer.m4

ip_transport.vhd :				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ip_buffer.vhd			\
		$(TOP_SRC_DIR)/wb_intercon.vhd	\
		ip_transport.m4
	$(M4) $(M4_DIVERT) ip_buffer.m4 $(M4_UNDIVERT) ip_transport.m4 > $@
	$(DOS2UNIX) $@

ip.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		ip_receive.vhd			\
		ip_transport.vhd		\
		ip_transmit.vhd			\
		arp.vhd				\
		ip.m4
	$(M4) $(M4_DIVERT) ip_receive.m4 ip_transport.m4 ip_transmit.m4	\
		arp.m4 $(M4_UNDIVERT) ip.m4 > $@
	$(DOS2UNIX) $@

icmp_receive.vhd: $(M4_INCLUDES)		\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		icmp_receive.m4

icmp_transmit.vhd: 				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		icmp_transmit.m4

icmp.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		icmp_receive.vhd			\
		icmp_transmit.vhd			\
		icmp.m4
	$(M4) $(M4_DIVERT) icmp_receive.m4 icmp_transmit.m4	\
		$(M4_UNDIVERT) icmp.m4 > $@
	$(DOS2UNIX) $@

udp_receive.vhd: $(M4_INCLUDES)		\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		udp_receive.m4

udp_transmit.vhd: 				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		udp_transmit.m4

udp.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		udp_receive.vhd			\
		udp_transmit.vhd			\
		udp.m4
	$(M4) $(M4_DIVERT) udp_receive.m4 udp_transmit.m4	\
		$(M4_UNDIVERT) udp.m4 > $@
	$(DOS2UNIX) $@

dhcp_transmit.vhd:				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		dhcp_transmit.m4

dhcp_receive.vhd:				\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		dhcp_receive.m4

dhcp.vhd :                          		\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		dhcp_receive.vhd			\
		dhcp_transmit.vhd			\
		dhcp.m4
	$(M4) $(M4_DIVERT) dhcp_receive.m4 dhcp_transmit.m4	\
		$(M4_UNDIVERT) dhcp.m4 > $@
	$(DOS2UNIX) $@

M4_NETWORK_COMPONENTS =				\
		ethernet.m4			\
		ip.m4				\
		icmp.m4				\
		udp_receive.m4			\
		udp_transmit.m4			\
#		fast_buffer.m4			\

VHDL_NETWORK_COMPONENTS = $(M4_NETWORK_COMPONENTS:.m4=.vhd)

network_controller.vhd :                       	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(VHDL_NETWORK_COMPONENTS)	\
		network_controller.m4
	$(M4) $(M4_DIVERT) $(M4_NETWORK_COMPONENTS)	\
		$(M4_UNDIVERT) network_controller.m4 > $@
	$(DOS2UNIX) $@

network_controller_dma_test.vhd :			\
		$(M4_INCLUDES)				\
		$(M4_TOP_INCLUDES)			\
		$(TOP_SRC_DIR)/avr.m4			\
		$(TOP_SRC_DIR)/test.m4			\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		network_controller.vhd			\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		$(TOP_SRC_DIR)/memory_sizer.vhd		\
		network_controller_dma_test.m4
	$(M4) $(M4_TOP_INCLUDES) $(TOP_SRC_DIR)/avr.m4 $(TOP_SRC_DIR)/test.m4 \
		$(M4_DIVERT) \
		$(TOP_M4) $(M4_UNDIVERT) network_controller_dma_test.m4 > $@
	$(DOS2UNIX) $@
