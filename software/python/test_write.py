from test_config import *

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

setup()
payload = write_imem(0x20, "\x11\x22\x33\x44\x55\x66\x77\x88")
teardown()

