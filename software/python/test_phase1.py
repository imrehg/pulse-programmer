from test_config import *
from math import *
import time 
import sys
import random

parse_params()

#sequencer.params.debug=1
sequencer.params.nonet=1

#param=int(sys.argv[1])
param=50.0

begin_time=time.time()
dds_profile=0

begin_sequence()
ttl_signal_a(0x0)
#freq1=random.random()*250+1
freq1=190
#freq1=80.0
param=1
#phase1=1.1
#delta_t=98.06e-9
delta_t=0e-9

phase1=delta_t*freq1*1e6*2*pi

phase1=2*pi-phase1%2*pi #int(phase1/pi)
print phase1


wait(100)
first_dds_freq(freq1,dds_profile) # 500 MHz
second_dds_freq(freq1,dds_profile) # 500 MHz
first_dds_profile(dds_profile)
#first_dds_phase(0,dds_profile)
frequency=coherent_create_freq(freq1,phase1)
frequency2=coherent_create_freq(freq1,phase1)

#first_dds_init_frequency(frequency)
#first_dds_init_frequency(frequency2)
#second_dds_unset_autoclr()

#----------------start infinite loop------------------------
begin_infinite_loop()
ttl_signal_a(0x3)
ttl_signal_a(0x3)
ttl_signal_a(0x0)

second_dds_set_autoclr()
second_dds_phase(0,dds_profile)
first_dds_phase(0,dds_profile)
first_dds_profile(dds_profile)
first_dds_init_frequency(frequency)
first_dds_init_frequency(frequency2)
second_dds_unset_autoclr()

wait(100)
for i in range (0,4):
#    wait(int(random.random()*3000))

    wait(200)
 #   first_dds_freq(freq1,dds_profile)
    first_dds_switch_frequency(frequency)
    update_all_dds()

#first_dds_unset_autoclr()
wait(30)
phase=0.0

wait(3000)

first_dds_unset_autoclr()

second_dds_phase(pi/1000,dds_profile)
second_dds_profile(dds_profile)


wait(3000)
first_dds_set_autoclr()
wait(10)
#wait(10)
#wait(10)
end_infinite_loop()

end_sequence()

end_time=time.time()
print("used time: " + str(end_time-begin_time))
