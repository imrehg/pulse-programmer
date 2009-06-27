from innsbruck import *
from math import *
import time
import sys

parse_params(('param', 'int'))

param = sequencer.params.param

begin_sequence(reset_dds=True)
freq1=3
phase1=0
dds_profile=0
dds_freq(freq1, dds_profile, 1)
#dds_freq(freq1, dds_profile, 2)
update_all_dds()
frequency=coherent_create_freq(freq1,phase1)

first_dds_init_frequency(frequency)
dds_freq(freq1, dds_profile, 1)
first_dac_value(16000)
second_dac_value(16000)
second_dds_unset_autoclr()
#egin_finite_loop()
begin_infinite_loop()

#first_dds_switch_frequency(frequency)
#update_all_dds()
#frequency.relative_phase=pi
#set_channel("1",1)
#wait(100)
start_freq=freq1
delta_freq=1
rate_word=100


#dds_start_sweep(start_freq,delta_freq,dds_profile,1,rate_word)

#dds_freq(freq1,0,2)

#update_all_dds()

ttl_signal_a(0x1)
ttl_signal_a(0x0)
ttl_signal_a(0x2)
ttl_signal_a(0x0)
first_dds_switch_frequency(frequency)
update_all_dds()
wait(1000)
dds_freq(0,0,1)
update_all_dds()
wait(2000)
dds_freq(freq1,0,1)
first_dds_switch_frequency(frequency)
update_all_dds()
wait(1000)
dds_freq(0,0,1)
update_all_dds()
wait(1000)
#update_all_dds()
n=100
max_ampl=10000
#for i in range(0,n):
#    x=float(i)/n
#    f=1.0/2.0*(0.84-cos(x*pi)+0.16*cos(2*x*pi))
#    value=int(f*max_ampl)
#    first_dac_value(value)
#for i in range(0,n):
#    x=float(i)/n
#    f=1.0/2.0*(0.84-cos((x+1)*pi)+0.16*cos(2*(x+1)*pi))
#    value=int(f*max_ampl)
#    first_dac_value(value)
delta_freq=0
#rate_word=0
#dds_start_sweep(start_freq,delta_freq,dds_profile,1,rate_word)
#update_all_dds()
#dds_stop_sweep(1,0)
#update_all_dds()
#update_all_dds()
#wait(1000)
#end_finite_loop(2)
end_infinite_loop()

end_sequence()
