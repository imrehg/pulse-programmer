from test_config import *

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

setup()

test_config.first_sequencer.stop_processor()

# Reads 128 bytes from the memory written to by icnt write
# NOTE: There appears to be a bug where reading from 0x100000 actually reads from 0x0
payload = read_imem(0x40000 - 0x4, 36)
i = 0x40000-0x4
i -= 1

for byte in payload:
    print('addr: '+hex(i)+'['+hex(byte)+']')
    i += 1 


teardown()

