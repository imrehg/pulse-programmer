#channel=self.set_variable("FLOAT","duration",0,1e7)
#value=self.set_variable("BOOL","value")
wait(10)
#ttl_set_channel(channel,value)


start_time=0
duration=10
slope_type="blackman"
slope_duration=1.0
amplitude=1.0

frequency=self.set_variable("float","frequency",0,400)
freq1=coherent_create_freq(frequency,0)
freq2=coherent_create_freq(frequency/2,0)

first_dds_init_frequency(freq1)
first_dds_init_frequency(freq2)

#    start_time+=32
#    shape_add_to_super_parallel_env(start_time,duration,freq2,slope_type,slope_duration,amplitude)

start_time=44
#shape_add_to_super_parallel_env(start_time,duration,freq1,slope_type,slope_duration,amplitude)
#ttl_add_to_super_parallel_env("854 sw",62,5)

end_parallel_env()
