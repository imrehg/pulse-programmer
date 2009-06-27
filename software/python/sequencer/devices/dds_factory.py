# Module : dds_factory
# Package: sequencer.devices
# Abstract factory class for DDS devices.

from sequencer.util                       import *
from sequencer.pcp.output_mask            import *
from sequencer.pcp.events.atomic_pulse    import *
from sequencer.pcp.events.separable_pulse import *
from sequencer.devices.device_factory     import Device_Factory
from sequencer.devices.dds                import DDS_Device
import copy

###############################################################################
# Initialisation code for sub-modules
  
class DDS_Factory(Device_Factory):
  #----------------------------------------------------------------------------
  REGISTER_WIDTH     = 8
  MIN_REF_FREQ       = 300
  MAX_REF_FREQ       = 300
#  PROFILE_COUNT      = 4
  #----------------------------------------------------------------------------
  def create_address_mask(self, address_value):
    return OutputMask(mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
                      bit_tuples = [(self.ADDRESS_MASK, address_value)])
  #----------------------------------------------------------------------------
  def __init__(self,
               chain_address_mask, # Chain address mask
               power_mask        , # Power bitmask
               min_ref_freq      , # Minimum reference frequency in MHz
               max_ref_freq      , # Maximum reference frequency in MHz
               reset_mask        , # Bit mask for reset
               spmode_mask       , # Bit mask for programming mode
               wrb_mask          , # Bit mask for write strobe
               rdb_mask          , # Bit mask for read strobe
               update_mask       , # Bit mask for updating
               psen_mask         , # Bit mask for profile select enable
               address_mask      , # Bit mask for register address
               data_mask         , # Bit mask for register data
               profile_mask      , # Bit mask for profile select bits
               register_width    , # Subdivision width of a data register
               frequency_width   , # Width of frequency tuning word in bits
               phase_width       , # Width of phase tuning word in bits
               dac_width         , # Width of DAC in bits
               **other_bitmasks
               ):
    output_mask_list = [reset_mask  ,
                        spmode_mask,
                        wrb_mask    ,
                        rdb_mask    ,
                        update_mask ,
                        psen_mask   ,
                        profile_mask,
                        address_mask,
                        data_mask]
    output_mask_list.extend(other_bitmasks.values())
    Device_Factory.__init__(self,
                            chain_address_mask = chain_address_mask,
                            power_mask      = power_mask,
                            output_masks    = output_mask_list)

    if (max_ref_freq < min_ref_freq):
      raise RangeError("Max ref frequency cannot be less than min ref freq.",
                       min_ref_freq, max_ref_freq, 0)

    self.MIN_REF_FREQ    = min_ref_freq
    self.MAX_REF_FREQ    = max_ref_freq
    self.RESET_MASK      = reset_mask
    self.SPMODE_MASK     = spmode_mask
    self.WRITE_MASK      = wrb_mask
    self.READ_MASK       = rdb_mask
    self.UPDATE_MASK     = update_mask
    self.PSEN_MASK       = psen_mask
    self.PROFILE_MASK    = profile_mask
    self.ADDRESS_MASK    = address_mask
    self.DATA_MASK       = data_mask
    self.REGISTER_WIDTH  = register_width
    self.FREQUENCY_WIDTH = frequency_width
    self.PHASE_WIDTH     = phase_width
    self.DAC_WIDTH       = dac_width
#    self.PROFILE_COUNT  = profile_count
    # Create instance masks.
    print reset_mask
    if (reset_mask != None):
      self.reset_outmask = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(reset_mask, 1)])
      self.not_reset_outmask  = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(reset_mask, 0)])
      
    # DDS chain should always be powered on, never reads, is always in parallel
    # programming mode, and initially doesn't write (negative true).
#    self.init_mask       = OutputMask(
#      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
#      bit_tuples = [(power_mask  , 1),
#                    (rdb_mask    , 1),
#                    (wrb_mask    , 1),
#                    (profile_mask, 0),
#                    (update_mask , 0),
#                    (sp_mode_mask, 1)])
    # Create mask for updating written values into registers.
    self.update_outmask     = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(update_mask , 1)])
    self.write_outmask = OutputMask (
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(wrb_mask    , 0)])
    self.not_update_outmask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(update_mask , 0)])
    self.not_write_outmask = OutputMask (
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(wrb_mask    , 1)])

    #create mask for sending the frequency register PSEN --PS
    # we need this for profile switching see ad9858.py for details
    self.psen_outmask     = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(psen_mask , 1)])
    self.not_psen_outmask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(psen_mask , 0)])

    self.clear_outmask = self.not_update_outmask.merge(self.not_write_outmask)
    self.update_write_outmask = self.update_outmask.merge(self.write_outmask)
    

    # Create address output masks for control registers
    self.create_register_masks()
  #----------------------------------------------------------------------------
  def create_reset_events(self):
    reset_event_list = []
    # Add the daisy-chain power-on event if applicable
    if (self.POWER_MASK != None):
      power_outmask = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(self.POWER_MASK, 1)])
      power_event = AtomicPulse_Event(
        output_mask     = copy.copy(power_outmask),
        is_min_duration = True)
      reset_event_list.append(power_event)

    # Add the programming mode event if applicable
    if (self.SPMODE_MASK != None):
      spmode_outmask = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(self.SPMODE_MASK, 1)])
      spmode_event = AtomicPulse_Event(
        output_mask     = copy.copy(spmode_outmask),
        is_min_duration = True)
      reset_event_list.append(spmode_event)

    # Add the rdb event
    if (self.READ_MASK != None):
      rdb_outmask = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(self.READ_MASK, 1)])
      rdb_event   = AtomicPulse_Event(
        output_mask     = copy.copy(rdb_outmask),
        is_min_duration = True)
      reset_event_list.append(rdb_event)

    # Add the wrb event
    wrb_event   = AtomicPulse_Event(
      output_mask     = copy.copy(self.not_write_outmask),
      is_min_duration = True)
    reset_event_list.append(wrb_event)
    
#    profile_zero_outmask = OutputMask(
#      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
#      bit_tuples = [(self.PROFILE_MASK, 0x00)])
#    profile_zero event = AtomicPulse_Event(
#      output_mask = profile_zero_outmask,
#      is_min_duration = True)

    # Add the not update event
    update_event = AtomicPulse_Event(
      output_mask = copy.copy(self.not_update_outmask),
      is_min_duration = True)
    reset_event_list.append(update_event)

    reset_event = SeparablePulse_Event(reset_event_list)

    return [reset_event]
  #----------------------------------------------------------------------------
  def create_write_events(self, reg_address_mask, reg_value):
    data_outmask = OutputMask(mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
                              bit_tuples = [(self.DATA_MASK, reg_value)])
    data_outmask = data_outmask.merge(reg_address_mask)
    not_update_event = AtomicPulse_Event(
      output_mask = copy.copy(self.not_update_outmask),
      is_min_duration = True)
    not_write_event = AtomicPulse_Event(
      output_mask = copy.copy(self.not_write_outmask),
      is_min_duration = True)
    data_event    = AtomicPulse_Event(
      output_mask = data_outmask,
      duration=0x3)
#      is_min_duration = True)
    update_event = AtomicPulse_Event(
      output_mask = copy.copy(self.update_outmask),
      is_min_duration = True)
    write_event = AtomicPulse_Event(
      output_mask = copy.copy(self.write_outmask),
      is_min_duration = True)

    setup_event = SeparablePulse_Event(
      pulse_events = [not_write_event]
      )

    data_event = SeparablePulse_Event(
      pulse_events = [data_event]
      )
    hold_event = SeparablePulse_Event(
      pulse_events = [write_event]
      )
    # the write cycle goes as follows:
    # write_the data, set the write bit, unset the write bit
    # I don't think we still need separable pulses here. --PS
    return [data_event, hold_event,setup_event]
  #----------------------------------------------------------------------------
  
  def create_tuple_write_events(self, reg_address_mask, bit_tuples):
    # This version of the method handles flags in the bit_tuples and is useful
    # for infrequent or one-time configuration
    reg_value = 0x00
    for (bitmask, bit_value) in bit_tuples:
      reg_value |= bitmask.get_shifted_value(bit_value)
    return self.create_write_events(reg_address_mask, reg_value)
  #----------------------------------------------------------------------------
  def create_value_events(self, reg_array, old_value, new_value):
    value_events = []
    difference   = old_value ^ new_value
    # We don't write on the first event b/c of setup times.
    first        = True
#    aux_mask     = None
    last_index   = -1
    diff_map     = {}
    for i in range(len(reg_array)):
#      if (((old_value ^ new_value) >> (self.REGISTER_WIDTH*i)) & 0xFF):
    # Create an event for every register, to make timing uniform
      diff = (new_value >> (self.REGISTER_WIDTH*i)) & 0xFF
      diff_map[i] = diff
      last_index = i

    for (index, diff) in diff_map.iteritems():
#      if (first):
#        first = False
#        setup_duration = self.min_duration
#      else:
#        setup_duration = self.min_duration
        
#      if (index == last_index):
#        aux_mask = self.update_outmask
#      else:
#        aux_mask = None #self.not_update_mask

      event_list = self.create_write_events(
        reg_address_mask = reg_array[index],
        reg_value        = diff)
      value_events.extend(event_list)
#        last_event = event_list[len(event_list)-1]
#        print("valev: " + hex(i) + " " + hex(diff))
#        o = OutputMask(HARDWARE_OUTPUT_WIDTH, self.data_bits, diff)
#        e = AtomicPulse_Event(reg_array[i].merge(o), self.min_duration)
#        value_events.append(e)

    # The last write in a series should update simultaneously with write.
    # KLUDGE: We shouldn't be editing the event's output_mask directly here.
    # There must be a better way.
#    last_event.output_mask = last_event.output_mask.merge(self.update_mask)

    return value_events
  #----------------------------------------------------------------------------
  def create_register_masks(self):
    # Stub function for testing
    pass
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address, ref_freq):
    return DDS_Device(parent = self, chain_address = chain_address,
                      ref_freq = ref_freq)
