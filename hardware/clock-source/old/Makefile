BOARD = clock-source-top
REV = A
TARGETS = $(BOARD).sch

# Dummy targets to remake dependencies
SCHEM_FILES = \
		clock-divider-jumpers.sch \
		clock-divider-port0.sch \
		clock-divider-port10.sch \
        clock-source.sch \
        clock-source-page2.sch \


LAYER_COLORS = \
	--layer-color-1 "\#8b2323" \
	--layer-color-2 "\#3a5fcd" \
	--layer-color-3 "\#ff0000" \
	--layer-color-4 "\#404040" \
	--layer-color-5 "\#408040" \

# This is a high-speed board
TARGETS_GERBER = $(GERBER_FILES_HS_FRONT)
TARGETS_PS = $(PS_FILES_HS_FRONT)

include ../Makefile.common
