dnl Global parameters for enabling/disabling macros
dnl ---------------------------------------------------------------------------
dnl MIT-NIST-ARDA Pulse Sequencer
dnl http://pulse-sequencer.sf.net
dnl Paul T. Pham
dnl ---------------------------------------------------------------------------
dnl
dnl Divert output to null to get rid of newlines.
divert(-1)dnl

dnl These defines/params are only for the top-level build of sequencer_top.
dnl For all other builds, you should not specify the Makefile variables
dnl USE_PARAMS, allowing each module to set their values locally with
dnl define_check_ (defined in util.m4) for simulation/testing.

dnl Enable the PCP32 architecture
define([enable_pcp32_], [false])

dnl Enable the AVR
define([enable_avr_], [false])

dnl Enable the PTP I2C submodule.
define([enable_ptp_i2c_], [true])

dnl Eanble the PTP triggering submodule.
define([enable_ptp_trigger_], [true])

dnl Enable the network ICMP (ping) module.
define([enable_network_icmp_], [false])

dnl Renable output for processed file
divert(0)dnl