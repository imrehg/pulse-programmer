BOARD = island-fpga
REV = Ab1
TARGETS = $(BOARD).sch

SCHEM_FILES = \
	island-fpga-north.sch \
	island-fpga-south.sch \
	island-fpga-east.sch \
	island-fpga-west.sch \
	island-fpga-power.sch \

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
