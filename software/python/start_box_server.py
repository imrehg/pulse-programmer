from innsbruck import *
from math import *
import time


parse_params(('dummy', 'int'))

# A simple program to reset the processor
begin_sequence(reset_dds=True)
first_dac_value(0)
first_dac_value(0)
first_dac_value(0)
first_dac_value(0)
end_sequence()
#Create the main program
my_program=MainProgram()
#Add some shapes
slope_duration=1

my_program.add_pulse(blackman_pulse(slope_duration*5.0,dac_device=2,amplitude=-5))
my_program.add_pulse(blackman_pulse(slope_duration,amplitude=-1))
my_program.start_server()


