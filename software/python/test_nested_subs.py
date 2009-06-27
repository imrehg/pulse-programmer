from test_config import *
from math import *
import time

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))
#sequencer.params.debug=1

amplitude=5000
n=100
pause=100
profile=0
freq1=1.0
freq2=5.0
phase=0

begin_time=time.time()
#setup()
begin_sequence()

begin_subroutine("test_sub2")
wait(10)
ttl_signal_a(0x2)
ttl_signal_a(0x0)
for x in range(0,n):
    first_dac_value(int(pow(sin(x/float(n)*pi/2),2)*amplitude)+8000)
end_subroutine()


begin_subroutine("test_sub")
wait(10)
ttl_signal_a(0x2)
ttl_signal_a(0x0)
for x in range(0,n):
    first_dac_value(int(pow(sin(x/float(n)*pi/2+pi/2),2)*amplitude)+8000)

end_subroutine()

ttl_signal_a(0x1)
ttl_signal_a(0x0)

first_dds_freq(freq1,profile+1)
first_dds_freq(freq2,profile+2)
first_dds_freq(1,1)
first_dds_freq(1,3)
first_dds_profile(0)
first_dds_phase(phase,0)
first_dds_phase(0,2)

begin_infinite_loop()
wait(10)

ttl_signal_a(0x1)
wait(10)
ttl_signal_a(0x0)

for i1 in range (0,30):
#    first_dds_profile(1)
    call_subroutine("test_sub2")
    first_dds_freq(freq1,profile+2)
    first_dds_phase(phase,0)
    wait(100)
    call_subroutine("test_sub")
    wait(100)

end_infinite_loop()

end_sequence()

begin_sequence(reuse_subs = True)

begin_infinite_loop()
call_subroutine("test_sub")
ttl_signal_a(0x1)
ttl_signal_a(0x0)
call_subroutine("test_sub2")
end_infinite_loop()

end_sequence()

teardown()

end_time=time.time()
print("total time: " + str(end_time-begin_time))
