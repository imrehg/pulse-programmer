from test_config import *

parse_params(('dummy', 'int'))

begin_sequence()

# This is the beginning of an infinite loop
label_event2 = create_and_insert_label("label_name2")

ttl_signal_a(0x1)

ttl_signal_a(0x0)

# Create the label here, but don't insert it yet
label_event1 = create_label("label_name1")

# Branch forward and break out of loop if we get a trigger (high) on input 0
branch(label_event1, [Input_7_Trigger, Input_6_Trigger, Input_5_Trigger,
                      Input_4_Trigger, Input_3_Trigger, Input_2_Trigger,
                      Input_1_Trigger, Input_0_Trigger])

# Otherwise, continue looping
jump_label(label_event2)

# This is where we jump to break out of loop.
# TTL signals will stop toggling here so you can measure on scope.
insert_label(label_event1)

end_sequence()

