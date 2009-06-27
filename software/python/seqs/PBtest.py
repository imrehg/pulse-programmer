import random

frequency=self.set_variable("float","frequency",0,400)

freq1=coherent_create_freq(frequency,0)
wait(10)

first_dds_freq(frequency,0)
second_dds_freq(frequency,0)
second_dds_unset_autoclr()
update_all_dds()

first_dds_init_frequency(freq1)

start_parallel_env()
add_to_parallel_env("866 sw",0,10)
add_to_parallel_env("397 sw",2,5)
end_parallel_env()

get_shaped_pulse(type="blackman",slope_duration=1.1,duration=10,amplitude=.234,frequency=freq1,phase=0)
get_square_pulse(duration=10,frequency=freq1,amplitude=1)


for i in range (0,5):
    get_shaped_pulse(type="blackman",slope_duration=1.32344+float(i)/10.0,amplitude=0.5,duration=10+i,frequency=freq1,phase=0)


