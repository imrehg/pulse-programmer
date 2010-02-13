# Tests the icnt write instruction
# With a variety of triggers and latches

from test_config import *

parse_params(('dummy', 'int'))

begin_sequence(reset_dds=False)

reset_input_counter(Input_0_Trigger)
reset_input_counter(Input_1_Trigger)
reset_input_counter(Input_2_Trigger)


for i in range(128):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0x1)
  wait(100)

# Should write approx:
# 0x00 00 00 10
# 0x00 00 00 00
# 0x00 00 00 00
latch_input_counter(Input_0_Trigger)
write_input_counter(Input_0_Trigger)
latch_input_counter(Input_1_Trigger)
write_input_counter(Input_1_Trigger)
latch_input_counter(Input_2_Trigger)
write_input_counter(Input_2_Trigger)

for i in range(128):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0x3)
  wait(100)

# Should write approx:
# 0x00 00 00 20
# 0x00 00 00 10
# 0x00 00 00 00
latch_input_counter(Input_0_Trigger)
write_input_counter(Input_0_Trigger)
latch_input_counter(Input_1_Trigger)
write_input_counter(Input_1_Trigger)
latch_input_counter(Input_2_Trigger)
write_input_counter(Input_2_Trigger)

for i in range(128):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0x6)
  wait(100)
 

# Should write approx:
# 0x00 00 00 20
# 0x00 00 00 10
# 0x00 00 00 10

latch_input_counter(Input_0_Trigger)
write_input_counter(Input_0_Trigger)
# No latch on trigger 1
write_input_counter(Input_1_Trigger)
latch_input_counter(Input_2_Trigger)
write_input_counter(Input_2_Trigger)

end_sequence()



