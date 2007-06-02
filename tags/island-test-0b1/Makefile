BOARD = island-test
REV = 0b1
TARGETS = $(BOARD).sch

# Dummy targets to remake dependencies
island-test.tgt: \
	island-test-top.tgt \
	island-test-bottom.tgt \

LAYER_COLORS = \
	--layer-color-1 "\#8b2323" \
	--layer-color-2 "\#3a5fcd" \
	--layer-color-3 "\#408040" \

# This is a high-speed board
TARGETS_GERBER = $(GERBER_FILES)
TARGETS_PS = $(PS_FILES)

include ../Makefile.common
