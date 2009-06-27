import sequencer.ptp

sequencer.ptp.setup_socket()
# Broadcast address, same network as device
sequencer.ptp.discover_devices()
sequencer.ptp.teardown_socket()
