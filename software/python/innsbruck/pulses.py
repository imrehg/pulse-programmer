from sequencer.api import *
from math import *
from test_config.api import first_dac_value
from innsbruck import *


class Shaped_pulse:

    def generate_ramp(self,ramp_function):
        unset_current_devices()
        steps=self.steps
        wait_duration=self.step_wait
        for i in range(0,steps+1):
            for amplitude , dac_event  in self.amplitude_list:
                value=self.todB(ramp_function(float(i)/float(steps)))+amplitude                      
                dac_value=self.recalibration(value)
                dac_event(dac_value)
            wait(wait_duration)

    def generate_pulse_ramps(self):
        ramp_up_function=self.ramp_up_function
        ramp_down_function=self.ramp_down_function
        sub_name=self.sub_name+"_up"
        begin_subroutine(sub_name)
        dac_setup()
        self.generate_ramp(ramp_up_function)
        end_subroutine()
        sub_name=self.sub_name+"_down"
        begin_subroutine(sub_name)
        dac_setup()
        self.generate_ramp(ramp_down_function)
        end_subroutine()

    def recalibration(self,x):
        return innsbruck.calibration(x)

    def todB(self,x):
        if x<=0 :
            return -100
        if x>=1:
            return 0
        try:
            y=10*log(x)
        except OverflowError:
            innsbruck.error_handler("error while calculating pulse value")
        return y

    def __init__(self,
                 slope_duration,
                 amplitude=1,
                 amplitude2=-1,
                 step_duration=30e-3,
                 dac_device=1,
                 dac_device2=2,
                 max_step_count=100
                 ):

#        if slope_duration > 100:
#            real_slope_duration=slope_duration%100
#            self.down_amplitude=(slope_duration-real_slope_duration)/100.0
#            if self.down_amplitude==0:
#                self.down_amplitude=1
#            slope_duration=real_slope_duration
#        else:
#            self.down_amplitude=1
        # Get this from a config file
        self.down_amplitude=1
        cycle_time=innsbruck.cycle_time/1000.0
        self.dac_device=dac_device
        self.dac_duration=3
        self.slope_duration=float(slope_duration)
        self.amplitude=float(amplitude)
        self.amplitude2=float(amplitude2)
        #The steps are quantized
        self.dac_event_dict={}
        self.dac_event_dict[1]=first_dac_value
        self.dac_event_dict[2]=second_dac_value
        self.dac_event=self.dac_event_dict[dac_device]
        self.amplitude_list=[(amplitude,self.dac_event)]

        if amplitude2 > -1:
            debug_print("getting dual dac pulse",1)
            self.amplitude_list.append((amplitude2,self.dac_event_dict[dac_device2]))
            self.dac_duration=14#self.dac_duration*2
            self.one_dac=False
        else:
            self.one_dac=True

        self.step_wait=int((step_duration/cycle_time)-self.dac_duration)
        print "step_wait: "+str(self.step_wait)
        if self.step_wait < 0:
            self.step_wait=0
            step_duration=self.dac_duration*cycle_time
        #calculate the step number -> The duration may not be exact
        self.steps=int(self.slope_duration/(step_duration))
        if self.steps==0: self.steps=1
        if (self.steps < 10):
            debug_print("warning step number smaller than 10: "+str(self.steps),1)
        # generate the subroutine name
        if (self.steps > max_step_count):
            self.steps=max_step_count
            step_duration=slope_duration/float(self.steps)
            self.step_wait=int((step_duration/cycle_time)-self.dac_duration)
            print "max step size exceeded - new step wait: "+str(self.step_wait)
            
        self.sub_name="sub_slope-"+str(self.slope_duration)+"-"+str(self.get_type())\
                       +"-"+str(self.amplitude)+"-"+str(self.amplitude2)+"-"+str(dac_device)
        debug_print("generating slope: "+self.sub_name,1)
        #WE've got to count how often we're called:
        self.counter=0
        #calculate the duration
        if self.one_dac:
             time_offset=9*cycle_time
        else:
            time_offset=-5*cycle_time
        self.duration=self.steps*((self.step_wait+self.dac_duration)*cycle_time)+time_offset
# when adding a new pulse --- add also in __init__
# x geht von 0 bis 1 und f auch!
class sine_pulse(Shaped_pulse):

    def ramp_up_function(self,x):
        f=sin(x*pi/2)
        return f

    def ramp_down_function(self,x):
        f=sin(x*pi/2+pi/2)
        return f

    def get_type(self):
        return "sine"

class gauss_pulse(Shaped_pulse):


    def ramp_up_function(self,x):
        a=.2
        f=exp(-(x-.5)^2/4*a^2)
        return f

    def ramp_down_function(self,x):
        f=sin(x*pi/2+pi/2)
        return f

    def get_type(self):
        return "gauss"


class blackman_pulse(Shaped_pulse):

    def get_type(self):
        return "blackman"

    def ramp_up_function(self,x):
        f=1.0/2.0*(0.84-cos(x*pi)+0.16*cos(2*x*pi))
        return f

    def ramp_down_function(self,x):
        try:
            if x > self.down_amplitude:
                x=1
            else:
                x=x
        except:
            x=x
        f=1.0/2.0*(0.84-cos((x+1)*pi)+0.16*cos(2*(x+1)*pi))
        return f

def fix_loop_bug(n=15):
    print "no need to fix the bug anymore as it's gone - forever"
#    dummy_signal="PB dummy"
#    for i in range(n):
#        wait(1)
#    third_dac_value(0)
#        third_dac_value(1)
