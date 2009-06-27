#channel=self.set_variable("FLOAT","duration",0,1e7)
#value=self.set_variable("BOOL","value")
wait(10)
#ttl_set_channel(channel,value)

frequency=self.set_variable("float","frequency",0,400)
freq1=coherent_create_freq(frequency,0)
first_dds_init_frequency(freq1)

first_dac_value(14000)
first_dac_value(0)

second_dac_value(14000)
second_dac_value(0)

#first_dac_value(14000)
#first_dac_value(0)

start_super_parallel_env()
ttl_add_to_super_parallel_env("854 sw",0,10)
ttl_add_to_super_parallel_env("866 sw",2,5)
start_time=9.7
duration=10
slope_type="blackman"
slope_duration=1.0
amplitude=1.0
shape_add_to_super_parallel_env(start_time,duration,freq1,slope_type,slope_duration,amplitude)
end_super_parallel_env()
