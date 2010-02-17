# Tests the icnt write instruction
# With a variety of triggers and latches

from test_config import *

parse_params(('dummy', 'int'))

begin_sequence(reset_dds=False)

reset_input_counter(Input_1_Trigger)
reset_input_counter(Input_2_Trigger)
reset_input_counter(Input_3_Trigger)


for i in range(256):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0x2)
  wait(100)

# Should write approx:
# 0x00 00 01 00
# 0x00 00 00 00
# 0x00 00 00 00
latch_input_counter(Input_1_Trigger)
write_input_counter(Input_1_Trigger)
latch_input_counter(Input_2_Trigger)
write_input_counter(Input_2_Trigger)
latch_input_counter(Input_3_Trigger)
write_input_counter(Input_3_Trigger)

for i in range(256):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0x6)
  wait(100)

# Should write approx:
# 0x00 00 02 00
# 0x00 00 01 00
# 0x00 00 00 00
latch_input_counter(Input_1_Trigger)
write_input_counter(Input_1_Trigger)
latch_input_counter(Input_2_Trigger)
write_input_counter(Input_2_Trigger)
latch_input_counter(Input_3_Trigger)
write_input_counter(Input_3_Trigger)

for i in range(256):
  ttl_signal_loopback(0x0)
  wait(100)
  ttl_signal_loopback(0xC)
  wait(100)
 

# Should write approx:
# 0x00 00 02 00
# 0x00 00 01 00
# 0x00 00 01 00
latch_input_counter(Input_1_Trigger)
write_input_counter(Input_1_Trigger)
# No latch on trigger 2
write_input_counter(Input_2_Trigger)
latch_input_counter(Input_3_Trigger)
write_input_counter(Input_3_Trigger)

end_sequence()



