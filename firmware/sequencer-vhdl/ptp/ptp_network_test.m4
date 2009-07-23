sequencer_unit_([ptp_network_test],dnl
  [dnl -- Declarations -------------------------------------------------------
],[dnl -- Body ----------------------------------------------------------------
peripheral_instances_
sram_instances_
i2c_instances_
network_instances_
ptp_instances_

  tcp_sram_wb_cyc <= '0';
  ptp_dma_sram_wb_cyc <= '0';
  avr_dmem_wb_cyc <= '0';
  avr_imem_wb_cyc <= '0';

])