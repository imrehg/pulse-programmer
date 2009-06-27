from test_config import *

setup()
send_i2c(slave_address = 0x61,
         write_data = '\xFF')
teardown()


