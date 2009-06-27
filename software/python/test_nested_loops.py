from test_config import *
import time

parse_params(('dummy', 'int'))

begin_sequence()

begin_finite_loop()
begin_finite_loop()
ttl_signal_a(0x2)
ttl_signal_a(0x0)
end_finite_loop(2)
end_finite_loop(2)

end_sequence()

teardown()
