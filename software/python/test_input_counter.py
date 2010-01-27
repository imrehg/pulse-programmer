from test_config import *

parse_params(('dummy', 'int'))

begin_sequence(reset_dds=False)

reset_input_counter(Input_1_Trigger)
latch_input_counter(Input_3_Trigger)
write_input_counter(Input_4_Trigger)
compare_input_counter(Input_5_Trigger)

label1 = create_and_insert_label("test_label1")
label2 = create_label("test_label2")
branch_input(label2)
jump_label(label1)
insert_label(label2)

end_sequence()

