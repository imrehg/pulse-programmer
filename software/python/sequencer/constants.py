# Module: constants.py
# Package: sequencer
# Hardware constants.

# Module global constants
HARDWARE_OUTPUT_WIDTH       = 64 # Hardware parameter of pulse sequencer
AD9858_PHASE_DATA_WIDTH     = 32 # Hardware parameter of AD9858
AD9858_PHASE_ADJUST_WIDTH   = 14 # Hardware parameter of AD9858
DEFAULT_STARTING_ADDRESS    = 0x00000
SEQUENCER_I2C_SLAVE_ADDRESS = 0x60
BREAKOUT_I2C_SLAVE_ADDRESS  = 0x61

from sequencer.pcp.events import FeedbackSource

# Create feedback/trigger objects and a function to translate them into
# bitmasks
###############################################################################
# Creates all feedback sources
# These may or may not be supported by all machines.
# Tuples of these feedback sources are translated into bitmasks in
# pcp.machines
Start_Trigger   = FeedbackSource("PTP Start Trigger", 9)
Switch_Trigger  = FeedbackSource("Manual Switch Trigger", 8)
Input_0_Trigger = FeedbackSource("Input Channel 0 Trigger", 0)
Input_1_Trigger = FeedbackSource("Input Channel 1 Trigger", 1)
Input_2_Trigger = FeedbackSource("Input Channel 2 Trigger", 2)
Input_3_Trigger = FeedbackSource("Input Channel 3 Trigger", 3)
Input_4_Trigger = FeedbackSource("Input Channel 4 Trigger", 4)
Input_5_Trigger = FeedbackSource("Input Channel 5 Trigger", 5)
Input_6_Trigger = FeedbackSource("Input Channel 6 Trigger", 6)
Input_7_Trigger = FeedbackSource("Input Channel 7 Trigger", 7)
