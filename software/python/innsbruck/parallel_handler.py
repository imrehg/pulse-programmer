from api import *
# This circular include is not good at all
from user_function import *
import copy

# The base parallel event class
class parallel_event:

    #Some default values which will be overridden by our sweet childs
    #pre delay: the delay we got before the real action goes on
    # example: A rf pulse has to switch the frequency before the actual pulse starts
    def get_pre_delay(self):
        return 0

    #The inverse o post delay - Take switching off some stuff into account
    def get_post_delay(self):
        return 0

    #returns the delay variable from the __init__,py file
    def get_delay_conf(self):
        return innsbruck.delay

    def get_configuration(self):
        return innsbruck.configuration

    #add the instruction to the instruciotnm list -- distinguishes between parallel and sequential mode !!
    def add_insn(self,instruction,is_last=False):
        if self.is_sequential:
            try:
                current_time=sequencer.main_program.time+instruction.start_time
                instruction.start_time=self.get_rounded_time(current_time)
                sequencer.main_program.sequence_list.append(instruction)
                if current_time > sequencer.main_program.max_time:
                    sequencer.main_program.max_time=current_time
                    sequencer.main_program.max_time_insn=instruction
            except AttributeError:
                #create the globals vars if they don't exist
                sequencer.main_program.sequence_list=[instruction]
                sequencer.main_program.time=1
                sequencer.main_program.max_time=1
            if is_last:
                self.got_last()
        else:
            # We're a mighty parallel environment
            sequencer.main_program.parallel_insn.append(instruction)

    # gets the actual time rounded to cycle times of the clock
    def get_rounded_time(self,start_time):
        cycle_time=innsbruck.cycle_time/1000.0
        rounded_time=cycle_time*round(start_time/cycle_time)
        return rounded_time

    # sets the stop time after the last event of a sequential instruction
    def got_last(self):
        try:
            instruction=sequencer.main_program.max_time_insn
        except AttributeError:
            instruction=sequencer.main_program.sequence_list[len(sequencer.main_program.sequence_list)-1]            
        sequencer.main_program.time=sequencer.main_program.max_time + \
                                     instruction.get_duration()

        #instruction=sequencer.main_program.sequence_list[len(sequencer.main_program.sequence_list)-1]
        #sequencer.main_program.time=instruction.start_time+instruction.get_duration()
        #We need to get the max length of the ttl seq!


    # gets the time the first event has to start
    def get_real_start_time(self):
        if self.is_sequential:
            self.real_start_time=self.start_time
#            self.real_start_time=0
        else:
            self.real_start_time=self.start_time-self.get_pre_delay()


########## The event classes ##########

#Don't get confused with the many ttl clases we got here - We'll ned every one of them - perhaps


class parallel_ttl(parallel_event):
    def __init__(self,start_time,duration,device_key,is_sequential=False,is_pulse=True,value=1,is_last=True):
        self.start_time=start_time
        self.is_sequential=is_sequential

        #Let's see if we got multiple TTL's at once
        if device_key==str(device_key):
            self.add_insn(multiple_ttl_instruction(start_time,[device_key],[value],parent=self))
            if is_pulse:
                self.add_insn(multiple_ttl_instruction(start_time+duration,[device_key],[0],parent=self)
                              ,is_last=is_last)
        else:
            values_1=[]
            values_0=[]
            for i in range(len(device_key)):
                values_1.append(1)
                values_0.append(0)
            self.add_insn(multiple_ttl_instruction(start_time,copy.copy(device_key),values_1,parent=self))
            self.add_insn(multiple_ttl_instruction(start_time+duration,copy.copy(device_key),values_0,parent=self)
                          ,is_last=is_last)


#This is some mini parallel environment for the sequential mode
# you can use the method add_pulse to add a whole TTL pulse or
# add_event to set a channel to a given value !!
# At the end you must use the method end_sequence to write out the mini sequence
class TTL_sequence(parallel_event):
    def __init__(self):
        self.is_sequential=True
        #I gonna love those dictionaries
        # data is stored in event_dict{start_time}
        self.event_dict={}

    def add_event(self,start_time,device_key,value):
        #WE've to check multiple pulses !!!!
        start_time=self.get_rounded_time(start_time)
        if self.event_dict.has_key(start_time):
            item=self.event_dict[start_time]
            item[0].append(device_key)
            device_key1=item[0]
            item[1].append(value)
            value1=item[1]
        else:
            device_key1=[device_key]
            value1=[value]
        self.event_dict[start_time]=[device_key1,value1]

    def add_pulse(self,start_time,duration,device_key,repeat=None,TimeOffset=0,ion=None,parent=None):
        if (ion!=None) and (parent != None):
            parent.ion_event=self.add_pulse
            configuration=parent.get_config()
            cycle_time=configuration.cycle_time
            ion_start_time=start_time
            parent.address_ion(ion,start_time=ion_start_time)
            start_time=start_time+5*cycle_time
        self.add_event(start_time,device_key,1)
        self.add_event(start_time+duration,device_key,0)
        if repeat != None:
            for i in range(repeat):
                start_time+=TimeOffset
                self.add_event(start_time,device_key,1)
                self.add_event(start_time+duration,device_key,0)

    def end_sequence(self):
        times=self.event_dict.keys()
        times.sort()
        for key  in times:
            start_time=key
            device_key=self.event_dict[key][0]
            values=self.event_dict[key][1]
            self.add_insn(multiple_ttl_instruction(start_time,device_key,values,parent=self))
        self.got_last()

# Waiting - for Ramsey experiments or stuff like that
class seq_wait_event(parallel_event):
    def __init__(self,start_time,value):
        self.is_sequential=True
        self.add_insn(seq_wait_instruction(start_time,value,parent=self),is_last=True)

# This is the most sophisticated and most likely buggy function -- adds a whole shaped rf pulse
class parallel_shape(parallel_event):
    def __init__(self,start_time,duration,frequency,slope_type,
                 slope_duration,amplitude,phase=0,
                 amplitude2=-1,frequency2=0,phase2=0,
                 is_sequential=False,device_nr=1,is_last=True):
        self.slope_duration=slope_duration
        self.is_sequential=is_sequential
        #Check if we gonna need 2 rf outputs
        if frequency2 != 0 :
            self.is_dual=True
        else:
            self.is_dual=False

        self.start_time=start_time

        delay=self.get_delay_conf()
        self.get_real_start_time()
        #get the time where the slope starts - after freq switching
        slope_start_time=self.real_start_time+delay.switch_delay+delay.sub_delay1
        if self.is_dual:
            slope_start_time+=delay.switch_delay

        #Calculate the start times of the 4 instuctions
        #set the first freq
        switch_start_time=self.real_start_time
        #set the second freq
        switch_start_time2=self.real_start_time+delay.switch_delay
        #The raising slope
        raising_start_time=slope_start_time
        #The falling slope

        falling_start_time=slope_start_time+duration-delay.sub_delay2
        off_start_time=falling_start_time+delay.switch_delay
        off_start_time2=off_start_time+delay.switch_delay

        #Add the 3 instructions
        #The switch freq instruction is not fixed in time

        #The second dds switch function has to be carried out before the first one
        #because the AutoClr is set and we don't care about the phase of the second freq
        if frequency2 !=0:
            self.add_insn(switch_freq_instruction(switch_start_time2,frequency2,phase2
                                                  ,dds_device=2,parent=self))
        #switch the coherent frequency
        self.add_insn(switch_coherent_freq_instruction(switch_start_time,frequency,phase
                                                       ,dds_device=device_nr,parent=self))
        #Add the slope function if we use shaping
        if slope_duration > 0:
            #There is the devic nr missing right here !!
            my_pulse=sequencer.main_program.get_slope_name(slope_type,slope_duration,amplitude,amplitude2,device_nr=device_nr)
            self.add_insn(slope_instruction(raising_start_time,my_pulse,True,parent=self,device_nr=device_nr))
            self.add_insn(slope_instruction(falling_start_time,my_pulse,False,parent=self,device_nr=device_nr))
        else:
            #uups this doesn't look good - check how to get the off value right if we've got only one pulse
            if amplitude2 > -1:
                fall2=0
            else:
                fall2=-1
            #Add some dac instructions for non shaped pulses
            self.add_insn(dac_instruction(raising_start_time,amplitude,amplitude2,priority=3,device_nr=device_nr))
            self.add_insn(dac_instruction(falling_start_time,-100,fall2,priority=8,device_nr=device_nr))
                #TK changes because of new dB scaling
        self.add_insn(freq_off_instruction(off_start_time,dds_device=device_nr,parent=self),is_last=is_last)
        if frequency2 != 0:
            self.add_insn(freq_off_instruction(off_start_time2,dds_device=2,parent=self))
    #We've to set the delay configuration
    def get_pre_delay(self):
        delay=self.get_delay_conf()
        delay_time=delay.switch_delay+delay.sub_delay1
        if self.is_dual:
            delay_time+=delay.switch_delay
        delay_time+=self.slope_duration/2.0
        return delay_time

    def get_post_delay(self):
        delay=self.get_delay_conf()
        delay_time=delay.sub_delay2+self.slope_duration/2.0
        return delay_time


class parallel_sweep(parallel_event):
    def __init__(self,start_time,duration,start_frequency,stop_frequency,amplitude,
                 slope_duration,dds_device=1,slope_type="blackman",is_last=True):
        #Dauer 100us - Verstimmung 1MHz
        # ca 1kHz / Schritt - 1000 Schritte
        # 100ns / Schritt - ramp rate word = 10 -> 10
        dac_device=dds_device
        self.is_sequential=True
        delay=self.get_delay_conf()
        configuration=self.get_configuration()
        ramp_rate_word=20

        delta_freq=(stop_frequency-start_frequency)
        step_time=ramp_rate_word*configuration.cycle_time
        step_count=(slope_duration+duration)/(step_time)
        delta_freq_word=delta_freq/(step_count)
        print "duration: "+str(duration)
        print "delta freq word: "+str(delta_freq_word)
        print "start frequency: "+str(start_frequency)
        print "stop frequency: "+str(stop_frequency)
        self.start_time=start_time
        self.get_real_start_time()
        sweep_start_time=self.real_start_time
        switch_start_time=self.real_start_time-1
        stop_time=self.real_start_time+duration+slope_duration
        delay1=0
        raising_start_time=sweep_start_time+delay1
        falling_start_time=stop_time-slope_duration+1.8+delay1
        sweep_stop_time=stop_time+2.4+delay1
        
        phase=0
        self.add_insn(switch_freq_instruction(switch_start_time,start_frequency,phase
                                                  ,dds_device=dds_device,parent=self))
        self.add_insn(sweep_instruction(sweep_start_time,start_frequency,delta_freq_word,ramp_rate_word))
#        slope_type="blackman"
        amplitude2=-1
        my_pulse=sequencer.main_program.get_slope_name(slope_type,slope_duration,amplitude,amplitude2,device_nr=dds_device)
        self.add_insn(slope_instruction(raising_start_time,my_pulse,True,parent=self,device_nr=dds_device))
        self.add_insn(slope_instruction(falling_start_time,my_pulse,False,parent=self,device_nr=dds_device))
        self.add_insn(sweep_stop_instruction(sweep_stop_time,device=dds_device),is_last=is_last)
        #fall2=-1
        #amplitude2=-1
        #self.add_insn(dac_instruction(raising_start_time,amplitude,amplitude2,priority=3,device_nr=dac_device))
        #self.add_insn(dac_instruction(falling_start_time,-100,fall2,priority=8,device_nr=dac_device),is_last=True)


    def get_pre_delay(self):
        delay=self.get_delay_conf()
        delay_time=delay.switch_delay
        return delay_time

    def get_post_delay(self):
        delay=self.get_delay_conf()
        delay_time=delay.switch_delay
        return delay_time


######### The instruction base class #############

class parallel_instruction:
    priority=5
    is_fixed=False

    def __str__(self):
        string=self.type+" "+str(self.start_time)+"-  "+str(self.start_time+self.get_duration())
        return string

    def get_current_dac(self):
        current=test_config.dac_factory.current_device
        first_device = test_config.first_dac_device
        if current == first_device:
            self.current=True
        else:
#            print "not current"
            self.current=False

    def get_current_dds(self):
        current=test_config.dds_factory.current_device
        dds_device = test_config.dds_devices[self.dds_device]
        if current == dds_device:
            self.current=True
        else:
            debug_print("dds is not current device",2)
            self.current=False


######## The instruction classes ###################

class seq_wait_instruction(parallel_instruction):
    def __init__(self,start_time,value,parent=None):
        self.parent=parent
        self.type="wait"
        self.start_time=start_time
        self.value=value
        try:
            self.index=len(sequencer.main_program.sequence_list)
        except AttributeError:
            print("Error while getting sequential wait index")
        self.wait_time=value
        self.is_fixed=0

    def get_wait_time(self):
        try:
            pre_delay=sequencer.main_program.sequence_list[self.index+1].parent.get_pre_delay()
        except (IndexError,AttributeError) :
            pre_delay=0
        try:
            post_delay=sequencer.main_program.sequence_list[self.index-1].parent.get_post_delay()
        except (IndexError,AttributeError):
            post_delay=0
        self.wait_time=self.value-pre_delay-post_delay
        return self.wait_time

    def handle_instruction(self):
        cycle_time=innsbruck.cycle_time/1000.0
        wait(int(self.get_wait_time()/cycle_time))

    def get_duration(self):
        return self.value


# The famous TTL class
class ttl_instruction(parallel_instruction):
    import api
    # This circular include is not good at all
    import user_function

    def __init__(self,start_time,device_key,value,parent=None):
        self.type="TTL"
        self.start_time=start_time
        self.value=value
        self.device_key=device_key
        self.is_fixed=1
        self.parent=parent

    def handle_instruction(self):
        debug_print(self.device_key+" value: "+str(self.value),2)
        ttl_set_channel(self.device_key,self.value)

    def get_duration(self):
        return innsbruck.cycle_time/1000.0



class multiple_ttl_instruction(parallel_instruction):
    import api
    # This circular include is not good at all
    import user_function

    def __init__(self,start_time,device_keys,values,parent=None):
        self.type="mult_TTL"
        self.start_time=start_time
        self.values=values
        self.device_keys=device_keys
        self.is_fixed=1
        self.parent=parent

    def handle_instruction(self):
        debug_print(str(self.device_keys)+" value: "+str(self.values),2)
        ttl_set_multiple_channel(self.device_keys,self.values)

    def get_duration(self):
        return innsbruck.cycle_time/1000.0

    def solve_conflict(self,item_list):
        # We don't want to add us twice so remove the first entry from the list
        item_list.pop(0)
        for item in item_list:
#            for key_item in item.device_keys:
#                for key_item2 in self.device_keys:
#                    if key_item==key_item2:
#                        innsbruck.error_handler("cannot add the same TTL at the same time twice")
#                        print "error same ttl "
            self.values+=item.values
            self.device_keys+=item.device_keys

    def __str__(self):
        string="mult ttl "+str(self.start_time)+" "+str(self.device_keys)
        return string

class freq_off_instruction(parallel_instruction):
    def __init__(self,start_time,dds_device=1,parent=None):
        self.type="freq_off"
        self.start_time=start_time
        self.is_fixed=True
        self.parent=parent
        self.dds_device=dds_device

    def handle_instruction(self):
        first_dds_set_autoclr()
        dds_freq(0,0,self.dds_device)
        update_all_dds()

    def get_duration(self):
        delay=innsbruck.delay.switch_delay
        return delay

#The even better known shape classes
class switch_coherent_freq_instruction(parallel_instruction):
    def __init__(self,start_time,frequency,phase,dds_device=1,parent=None):
        self.type="switch_freq"
        self.start_time=start_time
        self.is_fixed=False
        try:
            frequency.relative_phase=phase
        except:
            print "no frequency"
        self.frequency=frequency
        self.dds_device=dds_device
        self.current=True
        self.parent=parent
        self.phase=phase

    def handle_instruction(self):
        debug_print("handling switch freq instruction: "+str(self.frequency),2)
        self.get_current_dds()
        first_dds_set_autoclr()
        update_all_dds()
        dds_freq(self.frequency.frequency, 0, self.dds_device)
        update_all_dds()
        self.frequency.relative_phase=self.phase
        if self.dds_device==1:

            first_dds_switch_frequency(self.frequency)
        else:
            second_dds_switch_frequency(self.frequency)


        first_dds_unset_autoclr()
        update_all_dds()
#        self.frequency.relative_phase=self.phase
#        first_dds_switch_frequency(self.frequency)
#        update_all_dds()
#        wait(1000)
#        self.frequency.relative_phase=self.phase
#        if self.dds_device==1:
#            first_dds_switch_frequency(self.frequency)
#        else:
#            second_dds_switch_frequency(self.frequency)
#        update_all_dds()

#         first_dds_phase(pi,1)#self.frequency.relative_phase,0)
#         update_all_dds()

    def get_duration(self):
        delay= innsbruck.delay.switch_delay
        self.get_current_dds()
        if not self.current:
            delay += innsbruck.delay.dds_address_delay
        return delay


class switch_freq_instruction(switch_coherent_freq_instruction):

    def handle_instruction(self):
        debug_print("handling switch freq instruction: "+str(self.frequency),2)
        self.get_current_dds()
        try:
            freq=self.frequency.frequency
        except:
            freq=self.frequency
        dds_freq(freq, 0, self.dds_device)
        update_all_dds()

    def get_duration(self):
        delay= innsbruck.delay.switch_delay
        self.get_current_dds()
        if not self.current:
            delay += innsbruck.delay.dds_address_delay
        return delay


class sweep_instruction(parallel_instruction):

    def __init__(self,sweep_start_time,start_frequency,delta_freq_word,ramp_rate_word,device=1):
        self.type="sweep_freq"
        self.dds_device=device
        self.frequency=start_frequency
        self.start_time=sweep_start_time
        self.rate_word=ramp_rate_word
        self.device=device
        self.profile=0
        self.delta_freq=delta_freq_word
        self.start_freq=start_frequency
        self.priority=2

    def handle_instruction(self):
        debug_print("handling sweep freq instruction: "+str(self.frequency),2)
        dds_start_sweep(self.start_freq,self.delta_freq,self.profile,self.device,self.rate_word)
        update_all_dds()
      
        
    def get_duration(self):
        delay= innsbruck.delay.sweep_delay
        self.get_current_dds()
        if not self.current:
            delay += innsbruck.delay.dds_address_delay
        return delay


class sweep_stop_instruction(parallel_instruction):
    def __init__(self,start_time,device=1):
        self.type="sweep stop"
        self.dds_device=device
        self.start_time=start_time

    def handle_instruction(self):
        dds_freq(0,0,self.dds_device)
        first_dds_unset_autoclr()
        dds_stop_sweep(self.dds_device)
        update_all_dds()

    def get_duration(self):
        delay=innsbruck.delay.sweep_stop_delay
        self.get_current_dds()
        if not self.current:
            delay += innsbruck.delay.dds_address_delay
        return delay


class slope_instruction(parallel_instruction):
    '''class for slope instruction'''
    def __init__(self,start_time,pulse,is_raising,dac=0,parent=None,device_nr=1):
        self.type="slope"
        self.start_time=start_time
        self.is_fixed=True
        self.pulse=pulse
        self.dac=dac
        self.parent=parent
        if is_raising:
            self.sub_name=pulse.sub_name+"_up"
            self.priority=3
        else:
            self.sub_name=pulse.sub_name+"_down"
            self.priority=8
    def handle_instruction(self):
        debug_print("handle slope instruction",2)
        call_subroutine(self.sub_name)

    def get_duration(self):
        self.get_current_dac()
        duration=self.pulse.duration+innsbruck.delay.sub_delay1+innsbruck.delay.sub_delay2
        if not self.current:
            duration+=innsbruck.delay.dac_address_delay
        return duration

#The duration and the logarithmic compensation is still missing
class dac_instruction(parallel_instruction):
    def __init__(self,start_time,amplitude,amplitude2=-1,priority=5,device_nr=1):
        self.priority=priority
        self.type="dac instruction"
        if device_nr==1:
            self.first_insn=first_dac_value
        else:
            self.first_insn=second_dac_value
        self.start_time=start_time
        self.is_fixed=True
        self.amplitude=amplitude
        self.amplitude2=amplitude2
        self.max=16000
        self.get_current_dac()

    def handle_instruction(self):
        self.get_current_dac()
        self.first_insn(innsbruck.calibration(self.amplitude))
        if self.amplitude2 > -1:
            second_dac_value(innsbruck.calibration(self.amplitude2))


    def get_duration(self):
        duration=0
        self.get_current_dac()
        if not self.current:
#            print "not current"
            duration+=innsbruck.delay.dac_address_delay
        if self.amplitude2 > -0.5:
            duration+=innsbruck.delay.dac_address_delay
            duration+=innsbruck.delay.dac_delay
        duration+=innsbruck.delay.dac_delay
        return duration

