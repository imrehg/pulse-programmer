# __init__ module for ptp package
# Global package definitions for handling Pulse Transfer Protocol operations
# using UDP.

###############################################################################
# Module global constants
HOST_ID            = 0x00
CHAIN_INITIATOR_ID = 0x02 # The ID of the first device in the chain.
PTP_BROADCAST_ID   = 0xFF # The pseudo-ID for all devices on chain

DEBUG_LED_SUBOPCODE = 0x01
DEBUG_MAC_SUBOPCODE = 0x02

###############################################################################
# Module global constants
CLIENT_PORT         = 8735 # 0x221F
RETRY_TIMEOUT       = 0.1  # In seconds
MIN_FRAME_SIZE      = 6    # Minimum static payload of all opcodes.
