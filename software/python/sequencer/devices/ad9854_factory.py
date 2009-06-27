# Module : ad9858_factory
# Package: sequencer.devices
# Class definition for the Analog Devices 9858 evaluation board factory.

#from sequencer import *
from sequencer.util                    import *
from sequencer.devices                 import *
from sequencer.pcp.events.atomic_pulse import *
from sequencer.devices.dds_factory     import *
from sequencer.devices.dac_factory     import *
from sequencer.devices.ad9854          import *

#==============================================================================
class AD9854_Factory(DDS_Factory, DAC_Factory):
  """
  Class for the Analog Devices 9854 DDS evaluation board, specifically its
  DAC functionality in driving the AD8367 variable gain amplifier.
  """
  #----------------------------------------------------------------------------
  # Control register addresses
  REG_PHASE_ADJUST_ONE = (0x01, 0x00)
  REG_PHASE_ADJUST_TWO = (0x03, 0x02)

  REG_FREQ_TUNE_ONE = (
    0x09, # [0] 7:0
    0x08, # [1] 15:8
    0x07, # [2] 23:16
    0x06, # [3] 31:24
    0x05, # [4] 39:32
    0x04  # [5] 47:40
    )
  REG_FREQ_TUNE_TWO = (
    0x0F, # [0] 7:0
    0x0E, # [1] 15:8
    0x0D, # [2] 23:16
    0x0C, # [3] 31:24
    0x0B, # [4] 39:32
    0x0A  # [5] 47:40
    )
  REG_DELT_FREQ = (
    0x15, # [0] 7:0
    0x14, # [1] 15:8
    0x13, # [2] 23:16
    0x12, # [3] 31:24
    0x11, # [4] 39:32
    0x10  # [5] 47:40
    )
  REG_POWER_DOWN = 0x1D
  REG_REF_MULT   = 0x1E
  REG_MODE       = 0x1F
  REG_OSK        = 0x20
  REG_OUTPUT_SHAPE_I = (
    0x22, # [0] 7:0
    0x21  # [1] 11:8
    )
  REG_OUTPUT_SHAPE_Q = (
    0x22, # [0] 7:0
    0x21  # [1] 11:8
    )
  REG_QDAC = (
    0x27, # [0] 7:0
    0x26  # [1] 11:8
    )
  # Bit index values within control registers
  # Bits in REG_POWER_DOWN
  BITS_COMP_PD     = 4
  # Bits in REG_MODE
  BITS_MODE        = [1, 2, 3]
  BITS_UPDATE_CLK  = 0
  BITS_SRC_QDAC    = 4
  BITS_TRIANGLE    = 5
  BITS_CLEAR_ACC_1 = 7
  BITS_CLEAR_ACC_2 = 6
  # Bits in REG_REF_MULT
  BITS_PLL_RANGE   = 6
  BITS_PLL_BYPASS  = 5
  BITS_REF_MULT    = [0, 1, 2, 3, 4]
  REF_MULTIPLIER_WIDTH = 5 # bits
  # Bits in REG_OSK
  BITS_OSK_EN      = 5
  BITS_OSK_INT     = 4

  ## AD8367 variable gain amplifier parameters.
  # Minimum gain in dB
  MINIMUM_GAIN_DB  = -2.5
  # Maximum gain in dB
  MAXIMUM_GAIN_DB  = 42.5
  # Total gain range in dB
  GAIN_RANGE_DB    = MAXIMUM_GAIN_DB - MINIMUM_GAIN_DB
  # Minimum dac output level in mV corresponding to MINIMUM_GAIN_DB
  MINIMUM_LEVEL_MV = 50
  # Maximum DAC output level in mV corresponding to MAXIMUM_GAIN_DB
  MAXIMUM_LEVEL_MV = 950
  # Total level range in mV
  LEVEL_RANGE_MV   = MAXIMUM_LEVEL_MV - MINIMUM_LEVEL_MV
  # Derive mv/dB gain control for AD8367
  MV_PER_DB        = LEVEL_RANGE_MV / GAIN_RANGE_DB

  # AD9854 DDS parameters
  MAX_FREQ = 300 # Megahertz
  MAX_REF_FREQ = 300
  MIN_REF_FREQ = 0
  MAX_REF_MULTIPLIER = 20
  MIN_REF_MULTIPLIER  = 4
  #----------------------------------------------------------------------------
  def create_register_masks(self):
    # Control register addresses
    self.mask_phase_adjust_one = [self.create_address_mask(x)
                                  for x in self.REG_PHASE_ADJUST_ONE]
    self.mask_phase_adjust_two = [self.create_address_mask(x)
                                  for x in self.REG_PHASE_ADJUST_TWO]
    self.mask_freq_tune_one    = [self.create_address_mask(x)
                                  for x in self.REG_FREQ_TUNE_ONE]
    self.mask_freq_tune_two    = [self.create_address_mask(x)
                                  for x in self.REG_FREQ_TUNE_TWO]
    self.mask_delt_freq        = [self.create_address_mask(x)
                                  for x in self.REG_DELT_FREQ]
    self.mask_power_down       = self.create_address_mask(self.REG_POWER_DOWN)
    self.mask_ref_mult         = self.create_address_mask(self.REG_REF_MULT)
    self.mask_mode             = self.create_address_mask(self.REG_MODE)
    self.mask_osk              = self.create_address_mask(self.REG_OSK)
    self.mask_output_shape_i   = [self.create_address_mask(x)
                                  for x in self.REG_OUTPUT_SHAPE_I]
    self.mask_output_shape_q   = [self.create_address_mask(x)
                                  for x in self.REG_OUTPUT_SHAPE_Q]
    self.mask_qdac             = [self.create_address_mask(x)
                                  for x in self.REG_QDAC]
  #----------------------------------------------------------------------------
  def create_reset_events(self):
    reset_events = []
    # Generate reset and static setting events
    # Hold for at least ten clock cycles (64 here to be safe)
#    reset_events.append(AtomicPulse_Event(self.reset_mask, 0x40))
    # Deassert reset here
#    reset_events.append(AtomicPulse_Event(self.not_reset_mask,
#                                          self.min_duration))
#    reset_events.append(AtomicPulse_Event(self.init_mask, self.min_duration))
#    reset_events.append(AtomicPulse_Event(self.init_mask2, self.min_duration))
    # Create event to power-up the comparator for clock generation.
#    comp_events  = self.create_write_events_2(self.mask_power_down,
#                                              [(self.BITS_COMP_PD, 0)],
#                                              self.min_duration)
    # Create events for changing reference clock multiplier to maximum
    # for fast updating.
#    mult_events  = self.create_ref_mult_events(6)
    # Create event to set external update clock and take QDAC externally
    # Must hold this value for the default update clock interval
#    dac_events   = self.create_write_events_2(self.mask_mode,
#                                              [(self.BITS_SRC_QDAC  , 1),
#                                               (self.BITS_UPDATE_CLK, 0)],
#                                              0xF0)
    # Create event to disable on-shape keying, enable full-scale outputs,
    # and make amplitudes controllable from internal registers.
#    shape_events = self.create_write_events_2(self.mask_osk,
#                                              [(self.BITS_OSK_EN, 0),
#                                               (self.BITS_OSK_INT, 0)],
#                                              self.min_duration)
                                              
#    reset_events.extend(dac_events)
#    reset_events.extend(comp_events)
#    reset_events.extend(self.create_after_update_events())
#    reset_events.extend(mult_events)
#    reset_events.extend(self.create_after_update_events())
#    reset_events.extend(shape_events)
#    reset_events.extend(self.create_after_update_events())
    return reset_events
  #----------------------------------------------------------------------------
  def __init__(self,
               chain_address_mask,
               power_mask,
               reset_mask,
               spmode_mask,
               osk_mask,
               wrb_mask,
               rdb_mask,
               update_mask,
               address_mask,
               data_mask):
    # Init DAC_Factory parent first so that DDS stomps on data and update masks
    self.DAC_DATA_MASK = Bitmask(label = "AD9854 DAC Data Mask",
                                 width = 12,
                                 shift = 0)
    DAC_Factory.__init__(
      self,
      min_level_mv       = 0   , # mV
      max_level_mv       = 1000, # mV
      chain_address_mask = chain_address_mask,
      update_mask        = None,
      data_mask          = self.DAC_DATA_MASK)
    DDS_Factory.__init__(
      self,
      chain_address_mask = chain_address_mask,
      power_mask         = power_mask,
      min_ref_freq       = 20, # 20 MHz
      max_ref_freq       = 300, # 300 MHz
      reset_mask         = reset_mask,
      spmode_mask        = spmode_mask,
      wrb_mask           = wrb_mask,
      rdb_mask           = rdb_mask,
      update_mask        = update_mask,
      psen_mask          = None,
      address_mask       = address_mask,
      data_mask          = data_mask,
      profile_mask       = None,
      register_width     = 8,
      frequency_width    = 48,
      phase_width        = 14,
      dac_width          = 12,
      osk_mask           = osk_mask)
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address, ref_freq):
    return AD9854_Device(parent        = self,
                         chain_address = chain_address,
                         ref_freq      = ref_freq)
  #----------------------------------------------------------------------------
  def 
