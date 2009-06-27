from mpq import *
import sys
import time

parse_params(('phase', 'float'))

begin_time=time.time()
profile=0

begin_sequence()
ttl_signal_a(0x0)
freq1=1
phase1=(90/360)*2*pi
dds_freq(freq = freq1, profile = profile, device = 1)
dds_freq(freq = freq1, profile = profile, device = 2)
dds_freq(freq = freq1, profile = profile, device = 3)
dds_freq(freq = freq1, profile = profile, device = 4)
dds_phase(phase = phase1, profile = profile, device = 1)

begin_infinite_loop()
dds_profile(profile = profile, device = 1)
wait(100)
wait(10)
wait(10)
ttl_signal_a(0x1)
ttl_signal_a(0x0)
wait(0)

dds_phase=pi
end_infinite_loop()
end_sequence()

end_time=time.time()
print("used time: " + str(end_time-begin_time))
