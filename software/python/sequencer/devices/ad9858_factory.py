# Module : ad9858_factory
# Package: sequencer.devices
# Class definition for the Analog Devices 9858 evaluation board factory.

#from sequencer import *
from sequencer.util                    import *
from sequencer.devices                 import *
from sequencer.pcp.events.atomic_pulse import *
from sequencer.devices.dds_factory     import *
from sequencer.devices.ad9858          import AD9858

#==============================================================================
class AD9858_Factory(DDS_Factory):
  "Class for the Analog Devices 9858 evaluation board."

  #----------------------------------------------------------------------------
  # Control register addresses
  REG_POWER_DOWN  = 0x00
  REG_CONFIG      = 0x01
  REG_CLEAR_ACCUM = 0x02
  REG_CHARGE_PUMP = 0x03
  
  REG_DELT_FREQ_TUNE = (
    0x04, # [0] 7:0
    0x05, # [1] 15:8
    0x06, # [2] 23:16
    0x07  # [3] 31:24
    )
  REG_DELT_FREQ_RAMP = (
    0x08, # [0] 7:0
    0x09  # [1] 15:8
    )
  REG_FREQ_TUNE = (
    ( # Profile 0
    0x0A, # [0] 7:0
    0x0B, # [1] 15:8
    0x0C, # [2] 23:16
    0x0D  # [3] 31:24
    ),
    ( # Profile 1
    0x10, # [0] 7:0
    0x11, # [1] 15:8
    0x12, # [2] 23:16
    0x13  # [3] 31:24
    ),
    ( # Profile 2
    0x16, # [0] 7:0
    0x17, # [1] 15:8
    0x18, # [2] 23:16
    0x19  # [3] 31:24
    ),
    ( # Profile 3
    0x1C, # [0] 7:0
    0x1D, # [1] 15:8
    0x1E, # [2] 23:16
    0x1F  # [3] 31:24
    )
    )
    
  REG_PHASE_OFFSET = (
    ( # Profile 0
    0x0E, # [0] 7:0
    0x0F  # [1] 13:8
    ),
    ( # Profile 1
    0x14, # [0] 7:0
    0x15  # [1] 13:8
    ),
    ( # Profile 2
    0x1A, # [0] 7:0
    0x1B  # [1] 13:8
    ),
    ( # Profile 3
    0x20, # [0] 7:0
    0x21  # [1] 13:8
    )
    )

  # Control bits in REG_POWER_DOWN
  BIT_CLK_DIV_DIS     = Bitmask(label = "AD9858 Clock Divider Disable",
                                width = 1,
                                shift = 6)
  BIT_MIXER_PD        = Bitmask(label = "AD9858 Power-Down Mixer",
                                width = 1,
                                shift = 4)
  BIT_PHASE_DETECT_PD = Bitmask(label = "AD9858 Phase Detector Power-down",
                                width = 1,
                                shift = 3)

 #Control Bit for the clear phase accumulation --PS
  BIT_AUTO_CLEAR_PHASE_ACCUM   =  Bitmask(label = "AD9858 auto clear phase accumulation",
                                width = 1,
                                shift = 6)
  BIT_AUTO_CLEAR_FREQ_ACCUM   =  Bitmask(label = "AD9858 auto clear frequency accumulation",
                                width = 1,
                                shift = 7)

  BIT_SWEEP_ENABLE        = Bitmask(label = "AD9858 sweep enable",
                                width = 1,
                                shift = 7)


  BIT_SWEEP_TIMER        = Bitmask(label = "AD9858 load delta freq timer",
                                width = 1,
                                shift = 5)

  #----------------------------------------------------------------------------
  def create_register_masks(self):
    # Control register addresses
    self.mask_power_down       = self.create_address_mask(self.REG_POWER_DOWN)
    self.mask_config           = self.create_address_mask(self.REG_CONFIG)
    self.mask_clear_accum      = self.create_address_mask(self.REG_CLEAR_ACCUM)
    self.mask_charge_pump      = self.create_address_mask(self.REG_CHARGE_PUMP)
    self.mask_delt_freq_tune   = [self.create_address_mask(x)
                                  for x in self.REG_DELT_FREQ_TUNE]
    self.mask_delt_freq_ramp   = [self.create_address_mask(x)
                                  for x in self.REG_DELT_FREQ_RAMP]
    self.mask_freq_tune      = [[self.create_address_mask(x)
                                 for x in y] for y in self.REG_FREQ_TUNE]
    self.mask_phase_offset   = [[self.create_address_mask(x)
                                  for x in y] for y in self.REG_PHASE_OFFSET]
  #----------------------------------------------------------------------------
  def create_reset_events(self):
    event_list = DDS_Factory.create_reset_events(self)
    # Disable the clock-by-two divider and power-down mixer/phase detector
    # for each device created by this factory.
    for device in self.device_map.values():
      event_list.extend(self.create_setup_events(device))
      clock_events = self.create_tuple_write_events(
        reg_address_mask = self.mask_power_down,
        bit_tuples       = [(self.BIT_CLK_DIV_DIS    , 1),
                            (self.BIT_MIXER_PD       , 1),
                            (self.BIT_PHASE_DETECT_PD, 1)])
      event_list.extend(clock_events)
      #insert the phase autoclear setup events --PS
      accum_events= self.create_tuple_write_events(
        reg_address_mask =  self.mask_clear_accum ,
        bit_tuples       = [(self.BIT_AUTO_CLEAR_PHASE_ACCUM , 1),
                            (self.BIT_AUTO_CLEAR_FREQ_ACCUM , 1),
                            (self.BIT_SWEEP_TIMER , 1)])
      event_list.extend(accum_events)
      sweep_events=self.create_tuple_write_events(
        reg_address_mask =self.mask_config ,
        bit_tuples       = [(self.BIT_SWEEP_ENABLE , 0)])
      event_list.extend(sweep_events)
      not_update_event = AtomicPulse_Event(
        output_mask = copy.copy(self.not_update_outmask),
        is_min_duration = True)
      not_write_event = AtomicPulse_Event(
        output_mask = copy.copy(self.not_write_outmask),
        is_min_duration = True)
      not_reset_event = SeparablePulse_Event(
        pulse_events = [not_update_event, not_write_event]
        )
      event_list.append(not_reset_event)
    return event_list
  #----------------------------------------------------------------------------
  def create_freq_events(self, freq, profile):
    freq_events = self.create_value_events(self.mask_freq_tune[profile],
                                           self.freq[profile], freq)
    self.freq[profile] = freq
    return freq_events
  #----------------------------------------------------------------------------
  def create_profile_events(self, profile):
    profile_events = []
    if (profile != self.profile):
      o = OutputMask(HARDWARE_OUTPUT_WIDTH, self.profile_bits, profile)
      profile_events.append(AtomicPulse_Event(o, self.min_duration))
      self.profile = profile
    return profile_events
  #----------------------------------------------------------------------------
  def __init__(self,
               chain_address_mask,
               power_mask,
               reset_mask,
               spmode_mask,
               wrb_mask,
               rdb_mask,
               update_mask,
               psen_mask,
               address_mask,
               data_mask,
               profile_mask):
    DDS_Factory.__init__(
      self,
      chain_address_mask = chain_address_mask,
      power_mask         = power_mask,
      min_ref_freq       = 200, # 1000 MHz = 1 GHz
      max_ref_freq       = 1200, # 1000 MHz = 1 GHz
      reset_mask         = reset_mask,
      spmode_mask        = spmode_mask,
      wrb_mask           = wrb_mask,
      rdb_mask           = rdb_mask,
      update_mask        = update_mask,
      psen_mask          = psen_mask,
      address_mask       = address_mask,
      data_mask          = data_mask,
      profile_mask       = profile_mask,
      register_width     = 8,
      frequency_width    = 32,
      phase_width        = 14,
      dac_width          = 10)


  #----------------------------------------------------------------------------
  # just trying to add some create device so we don't get a generic dds device --PS
  def internal_create_device(self, chain_address, ref_freq):
    return AD9858(parent        = self,
                  chain_address = chain_address,
                  ref_freq      = ref_freq)
  #----------------------------------------------------------------------------
