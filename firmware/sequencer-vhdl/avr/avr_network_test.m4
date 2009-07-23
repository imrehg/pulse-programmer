sequencer_unit_([avr_network_test],dnl
  [dnl -- Declarations -------------------------------------------------------
  constant NETWORK_ICMP_ENABLE : boolean := false;
  constant PTP_I2C_ENABLE      : boolean := false;
  constant PTP_TRIGGER_ENABLE  : boolean := false;
],[dnl -- Body ----------------------------------------------------------------
peripheral_instances_
sram_instances_
i2c_instances_
network_instances_
avr_instances_
ptp_instances_

])