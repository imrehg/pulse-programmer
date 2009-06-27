from test_config import *

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

setup()

test_config.first_sequencer.stop_processor()

teardown()


