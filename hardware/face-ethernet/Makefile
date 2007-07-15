BOARD = face-ethernet
REV = 0
TARGETS = $(BOARD).sch

# Dummy targets to remake dependencies
face-ethernet.tgt: \
	face-ethernet-phy.tgt \

LAYER_COLORS = \
	--layer-color-1 "\#8b2323" \
	--layer-color-2 "\#3a5fcd" \
	--layer-color-3 "\#404040" \
	--layer-color-4 "\#ff0000" \
	--layer-color-5 "\#000088" \
	--layer-color-6 "\#0000cc" \
	--layer-color-7 "\#408040" \

# This is a high-speed board
TARGETS_GERBER = $(GERBER_FILES_HS)
TARGETS_PS = $(PS_FILES_HS)

include ../Makefile.common
