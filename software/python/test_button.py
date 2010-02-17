# Tests the icnt write instruction
# With a variety of triggers and latches

from test_config import *

parse_params(('dummy', 'int'))

begin_sequence(reset_dds=False)

reset_input_counter(Input_0_Trigger)

label1 = create_label("button_label1")

branch_wait(label1, [Switch_Trigger])

insert_label(label1)

latch_input_counter(Input_0_Trigger)
write_input_counter(Input_0_Trigger)


end_sequence()



