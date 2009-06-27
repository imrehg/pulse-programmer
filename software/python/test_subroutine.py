from test_config import *
from math import *
import time

parse_params(('dummy', 'int'))

print("Dummy option = " + str(sequencer.params.dummy))
sequencer.params.debug=0

amplitude=[2000,4000,6000,8000]
freq=[3.0,4.0,3.0,2.0,1.0]
#freq=[1,1,1,1]
pause=[200,400,600,800]
phase=[0,0,0,0]

n=100

begin_time=time.time()
begin_sequence()

nr_ramps=4

ramp_up=["ramp1_up","ramp2_up","ramp3_up","ramp4_up"]
ramp_down=["ramp1_down","ramp2_down","ramp3_down","ramp4_down"]

for i2 in range (0,nr_ramps):
    ramp_nr=i2
    print "Amplitude: "+str(amplitude[ramp_nr])
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


begin_infinite_loop()
wait(10)
wait(10)
ttl_signal_a(0x1)
wait(10)
ttl_signal_a(0x0)
#first_dac_value(0)
profile=0

#first_dds_profile(profile)

first_dds_freq(freq[0],profile)
for i1 in range (0,20):
    for i2 in range (0,nr_ramps):
        first_dds_profile(profile)
        first_dds_profile(profile)
        call_subroutine(ramp_up[i2])
        first_dds_freq(freq[i2+1],profile)
        second_dds_freq(freq[i2+1]/2,profile)
        first_dds_phase(phase[i2],profile)
        wait(pause[i2])
        call_subroutine(ramp_down[i2])
        ttl_signal_a(0x2)
        
end_infinite_loop()

end_sequence()

end_time1=time.time()


begin_sequence(reuse_subs = True)
begin_infinite_loop()
ttl_signal_a(0x1)
ttl_signal_a(0x0)
ttl_signal_a(0x1)

for i1 in range (0,10):
    for i2 in range (0,nr_ramps):
        first_dds_profile(profile)
        call_subroutine(ramp_up[i2])
        first_dds_freq(freq[i2+1],profile)
        second_dds_freq(freq[i2+1]/2,profile)
        first_dds_phase(phase[i2],profile)
        wait(pause[i2])
        call_subroutine(ramp_down[i2])
        ttl_signal_a(0x1)
        ttl_signal_a(0x0)

end_infinite_loop()
end_sequence()
end_time2=time.time()
print("nested time: "+ str(end_time2-end_time1))
print "compilation time: " + str(end_time1-begin_time)            

