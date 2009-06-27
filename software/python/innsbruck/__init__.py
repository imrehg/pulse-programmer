import sequencer

from sequencer.api   import *
from test_config.api import * # Template config overrides distribution

from innsbruck.api                  import * # Box config overrides distrib
from innsbruck.user_function        import *
from innsbruck.pulses               import * # get the pulse shapes
from innsbruck.main_program         import *
from innsbruck.device1              import *
from innsbruck.get_devices          import *
import os


ref_freq   = 800 # in MHz, so 1000 = 1 GHz


# Some site wide configuration variables
class configuration:
  # The output of the ion trigger
  ion_trig_device="address trig"
  # The done signal for labview
  done_signal="PB trigger"
  #The default port for the server
  default_port=8880
  #The Hardware config file:
  #hardware_config="E:\My Documents\(Work)\expcontrol\qfp\Configuration\Settings\Hardware settings.txt"
  #sequences_dir="E:/My Documents/(Work)/expcontrol/qfp/PulseSequences/"
  #includes_dir="E:/My Documents/(Work)/expcontrol/qfp/PulseSequences/Includes/"
  file1=open("innsbruck/paths.txt");
  exec(file1); # assigns hardware_config, sequences_dir, includes_dir

  #The line TRigger:
  line_trigger=(Input_0_Trigger,)
  #The PMT detection Trigger pulse length:
  PMT_trigger_length=1

  #do we write an tcp answer by default?
  #answer_tcp=True #for ca40
  answer_tcp=True
  #do we run in parallel mode by default?
  #parallel_mode=False #fr ca40
  parallel_mode=False
  #Shall we send a return before compiling the seqeunce?
  #send_pre_return=False #for ca40
  send_pre_return=True
  #Reset the ttl outputs every time we're running?
  #reset_ttl=True #for ca40
  reset_ttl=False
  #Should we disconnect the tcp after every sequence?
  #disconnect_tcp=False #for ca40
  disconnect_tcp=False

  #The name of the Ca40 TTL outputs:
  detection397="Detection 397"
  Detection="Detection"
  PMTrigger="PM trigger"
  PMGate="PM Gate"
  Doppler="Doppler"
  PMTrigPulses="PM trigger"
  Sigma397="Sigma397"
  Reset854="Reset854"
  Quench854="Quench854"
  SbCool6="SbCool6"
  SbCool7="SbCool7"
  CameraTrigger="Camera trigger"
  #main_loop_wait: min number of cycles to wait between 2 triggered programs
  main_loop_wait=100
  # The default ion list:
  ion_list={}
  for i in range(10):
    ion_list[i]=i
  # The sequences directory
  dir1=os.getcwd()
  #sequences_dir=dir1+"/seqs/"
  #sequences_dir="E:/My Documents/(Work)/expcontrol/qfp/PulseSequences/"
  #sequences_dir="PulseSequences/"
  # inludes dir
  #includes_dir="E:/My Documents/(Work)/expcontrol/qfp/PulseSequences/Includes/"
  #includes_dir="Includes/"
  #std_includes_dir="/home/c704/c704271/sequencer/python/Includes/"
  std_includes_dir=includes_dir
  # The known pulse shapes
  pulse_dictionary={}
  pulse_dictionary["blackman"]=blackman_pulse
  pulse_dictionary["sine"]=sine_pulse
  pulse_dictionary["gauss_pulse"]=gauss_pulse
  cycle_time=1/float(ref_freq/8)
  # An inverse dictionary ch->key so that one can access the TTL channels by number
  ttl_dictt=get_hardware(hardware_config)
  ttl_inverse_dict={}
  for key , channel  in ttl_dictt.iteritems():
    ttl_inverse_dict[channel[0]]=key


cycle_time = (1e3 / ref_freq) * 8 # in ns, AD9858 sync clock is divide-by-8
debug_print("Cycle Time: " + str(cycle_time), 1)

#creating the ttl devices
ttl_dict=get_hardware(configuration.hardware_config)
ttl_device={}
for key , channel  in ttl_dict.iteritems():
  print key,channel
  ttl_device[key]=[]
  ttl_device[key].append(TTL_Device(channel[0]))
  ttl_device[key].append(channel[1])

# create ttl devices according to channel number
for i in range(0,15):
  ttl_device[str(i)]=[]
  ttl_device[str(i)].append(TTL_Device(i))
  ttl_device[str(i)].append(0)

# The delay times for the more complex pulses
class delay:
  cycle_time=innsbruck.cycle_time/1000.0
  # switch_time : the time needed for switcheing the frequency
  #switch_delay=(39)*cycle_time
  switch_delay=(28)*cycle_time
  #sub_delay : the delay for jumoping into a subroutine
  sub_delay1=6*cycle_time
  sub_delay2=6*cycle_time
  # dac_delay the delay needed for a rectangular shape
  # There seems to be an unbalance between raising and falling slope
  dac_delay=3*cycle_time
  # the addressing delays
  dds_address_delay=4*cycle_time
  dac_address_delay=3*cycle_time

  sweep_delay=32*cycle_time
  sweep_stop_delay=32*cycle_time

  # The times the dds needs to get a good rf signal out:
  real_switch_delay=9*cycle_time

def calibration(x):
  if x>=0:
    x=0
  if x<=-100:
    x=-100
  a0=14.279
  a1=0.196
  a2=0.000375
  y=(a0 + a1*x + a2*x*x)*1000
  if y>14500:
    y=14500
  if y<0:
    y=0
  #a=14300
  #b=3200
  #min1=1500
  #const=0
  #const=exp(log(10)*(min1-a)/b)##
  #
  #if x > 0:
  #  y=a + b*log10(x+const)
  #else:
  #  y=min1
#  print "DAC VALS:",x,y
  
  return int(y)
#  maximum=16000
#  return int(x*maximum)

#  a=-3.16*0.1
#  b=0.00209
#  c=0.00066612
#  x_max=39.5
#  y=log((x*x_max-a)/b)*1/c
#  return int(y)
