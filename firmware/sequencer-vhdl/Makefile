all: help

HELP_LOCAL = "  make pof	makes the object file for programming firmware."

TEST_FILES =					\
	pulse_generator.sim.fun			\
	memory_controller.sim.fun		\
	memory_sizer.sim.fun			\
	clock_multiplier.sim.fun		\
	clock_divider.sim.fun			\
	subtimer.sim.fun			\
	subtimer_test.sim.fun			\
	timer.sim.fun				\
	timer_test.sim.fun			\
	timer_test_zeros.sim.fun		\
	timer_test_large.sim.fun		\
	timer_test_middle.sim.fun		\
	timer_test_small.sim.fun		\
	boot_led.sim.fun			\
	memory_sizer_test.sim.fun		\
	memory_sizer_endian_test.sim.fun	\
	subtimer_test.sim.fun			\
	dma_controller_test.sim.fun		\
	memory_controller_test.sim.fun		\
	memory_controller_test_oneshot.sim.fun	\
	async_read_fifo.sim.fun			\
	async_fifo.sim.fun			\
	async_fifo_fast.sim.fun			\
	async_read_write.sim.fun		\
	wb_intercon.sim.fun			\
#	clock_scaler.sim.fun			\

pof:	vhdl sequencer_top.pof
	make sequencer_top.pof BUILD=release

pgm:
	$(PGM) -o "PL;sequencer_top.pof"

TOP_SRC_DIR = .

SUBDIRS = i2c sram network ptp pcp

VHDL_FILES =					\
		wb_intercon.vhd			\
		memory_controller.vhd		\
		memory_burst_controller.vhd	\
		memory_dual_controller.vhd	\
		memory_sizer.vhd		\
		timer.vhd			\
		subtimer.vhd			\
		clock_multiplier.vhd		\
		clock_divider.vhd		\
		clock_shifter.vhd		\
		divider.vhd			\
		async_fifo.vhd			\
		async_read_fifo.vhd		\
		async_read_write.vhd		\
		pulse_generator.vhd		\
		boot_led.vhd			\
		dma_controller.vhd		\
		seqlib.vhd			\
		subtimer_test.vhd		\
		dma_controller_test.vhd		\
		memory_sizer_test.vhd		\
		memory_sizer_endian_test.vhd	\
		memory_controller_test.vhd	\
		timer_test.vhd			\
		seqlib.vhd			\
#		clock_scaler.vhd		\
#		clock_scaler_test.vhd		\
# Don't include sequencer_top with normal VHDL files b/c some files
# in TOP_VHDL/M4_TOP have special build rules in their own Makefiles.
#		sequencer_top.vhd		\

include Makefile.common

#M4_INCLUDES += $(TOP_SRC_DIR)/network.m4

subtimer.vhd    : $(M4_INCLUDES) subtimer.m4

subtimer_test.vhd       : $(M4_INCLUDES) subtimer.vhd subtimer_test.m4
	$(M4) $(M4_DIVERT) subtimer.m4 $(M4_UNDIVERT) subtimer_test.m4 > $@
	$(DOS2UNIX) $@

timer.vhd       : $(M4_INCLUDES) subtimer.vhd timer.m4
	$(M4) $(M4_DIVERT) subtimer.m4 $(M4_UNDIVERT) timer.m4 > $@
	$(DOS2UNIX) $@

timer_test.vhd       : $(M4_INCLUDES) subtimer.vhd timer.vhd timer_test.m4
	$(M4) $(M4_DIVERT) timer.m4 $(M4_UNDIVERT) timer_test.m4 > $@
	$(DOS2UNIX) $@

clock_scaler.vhd : $(M4_INCLUDES) divider.vhd clock_scaler.m4

memory_dual_controller.vhd: $(M4_INCLUDES) memory_burst_controller.vhd

async_read_write.vhd :                   	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_SRC_DIR)/wb_intercon.vhd	\
		$(TOP_SRC_DIR)/async_fifo.vhd	\
		$(TOP_SRC_DIR)/async_read_fifo.vhd	\
		async_read_write.m4
	$(M4) $(M4_DIVERT) $(TOP_SRC_DIR)/wb_intercon.m4 \
		$(TOP_SRC_DIR)/async_fifo.m4 \
		$(TOP_SRC_DIR)/async_read_fifo.m4 $(M4_UNDIVERT) \
		async_read_write.m4 > $@
	$(DOS2UNIX) $@

sequencer_top.vhd:	vhdl				\
			$(M4_INCLUDES)			\
			$(M4_TOP_INCLUDES)		\
			$(TOP_VHDL)			\
			seqlib.vhd			\
			sequencer_top.m4		\

	$(M4) $(M4_TOP_INCLUDES) $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) \
		sequencer_top.m4 > $@
	$(DOS2UNIX) $@

clock_scaler_test.vhd :                    	\
		$(M4_INCLUDES)			\
		$(TOP_SRC_DIR)/seqlib.vhd	\
		$(TOP_VHDL)			\
		clock_scaler_test.m4
	$(M4) $(M4_DIVERT) $(TOP_M4) $(M4_UNDIVERT) clock_scaler_test.m4 > $@
	$(DOS2UNIX) $@

memory_sizer_test.vhd :                      		\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		$(TOP_SRC_DIR)/memory_sizer.vhd		\
		memory_sizer_test.m4
	$(M4) $(M4_DIVERT) memory_sizer.m4	\
		$(M4_UNDIVERT) memory_sizer_test.m4 > $@
	$(DOS2UNIX) $@

memory_sizer_endian_test.vhd :                 		\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		$(TOP_SRC_DIR)/memory_sizer.vhd		\
		memory_sizer_endian_test.m4
	$(M4) $(M4_DIVERT) memory_sizer.m4	\
		$(M4_UNDIVERT) memory_sizer_endian_test.m4 > $@
	$(DOS2UNIX) $@

dma_controller_test.vhd :				\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_sizer.vhd		\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		dma_controller.vhd				\
		dma_controller_test.m4
	$(M4) $(M4_DIVERT) dma_controller.m4 $(M4_UNDIVERT)	\
		dma_controller_test.m4 > $@
	$(DOS2UNIX) $@

memory_controller_test.vhd :				\
		$(M4_INCLUDES)				\
		$(TOP_SRC_DIR)/seqlib.vhd		\
		$(TOP_SRC_DIR)/memory_controller.vhd	\
		memory_controller_test.m4
	$(M4) $(M4_DIVERT) memory_controller.m4 $(M4_UNDIVERT)	\
		memory_controller_test.m4 > $@
	$(DOS2UNIX) $@

async_fifo_fast.sim.fun: 			async_fifo_fast.vwf \
					async_fifo.map.simgen
	$(SIMFUN) --vector_source=$< async_fifo
	echo "blah" > $@

timer_test_zeros.sim.fun: 		timer_test_zeros.vwf \
					timer_test.map.simgen
	$(SIMFUN) --vector_source=$< timer_test
	echo "blah" > $@

timer_test_large.sim.fun: 		timer_test_large.vwf \
					timer_test.map.simgen
	$(SIMFUN) --vector_source=$< timer_test
	echo "blah" > $@

timer_test_middle.sim.fun: 		timer_test_middle.vwf \
					timer_test.map.simgen
	$(SIMFUN) --vector_source=$< timer_test
	echo "blah" > $@

timer_test_small.sim.fun: 		timer_test_small.vwf \
					timer_test.map.simgen
	$(SIMFUN) --vector_source=$< timer_test
	echo "blah" > $@

memory_controller_test_oneshot.sim.fun: memory_controller_test_oneshot.vwf \
					memory_controller_test.map.simgen
	$(SIMFUN) --vector_source=$< memory_controller_test
	echo "blah" > $@
