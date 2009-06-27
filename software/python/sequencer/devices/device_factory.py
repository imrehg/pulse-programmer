# Module : device_factory
# Package: devices

import copy
from sequencer.pcp                     import *
from sequencer.devices.device          import *
from sequencer.pcp.events.atomic_pulse import *

###############################################################################
  
class Device_Factory:
  """
  Abstract parent class for device factories, which are also multiplexers
  for a daisy chain.
  """
  SETUP_DURATION = 0x0 # Number of cycles to setup chain address before
                       # the select signal propagates.
  #----------------------------------------------------------------------------
  def __init__(self,
               output_masks,
               chain_address_mask = None,
               power_mask         = None,
               mask_list          = []):
    """
    Device_Factory(chain_address_mask):
      chain_address_mask    - Bitmask for chain address bits. Defaults to None.
      output_bitmasks       - list of Bitmasks that give valid output range of
                              devices produced by this factory.
    """
    self.OUTPUT_MASKS = output_masks
    self.POWER_MASK   = power_mask
    self.MASK_LIST    = list(mask_list)
    self.MASK_LIST.extend(output_masks)

    if (power_mask != None):
      self.MASK_LIST.append(power_mask)
    if (chain_address_mask == None):
      # Create singleton attribute
      self.singleton = None
    else:
      self.MASK_LIST.append(chain_address_mask)
      check_masks(self.MASK_LIST, sequencer.TOTAL_OUTPUT_WIDTH)
      check_overlap(self.MASK_LIST)

    self.CHAIN_ADDRESS_MASK = chain_address_mask
    if (self.is_chainable()):
      self.ZERO_MASK = OutputMask(mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
                                  bit_tuples = [(self.CHAIN_ADDRESS_MASK,
                                                 0x0)])
    self.reset()
  #----------------------------------------------------------------------------
  def reset(self):
    self.device_map = {}
    self.current_device = None
  #----------------------------------------------------------------------------
  def create_reset_events(self):
    reset_mask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(bitmask, 0x00) for bitmask in self.OUTPUT_MASKS])
    if (self.POWER_MASK != None):
      power_mask = OutputMask(
        mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
        bit_tuples = [(self.POWER_MASK, 1)])
      reset_mask = reset_mask.merge(power_mask)
    reset_event = AtomicPulse_Event(output_mask     = copy.copy(reset_mask),
                                    is_min_duration = True)
    return [reset_event]
  #----------------------------------------------------------------------------
  def create_device(self, chain_address = 0, **key_args):
    # If this device is chainable, Create singleton if it doesn't already exist
    if (not self.is_chainable()):
      if (self.singleton == None):
        self.singleton = self.internal_create_device(chain_address = 0,
                                                     **key_args)
      return self.singleton
    # Otherwise it is chainable
    check_inputs([(chain_address, self.CHAIN_ADDRESS_MASK)])
    if (chain_address in self.device_map.keys()):
      raise RuntimeError("Chain address " + hex(chain_address) + \
                         " already exists in this manager.")
    new_device = self.internal_create_device(chain_address = chain_address,
                                             **key_args)
    self.device_map[chain_address] = new_device
    return new_device
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address, *other_args):
    return Device(parent = self, chain_address = chain_address, *other_args)
  #----------------------------------------------------------------------------
  def create_setup_events(self, device):
    if (not self.is_chainable()):
      return []

    event_list = []
    if (device != self.current_device):
      chain_address_mask = None
      
      if (device == None):
        chain_address_mask = copy.copy(self.ZERO_MASK)
      else:
        if (device.chain_address not in self.device_map.keys()):
          raise RuntimeError("Chain address " + str(device.chain_address) + \
                             " does not exist in this manager.")
        chain_address_mask = copy.copy(device.chain_address_mask)
        
      setup_event = AtomicPulse_Event(
        output_mask = chain_address_mask,
        duration    = self.SETUP_DURATION)
      event_list.append(setup_event)
      self.current_device = device
    return event_list
  #----------------------------------------------------------------------------
  def is_chainable(self):
    return (self.CHAIN_ADDRESS_MASK != None)
