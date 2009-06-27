from test_config import *
from math import *
import time

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))
sequencer.params.debug=0

amplitude=[8000,4000,6000,8000]
freq=[189.9999999,190.0,189.9999,189.9999,189.9999,189.9999]
coh_freq=[]
phase1=0
profile=0
for i in freq:
    coh_freq.append(coherent_create_freq(i,phase1))
#freq=[1,1,1,1]
pause=[9000,400,600,800]
phase=[0,0,0,0]

n=100

begin_time=time.time()
begin_sequence()

nr_ramps=3

ramp_up=["ramp1_up","ramp2_up","ramp3_up","ramp4_up"]
ramp_down=["ramp1_down","ramp2_down","ramp3_down","ramp4_down"]

for i2 in range (0,nr_ramps):
    ramp_nr=i2
    begin_subroutine(ramp_up[ramp_nr])
    wait(10)
    ttl_signal_a(0x2)
    ttl_signal_a(0x0)
    for x in range(0,n):
        first_dac_value(int(pow(sin(x/float(n)*pi/2),2)*amplitude[ramp_nr])+8000)
        second_dac_value(int(pow(sin(x/float(n)*pi/2+pi/2),2)*amplitude[ramp_nr])+8000)
        wait(3)
    end_subroutine()
    
    begin_subroutine(ramp_down[ramp_nr])
    wait(10)
    ttl_signal_a(0x2)
    ttl_signal_a(0x0)
    for x in range(0,n):
        first_dac_value(int(pow(sin(x/float(n)*pi/2+pi/2),2)*amplitude[ramp_nr])+8000)
        second_dac_value(int(pow(sin(x/float(n)*pi/2),2)*amplitude[ramp_nr])+8000)
        wait(3)
    end_subroutine()

ttl_signal_a(0x1)
ttl_signal_a(0x0)

#first_dds_profile(0)

second_dds_freq(1.34,profile)
first_dds_profile(profile)
second_dds_unset_autoclr()

begin_infinite_loop()
wait(10)
wait(10)
ttl_signal_a(0x1)
wait(10)
ttl_signal_a(0x0)
#first_dac_value(0)


#first_dds_profile(profile)
for init_freq in coh_freq:
    first_dds_init_frequency(init_freq)
first_dds_freq(freq[0],profile)
for i1 in range (0,20):
    for i2 in range (0,nr_ramps):
        first_dds_freq(freq[i2],profile)
        first_dds_switch_frequency(coh_freq[i2])
        first_dds_profile(profile)
        call_subroutine(ramp_up[i2])
        wait(pause[i2])
        call_subroutine(ramp_down[i2])
        ttl_signal_a(0x2)


wait(20000)
end_infinite_loop()

end_sequence()

end_time1=time.time()


begin_sequence(reuse_subs = True)

second_dds_freq(freq[1],profile)
first_dds_profile(profile)
second_dds_unset_autoclr()


begin_infinite_loop()
ttl_signal_a(0x1)
ttl_signal_a(0x0)
second_dds_freq(freq[1],profile)
for i1 in range (0,10):
    for i2 in range (0,nr_ramps):
        first_dds_freq(freq[i2+1],profile)
        first_dds_switch_frequency(coh_freq[i2+1])
        first_dds_profile(profile)
        call_subroutine(ramp_up[i2])
        wait(pause[i2])
        call_subroutine(ramp_down[i2])
        ttl_signal_a(0x2)

end_infinite_loop()
end_sequence()
end_time2=time.time()
print("nested time: "+ str(end_time2-end_time1))
print "compilation time: " + str(end_time1-begin_time)            

