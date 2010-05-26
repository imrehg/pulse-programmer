from test_config import *

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

setup()

reply = broadcast_status()
print(str(reply))

teardown()


