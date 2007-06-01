BOARD = island-fpga
REV = 0
TARGETS = $(BOARD).sch

# Dummy targets to remake dependencies
island-fpga.tgt: \
	island-fpga-north.tgt \
	island-fpga-south.tgt \
	island-fpga-east.tgt \
	island-fpga-west.tgt \
	island-fpga-power.tgt \

LAYER_COLORS = \
	--layer-color-1 "\#8b2323" \
	--layer-color-2 "\#3a5fcd" \
	--layer-color-3 "\#ff0000" \
	--layer-color-4 "\#0000ff" \
	--layer-color-5 "\#8000ff" \
	--layer-color-6 "\#404040" \
	--layer-color-7 "\#808080" \
	--layer-color-8 "\#408040" \
	--layer-color-9 "\#ff8000" \

# This is a high-speed board
TARGETS_GERBER = $(GERBER_FILES_HS)
TARGETS_PS = $(PS_FILES_HS)

include ../Makefile.common
