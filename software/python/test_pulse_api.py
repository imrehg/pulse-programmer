from innsbruck import *
from math import *
import time


parse_params(('dummy', 'int'))

#print("Dummy option = " + str(sequencer.params.dummy))
#sequencer.params.nonet=1

my_program=MainProgram()
duration=1000
steps=100
slope_duration=1
amplitude=1
sub_name="sub1"
sub_name2="sub2"

my_program.add_pulse(sine_pulse(slope_duration))
my_program.add_pulse(blackman_pulse(slope_duration))
my_program.start_server()


