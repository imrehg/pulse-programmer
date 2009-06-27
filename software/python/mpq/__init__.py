import sequencer

ref_freq   = 1200 # in MHz, so 1000 = 1 GHz
cycle_time = (1e3 / ref_freq) * 8 # in ns, AD9858 sync clock is divide-by-8

# Test setup runs firmware version 0.15
sequencer.set_site_params(version      = (0, 15),
                          ref_freq     = ref_freq,
                          chain_length = 1)

# Use test_config as a template
# We must set site params first so that current total output width is used to
# create masks in test_config.
from sequencer.api   import *
from test_config.api import * # Template config overrides distribution
from mpq.api         import * # Box config overrides template.

# MPQ boxes only have one sequencer each.
# We use the one in test_config for now, although if Innsbruck uses a different
# MAC byte we will have to override the assignment here.

# Reset test_config's dds_factory here to use our own ref freq (1 GHz)
# and to create 4 devices (one MPQ box has 4 channels).
test_config.dds_factory_create_devices(
  chain_addresses = {1: 0x1, 2: 0x2, 3: 0x4, 4: 0x8},
  ref_freq        = ref_freq)
