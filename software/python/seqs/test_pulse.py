sequencer.main_program.got_negative=False
frequency=234
freq1=coherent_create_freq(frequency,0)
first_dds_init_frequency(freq1)

t1=transition(transition_name="1",t_rabi=10,
                 frequency=freq1,amplitude=1,slope_type="blackman",
                 slope_duration=1,amplitude2=-1,frequency2=0)

R729(1,1.65,0,t1)
seq_wait(10)
R729(1,1.65,0,t1)
end_sequential()
