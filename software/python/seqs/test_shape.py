import random
frequency=self.set_variable("float","frequency",0,400)

freq1=coherent_create_freq(frequency,0)
freq2=coherent_create_freq(frequency/10,0)
freq3=coherent_create_freq(frequency*10,0)

wait(10)
first_dds_freq(frequency,0)
second_dds_freq(frequency,0)
second_dds_unset_autoclr()
update_all_dds()

first_dds_init_frequency(freq1)
first_dds_init_frequency(freq2)

start_parallel_env()
ttl_add_to_parallel_env("1",0,10)
ttl_add_to_parallel_env("2",2,5)

#shape_add_to_parallel_env(start_time=11,duration=10,frequency=freq1,phase=0.000,slope_type="blackman",slope_duration=0,amplitude=1)

shape_add_to_parallel_env(start_time=20,duration=10,frequency=freq2,phase=0.000,slope_type="blackman",slope_duration=1,amplitude=1,frequency2=freq3,amplitude2=1) 


shape_add_to_parallel_env(start_time=45,duration=10,frequency=freq1,phase=0.000,slope_type="blackman",slope_duration=1,amplitude=1)

end_parallel_env()
#get_shaped_pulse(type="blackman",slope_duration=1,duration=10,amplitude=1,frequency=freq1,phase=0)
#get_square_pulse(duration=10,frequency=freq1,amplitude=1)


#for i in range (0,5):
#    get_shaped_pulse(type="blackman",slope_duration=1.32344+float(i)/10.0,amplitude=0.5,duration=10+i,frequency=freq1,phase=0)


