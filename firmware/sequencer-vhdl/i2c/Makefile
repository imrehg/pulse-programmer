# Makefile for I2C subsystem.
###############################################################################
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
###############################################################################

all: help

TEST_FILES =							\
	i2c_controller.sim.fun					\
	i2c_led_controller.sim.fun				\
	i2c_led_test.sim.fun					\

TOP_SRC_DIR = ..

VHDL_FILES =							\
		i2c_controller.vhd				\
		i2c_led_controller.vhd				\
		i2c_master_bit_ctrl.vhd				\
		i2c_master_byte_ctrl.vhd			\
		i2c_master_top.vhd				\
		i2c_controller_test.vhd				\
		i2c_led_test.vhd				\

include ../Makefile.common

M4_INCLUDES += 	$(TOP_SRC_DIR)/i2c.m4

i2c_master_byte_ctrl.vhd :                          		\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		i2c_master_bit_ctrl.vhd				\
		i2c_master_byte_ctrl.m4
	$(M4) $(M4_DIVERT) i2c_master_bit_ctrl.m4		\
		$(M4_UNDIVERT) i2c_master_byte_ctrl.m4 > $@
	$(DOS2UNIX) $@

i2c_master_top.vhd :                          			\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		i2c_master_byte_ctrl.vhd			\
		i2c_master_top.m4
	$(M4) $(M4_DIVERT) i2c_master_byte_ctrl.m4		\
		$(M4_UNDIVERT) i2c_master_top.m4 > $@
	$(DOS2UNIX) $@

i2c_controller.vhd :                          			\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		i2c_master_top.vhd				\
		i2c_controller.m4
	$(M4) $(M4_DIVERT) i2c_master_top.m4			\
		$(M4_UNDIVERT) i2c_controller.m4 > $@
	$(DOS2UNIX) $@

i2c_led_controller.vhd :                       			\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		i2c_led_controller.m4

i2c_controller_test.vhd :                      			\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		i2c_controller.vhd				\
		i2c_led_controller.vhd				\
		i2c_controller_test.m4
	$(M4) $(M4_DIVERT) i2c_controller.m4 i2c_led_controller.m4 \
		$(M4_UNDIVERT) i2c_controller_test.m4 > $@
	$(DOS2UNIX) $@

i2c_led_test.vhd :                          			\
		$(M4_INCLUDES)					\
		$(TOP_SRC_DIR)/seqlib.vhd			\
		$(TOP_SRC_DIR)/boot_led.vhd			\
		$(TOP_SRC_DIR)/wb_intercon.vhd			\
		i2c_led_controller.vhd				\
		i2c_led_test.m4
	$(M4) $(M4_DIVERT) $(TOP_SRC_DIR)/boot_led.m4 		\
		i2c_led_controller.m4 $(M4_UNDIVERT) i2c_led_test.m4 > $@
	$(DOS2UNIX) $@
