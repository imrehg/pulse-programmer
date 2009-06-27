from test_config import *

setup()
for i in range(1000):
  print("Iteration " + str(i))
  broadcast_status()
teardown()
