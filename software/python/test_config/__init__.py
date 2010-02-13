# Import function API
from sequencer.api                    import *
from test_config.api                  import * # Box config overrides distrib
from test_config.user_function        import *
from test_config.pulses               import * # get the pulse shapes
from test_config.main_program         import *
from sequencer.devices.ad9744_factory import *
from sequencer.devices.ad9858_factory import *
from sequencer.pcp.bitmask            import *
from sequencer.firmware               import *
import sequencer.ptp.devices
from test_config.device1              import *


ref_freq   = 800 # in MHz, so 1000 = 1 GHz
cycle_time = (1e3 / ref_freq) * 8 # in ns, AD9858 sync clock is divide-by-8
debug_print("Cycle Time: " + str(cycle_time), 1)

# Test setup runs firmware version 0.21
sequencer.set_site_params(version      = (0, 21),
                          ref_freq     = ref_freq,
                          chain_length = 2)

# Create a list of device factories, which pulse sequences will know to
# reset when they enter a loop body for subroutine definition.
device_factory_list = []

# Create sequencer devices, two in a chain at the same IP address.

first_sequencer = sequencer.ptp.devices.Device(
  id               = sequencer.ptp.constants.CHAIN_INITIATOR_ID,
  client_socket    = sequencer.ptp.client_socket,
  frame_size_limit = sequencer.firmware.current_params.frame_size_limit,
  machine          = sequencer.firmware.current_params.pcp_machine_class(),
  mac_byte         = 0x09
  )

second_sequencer = sequencer.ptp.devices.Device(
  id               = sequencer.ptp.constants.CHAIN_INITIATOR_ID+1,
  client_socket    = sequencer.ptp.client_socket,
  frame_size_limit = sequencer.firmware.current_params.frame_size_limit,
  machine          = sequencer.firmware.current_params.pcp_machine_class(),
  mac_byte         = 0x09
  )

all_sequencers = sequencer.ptp.devices.Device(
  id               = sequencer.ptp.constants.PTP_BROADCAST_ID,
  client_socket    = sequencer.ptp.client_socket,
  frame_size_limit = sequencer.firmware.current_params.frame_size_limit,
  machine          = sequencer.firmware.current_params.pcp_machine_class(),
  mac_byte         = 0x09
  )

device_one = Device1()
device_two = Device2()
device_loopback = LoopbackDevice()
pmt_device = Device_PMT()

# Create devices
dac_chain_address_mask = Bitmask(label = "DAC Chain Address",
                                 width = 4,
                                 shift = 60)
dac_update_bitmask     = Bitmask(label = "DAC Update",
                                 width = 1,
                                 shift = 1)
dac_data_bitmask       = Bitmask(label = "DAC Data",
                                 width = 14,
                                 shift = 2)
dac_power_bit    = 0

dac_factory = AD9744_Factory(
  chain_address_mask = dac_chain_address_mask,
  update_mask        = dac_update_bitmask,
  data_mask          = dac_data_bitmask)
first_dac_device   = dac_factory.create_device(chain_address = 0x1)
second_dac_device  = dac_factory.create_device(chain_address = 0x2)
third_dac_device   = dac_factory.create_device(chain_address = 0x4)
fourth_dac_device  = dac_factory.create_device(chain_address = 0x8)

device_factory_list.append(dac_factory)

# DDS bitmasks
dds_chain_address_mask = Bitmask(label = "DDS Chain Address",
                                 width = 4,
                                 shift = 51)
dds_update_bitmask     = Bitmask(label = "DDS Update",
                                 width = 1,
                                 shift = 48)
dds_data_bitmask       = Bitmask(label = "DDS Data",
                                 width = 8,
                                 shift = 24)
dds_address_bitmask    = Bitmask(label = "DDS Address",
                                 width = 6,
                                 shift = 18)
dds_wrb_bitmask        = Bitmask(label = "DDS Write Bit",
                                 width = 1,
                                 shift = 17)
dds_psen_bitmask       = Bitmask(label = "DDS Profile Select Enable",
                                 width = 1,
                                 shift = 16)
dds_profile_bitmask    = Bitmask(label = "DDS Profile",
                                 width = 2,
                                 shift = 49)

dds_factory = AD9858_Factory(
  chain_address_mask = dds_chain_address_mask,
  power_mask         = None, # Built into chain board
  reset_mask         = None, # Reset outside of clock by I2C
  spmode_mask        = None, # built into chain board
  wrb_mask           = dds_wrb_bitmask,
  rdb_mask           = None, # built into chain board
  update_mask        = dds_update_bitmask,
  psen_mask          = dds_psen_bitmask,
  address_mask       = dds_address_bitmask,
  data_mask          = dds_data_bitmask,
  profile_mask       = dds_profile_bitmask)

# This is already called in dds_factory.py constructor.
dds_factory.create_register_masks()
device_factory_list.append(dds_factory)

dds_devices = {}

def dds_factory_create_devices(chain_addresses, ref_freq):
  global dds_devices
  dds_factory.reset()
  for (index, address) in chain_addresses.iteritems():
    dds_devices[index] = dds_factory.create_device(chain_address = address,
                                                   ref_freq      = ref_freq)

dds_factory_create_devices(chain_addresses = {1: 0x1, 2: 0x2},
                           ref_freq = 800)

first_dds_device  = dds_devices[1]
second_dds_device = dds_devices[2]

