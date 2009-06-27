from test_config import *
import pdb

parse_params(('dummy', 'int'))
#pdb.set_trace()
import pprint

pp = pprint.PrettyPrinter(indent=4)

print("Dummy option = " + str(sequencer.params.dummy))

begin_sequence()
label_event1 = create_label("label_name1")
ttl_signal_a(0x1)

ttl_signal_a(0x0)

jump_label(label_event1)

label_event2 = create_and_insert_label("label_name2")

insert_label(label_event1)

jump_label(label_event2)

end_sequence()

pp.pprint(sequencer.current_sequence)
