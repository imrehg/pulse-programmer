from test_config.api import *
from innsbruck.api import *
from sequencer.api import *
import copy
from sequencer.pcp.events.wait import Wait_Event
from innsbruck.parallel_handler import *
from user_exceptions import *
import os,sys

class incl:
    is_include=True
class ca43:
    is_include=True

#class ca40:
#    is_include=True
#class cqed:
#    is_include=True
#class segtrap:
#    is_include=True

include_class=incl


#A base class for some basic commands
#We should include a framework for returning values to labview - been ther done that
class PulseCommand:

    #Get the configuration from the __init__.py script.
    #Don't really know waht to do with this
    def get_config(self):
        return innsbruck.configuration

    # Errors? - What's that ????????
    # Never needed an error handler for qfp what is it for ???
    def get_error_handler(self):
        return innsbruck.main_program.error_handler

    # returns the time in MICROSECONDS
    def get_cycle_time(self):
        return innsbruck.cycle_time

    # set the variable for labview return - look into the docs !!!!
    def set_variable(self,variable_name,value):
        sequencer.main_program.script_vars[variable_name]=value

    # Get the current value of a PREVIOUS SET VARIABLE
    def get_variable(self,variable_name,default=0):
        self.variable_name=variable_name
        try:
            value=sequencer.main_program.script_vars[variable_name]
        except KeyError:
            value=default
        return value
    #Don't know what this is doing right know but look in the docs it's certainly there
    def add_to_return_list(self,name,variable_name=None):
        try:
            sequencer.main_program.return_dict[variable_name]=name
        except AttributeError:
            debug_print("trying to return before defining the variable",2)


    #Something meaningful and full of wisdom
    #We've to keep track of the sequence the ions are addressed.
    def address_ion(self,ion,start_time=0):
        current_ion=detection_count=self.get_variable("current_ion",99)
        ion_list=detection_count=self.get_variable("ion_list",[])

        if current_ion != ion:
            configuration=self.get_config()
            debug_print("We've to change ions",2)
            duration=1
            #device_key=configuration.ion_trig_device   #disabled until we have a TTL channel for this TK
            #self.ion_event(start_time,duration,device_key)
            ion_list.append(ion)
            self.set_variable("ion_list",ion_list)
            self.set_variable("current_ion",ion)
            self.add_to_return_list("Ion List","ion_list")

    # we can use an alternative ion event if we are in sequential mode !!!
    def ion_event(self,start_time,duration,device_key):
	    parallel_ttl(start_time,duration,device_key,is_sequential=True)

# This has to be defined after the Pulse Command definition because it uses it !!
from innsbruck.pulse_handler import *



################################################
#                    Still needed?             #
################################################

####################### These commadns are necessary for laser scan to work. ##############################
#I think we'll never need that
#DEPRECIATED
def acq_mode(time,diff_mode=False):
    print "DEPRECIATED acq_mode shouldn't be called"
    trig_channel="20"
    laser_channel="6"
    pulse_time=1

    begin_infinite_loop()
    #The first few pulses after a infinite loop are ignored we have to compensate for this.

    set_channel(trig_channel,1)
    wait(pulse_time)
    set_channel(trig_channel,0)
    wait_time(time)
    if diff_mode:
        set_channel(laser_channel,1)

    set_channel(trig_channel,1)
    wait(pulse_time)
    set_channel(trig_channel,0)
    wait_time(time)
    if diff_mode:
        set_channel(laser_channel,0)

    end_infinite_loop()

#Defines wheter to return an answer or not
def request_tcp_answer():
    debug_print("return on",1)
    innsbruck.answer=True

#switch on the RF frequency with a given amplitude
def rf_on(frequency,amplitude):
    if amplitude > -100:
        dac_value=innsbruck.calibration(amplitude)
        first_dds_freq(float(frequency),0)
        update_all_dds()
        first_dac_value(dac_value)
    else:
        first_dds_freq(0,0)
	update_all_dds()

# Set the TTL channel imediatly
def set_channel(device_key,value):
    try:
        ttl_set_channel(device_key,value)
    except KeyError:
        sequencer.main_program.error_handler("error: cannot find channel for: "+str(device_key))

class DopplerPreparation_40(PulseCommand):
    def __init__(self):
        configuration=self.get_config()
        seq=TTL_sequence()
        seq.add_pulse(0,2000,configuration.Doppler)
        seq.add_pulse(1,1000,configuration.PMTrigPulses)
        seq.add_pulse(2010,40,configuration.Sigma397)
        seq.add_pulse(0,2050,configuration.Reset854)
        seq.end_sequence()

class SidebandCool(PulseCommand):
    def __init__(self):
        configuration=self.get_config()
        seq=TTL_sequence()
        seq.add_pulse(0,10000,configuration.Quench854)
        seq.add_pulse(0,10,configuration.Sigma397,repeat=9,TimeOffset=10000)
        seq.add_pulse(0,2000,configuration.SbCool6,ion=1,parent=self)
        seq.add_pulse(2000,8000,configuration.SbCool7,ion=2,parent=self)
        seq.end_sequence()

################################################
#                    Built-in User Commands    #
################################################

def ttl_pulse(duration,device_key,is_sequential=True,is_pulse=True,value=1,is_last=True,start_time=0):
    parallel_ttl(start_time,duration,device_key,is_sequential=is_sequential, \
                 is_pulse=is_pulse,value=value,is_last=is_last)

class ttl_set(PulseCommand):
    def __init__(self,device_name,value):
        configuration=self.get_config()
        seq=TTL_sequence()
        seq.add_event(0,device_name,value)
        seq.end_sequence()
        
# this sets all channels specified by a word and a mask. 
class ttl_setall(PulseCommand):
    def __init__(self,word,mask):
        configuration=self.get_config()
        seq=TTL_sequence()
        for i in range(16):
            mask_bit = (mask&int(pow(2,i)))/pow(2,i)
            value_bit = (word&int(pow(2,i)))/pow(2,i)
            if mask_bit==1:
               # seq.add_event(0,configuration.ttl_inverse_dict[i],value_bit)
               seq.add_event(0,str(i),value_bit)
        seq.end_sequence()

def rf_set(frequency,amplitude,channel=1):
    if channel == 1:
        if amplitude > -100:
            dac_value=innsbruck.calibration(amplitude)
            #first_dds_unset_autoclr()
            first_dds_freq(float(frequency),0)
            update_all_dds()
            first_dac_value(dac_value)
        else:
            first_dds_freq(0,0)
            update_all_dds()
    if channel == 2:
        if amplitude > -100:
            dac_value=innsbruck.calibration(amplitude)
            second_dds_freq(float(frequency),0)
            update_all_dds()
            second_dac_value(dac_value)
        else:
            second_dds_freq(0,0)
            update_all_dds()


def set_transition(transition,name_str="729"):
    if name_str=="729":
        multiplier=.5
        offset=0

    if name_str=="Raman":
        multiplier=.25
        offset=285

    if name_str=="RF":
        multiplier=1
        offset=285
    print "setting transition: "+str(transition)
    get_transition(transition,multiplier,offset)



def get_transition(transition=None,multiplier=1,offset=0):
    
    if transition==None:
        transition=sequencer.main_program.default_transition
    try:
        transition.is_transition()
    except :
        transition=sequencer.main_program.transitions[transition]
    print "frequency: "+str(transition.frequency)
    transition.offset=offset
    transition.multiplier=multiplier
    try:
        transition.frequency.is_abstract_frequency()
    except:
        transition.create_freq()
        transition.freq_is_init=False
#    transition.init_freq()    
    print "frequency2: "+str(transition.frequency)
    return transition

class rf_pulse(PulseCommand):
    def __init__(self,ion,theta,phi,transition=None,device_nr=1,musec_timebase=False,is_last=True,start_time=0,offset=0,multiplier=0.5):
        #test if we get the default transition
        #if theta<0.1 : theta=0.001
        main_program=sequencer.main_program
        transition=get_transition(transition)
        try:
            sweeprange=transition.sweeprange
        except:
            sweeprange=0
        if not transition.freq_is_init:
            transition.init_freq()
        #We need to get the rabi times before we map the ions
        try:
            t_rabi=transition.t_rabi[ion]
        except:
            debug_print("error while getting rabi frequency for ion: "\
                        +str(ion),1)
            return
        ion=transition.ion_list[ion]
        self.address_ion(ion)
        if musec_timebase==False : duration=t_rabi*float(theta)
        else : duration=float(theta)

        if duration < transition.slope_duration:
            debug_print("warning: duration of "+transition.name+ \
                        " is smaller than it's slope duration:"+ \
                        str(duration),1)
            
        phi=phi*multiplier
        if sweeprange==0 :
            print "rf frequency: "+str(transition.frequency.frequency)
#            transition.frequency.frequency=(transition.frequency.frequency)*multiplier+offset
            parallel_shape(start_time=start_time,duration=duration,  
                       frequency=transition.frequency,
                       slope_type=transition.slope_type ,
                       slope_duration=transition.slope_duration,
                       amplitude=transition.amplitude , phase=phi,
                       amplitude2=transition.amplitude2 , phase2=phi,
                       frequency2=transition.frequency2 , is_sequential=True,
                       device_nr=device_nr,is_last=is_last)
        else :
            staf=(transition.frequency.frequency)-sweeprange/2.0*multiplier
            stof=(transition.frequency.frequency)+sweeprange/2.0*multiplier
            parallel_sweep(start_time=start_time,duration=duration,start_frequency=staf,
                           stop_frequency=stof,
                           slope_duration=transition.slope_duration,
                           amplitude=transition.amplitude,dds_device=device_nr,
                           slope_type=transition.slope_type)

class SweepFreq(PulseCommand):
    def __init__(self,duration,start_freq,stop_freq,amplitude,slope_duration=None,device=1):
        if slope_duration==None:
            slope_duration=duration/1.9
        parallel_sweep(0,duration,start_freq,stop_freq,amplitude,device)

#############################################################################
#            User Commands for Ca43, derived from Built-in commands         #
#############################################################################
def rf_set729(frequency,power):
    frequency=frequency/2 #double pass AOM -> allow freq to be physical
    rf_set(frequency,power,1)
def rf_setRaman(frequency,power):
    frequency=frequency #Raman conversion from physical to AOM here
    rf_set(frequency,power,2)    
 
def rf_729(ion,theta,phi,transition=None,musec_timebase=False,is_last=True,start_time=0):
    rf729_mult=0.5
    transition=get_transition(transition,rf729_mult,0)
    t_rabi=transition.t_rabi[ion]
    slope_duration=transition.slope_duration
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    duration=duration+slope_duration+4
    try:
        port=transition.port
    except:
        port=0  #corresponds to horizontal 729 port
        print"PORT not found"
    if duration >0:
        if port==0 :
            ttl_pulse(duration,"TTL1",start_time=start_time,is_last=False)
        if port==1 :
            ttl_pulse(duration,"TTL1",start_time=start_time,is_last=False)
            ttl_pulse(duration,"TTL2",start_time=start_time,is_last=False)
        if port==2 :
            ttl_pulse(duration,"TTL2",start_time=start_time,is_last=False)
        if port==3 :
            ttl_pulse(duration,"TTL2",start_time=start_time,is_last=False)
            ttl_pulse(duration,"TTL3",start_time=start_time,is_last=False)
        ttl_pulse(duration,"3GhzRF",start_time=start_time,is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time+2,multiplier=rf729_mult)
        
def rf_Raman(ion,theta,phi,transition=None,musec_timebase=False,is_last=True
             ,start_time=0):
    Raman_offset=285
    Raman_mult=.25
    transition=get_transition(transition,Raman_mult,Raman_offset)
    t_rabi=transition.t_rabi[ion]
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    if duration >0:
        #ttl_pulse(duration+3,"3GhzRF",is_last=False)
        ttl_pulse(duration+3,"RamanR1",is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time+2,offset=Raman_offset,multiplier=Raman_mult)

def rf_Raman_sb(ion,theta,phi,transition=None,musec_timebase=False,is_last=True
             ,start_time=0):
    Raman_offset=285
    Raman_mult=.25
    transition=get_transition(transition,Raman_mult,Raman_offset)
    t_rabi=transition.t_rabi[ion]
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    if duration >0:
        ttl_pulse(duration+3,"3GhzRF",is_last=False)
        ttl_pulse(duration+3,"RamanR1",is_last=False)
        ttl_pulse(duration+3,"RamanR2",is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time+2,offset=Raman_offset,multiplier=Raman_mult)

def rf_Raman_dm(ion,theta,phi,transition=None,musec_timebase=False,is_last=True
             ,start_time=0):
    Raman_offset=285
    Raman_mult=.25
    transition=get_transition(transition,Raman_mult,Raman_offset)
    t_rabi=transition.t_rabi[ion]
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    if duration >0:
        ttl_pulse(duration+3,"3GhzRF",is_last=False)
        ttl_pulse(duration+3,"RamanR1",is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time+2,offset=Raman_offset,multiplier=Raman_mult)

def rf_Raman_dmsb(ion,theta,phi,transition=None,musec_timebase=False,is_last=True
             ,start_time=0):
    Raman_offset=285
    Raman_mult=.25
    transition=get_transition(transition,Raman_mult,Raman_offset)
    t_rabi=transition.t_rabi[ion]
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    if duration >0:
        ttl_pulse(duration+3,"3GhzRF",is_last=False)
        ttl_pulse(duration+3,"RamanR1",is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time+2,offset=Raman_offset,multiplier=Raman_mult)

def rf_RF(ion,theta,phi,transition=None,musec_timebase=False,is_last=True,start_time=0):
    RF_offset=285
    RF_mult=1
    transition=get_transition(transition,RF_mult,RF_offset)
    t_rabi=transition.t_rabi[ion]
    if musec_timebase==False : duration=t_rabi*float(theta)
    else : duration=float(theta)
    if duration >0:
        #ttl_pulse(duration,"3GhzRF",is_last=False)
        rf_pulse(ion,theta,phi,transition=transition,device_nr=1,musec_timebase=musec_timebase,\
                 is_last=is_last,start_time=start_time,offset=RF_offset,multiplier=RF_mult)

    
class SBCool(PulseCommand):  #for Ca40
    def __init__(self,length=1000,reps=10,offset=0,pumptime=10):
        configuration=self.get_config()        
        seq=TTL_sequence()
        seq.add_event(0,"397 sw",0)
        seq.add_event(0,"854 sw",1)
        seq.add_event(0,"866 sw",0)
        seq.end_sequence()
        if reps==0 :
            R729(1,length,1,"red sb for cooling",device_nr=1,musec_timebase=True,offset=offset)
        else : 
            for i in range(reps):
                if (length/reps)-pumptime<0 : pumptime=length/reps-1
                R729(1,(length/reps)-pumptime,1,"red sb for cooling",device_nr=1,musec_timebase=True,offset=offset)
                seq=TTL_sequence()
                seq.add_pulse(0,pumptime,"397sig sw")
                seq.add_pulse(0,pumptime,"866 sw")
                seq.end_sequence()
        
        seq=TTL_sequence()
        seq.add_event(0,"854 sw",0)
        seq.end_sequence()
        


class DopplerPreparation(PulseCommand):  #for Ca40
    def __init__(self,length=1000):
        configuration=self.get_config()
        trigger_length=configuration.PMT_trigger_length #new
        detection_count=self.get_variable("detection_count") 
        self.set_variable("detection_count",detection_count+2)
        self.add_to_return_list("PM Count","detection_count")
        seq=TTL_sequence()
        seq.add_pulse(0,trigger_length,"PMT trigger") #new
        #seq.add_pulse(0,length,"dopp/det") #JB 7.8.06
        seq.add_pulse(0,length,"397sig sw")
        seq.add_pulse(0,length,"397 sw")
        seq.add_pulse(0,length+1,"866 sw")
        seq.add_pulse(length,trigger_length,"PMT trigger") #new
        seq.end_sequence()


class DopplerPreparation43(PulseCommand):   #for Ca43
    def __init__(self,length=1000):
        configuration=self.get_config()
        trigger_length=configuration.PMT_trigger_length #new
        detection_count=self.get_variable("detection_count")
        self.set_variable("detection_count",detection_count+2)
        self.add_to_return_list("PM Count","detection_count")
        seq=TTL_sequence()
        seq.add_pulse(0,trigger_length,"PMT trigger") #new
        # seq.add_pulse(0,length,"dopp/det") #JB1.8.06
        seq.add_pulse(0,length,"397 sw")
        seq.add_pulse(0,length,"397sig sw")
        seq.add_pulse(0,length+1,"866 sw")
        seq.add_pulse(length,trigger_length,"PMT trigger") #new
        seq.end_sequence()

class OpticalPumping(PulseCommand):     #for Ca40
    def __init__(self,length=50):
        configuration=self.get_config()
        seq=TTL_sequence()
        #seq.add_pulse(0,length,"397sig sw") #JB 7.8.06
        seq.add_pulse(0,length,"dopp/det")
        seq.add_pulse(0,length,"397 sw") #JB 7.8.06
        seq.add_pulse(0,length+1,"866 sw") 
        seq.end_sequence()        

class OpticalPumping43(PulseCommand):   #for Ca43
    def __init__(self,length=50):
        configuration=self.get_config()
        seq=TTL_sequence()
        seq.add_pulse(0,length,"dopp/det") #JB1.8.06
        seq.add_pulse(0,length,"397 sw")
        seq.add_pulse(0,length+1,"866 sw") 
        seq.end_sequence()



class PMTDetection(PulseCommand): # for Ca40
    
    def __init__(self,detect_wait,CameraOn=False,trigger_length=None):
        configuration=self.get_config()
        if trigger_length==None:
            trigger_length=configuration.PMT_trigger_length

        detection_count=self.get_variable("detection_count")
        self.set_variable("detection_count",detection_count+2)
        self.add_to_return_list("PM Count","detection_count")

        seq=TTL_sequence()
        seq.add_event(0,"397 sw",1)
        seq.add_event(0,"397sig sw",1)
        seq.add_event(0,"866 sw",1)
        seq.add_event(0,"854 sw",0)
        seq.add_pulse(5,trigger_length,"PMT trigger")
        seq.add_pulse(5+detect_wait,trigger_length,"PMT trigger")
        seq.end_sequence()


class PMTDetection43(PulseCommand): # for Ca43 
    def __init__(self,detect_wait,CameraOn=False,trigger_length=None):
        configuration=self.get_config()
        if trigger_length==None:
            trigger_length=configuration.PMT_trigger_length

        detection_count=self.get_variable("detection_count")
        self.set_variable("detection_count",detection_count+2)
        self.add_to_return_list("PM Count","detection_count")

        seq=TTL_sequence()
        seq.add_event(0,"397 sw",1)
        seq.add_event(0,"397sig sw",1)
        seq.add_event(0,"866 sw",1)
        seq.add_event(0,"854 sw",0)
        seq.add_pulse(5,trigger_length,"PMT trigger")
        seq.add_pulse(5+detect_wait,trigger_length,"PMT trigger")
        seq.end_sequence()

class Repump_854(PulseCommand):   #for Ca40 and Ca43
    def __init__(self,length=50):
        configuration=self.get_config()
        seq=TTL_sequence()
        seq.add_pulse(0,length,"854 sw")
        seq.end_sequence()        
        
class PMTDetection_raw(PulseCommand): # for Ca43 and Ca40
    def __init__(self,detect_wait,CameraOn=False,trigger_length=None):
        configuration=self.get_config()
        if trigger_length==None:
            trigger_length=configuration.PMT_trigger_length

        detection_count=self.get_variable("detection_count")
        self.set_variable("detection_count",detection_count+2)
        self.add_to_return_list("PM Count","detection_count")

        seq=TTL_sequence()
        seq.add_pulse(0,trigger_length,"PMT trigger")
        seq.add_pulse(detect_wait,trigger_length,"PMT trigger")
        seq.end_sequence()  

#############################################################################
#        END User Commands for Ca43, derived from Built-in commands         #
#############################################################################


def include_all():
    include_dictionary={}
    dir1=innsbruck.configuration.std_includes_dir
    for f in os.listdir(dir1):
        module_name, ext = os.path.splitext(f) # Handles no-extension files, etc.
        if ((ext == '.py') and (module_name != "__init__")): # Important, ignore .pyc/other files.
            include_file(dir1+module_name+ext,absolute_path=True)


def include_file(file_name,absolute_path=False):
    error_handler=innsbruck.main_program.error_handler
    includes_dir=innsbruck.configuration.includes_dir
    if absolute_path:
        absolute_file_name=file_name
    else:
        absolute_file_name=includes_dir+file_name
    try:
        file1=open(absolute_file_name)
        string1=file1.read()
        file1.close()
    except:
        print("error couldn't open include file: "+str(file_name))
    try:
        exec(string1)
    except :
        print("error while executing include file: "+str(file_name))


#################### ---------- Here comes the one and only parallel handler !!! ---------- ######################
# It is used for the old qfp where python knows nothing but the timings of the channels :-(
# We want some wisdom so we can take over the world !!!!!!
def start_parallel_env():
    sequencer.main_program.parallel_insn=[]


# You have to call the add_parallel_env like follows:
# Be sure you get the decive key quoted as tring
# add_parallel_env("set_ttl_channel('3',VALUE)",0,10)
def ttl_add_to_parallel_env(device_key,start_time,duration,start_value=1,stop_value=0):
    parallel_ttl(start_time,duration,device_key)

#Add a whole shaped pulse into the sequence !!!
def shape_add_to_parallel_env(start_time,duration,frequency,
                              slope_type,slope_duration,amplitude,phase=0,
                              amplitude2=-1,frequency2=0,phase2=0):
    parallel_shape(start_time,duration,frequency,slope_type,slope_duration,amplitude,phase,amplitude2,frequency2,phase2)

# This is for the new sequential styled files so we can get some ramsey experiments
def seq_wait(value):
    seq_wait_event(0,value)

# This just starts the processing of the parallel environment.
# This is also called if we use sequential environments !!
class end_parallel_env(PulseCommand):
    def __init__(self,big_list1=None,trigger="None",repeat=0):
        #read the configuration
        configuration=self.get_config()

        #WE've to reset all unset ttl channels:
        # NOTE for ca43 here we can add the initial vaues of the ttl pulses
        if configuration.reset_ttl:
            ttl_signal_a(0x0)
        start_trigger=configuration.line_trigger
        self.error_handler=innsbruck.main_program.error_handler
        cycle_time=self.get_cycle_time()/1000.0
        ttl_cycles=1

        #check if we have to execute the sequence more than once
        if repeat>0:
            begin_finite_loop()

        #initialize the dds - to synchronize the compensation and coherent dds for Ca40
        if configuration.parallel_mode:
            init_parallel_dds()

        #check if we need a trigger
        if trigger != "None":
            get_slope_trigger()
        debug_print("processing parallel environment",1)

        # Get the mighty instruction list
        if big_list1==None:
            big_list=sequencer.main_program.parallel_insn
        else:
            big_list=big_list1
        item0=big_list[0]
        less,same,greater=[],[],[]
        # the big list is now called l because
        # the sorting example I found works this way and I'm a lazy guy :-(

        l=big_list
        #sort the instruction list so the first events come first
        for passesLeft in range(len(l)-1, 0, -1):
            for index in range(passesLeft):
                if l[index].start_time > l[index + 1].start_time:
                   l[index], l[index + 1] = l[index + 1], l[index]

        #set the current time the start time of the first instruction
        #So we hopefully don't get problems with negative times.
        current_time=l[0].start_time
        for i in range(len(l)-1):
            # check if there start more pulses at the same time and try to merge them
            # I think this is something that shuld be improved
            try:
                if abs(l[i].start_time-l[i+1].start_time)<1e-9:
                    start_time=l[i].start_time
                    i2=i+1
                    conflict_pulses=[i]

                    while (abs(start_time-l[i2].start_time)<1e-9):
                        conflict_pulses.append(i2)
                        i2+=1
                    l=merge_instructions(l,i,conflict_pulses)
                    conflict_pulses=[i]
            # I'm not quite shure what to do with that exception
            except IndexError:
                l=merge_instructions(l,i,conflict_pulses)
                conflict_pulses=[i]
                debug_print("reached end of sequence",2)

        
        for i in range(len(l)-1):
            # We may get some other conflicts
            try:
                if l[i].start_time+l[i].get_duration()-l[i+1].start_time > 1e-9 :
                    debug_print("warning we've got some overlap at time: "+str(l[i].start_time) \
                                       +" and " +str(l[i+1].start_time),1 )
                    debug_print("overlap between : "+str(l[i+1].type)+" and "+str(l[i].type),1)
                    l=resolve_conflicts(l,i)

            except IndexError:
                debug_print("reached end of sequence",2)
        
        #here we try to execute the instruction in the right order
        for item in l:
            debug_print("item: "+str(item),1)
            time_diff=float(item.start_time-current_time)

            if time_diff<-1e-9:
                debug_print("warning: pulses still overlap at: "+str(current_time)+str(item.start_time),1)
                wait_cycles=0
            else:
                wait_cycles=int(time_diff/cycle_time)
                wait(wait_cycles)
                debug_print("wait cycles: "+str(wait_cycles)\
                            +" time diff: "+str(time_diff),2)

            item.handle_instruction()
            current_time+=float(wait_cycles*cycle_time)+item.get_duration()
            debug_print("current time: "+str(current_time),2)
        
        # WE are kind guys and end the loop we started
        if repeat > 0:
            end_finite_loop(repeat)
        #removing the parallel list
        if big_list1==None:
            del(sequencer.main_program.parallell_insn)

def init_parallel_dds():
    #Stop all dds (just to be sure:
    dds_freq(0,0,1)
    dds_freq(0,0,2)
    #Set the phase every cycle to zero:
    dds_set_autoclr(2)
    update_all_dds()
    #another update just to be sure:
    update_all_dds()
    #just let the second dds evolve without any phase jumps ...
    dds_unset_autoclr(2)
    update_all_dds()

def return_all_variables():
    #We need this for returning values to the NEW QFP
    for key , pre_str in sequencer.main_program.return_dict.iteritems():
        variable=sequencer.main_program.script_vars[key]
        try:
            len(variable)
            return_list=[pre_str]+variable
        except TypeError:
            return_list=[pre_str,variable]
        sequencer.main_program.return_variables.append(return_list)



#Generate the real pulses when in sequential mode:
# Hehe we just use the parallel environment
def end_sequential():

    try:
#        for item in sequencer.main_program.sequence_list:
#            print item
        item=sequencer.main_program.sequence_list[-1]
        fake_command=PulseCommand()
        fake_command.add_to_return_list("sequence_duration","sequence_duration")
        fake_command.set_variable("sequence_duration",item.start_time)
        #sequencer.main_program.script_vars["sequence_duration"]=item.start_time
        return_all_variables()
        end_parallel_env(sequencer.main_program.sequence_list)
        del(sequencer.main_program.sequence_list)
    except AttributeError :
        debug_print("no sequence",1)

    sequencer.main_program.time=1


#Sometimes some instruction have to be meged into one
#This is like marriages, nothing good comes from it :-)
def merge_instructions(big_list,start_point,conflict_list):
    try:
        if len(conflict_list) < 2:
            return big_list
    except IndexError:
        return big_list
    conflict_dict={}
    # get the types in a dictionary
    for index in conflict_list:
        this_type=big_list[index].type
        this_item=big_list[index]
        if conflict_dict.has_key(this_type):
            conflict_dict[this_type].append(this_item)
        else:
            conflict_dict[this_type]=[this_item]
    #make love first - merge if possible
    merge_list=[]
    for this_type , lover_array in conflict_dict.iteritems():
        item=lover_array[0]
        try:
            item.solve_conflict(lover_array)
            debug_print("merging item: "+str(item),1)
            merge_list.append(item)
        except AttributeError:
            debug_print("no merging known for: "+str(item),1)
            #generate a list of all the items item_list
            merge_list+=lover_array
            # The merge list is now our return list.

    conflict_list.reverse()
    for index in conflict_list:
        big_list.pop(index)
    insert_index=start_point

    for item in merge_list:
        big_list.insert(insert_index,item)
        insert_index+=1
    return big_list


#When the two or more participants don't love each other anymore
#there is only one solution - DIVORCE them
def resolve_conflicts(big_list,index):
    #We use the speaking name l for the big list again uups
    l=big_list
    i=index
    if (not l[i].is_fixed):
        l[i].start_time=l[i-1].start_time+l[i-1].get_duration()
        debug_print("trying to move moveable command: "+str(l[i])
                    +" to "+str(l[i].start_time) ,1)

    if (not l[i+1].is_fixed):
        actual=l[i]
        l[i]=l[i+1]
        l[i].start_time=l[i-1].start_time+l[i-1].get_duration()
        l[i+1]=actual
        debug_print("trying to move moveable command: "+str(l[i])
                    +" to "+str(l[i].start_time),3)

    else:
        # interchange l[i] and l[i+1] if i+1 has a higher priority
        if l[i+1].priority > l[i].priority:
            item=l.pop(i+1)
            l.insert(i,item)

        l[i+1].start_time=l[i].start_time+l[i].get_duration()


    if l[i].start_time+l[i].get_duration()<l[i+1].start_time:
        debug_print("great:moving commands seemed to work",1)

    return l

# Don't look into this - I'VE WARNED YOU
#This is the result of a night in the lab at 6.AM
def get_slope_trigger():
    configuration=innsbruck.configuration
    start_trigger=configuration.line_trigger
    triggerlabel=create_label("infinite_start")
    triggerlabel0=create_label("infinite_start0")
    insert_label(triggerlabel0)
    branch(triggerlabel0,start_trigger)
    begin_infinite_loop()
    branch(triggerlabel,start_trigger)
    end_infinite_loop()
    insert_label(triggerlabel)


# The transition main class
class transition:
    '''class for characterizing an atomic transition'''
    def __init__(self,transition_name,t_rabi,
                 frequency,sweeprange=0,amplitude=1,slope_type="None",
                 slope_duration=0,ion_list=None,amplitude2=-1,frequency2=0,
                 port=0,multiplier=.5,offset=0):

        # The rabi frequency is unique for each ion !!!!
        configuration=innsbruck.configuration
        self.name=str(transition_name)
        if ion_list == None:
            ion_list=configuration.ion_list
        self.ion_list=ion_list
        self.t_rabi=t_rabi
        self.frequency=frequency
        self.sweeprange=sweeprange
        self.amplitude=float(amplitude)
        self.slope_type=slope_type
        self.slope_duration=slope_duration
        self.amplitude2=amplitude2
        self.frequency2=frequency2
        self.offset=offset
        self.multiplier=multiplier
        self.freq_is_init=False
        self.port=port

    # So some lazy labview gave us only a float frequency
    def create_freq(self):
        try:
            self.frequency.is_abstract_frequency()
        except:
            self.frequency=coherent_create_freq(float(self.frequency)*self.multiplier+self.offset,0)
        if self.frequency2 != 0:
            try:
                self.frequency2.is_abstract_frequency()
            except:
                self.frequency2=coherent_create_freq(self.frequency2,0)

    #We have to initialize the frequency ourself
    def init_freq(self):
        print "init freq: "+str(self.frequency)
        first_dds_init_frequency(self.frequency)
        self.freq_is_init=True

# The second frequency is not phase coherent
#        if self.frequency2 != 0:
#            first_dds_init_frequency(self.frequency2)
#        self.freq_is_init=True

    def is_transition(self):
        return True
