from test_config import *

parse_params(('dummy', 'int'))

#begin_sequence()
#ttl_signal_a(0x1)
#ttl_signal_a(0x1)
#ttl_signal_a(0x1)
#ttl_signal_a(0x1)
#ttl_signal_a(0x1)
#ttl_signal_a(0x1)

#end_sequence()

begin_sequence()
begin_infinite_loop()
for i in range(108):
  ttl_signal_a(0x0)
  wait(100)
  ttl_signal_a(0x1)

wait(200)

#ttl_signal_a(0x2)
end_infinite_loop()
end_sequence()

