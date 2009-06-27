from test_config import *
from math import *
import profile
import pstats
import time
import string

parse_params(('dummy', 'int'))
#sequencer.params.debug=4
print("Dummy option = " + str(sequencer.params.dummy))
x1=time.time()
CHECK_DUPLICATE=0
n=1000
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



begin_sequence()
amplitude=16000
begin_infinite_loop()
ttl_signal_a(0x1)
ttl_signal_a(0x0)
#wait(10)
#label_event1=create_label("label_name1")
for x in range(0,n):
    first_dac_value(int(pow(sin(x/float(n)*pi/2),2)*amplitude))
#    wait(step_duration/n)

#first_dac_value(0)
wait(500,'test')
first_dac_value(1000,"test1")
for x in range(0,n):
    first_dac_value(int(pow(sin(x/float(n)*pi/2+pi/2),2)*amplitude))
#    wait(step_duration/n)
#wait(pause)
end_infinite_loop()

#end_sequence()
charlist=end_sequence1()
z=time.time()
print("gesamtzeit: " + str(z-x1))
input_str=1
a=sequencer.current_sequence.variable_char_address['test']
a1=sequencer.current_sequence.variable_char_address['test1']
while (input_str!='0'):
    input_str=raw_input('delay: ')
    duration=int(input_str)
    input_str=raw_input('amplitude: ')
    level=int(input_str)
    z=time.time()
#    duration=500
    sequence1=PulseSequence()
    sequence1.add_event(Wait_Event(duration,'test'))
    print ("character address: " + str(a))
    sequencer.current_sequence.variable_word['test']
    pulse_program =  test_config.first_sequencer.translate_sequence(sequence1)
    variable_charlist=pulse_program.get_binary_charlist()
    print variable_charlist[4:16]
    print "original charlist: "  
    print (charlist[a:a+12])
    print "\n\n\n"
    working_charlist=charlist
    working_charlist[a:a+12]=variable_charlist[4:12]

   
    sequence2=PulseSequence()
#    level=0
    sequence2.add_event_list(test_config.first_dac_device.create_level_events(level = level,variable_name = 'test1'))
    sequencer.current_sequence.variable_word['test1']
    pulse_program =  test_config.first_sequencer.translate_sequence(sequence2)
    variable_charlist2=pulse_program.get_binary_charlist()
    print variable_charlist2[4:16]
    print "\n"
    print charlist[a1+20:a1+32]
    working_charlist[a1+20:a1+32]=variable_charlist2[4:16]

    end_sequence2(working_charlist)
    y=time.time()
    print("Sendezeit: "   + str(y-z))

teardown()
