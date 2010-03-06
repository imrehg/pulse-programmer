from test_config import *

parse_params(('dummy','int'))
import sequencer.ptp
sequencer.ptp.setup_socket()
#for i in range(100):
#  print("Iteration " + str(i))
sequencer.ptp.discover_devices()
sequencer.ptp.teardown_socket()
