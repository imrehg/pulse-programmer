from sequencer.api import *
from math import *
from api import first_dac_value

class Shaped_pulse:
      
    def generate_ramp(self,ramp_function):
        steps=self.steps
        wait_duration=self.step_wait
        for i in range(0,steps):
            value=ramp_function(float(i)/float(steps))*self.amplitude
            dac_value=self.recalibration(value)
            self.dac_event(dac_value)
            wait(wait_duration)

    def generate_pulse_ramps(self):
        ramp_up_function=self.ramp_up_function
        ramp_down_function=self.ramp_down_function
        sub_name=self.sub_name+"_up"
        begin_subroutine(sub_name)
        self.generate_ramp(ramp_up_function)
        end_subroutine()
        sub_name=self.sub_name+"_down"
        begin_subroutine(sub_name)
        self.generate_ramp(ramp_down_function)
        end_subroutine()

    def recalibration(self,x):
        a=-3.16
        b=0.00209
        c=0.00066612
        x_max=39.5
        y=log((x*x_max-a)/b)*1/c
        return int(y)


    def __init__(self,
                 steps,
                 sub_name,
                 step_wait=0,
                 amplitude=1,
                 ):
    
        # Get this from a config file
        self.dac_duration=2
        self.amplitude=amplitude
        #The steps are quantized
        self.step_wait=step_wait
        self.dac_event=first_dac_value
        #Calculate the steps for the top
        self.steps=steps
        self.sub_name=sub_name
        
class sine_pulse(Shaped_pulse):


    def ramp_up_function(self,x):
        f=sin(x*pi/2)
        return f

    def ramp_down_function(self,x):
        f=sin(x*pi/2+pi/2)
        return f
            
class blackman_pulse(Shaped_pulse):
    
    def ramp_up_function(self,x):
        f=1.0/2.0*(0.84-cos(x*pi)+0.16*cos(2*x*pi))
        return f

    def ramp_down_function(self,x):
        f=1.0/2.0*(0.84-cos((x+1)*pi)+0.16*cos(2*(x+1)*pi))
        return f

