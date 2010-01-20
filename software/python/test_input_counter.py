from test_config import *

parse_params(('dummy', 'int'))

begin_sequence(reset_dds=False)

reset_input_counter(Input_1_Trigger)
latch_input_counter(Input_3_Trigger)
write_input_counter(Input_4_Trigger, 0xbeef)
compare_input_counter(Input_5_Trigger)

end_sequence()

