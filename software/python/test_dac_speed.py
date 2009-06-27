from test_config import *
from math import *
import profile
import pstats
import time
import string

parse_params(('dummy', 'int'))
sequencer.params.debug=0
print("Dummy option = " + str(sequencer.params.dummy))
amplitude=16000
x1=time.time()
CHECK_DUPLICATE=0
n=100
step_time=1/(100e6)
duration=10e-6
delay=3e-6
step_delay=60e-9
edge_duration=1e-6
step_duration=int((edge_duration-step_delay*n)/step_time)
pause=int((duration-2*edge_duration-delay)/step_time)

step_duration=150
print ("pause step: "+str(step_duration))
print ("pause:" + str(pause))

sequence2=PulseSequence()
for x in range(0,n):
    level=int(pow(sin(x/float(n)*pi/2+pi/2),2)*amplitude)
    #level=10
    sequence2.add_event_list(test_config.first_dac_device.create_level_events(level = level))
    sequence2.add_event(Wait_Event(0))
pulse_program2=test_config.first_sequencer.translate_sequence(sequence2)
charlist3=pulse_program2.get_binary_charlist()

sequence1=PulseSequence()
for x in range(0,n):
    level=int(pow(sin(x/float(n)*pi/2),2)*amplitude)
    #level=10
    sequence1.add_event_list(test_config.first_dac_device.create_level_events(level = level))
    sequence1.add_event(Wait_Event(0))
pulse_program=test_config.first_sequencer.translate_sequence(sequence1)
charlist2=pulse_program.get_binary_charlist()



zz=time.time()

begin_sequence()
amplitude=16000
#begin_infinite_loop()

label_event1=create_label("label_name1")
ttl_signal_a(0x1)
ttl_signal_a(0x0)

for i in range (0,10):
    generate_pulse_ramp(charlist2)
    for j in range (0,5):
        ttl_signal_a(0x2)
        ttl_signal_a(0x0)
    wait(100*i,'test')
    generate_pulse_ramp(charlist3)
    wait(500)    

for j in range (0,30):
    ttl_signal_a(0x2)
    wait(500)
    ttl_signal_a(0x0)
    wait(500)
jumpto(label_event1)
wait(5000)
#end_infinite_loop()

end_sequence()
z=time.time()
print("complete time: " + str(z-x1))
print("core time: " + str(z-zz))
