from innsbruck import *
from math import *
import time

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))

start_time=time.time()
#sequencer.params.nonet=1
begin_sequence(reset_dds=False)

begin_subroutine("dac2")
#innsbruck.dds_factory.current_device=None
#print innsbruck.dac_factory.current_device
first_dac_value(1000)
#print innsbruck.dac_factory.current_device
end_subroutine()

begin_subroutine("dac1")
#print innsbruck.dac_factory.current_device
dac_setup()
first_dac_value(8000)
end_subroutine()

#second_dac_value(1000)

first_dac_value(1000)

begin_infinite_loop()
first_dac_value(1000)
second_dac_value(1000)
ttl_signal_a(0x0)
ttl_signal_a(0x1)
ttl_signal_a(0x0)
ttl_signal_a(0x1)

call_subroutine("dac1")
wait(100)
first_dac_value(15000)
wait(100)
#ttl_signal_a(0x0)
#wait(100)
#ttl_signal_a(0x1)
#wait(100)
end_infinite_loop()
end_sequence()
end_time=time.time()
print "used time: "+str(end_time-start_time)
