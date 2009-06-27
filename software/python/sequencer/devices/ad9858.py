# Module : ad9858
# Package: sequencer.dac
# Class definition for the Analog Devices 9858 evaluation board
# and its events.

from sequencer.util                    import *
from sequencer.devices.dds             import *
from sequencer.pcp.events.atomic_pulse import *
from sequencer.pcp.events.separable_pulse import *

#import the phase coherent events
from sequencer.pcp.events.init_frequency import InitFrequency_Event
from sequencer.pcp.events.switch_frequency import  SwitchFrequency_Event

from math import *
import copy # We need this to create the pulses for phase coherent switching  --PS

#==============================================================================
class AD9858(DDS_Device):
  "Class for the Analog Devices 9858 evaluation board."
  #----------------------------------------------------------------------------
  def create_freq_events(self, freq, dds_profile):
    setup_events = self.internal_get_setup_events()
    tuning_word = int(2**(self.parent.FREQUENCY_WIDTH) * freq / self.ref_freq)
    freq_events = self.create_value_events(
      reg_array = self.parent.mask_freq_tune[dds_profile],
      old_value = self.freq[dds_profile],
      new_value = tuning_word)
    self.freq[self.profile] = tuning_word
    # just use the setup events every time we are called this might be too simple --PS
    setup_events.extend(freq_events)
    return setup_events

  #----------------------------------------------------------------------------
  #writes phase information to the dds --PS
  #seems to work for now - needs some testing right now
  def create_phase_events(self, offset, profile):
    phase_word=int(offset*2**(self.parent.PHASE_WIDTH))

    debug_print("phase_word: "+hex(phase_word) + " length: "+hex(2**self.parent.PHASE_WIDTH),1)

    phase_events=self.create_value_events(self.parent.mask_phase_offset[profile],
                                          self.phase_offset[profile], phase_word)

    self.phase_offset[profile]=phase_word
    # just use the setup events every time we are called this might be too simple --PS
    setup_events = self.internal_get_setup_events()
    setup_events.extend(phase_events)
    return setup_events


  #----------------------------------------------------------------------------
  # creates a frequency sweep
  # The base frequency has to be set with a create_freq_event()

  def create_sweep_events(self, frequency_step, rate):
    RAMP_WIDTH=16
    tuning_word=int(2**(self.parent.FREQUENCY_WIDTH) * frequency_step / self.ref_freq)
    print "sweep_tuning word: "+str(tuning_word)
    print "sweep rate: "+str(rate)
    freq_ramp_word=int(rate)

    ftw_event=self.create_value_events(self.parent.mask_delt_freq_tune,
                                          self.sweep_word, tuning_word)

    dfrrw_event=self.create_value_events(self.parent.mask_delt_freq_ramp,
                                          self.freq_ramp, freq_ramp_word)
    #For those of you who are unaware of it: dfrrw stands for delta frequency ramp rate word
    sweep_timer_event= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_clear_accum ,
      bit_tuples       = [(self.parent. BIT_SWEEP_TIMER , 1)])

    sweep_on_event= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_config ,
      bit_tuples       = [(self.parent.BIT_SWEEP_ENABLE , 1)])

    autoclr_event= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_clear_accum ,
      bit_tuples       = [(self.parent.BIT_AUTO_CLEAR_FREQ_ACCUM , 0)])

    # just use the setup events every time we are called this might be too simple --PS
    setup_events = self.internal_get_setup_events()
    setup_events.extend(autoclr_event)
    setup_events.extend(sweep_on_event)
    setup_events.extend(sweep_timer_event)
    setup_events.extend(ftw_event)
    setup_events.extend(dfrrw_event)
#    setup_events.extend(dfrrw_event)

#    setup_events.extend(copy.copy(sweep_on_event))
    return setup_events

  def create_sweep_stop_events(self):
    sweep_off_event= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_config ,
      bit_tuples       = [(self.parent.BIT_SWEEP_ENABLE , 0)])
    freq_ramp_word=0
    autoclr_event= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_clear_accum ,
      bit_tuples       = [(self.parent.BIT_AUTO_CLEAR_FREQ_ACCUM , 1)])
 
    dfrrw_event=self.create_value_events(self.parent.mask_delt_freq_ramp,
                                          self.freq_ramp, freq_ramp_word)
    #For those of you who are unaware of it: dfrrw stands for delta frequency ramp rate word

    setup_events = self.internal_get_setup_events()
    setup_events.extend(sweep_off_event)
    setup_events.extend(autoclr_event)
    setup_events.extend(dfrrw_event)
    return setup_events


  #----------------------------------------------------------------------------
  #For writing a relative phase information we have to set and unset the Autoclr Phase register
  # --PS

  def unset_autoclr(self):
    event_list=[]
    set_accum_events= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_clear_accum ,
      bit_tuples       = [(self.parent.BIT_AUTO_CLEAR_PHASE_ACCUM , 0)])
    event_list.extend(set_accum_events)
    # just use the setup events every time we are called this might be too simple --PS
    setup_events = self.internal_get_setup_events()
    setup_events.extend(event_list)
    return setup_events

  def set_autoclr(self):
    event_list=[]
    set_accum_events= self.parent.create_tuple_write_events(
      reg_address_mask =  self.parent.mask_clear_accum ,
      bit_tuples       = [(self.parent.BIT_AUTO_CLEAR_PHASE_ACCUM , 1)])
    event_list.extend(set_accum_events)
    setup_events = self.internal_get_setup_events()
    setup_events.extend(event_list)
    return setup_events


  #----------------------------------------------------------------------------
  # got a working version for the profile update event --PS
  # This should go at least partially to dds_factory.py
  # Ps1 and PS2 aer switched

  def create_profile_events(self,dds_profile):
    HARDWARE_OUTPUT_WIDTH=64 #this stands in the constants file
    profile_events = []
    # Do a hack to turn around the ps0 ps1 issue --PS
    fake_profile=[0,2,1,3]
    real_dds_profile=fake_profile[dds_profile]

    if (dds_profile != self.profile):
      debug_print("creating profile_event",1)
      o = OutputMask(HARDWARE_OUTPUT_WIDTH, self.profile_bits, real_dds_profile)
      profile_events.append(AtomicPulse_Event(o))
#      profile_events.append(AtomicPulse_Event(o, self.min_duration))
      self.profile = dds_profile


      not_psen_event = AtomicPulse_Event(
        output_mask = copy.copy(self.parent.not_psen_outmask),
        is_min_duration = True)
      profile_events.append(not_psen_event)

      psen_event = AtomicPulse_Event(
        output_mask = copy.copy(self.parent.psen_outmask),
        is_min_duration = True)
      profile_events.append(psen_event)
    else:
      # we need a longer pulse if we use more than 1 dds --PS
      update_event = AtomicPulse_Event(
        output_mask = copy.copy(self.parent.update_outmask),
        is_min_duration = True)
      #  profile_events.append(update_event)

      update_event2 = AtomicPulse_Event(
        output_mask = copy.copy(self.parent.update_outmask),
        duration = 1)

      not_update_event2 = AtomicPulse_Event(
        output_mask = copy.copy(self.parent.not_update_outmask),
        is_min_duration = True)
      #  profile_events.append(not_update_event2)

      sep_update_event = SeparablePulse_Event(
        pulse_events = [update_event]
        )

      sep_update_event2 = SeparablePulse_Event(
        pulse_events = [update_event2]
        )

      sep_not_update_event = SeparablePulse_Event(
        pulse_events = [not_update_event2]
        )
      profile_events=[sep_update_event,sep_update_event2,sep_not_update_event]

    # just use the setup events every time we are called this might be too simple --PS
    setup_events = self.internal_get_setup_events()
    if (setup_events==[]):
      setup_events=profile_events
    else:
      setup_events=setup_events + profile_events

    return setup_events

  def update_register(self):
    update_event = AtomicPulse_Event(
      output_mask = copy.copy(self.parent.update_outmask),
      duration = 3)


    not_update_event = AtomicPulse_Event(
      output_mask = copy.copy(self.parent.not_update_outmask),
      is_min_duration = True)
    return_events=[update_event,not_update_event]
    return return_events

  #Functions for phase coherent switching --PS
  def coherent_init_frequency(self,frequency):
    # set the phase width
    phase_width=self.parent.PHASE_WIDTH
    # use the ref clock of the dds
    ref_freq=self.ref_freq
    event=InitFrequency_Event(frequency,ref_freq,phase_width)
    return event

  def coherent_switch_frequency(self,frequency):

    #For now we use the frequency's relative phase as phase offset
    phase_offset=frequency.get_relative_phase()
#    print "device phase: "+str(phase_offset)
    #Generate the mask list:
    # the update has to be generated seperatly by now.

    #get the code from dds_factory.py
    # and insert always a copy of the bitmasks
    not_write_mask = copy.copy(self.parent.not_write_outmask)
    write_mask = copy.copy(self.parent.write_outmask)

    #we also need masks for the phase address
    profile=0
    address_mask_1 = copy.copy(self.parent.mask_phase_offset[profile])

    #generate the final mask list
    #
    #get the mask listst for the high and low address with the write events.
    #We're gonna go brute force and just merge them
    #Maybe the addresses should be generated with seperate atomic pulses?
    # this is processed in pcp32.py

    write_mask_list=[write_mask,not_write_mask]
    address_mask_list=address_mask_1

    # Get the all magic switch frequency event
    event=SwitchFrequency_Event(frequency,write_mask_list,address_mask_list,phase_offset)

    setup_events = self.internal_get_setup_events()
    setup_events.extend([event])
    return setup_events

  #----------------------------------------------------------------------------
  def __init__(self,
               parent,
               chain_address,
               ref_freq):
    DDS_Device.__init__(
      self,
      parent = parent,
      chain_address = chain_address,
      ref_freq = ref_freq)
    self.profile = 0x00                  # Current profile
    self.freq = [0x00, 0x00, 0x00, 0x00] # Initially zero for all profiles
    self.phase_offset = [0x00, 0x00, 0x00, 0x00] # zero also the phase offsets
    # this is just borrowed from the tests file:
    # I think this should come from the test_config_init file or something like that --PS
    self.profile_bits=(49,50) #got the profile bits right
    self.ref_freq=ref_freq
    self.freq_ramp=0
    self.sweep_word=0
#==============================================================================
