v 20100214 2
C 40000 40000 0 0 0 title-B.sym
T 50000 40400 9 10 1 0 0 0 1
breakout-lvds-1.sch
T 51500 40100 9 10 1 0 0 0 1
?
T 53000 40700 9 10 1 0 0 0 1
http://pulse-programmer.org
T 54000 40400 9 10 1 0 0 0 1
D
T 54000 40100 9 10 1 0 0 0 1
Paul T. Pham
T 50000 40700 9 10 1 0 0 0 3
Pulse Programmer
Breakout Board
LVDS Subsheet 1
C 44800 49300 1 0 0 generic-power.sym
{
T 45000 49550 5 10 1 1 0 3 1
net=Vcc3.3
}
C 40900 48200 1 0 0 ds90lv048.sym
{
T 42900 50800 5 10 1 1 0 6 1
refdes=U1
T 41300 52200 5 10 0 0 0 0 1
device=ds90lv048
T 41300 52400 5 10 0 0 0 0 1
footprint=TSSOP-16
T 40900 48200 5 10 0 0 0 0 1
value=DS90LV048ATMTC
}
C 43700 48700 1 90 0 cap-small.sym
{
T 43800 49220 5 10 1 1 180 6 1
refdes=C2
T 43220 49100 5 10 0 0 90 0 1
device=Cap Small
T 43700 48700 5 10 0 0 90 0 1
footprint=0402
T 44000 49000 5 10 1 1 180 0 1
value=0.1u
}
C 44700 48700 1 90 0 cap-small.sym
{
T 44800 49220 5 10 1 1 180 6 1
refdes=C24
T 44220 49100 5 10 0 0 90 0 1
device=Cap Small
T 44700 48700 5 10 0 0 90 0 1
footprint=0402
T 45300 49000 5 10 1 1 180 0 1
value=0.001u
}
N 43100 48700 43700 48700 4
{
T 43100 48500 5 10 1 1 0 0 1
netname=lvds_re_00_15
}
N 43100 49000 43200 49000 4
N 43200 49000 43200 49300 4
N 43100 49300 45000 49300 4
N 43500 49000 43500 48800 4
N 44500 48800 44500 49000 4
N 43500 48800 44600 48800 4
N 44600 48800 44600 48400 4
N 44600 48400 43100 48400 4
C 44500 48100 1 0 0 gnd-1.sym
{
T 44500 48100 5 10 0 0 0 0 1
netname=GND
}
N 43100 49600 44400 49600 4
{
T 44100 49400 5 10 1 1 0 0 1
netname=dT6
}
N 43100 49900 44400 49900 4
{
T 44100 49700 5 10 1 1 0 0 1
netname=dT4
}
N 43100 50200 44400 50200 4
{
T 44100 50000 5 10 1 1 0 0 1
netname=dT2
}
N 43100 50500 44400 50500 4
{
T 44100 50300 5 10 1 1 0 0 1
netname=dT0
}
N 41000 50500 40200 50500 4
{
T 40200 50300 5 10 1 1 0 0 1
netname=dT0-
}
N 41000 50200 40200 50200 4
{
T 40200 50000 5 10 1 1 0 0 1
netname=dT0+
}
N 41000 49900 40200 49900 4
{
T 40200 49700 5 10 1 1 0 0 1
netname=dT2-
}
N 41000 49600 40200 49600 4
{
T 40200 49400 5 10 1 1 0 0 1
netname=dT2+
}
N 41000 49300 40200 49300 4
{
T 40200 49100 5 10 1 1 0 0 1
netname=dT4-
}
N 41000 49000 40200 49000 4
{
T 40200 48800 5 10 1 1 0 0 1
netname=dT4+
}
N 41000 48700 40200 48700 4
{
T 40200 48500 5 10 1 1 0 0 1
netname=dT6+
}
N 41000 48400 40200 48400 4
{
T 40200 48200 5 10 1 1 0 0 1
netname=dT6-
}
C 44800 46400 1 0 0 generic-power.sym
{
T 45000 46650 5 10 1 1 0 3 1
net=Vcc3.3
}
C 40900 45300 1 0 0 ds90lv048.sym
{
T 42900 47900 5 10 1 1 0 6 1
refdes=U3
T 41300 49300 5 10 0 0 0 0 1
device=ds90lv048
T 41300 49500 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 43100 45800 43700 45800 4
{
T 43100 45600 5 10 1 1 0 0 1
netname=lvds_re_00_15
}
N 43100 46100 43200 46100 4
N 43200 46100 43200 46400 4
N 43100 46400 45000 46400 4
N 43500 46100 43500 45900 4
N 44500 45900 44500 46100 4
N 43500 45900 44600 45900 4
N 44600 45900 44600 45500 4
N 44600 45500 43100 45500 4
C 44500 45200 1 0 0 gnd-1.sym
{
T 44500 45200 5 10 0 0 0 0 1
netname=GND
}
N 43100 46700 44400 46700 4
{
T 44100 46500 5 10 1 1 0 0 1
netname=dT14
}
N 43100 47000 44400 47000 4
{
T 44100 46800 5 10 1 1 0 0 1
netname=dT12
}
N 43100 47300 44400 47300 4
{
T 44100 47100 5 10 1 1 0 0 1
netname=dT10
}
N 43100 47600 44400 47600 4
{
T 44100 47400 5 10 1 1 0 0 1
netname=dT8
}
N 41000 47600 40200 47600 4
{
T 40200 47400 5 10 1 1 0 0 1
netname=dT8-
}
N 41000 47300 40200 47300 4
{
T 40200 47100 5 10 1 1 0 0 1
netname=dT8+
}
N 41000 47000 40200 47000 4
{
T 40200 46800 5 10 1 1 0 0 1
netname=dT10-
}
N 41000 46700 40200 46700 4
{
T 40200 46500 5 10 1 1 0 0 1
netname=dT10+
}
N 41000 46400 40200 46400 4
{
T 40200 46200 5 10 1 1 0 0 1
netname=dT12-
}
N 41000 46100 40200 46100 4
{
T 40200 45900 5 10 1 1 0 0 1
netname=dT12+
}
N 41000 45800 40200 45800 4
{
T 40200 45600 5 10 1 1 0 0 1
netname=dT14+
}
N 41000 45500 40200 45500 4
{
T 40200 45300 5 10 1 1 0 0 1
netname=dT14-
}
C 43700 45800 1 90 0 cap-small.sym
{
T 43800 46320 5 10 1 1 180 6 1
refdes=C4
T 44000 46100 5 10 1 1 180 0 1
value=0.1u
T 43220 46200 5 10 0 0 90 0 1
device=Cap Small
T 43700 45800 5 10 0 0 90 0 1
footprint=0402
}
C 44700 45800 1 90 0 cap-small.sym
{
T 44800 46320 5 10 1 1 180 6 1
refdes=C26
T 45300 46100 5 10 1 1 180 0 1
value=0.001u
T 44220 46200 5 10 0 0 90 0 1
device=Cap Small
T 44700 45800 5 10 0 0 90 0 1
footprint=0402
}
C 44800 43500 1 0 0 generic-power.sym
{
T 45000 43750 5 10 1 1 0 3 1
net=Vcc3.3
}
C 40900 42400 1 0 0 ds90lv048.sym
{
T 42900 45000 5 10 1 1 0 6 1
refdes=U5
T 41300 46400 5 10 0 0 0 0 1
device=ds90lv048
T 41300 46600 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 43100 42900 43700 42900 4
{
T 43100 42700 5 10 1 1 0 0 1
netname=lvds_re_16_31
}
N 43100 43200 43200 43200 4
N 43200 43200 43200 43500 4
N 43100 43500 45000 43500 4
N 43500 43200 43500 43000 4
N 44500 43000 44500 43200 4
N 43500 43000 44600 43000 4
N 44600 43000 44600 42600 4
N 44600 42600 43100 42600 4
C 44500 42300 1 0 0 gnd-1.sym
{
T 44500 42300 5 10 0 0 0 0 1
netname=GND
}
N 43100 43800 44400 43800 4
{
T 44100 43600 5 10 1 1 0 0 1
netname=dT21
}
N 43100 44100 44400 44100 4
{
T 44100 43900 5 10 1 1 0 0 1
netname=dT19
}
N 43100 44400 44400 44400 4
{
T 44100 44200 5 10 1 1 0 0 1
netname=dT17
}
N 43100 44700 44400 44700 4
{
T 44100 44500 5 10 1 1 0 0 1
netname=dT16
}
N 41000 44700 40200 44700 4
{
T 40200 44500 5 10 1 1 0 0 1
netname=dT16-
}
N 41000 44400 40200 44400 4
{
T 40200 44200 5 10 1 1 0 0 1
netname=dT16+
}
N 41000 44100 40200 44100 4
{
T 40200 43900 5 10 1 1 0 0 1
netname=dT17-
}
N 41000 43800 40200 43800 4
{
T 40200 43600 5 10 1 1 0 0 1
netname=dT17+
}
N 41000 43500 40200 43500 4
{
T 40200 43300 5 10 1 1 0 0 1
netname=dT19-
}
N 41000 43200 40200 43200 4
{
T 40200 43000 5 10 1 1 0 0 1
netname=dT19+
}
N 41000 42900 40200 42900 4
{
T 40200 42700 5 10 1 1 0 0 1
netname=dT21+
}
N 41000 42600 40200 42600 4
{
T 40200 42400 5 10 1 1 0 0 1
netname=dT21-
}
C 43700 42900 1 90 0 cap-small.sym
{
T 43800 43420 5 10 1 1 180 6 1
refdes=C6
T 44000 43200 5 10 1 1 180 0 1
value=0.1u
T 43220 43300 5 10 0 0 90 0 1
device=Cap Small
T 43700 42900 5 10 0 0 90 0 1
footprint=0402
}
C 44700 42900 1 90 0 cap-small.sym
{
T 44800 43420 5 10 1 1 180 6 1
refdes=C28
T 45300 43200 5 10 1 1 180 0 1
value=0.001u
T 44220 43300 5 10 0 0 90 0 1
device=Cap Small
T 44700 42900 5 10 0 0 90 0 1
footprint=0402
}
C 50200 49300 1 0 0 generic-power.sym
{
T 50400 49550 5 10 1 1 0 3 1
net=Vcc3.3
}
C 46300 48200 1 0 0 ds90lv048.sym
{
T 48300 50800 5 10 1 1 0 6 1
refdes=U7
T 46700 52200 5 10 0 0 0 0 1
device=ds90lv048
T 46700 52400 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 48500 48700 49100 48700 4
{
T 48500 48500 5 10 1 1 0 0 1
netname=lvds_re_16_31
}
N 48500 49000 48600 49000 4
N 48600 49000 48600 49300 4
N 48500 49300 50400 49300 4
N 48900 49000 48900 48800 4
N 49900 48800 49900 49000 4
N 48900 48800 50000 48800 4
N 50000 48800 50000 48400 4
N 50000 48400 48500 48400 4
C 49900 48100 1 0 0 gnd-1.sym
{
T 49900 48100 5 10 0 0 0 0 1
netname=GND
}
N 48500 49600 49800 49600 4
{
T 49500 49400 5 10 1 1 0 0 1
netname=dT29
}
N 48500 49900 49800 49900 4
{
T 49500 49700 5 10 1 1 0 0 1
netname=dT27
}
N 48500 50200 49800 50200 4
{
T 49500 50000 5 10 1 1 0 0 1
netname=dT25
}
N 48500 50500 49800 50500 4
{
T 49500 50300 5 10 1 1 0 0 1
netname=dT23
}
N 46400 50500 45600 50500 4
{
T 45600 50300 5 10 1 1 0 0 1
netname=dT23-
}
N 46400 50200 45600 50200 4
{
T 45600 50000 5 10 1 1 0 0 1
netname=dT23+
}
N 46400 49900 45600 49900 4
{
T 45600 49700 5 10 1 1 0 0 1
netname=dT25-
}
N 46400 49600 45600 49600 4
{
T 45600 49400 5 10 1 1 0 0 1
netname=dT25+
}
N 46400 49300 45600 49300 4
{
T 45600 49100 5 10 1 1 0 0 1
netname=dT27-
}
N 46400 49000 45600 49000 4
{
T 45600 48800 5 10 1 1 0 0 1
netname=dT27+
}
N 46400 48700 45600 48700 4
{
T 45600 48500 5 10 1 1 0 0 1
netname=dT29+
}
N 46400 48400 45600 48400 4
{
T 45600 48200 5 10 1 1 0 0 1
netname=dT29-
}
C 49100 48700 1 90 0 cap-small.sym
{
T 49200 49220 5 10 1 1 180 6 1
refdes=C8
T 49400 49000 5 10 1 1 180 0 1
value=0.1u
T 48620 49100 5 10 0 0 90 0 1
device=Cap Small
T 49100 48700 5 10 0 0 90 0 1
footprint=0402
}
C 50100 48700 1 90 0 cap-small.sym
{
T 50200 49220 5 10 1 1 180 6 1
refdes=C30
T 50700 49000 5 10 1 1 180 0 1
value=0.001u
T 49620 49100 5 10 0 0 90 0 1
device=Cap Small
T 50100 48700 5 10 0 0 90 0 1
footprint=0402
}
C 50200 46400 1 0 0 generic-power.sym
{
T 50400 46650 5 10 1 1 0 3 1
net=Vcc3.3
}
C 46300 45300 1 0 0 ds90lv048.sym
{
T 48300 47900 5 10 1 1 0 6 1
refdes=U9
T 46700 49300 5 10 0 0 0 0 1
device=ds90lv048
T 46700 49500 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 48500 45800 49100 45800 4
{
T 48500 45600 5 10 1 1 0 0 1
netname=lvds_re_32_47
}
N 48500 46100 48600 46100 4
N 48600 46100 48600 46400 4
N 48500 46400 50400 46400 4
N 48900 46100 48900 45900 4
N 49900 45900 49900 46100 4
N 48900 45900 50000 45900 4
N 50000 45900 50000 45500 4
N 50000 45500 48500 45500 4
C 49900 45200 1 0 0 gnd-1.sym
{
T 49900 45200 5 10 0 0 0 0 1
netname=GND
}
N 48500 46700 49800 46700 4
{
T 49500 46500 5 10 1 1 0 0 1
netname=dT38
}
N 48500 47000 49800 47000 4
{
T 49500 46800 5 10 1 1 0 0 1
netname=dT36
}
N 48500 47300 49800 47300 4
{
T 49500 47100 5 10 1 1 0 0 1
netname=dT34
}
N 48500 47600 49800 47600 4
{
T 49500 47400 5 10 1 1 0 0 1
netname=dT32
}
N 46400 47600 45600 47600 4
{
T 45600 47400 5 10 1 1 0 0 1
netname=dT32-
}
N 46400 47300 45600 47300 4
{
T 45600 47100 5 10 1 1 0 0 1
netname=dT32+
}
N 46400 47000 45600 47000 4
{
T 45600 46800 5 10 1 1 0 0 1
netname=dT34-
}
N 46400 46700 45600 46700 4
{
T 45600 46500 5 10 1 1 0 0 1
netname=dT34+
}
N 46400 46400 45600 46400 4
{
T 45600 46200 5 10 1 1 0 0 1
netname=dT36-
}
N 46400 46100 45600 46100 4
{
T 45600 45900 5 10 1 1 0 0 1
netname=dT36+
}
N 46400 45800 45600 45800 4
{
T 45600 45600 5 10 1 1 0 0 1
netname=dT38+
}
N 46400 45500 45600 45500 4
{
T 45600 45300 5 10 1 1 0 0 1
netname=dT38-
}
C 49100 45800 1 90 0 cap-small.sym
{
T 49200 46320 5 10 1 1 180 6 1
refdes=C10
T 49400 46100 5 10 1 1 180 0 1
value=0.1u
T 48620 46200 5 10 0 0 90 0 1
device=Cap Small
T 49100 45800 5 10 0 0 90 0 1
footprint=0402
}
C 50100 45800 1 90 0 cap-small.sym
{
T 50200 46320 5 10 1 1 180 6 1
refdes=C32
T 50700 46100 5 10 1 1 180 0 1
value=0.001u
T 49620 46200 5 10 0 0 90 0 1
device=Cap Small
T 50100 45800 5 10 0 0 90 0 1
footprint=0402
}
C 50200 43500 1 0 0 generic-power.sym
{
T 50400 43750 5 10 1 1 0 3 1
net=Vcc3.3
}
C 46300 42400 1 0 0 ds90lv048.sym
{
T 48300 45000 5 10 1 1 0 6 1
refdes=U11
T 46700 46400 5 10 0 0 0 0 1
device=ds90lv048
T 46700 46600 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 48500 42900 49100 42900 4
{
T 48500 42700 5 10 1 1 0 0 1
netname=lvds_re_32_47
}
N 48500 43200 48600 43200 4
N 48600 43200 48600 43500 4
N 48500 43500 50400 43500 4
N 48900 43200 48900 43000 4
N 49900 43000 49900 43200 4
N 48900 43000 50000 43000 4
N 50000 43000 50000 42600 4
N 50000 42600 48500 42600 4
C 49900 42300 1 0 0 gnd-1.sym
{
T 49900 42300 5 10 0 0 0 0 1
netname=GND
}
N 48500 43800 49800 43800 4
{
T 49500 43600 5 10 1 1 0 0 1
netname=dT46
}
N 48500 44100 49800 44100 4
{
T 49500 43900 5 10 1 1 0 0 1
netname=dT44
}
N 48500 44400 49800 44400 4
{
T 49500 44200 5 10 1 1 0 0 1
netname=dT42
}
N 48500 44700 49800 44700 4
{
T 49500 44500 5 10 1 1 0 0 1
netname=dT40
}
N 46400 44700 45600 44700 4
{
T 45600 44500 5 10 1 1 0 0 1
netname=dT40-
}
N 46400 44400 45600 44400 4
{
T 45600 44200 5 10 1 1 0 0 1
netname=dT40+
}
N 46400 44100 45600 44100 4
{
T 45600 43900 5 10 1 1 0 0 1
netname=dT42-
}
N 46400 43800 45600 43800 4
{
T 45600 43600 5 10 1 1 0 0 1
netname=dT42+
}
N 46400 43500 45600 43500 4
{
T 45600 43300 5 10 1 1 0 0 1
netname=dT44-
}
N 46400 43200 45600 43200 4
{
T 45600 43000 5 10 1 1 0 0 1
netname=dT44+
}
N 46400 42900 45600 42900 4
{
T 45600 42700 5 10 1 1 0 0 1
netname=dT46+
}
N 46400 42600 45600 42600 4
{
T 45600 42400 5 10 1 1 0 0 1
netname=dT46-
}
C 49100 42900 1 90 0 cap-small.sym
{
T 49200 43420 5 10 1 1 180 6 1
refdes=C34
T 49400 43200 5 10 1 1 180 0 1
value=0.1u
T 48620 43300 5 10 0 0 90 0 1
device=Cap Small
T 49100 42900 5 10 0 0 90 0 1
footprint=0402
}
C 50100 42900 1 90 0 cap-small.sym
{
T 50200 43420 5 10 1 1 180 6 1
refdes=C12
T 50700 43200 5 10 1 1 180 0 1
value=0.001u
T 49620 43300 5 10 0 0 90 0 1
device=Cap Small
T 50100 42900 5 10 0 0 90 0 1
footprint=0402
}
C 55700 49300 1 0 0 generic-power.sym
{
T 55900 49550 5 10 1 1 0 3 1
net=Vcc3.3
}
C 51800 48200 1 0 0 ds90lv048.sym
{
T 53800 50800 5 10 1 1 0 6 1
refdes=U13
T 52200 52200 5 10 0 0 0 0 1
device=ds90lv048
T 52200 52400 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 54000 48700 54600 48700 4
{
T 54000 48500 5 10 1 1 0 0 1
netname=lvds_re_48_63
}
N 54000 49000 54100 49000 4
N 54100 49000 54100 49300 4
N 54000 49300 55900 49300 4
N 54400 49000 54400 48800 4
N 55400 48800 55400 49000 4
N 54400 48800 55500 48800 4
N 55500 48800 55500 48400 4
N 55500 48400 54000 48400 4
C 55400 48100 1 0 0 gnd-1.sym
{
T 55400 48100 5 10 0 0 0 0 1
netname=GND
}
N 54000 49600 55300 49600 4
{
T 55000 49400 5 10 1 1 0 0 1
netname=dT53
}
N 54000 49900 55300 49900 4
{
T 55000 49700 5 10 1 1 0 0 1
netname=dT51
}
N 54000 50200 55300 50200 4
{
T 55000 50000 5 10 1 1 0 0 1
netname=dT49
}
N 54000 50500 55300 50500 4
{
T 55000 50300 5 10 1 1 0 0 1
netname=dT48
}
N 51900 50500 51100 50500 4
{
T 51100 50300 5 10 1 1 0 0 1
netname=dT48-
}
N 51900 50200 51100 50200 4
{
T 51100 50000 5 10 1 1 0 0 1
netname=dT48+
}
N 51900 49900 51100 49900 4
{
T 51100 49700 5 10 1 1 0 0 1
netname=dT49-
}
N 51900 49600 51100 49600 4
{
T 51100 49400 5 10 1 1 0 0 1
netname=dT49+
}
N 51900 49300 51100 49300 4
{
T 51100 49100 5 10 1 1 0 0 1
netname=dT51-
}
N 51900 49000 51100 49000 4
{
T 51100 48800 5 10 1 1 0 0 1
netname=dT51+
}
N 51900 48700 51100 48700 4
{
T 51100 48500 5 10 1 1 0 0 1
netname=dT53+
}
N 51900 48400 51100 48400 4
{
T 51100 48200 5 10 1 1 0 0 1
netname=dT53-
}
C 54600 48700 1 90 0 cap-small.sym
{
T 54700 49220 5 10 1 1 180 6 1
refdes=C36
T 54900 49000 5 10 1 1 180 0 1
value=0.1u
T 54120 49100 5 10 0 0 90 0 1
device=Cap Small
T 54600 48700 5 10 0 0 90 0 1
footprint=0402
}
C 55600 48700 1 90 0 cap-small.sym
{
T 55700 49220 5 10 1 1 180 6 1
refdes=C14
T 56200 49000 5 10 1 1 180 0 1
value=0.001u
T 55120 49100 5 10 0 0 90 0 1
device=Cap Small
T 55600 48700 5 10 0 0 90 0 1
footprint=0402
}
C 55700 46500 1 0 0 generic-power.sym
{
T 55900 46750 5 10 1 1 0 3 1
net=Vcc3.3
}
C 51800 45400 1 0 0 ds90lv048.sym
{
T 53800 48000 5 10 1 1 0 6 1
refdes=U15
T 52200 49400 5 10 0 0 0 0 1
device=ds90lv048
T 52200 49600 5 10 0 0 0 0 1
footprint=TSSOP-16
}
N 54000 45900 54600 45900 4
{
T 54000 45700 5 10 1 1 0 0 1
netname=lvds_re_48_63
}
N 54000 46200 54100 46200 4
N 54100 46200 54100 46500 4
N 54000 46500 55900 46500 4
N 54400 46200 54400 46000 4
N 55400 46000 55400 46200 4
N 54400 46000 55500 46000 4
N 55500 46000 55500 45600 4
N 55500 45600 54000 45600 4
C 55400 45300 1 0 0 gnd-1.sym
{
T 55400 45300 5 10 0 0 0 0 1
netname=GND
}
N 54000 46800 55300 46800 4
{
T 55000 46600 5 10 1 1 0 0 1
netname=dT61
}
N 54000 47100 55300 47100 4
{
T 55000 46900 5 10 1 1 0 0 1
netname=dT59
}
N 54000 47400 55300 47400 4
{
T 55000 47200 5 10 1 1 0 0 1
netname=dT57
}
N 54000 47700 55300 47700 4
{
T 55000 47500 5 10 1 1 0 0 1
netname=dT55
}
N 51900 47700 51100 47700 4
{
T 51100 47500 5 10 1 1 0 0 1
netname=dT55-
}
N 51900 47400 51100 47400 4
{
T 51100 47200 5 10 1 1 0 0 1
netname=dT55+
}
N 51900 47100 51100 47100 4
{
T 51100 46900 5 10 1 1 0 0 1
netname=dT57-
}
N 51900 46800 51100 46800 4
{
T 51100 46600 5 10 1 1 0 0 1
netname=dT57+
}
N 51900 46500 51100 46500 4
{
T 51100 46300 5 10 1 1 0 0 1
netname=dT59-
}
N 51900 46200 51100 46200 4
{
T 51100 46000 5 10 1 1 0 0 1
netname=dT59+
}
N 51900 45900 51100 45900 4
{
T 51100 45700 5 10 1 1 0 0 1
netname=dT61+
}
N 51900 45600 51100 45600 4
{
T 51100 45400 5 10 1 1 0 0 1
netname=dT61-
}
C 54600 45900 1 90 0 cap-small.sym
{
T 54700 46420 5 10 1 1 180 6 1
refdes=C38
T 54900 46200 5 10 1 1 180 0 1
value=0.1u
T 54120 46300 5 10 0 0 90 0 1
device=Cap Small
T 54600 45900 5 10 0 0 90 0 1
footprint=0402
}
C 55600 45900 1 90 0 cap-small.sym
{
T 55700 46420 5 10 1 1 180 6 1
refdes=C16
T 56200 46200 5 10 1 1 180 0 1
value=0.001u
T 55120 46300 5 10 0 0 90 0 1
device=Cap Small
T 55600 45900 5 10 0 0 90 0 1
footprint=0402
}
C 40900 40800 1 0 0 respack4-2.sym
{
T 41200 41900 5 6 0 1 0 0 1
device=RPAK_CTS
T 41200 42100 5 6 1 1 0 0 1
refdes=RP1
T 41600 42000 5 10 1 1 0 0 1
value=47
}
N 40900 41300 40700 41300 4
{
T 40200 41200 5 10 1 1 0 0 1
netname=dT6
}
N 40900 41500 40700 41500 4
{
T 40200 41400 5 10 1 1 0 0 1
netname=dT4
}
N 40900 41700 40700 41700 4
{
T 40200 41600 5 10 1 1 0 0 1
netname=dT2
}
N 40900 41900 40700 41900 4
{
T 40200 41800 5 10 1 1 0 0 1
netname=dT0
}
N 41900 41300 42100 41300 4
{
T 42400 41400 5 10 1 1 180 0 1
netname=T6
}
N 41900 41500 42100 41500 4
{
T 42400 41600 5 10 1 1 180 0 1
netname=T4
}
N 41900 41700 42100 41700 4
{
T 42400 41800 5 10 1 1 180 0 1
netname=T2
}
N 41900 41900 42100 41900 4
{
T 42400 42000 5 10 1 1 180 0 1
netname=T0
}
C 40900 39700 1 0 0 respack4-2.sym
{
T 41200 40800 5 6 0 1 0 0 1
device=RPAK_CTS
T 41200 41000 5 6 1 1 0 0 1
refdes=RP3
T 41600 40900 5 10 1 1 0 0 1
value=47
}
N 40900 40200 40700 40200 4
{
T 40200 40100 5 10 1 1 0 0 1
netname=dT14
}
N 40900 40400 40700 40400 4
{
T 40200 40300 5 10 1 1 0 0 1
netname=dT12
}
N 40900 40600 40700 40600 4
{
T 40200 40500 5 10 1 1 0 0 1
netname=dT10
}
N 40900 40800 40700 40800 4
{
T 40200 40700 5 10 1 1 0 0 1
netname=dT8
}
N 41900 40200 42100 40200 4
{
T 42500 40300 5 10 1 1 180 0 1
netname=T14
}
N 41900 40400 42100 40400 4
{
T 42500 40500 5 10 1 1 180 0 1
netname=T12
}
N 41900 40600 42100 40600 4
{
T 42500 40700 5 10 1 1 180 0 1
netname=T10
}
N 41900 40800 42100 40800 4
{
T 42400 40900 5 10 1 1 180 0 1
netname=T8
}
C 43700 40900 1 0 0 respack4-2.sym
{
T 44000 42000 5 6 0 1 0 0 1
device=RPAK_CTS
T 44000 42200 5 6 1 1 0 0 1
refdes=RP5
T 44400 42100 5 10 1 1 0 0 1
value=47
}
N 43700 41400 43500 41400 4
{
T 43000 41300 5 10 1 1 0 0 1
netname=dT21
}
N 43700 41600 43500 41600 4
{
T 43000 41500 5 10 1 1 0 0 1
netname=dT19
}
N 43700 41800 43500 41800 4
{
T 43000 41700 5 10 1 1 0 0 1
netname=dT17
}
N 43700 42000 43500 42000 4
{
T 43000 41900 5 10 1 1 0 0 1
netname=dT16
}
N 44700 41400 44900 41400 4
{
T 45300 41500 5 10 1 1 180 0 1
netname=T21
}
N 44700 41600 44900 41600 4
{
T 45300 41700 5 10 1 1 180 0 1
netname=T19
}
N 44700 41800 44900 41800 4
{
T 45300 41900 5 10 1 1 180 0 1
netname=T17
}
N 44700 42000 44900 42000 4
{
T 45300 42100 5 10 1 1 180 0 1
netname=T16
}
C 43700 39800 1 0 0 respack4-2.sym
{
T 44000 40900 5 6 0 1 0 0 1
device=RPAK_CTS
T 44000 41100 5 6 1 1 0 0 1
refdes=RP7
T 44400 41000 5 10 1 1 0 0 1
value=47
}
N 43700 40300 43500 40300 4
{
T 43000 40200 5 10 1 1 0 0 1
netname=dT29
}
N 43700 40500 43500 40500 4
{
T 43000 40400 5 10 1 1 0 0 1
netname=dT27
}
N 43700 40700 43500 40700 4
{
T 43000 40600 5 10 1 1 0 0 1
netname=dT25
}
N 43700 40900 43500 40900 4
{
T 43000 40800 5 10 1 1 0 0 1
netname=dT23
}
N 44700 40300 44900 40300 4
{
T 45300 40400 5 10 1 1 180 0 1
netname=T29
}
N 44700 40500 44900 40500 4
{
T 45300 40600 5 10 1 1 180 0 1
netname=T27
}
N 44700 40700 44900 40700 4
{
T 45300 40800 5 10 1 1 180 0 1
netname=T25
}
N 44700 40900 44900 40900 4
{
T 45300 41000 5 10 1 1 180 0 1
netname=T23
}
N 46300 41400 46100 41400 4
{
T 45600 41300 5 10 1 1 0 0 1
netname=dT38
}
N 46300 41600 46100 41600 4
{
T 45600 41500 5 10 1 1 0 0 1
netname=dT36
}
N 46300 41800 46100 41800 4
{
T 45600 41700 5 10 1 1 0 0 1
netname=dT34
}
N 46300 42000 46100 42000 4
{
T 45600 41900 5 10 1 1 0 0 1
netname=dT32
}
N 47300 41400 47500 41400 4
{
T 47900 41500 5 10 1 1 180 0 1
netname=T38
}
N 47300 41600 47500 41600 4
{
T 47900 41700 5 10 1 1 180 0 1
netname=T36
}
N 47300 41800 47500 41800 4
{
T 47900 41900 5 10 1 1 180 0 1
netname=T34
}
N 47300 42000 47500 42000 4
{
T 47900 42100 5 10 1 1 180 0 1
netname=T32
}
C 46300 40900 1 0 0 respack4-2.sym
{
T 46600 42000 5 6 0 1 0 0 1
device=RPAK_CTS
T 46600 42200 5 6 1 1 0 0 1
refdes=RP9
T 47000 42100 5 10 1 1 0 0 1
value=47
}
N 46300 40300 46100 40300 4
{
T 45600 40200 5 10 1 1 0 0 1
netname=dT46
}
N 46300 40500 46100 40500 4
{
T 45600 40400 5 10 1 1 0 0 1
netname=dT44
}
N 46300 40700 46100 40700 4
{
T 45600 40600 5 10 1 1 0 0 1
netname=dT42
}
N 46300 40900 46100 40900 4
{
T 45600 40800 5 10 1 1 0 0 1
netname=dT40
}
N 47300 40300 47500 40300 4
{
T 47900 40400 5 10 1 1 180 0 1
netname=T46
}
N 47300 40500 47500 40500 4
{
T 47900 40600 5 10 1 1 180 0 1
netname=T44
}
N 47300 40700 47500 40700 4
{
T 47900 40800 5 10 1 1 180 0 1
netname=T42
}
N 47300 40900 47500 40900 4
{
T 47900 41000 5 10 1 1 180 0 1
netname=T40
}
C 46300 39800 1 0 0 respack4-2.sym
{
T 46600 40900 5 6 0 1 0 0 1
device=RPAK_CTS
T 46600 41100 5 6 1 1 0 0 1
refdes=RP11
T 47000 41000 5 10 1 1 0 0 1
value=47
}
N 52200 44000 52000 44000 4
{
T 51500 43900 5 10 1 1 0 0 1
netname=dT53
}
N 52200 44200 52000 44200 4
{
T 51500 44100 5 10 1 1 0 0 1
netname=dT51
}
N 52200 44400 52000 44400 4
{
T 51500 44300 5 10 1 1 0 0 1
netname=dT49
}
N 52200 44600 52000 44600 4
{
T 51500 44500 5 10 1 1 0 0 1
netname=dT48
}
N 53200 44000 53400 44000 4
{
T 53800 44100 5 10 1 1 180 0 1
netname=T53
}
N 53200 44200 53400 44200 4
{
T 53800 44300 5 10 1 1 180 0 1
netname=T51
}
N 53200 44400 53400 44400 4
{
T 53800 44500 5 10 1 1 180 0 1
netname=T49
}
N 53200 44600 53400 44600 4
{
T 53800 44700 5 10 1 1 180 0 1
netname=T48
}
C 52200 43500 1 0 0 respack4-2.sym
{
T 52500 44600 5 6 0 1 0 0 1
device=RPAK_CTS
T 52500 44800 5 6 1 1 0 0 1
refdes=RP13
T 52900 44700 5 10 1 1 0 0 1
value=47
}
N 52200 42700 52000 42700 4
{
T 51500 42600 5 10 1 1 0 0 1
netname=dT61
}
N 52200 42900 52000 42900 4
{
T 51500 42800 5 10 1 1 0 0 1
netname=dT59
}
N 52200 43100 52000 43100 4
{
T 51500 43000 5 10 1 1 0 0 1
netname=dT57
}
N 52200 43300 52000 43300 4
{
T 51500 43200 5 10 1 1 0 0 1
netname=dT55
}
N 53200 42700 53400 42700 4
{
T 53800 42800 5 10 1 1 180 0 1
netname=T61
}
N 53200 42900 53400 42900 4
{
T 53800 43000 5 10 1 1 180 0 1
netname=T59
}
N 53200 43100 53400 43100 4
{
T 53800 43200 5 10 1 1 180 0 1
netname=T57
}
N 53200 43300 53400 43300 4
{
T 53800 43400 5 10 1 1 180 0 1
netname=T55
}
C 52200 42200 1 0 0 respack4-2.sym
{
T 52500 43300 5 6 0 1 0 0 1
device=RPAK_CTS
T 52500 43500 5 6 1 1 0 0 1
refdes=RP15
T 52900 43400 5 10 1 1 0 0 1
value=47
}