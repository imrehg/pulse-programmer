BOARD = island-memory
REV = 0
TARGETS = $(BOARD).sch

# Dummy targets to remake dependencies
island-memory.tgt: \
	island-memory-sram.tgt \

LAYER_COLORS = \
	--layer-color-1 "\#8b2323" \
	--layer-color-2 "\#3a5fcd" \
	--layer-color-3 "\#404040" \
	--layer-color-4 "\#0000ff" \
	--layer-color-5 "\#8000ff" \
	--layer-color-6 "\#408040" \

# This is a high-speed board
TARGETS_GERBER = $(GERBER_FILES_HS)
TARGETS_PS = $(PS_FILES_HS)

include ../Makefile.common
