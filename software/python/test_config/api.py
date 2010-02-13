import sequencer
import sequencer.ptp
import sequencer.ptp.requests
import test_config
import profile
import pstats
from sequencer.constants           import *
from sequencer.pcp.events.sequence import PulseSequence
from sequencer.ptp.requests        import *

socket_initialized = False

#------------------------------------------------------------------------------
# Interpose site-specific parse-params to allow params in startup
def parse_params(*option_list):
  # Augment standard params with site-specific ones
  sequencer.standard_params.append(('router', 'boolean'))
  sequencer.api.parse_params(*option_list)

def setup():
  sequencer.ptp.setup_socket()

def teardown():
  sequencer.ptp.teardown_socket()

def begin_sequence(reuse_subs = False,reset_dds=True):
  global socket_initialized
  if (not socket_initialized):
    setup()
    socket_initialized = True

  # Assign daisy-chain addresses
  test_config.first_sequencer.send_frame(DISCOVER_REQUEST)

  if reset_dds:
    # Reset the DDS for sync clocks
    reset_dds_request = I2C_Request_Frame(
      slave_address = BREAKOUT_I2C_SLAVE_ADDRESS,
      read_length   = 0,
      write_data    = '\x44\x00')
    test_config.first_sequencer.send_frame(reset_dds_request)
    unreset_dds_request = I2C_Request_Frame(
      slave_address = BREAKOUT_I2C_SLAVE_ADDRESS,
      read_length   = 0,
      write_data    = '\x44\xFF')
    test_config.first_sequencer.send_frame(unreset_dds_request)

  old_sub_names_dict = {}
  if (reuse_subs):
    if (sequencer.current_sequence == None):
      raise RuntimeError("Cannot reuse subs if this is the first sequence.")
    old_sub_names_dict = sequencer.current_sequence.sub_names_dict

  sequencer.current_sequence = PulseSequence(
    sub_names_dict = old_sub_names_dict)
  sequencer.current_sequence.unset_current_devices=unset_current_devices
  reset_events = []
  reset_events.extend(test_config.dds_factory.create_reset_events())
  reset_events.extend(test_config.dac_factory.create_reset_events())
  reset_events.extend(test_config.first_dds_device.create_profile_events(0))
  sequencer.current_sequence.add_event_list(reset_events)

def unset_current_devices():
  test_config.dac_factory.current_device=None
  test_config.dds_factory.current_device=None


def end_sequence(program_address = DEFAULT_STARTING_ADDRESS):
  global starting_address
  starting_address = program_address
  if (sequencer.params.profile != None):
    profile.run(
      'test_config.first_sequencer.'
      'load_program(pulse_sequence = sequencer.current_sequence, '
      '             starting_address = test_config.api.starting_address)',
                sequencer.params.profile)
    profile_stats = pstats.Stats(sequencer.params.profile)
    profile_stats.strip_dirs().sort_stats('cum').print_stats(10)
    profile_stats.sort_stats('cum').strip_dirs().print_callers()
    pass
  else:
    pulse_program = test_config.first_sequencer.load_program(
      pulse_sequence   = sequencer.current_sequence,
      starting_address = program_address)

  #test_config.first_sequencer.load_program(program_address)
#  teardown()

def ttl_signal_a(value):
  event_list = test_config.device_one.create_output_events(value = value)
  sequencer.current_sequence.add_event_list(event_list)

def ttl_set_channel(bit,value):
  event_list = test_config.device_two.create_bit_output_events(bit = bit,value = value)
  sequencer.current_sequence.add_event_list(event_list)
  
def ttl_signal_loopback(value):
  event_list = test_config.device_loopback.create_output_events(value = value)
  sequencer.current_sequence.add_event_list(event_list)

def dac_setup():
  event_list = test_config.first_dac_device.internal_get_setup_events()
  event_list += test_config.second_dac_device.internal_get_setup_events()
  sequencer.current_sequence.add_event_list(event_list)

def first_dac_value(level):
  event_list = test_config.first_dac_device.create_level_events(level = level)
  sequencer.current_sequence.add_event_list(event_list)

def second_dac_value(level):
  event_list = test_config.second_dac_device.create_level_events(level = level)
  sequencer.current_sequence.add_event_list(event_list)

def third_dac_value(level):
  event_list = test_config.third_dac_device.create_level_events(level = level)
  sequencer.current_sequence.add_event_list(event_list)

def fourth_dac_value(level):
  event_list = test_config.fourth_dac_device.create_level_events(level = level)
  sequencer.current_sequence.add_event_list(event_list)

# Define box-specific commands.
def write_amplitude(gain):
  event_list = test_config.dac_device.create_gain_events(gain)
  test-config.current_event_list.extend(event_list)

def update_secondary():
  event_list = test_config.dac_device.create_after_update_events()
  test-config.current_event_list.extend(event_list)

def amplitude_gain(gain):
  write_amplitude(gain)
  update_secondary()

def write_secondary_freq(freq):
  event_list = test_config.dac_device.create_frequency_events(freq)
  sequencer.current_event_list.extend(event_list)

def secondary_freq(freq):
  write_secondary_freq(freq)
  update_secondary()

def read_imem(start_address, read_length):
  read_request = sequencer.ptp.requests.Read_Request_Frame(
    start_address = start_address,
    read_length   = read_length)
  reply_list = test_config.first_sequencer.send_frame(read_request)
  return reply_list[0].payload

def write_imem(start_address, write_data):
  write_request = sequencer.ptp.requests.Write_Request_Frame(
    start_address = start_address,
    write_data    = write_data)
  reply_list = test_config.first_sequencer.send_frame(write_request)
  return reply_list[0].payload

def send_i2c(slave_address, write_data):
  i2c_request = sequencer.ptp.requests.I2C_Request_Frame(
    slave_address = slave_address,
    read_length   = 0,
    write_data    = write_data)
  reply_list = test_config.first_sequencer.send_frame(i2c_request)
  return reply_list[0].payload

def broadcast_status():
  status_request = sequencer.ptp.requests.STATUS_REQUEST
  reply_list = test_config.all_sequencers.send_frame(status_request)
  return reply_list[0].payload

# Generic DDS functions that accept a device index
def dds_freq(freq, profile, device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_freq_events(abs(freq), profile)
  sequencer.current_sequence.add_event_list(event_list)

def dds_profile(profile, device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_profile_events(profile)
  sequencer.current_sequence.add_event_list(event_list)

def dds_phase(phase, profile, device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_phase_events(phase, profile)
  sequencer.current_sequence.add_event_list(event_list)

def dds_start_sweep(start_freq,delta_freq,profile,device,rate_word=100):
#  dds_freq(start_freq,profile,device)
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_sweep_events(delta_freq,rate_word)
  sequencer.current_sequence.add_event_list(event_list)

def dds_stop_sweep(device,profile=0):
#  dds_start_sweep(start_freq=0,delta_freq=0,profile=profile,device=device,rate_word=100)
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_sweep_stop_events()
  sequencer.current_sequence.add_event_list(event_list)

def dds_relative_phase(phase, profile, device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.create_relative_phase_events(phase, profile)
  sequencer.current_sequence.add_event_list(event_list)

def dds_unset_autoclr(device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.unset_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

def dds_set_autoclr(device):
  dds_device = test_config.dds_devices[device]
  event_list = dds_device.set_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

# Hard-coded DDS functions
def first_dds_freq(freq,dds_profile):
  event_list = test_config.first_dds_device.create_freq_events(abs(freq),dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def first_dds_profile(dds_profile):
  event_list=test_config.first_dds_device.create_profile_events(dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def first_dds_phase(phase,dds_profile):
  event_list = test_config.first_dds_device.create_phase_events(phase,dds_profile)
  sequencer.current_sequence.add_event_list(event_list)


def first_dds_relative_phase(phase,dds_profile):
  event_list = test_config.first_dds_device.create_relative_phase_events(phase,dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def first_dds_unset_autoclr():
  event_list = test_config.first_dds_device.unset_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

def first_dds_set_autoclr():
  event_list = test_config.first_dds_device.set_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_freq(freq,dds_profile):
  event_list = test_config.second_dds_device.create_freq_events(abs(freq),dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_profile(dds_profile):
  event_list=test_config.second_dds_device.create_profile_events(dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_phase(phase,dds_profile):
  event_list = test_config.second_dds_device.create_phase_events(phase,dds_profile)
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_unset_autoclr():
  event_list = test_config.second_dds_device.unset_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_set_autoclr():
  event_list = test_config.second_dds_device.set_autoclr()
  sequencer.current_sequence.add_event_list(event_list)

def update_all_dds():
  event_list = test_config.first_dds_device.update_register()
  sequencer.current_sequence.add_event_list(event_list)

# Just playing around with coherent phase switching --PS

from sequencer.pcp.events import Frequency
def coherent_create_freq(frequency,relative_phase):
  f=Frequency(frequency=abs(frequency), relative_phase=relative_phase)
  return f

def first_dds_init_frequency(frequency):
  event=test_config.first_dds_device.coherent_init_frequency(frequency)
  sequencer.current_sequence.add_event(event)

def first_dds_switch_frequency(frequency):
  event_list=test_config.first_dds_device.coherent_switch_frequency(frequency)
  sequencer.current_sequence.add_event_list(event_list)

def second_dds_init_frequency(frequency):
  event=test_config.second_dds_device.coherent_init_frequency(frequency)
  sequencer.current_sequence.add_event(event)

def second_dds_switch_frequency(frequency):
  event_list=test_config.second_dds_device.coherent_switch_frequency(frequency)
  sequencer.current_sequence.add_event_list(event_list)

#some math for pulse shapes: --PS

from math import *

def blackman(x):
  f=1/2*(0.84-cos(x*pi)+0.16*cos(2*x*pi))
  return f

def sine_shape(x):
  value=sin(x*pi/2)
  return value

def recalibrate_laser(x):
  a=-3.16
  b=0.00209
  c=0.00066612
  x_max=39.5
  y=log((x*x_max-a)/b*1/c)
  return y
