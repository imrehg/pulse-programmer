v 20070216 1
C 40000 40000 0 0 0 title-B.sym
T 50000 40700 9 10 1 0 0 0 3
Pulse Programmer
LVDS Face Board
Main Schematic Sheet
T 50000 40400 9 10 1 0 0 0 1
face-lvds.sch
T 50000 40100 9 10 1 0 0 0 1
1
T 51500 40100 9 10 1 0 0 0 1
1
T 53000 40700 9 10 1 0 0 0 1
http://local-box.org
T 54000 40400 9 10 1 0 0 0 1
0
T 54000 40100 9 10 1 0 0 0 1
Paul T. Pham
T 40800 46600 8 10 0 0 0 0 1
device=HEADER26
C 47100 45300 1 180 0 connector2-2.sym
{
T 46400 44000 5 10 1 1 180 6 1
refdes=J3
T 46800 44050 5 10 0 0 180 0 1
device=CONNECTOR_2
T 46800 43850 5 10 0 0 180 0 1
footprint=GND-LOOP
}
C 48400 45300 1 180 0 connector2-2.sym
{
T 47700 44000 5 10 1 1 180 6 1
refdes=J6
T 48100 44050 5 10 0 0 180 0 1
device=CONNECTOR_2
T 48100 43850 5 10 0 0 180 0 1
footprint=GND-LOOP
}
C 47000 44100 1 0 0 gnd-1.sym
{
T 47300 44000 5 10 1 1 180 0 1
netname=GND
}
C 48400 45000 1 270 0 vcc-small.sym
{
T 48940 45000 5 10 0 0 270 0 1
device=VCC Small
T 48500 44600 5 10 1 1 0 0 1
netname=+3.3V
}
N 48500 44900 48400 44900 4
{
T 48500 44900 5 10 0 0 0 0 1
netname=+3.3V
}
N 48400 44900 48400 44500 4
N 47100 44400 47100 44900 4
T 46400 45400 9 10 1 0 0 0 1
Ground Loop
T 47700 45400 9 10 1 0 0 0 1
Power Loop
C 50000 45300 1 180 0 connector2-2.sym
{
T 49300 44000 5 10 1 1 180 6 1
refdes=J7
T 49700 44050 5 10 0 0 180 0 1
device=CONNECTOR_2
T 49700 43850 5 10 0 0 180 0 1
footprint=GND-LOOP
}
N 50000 44900 50000 44500 4
T 49300 45400 9 10 1 0 0 0 1
Chassis Ground Loop
N 50000 44900 50700 44900 4
{
T 50200 44700 5 10 1 1 0 0 1
netname=CGND
}
C 53800 43200 1 270 0 cap-small-pol.sym
{
T 53900 42480 5 10 1 1 0 6 1
refdes=C10
T 54280 42800 5 10 0 0 270 0 1
device=Cap Small
T 53800 43200 5 10 0 0 270 0 1
footprint=6032
T 53600 42900 5 10 1 1 0 0 1
value=10u
}
C 54900 42300 1 90 0 cap-small.sym
{
T 54300 42620 5 10 1 1 180 6 1
refdes=C11
T 54420 42700 5 10 0 0 90 0 1
device=Cap Small
T 54900 42300 5 10 0 0 90 0 1
footprint=0603
T 54600 43000 5 10 1 1 180 0 1
value=1u
}
C 53900 42000 1 0 0 gnd-1.sym
{
T 53800 41800 5 10 1 1 0 0 1
netname=GND
}
N 54000 42300 54000 42600 4
N 54700 42600 54700 42300 4
C 53100 43200 1 270 0 cap-small-pol.sym
{
T 53200 42480 5 10 1 1 0 6 1
refdes=C8
T 53580 42800 5 10 0 0 270 0 1
device=Cap Small
T 53100 43200 5 10 0 0 270 0 1
footprint=7343
T 52800 42900 5 10 1 1 0 0 1
value=100u
}
N 53300 42600 53300 42300 4
N 53300 42300 54700 42300 4
N 51500 43200 52800 43200 4
{
T 51500 43000 5 10 1 1 0 0 1
netname=+3.3V_IN
}
N 53300 43200 53300 42900 4
N 54000 42900 54000 43200 4
N 54700 42900 54700 43200 4
T 49900 41800 9 10 1 0 0 0 1
+3.3V power circuit (regulated off-board)
C 44300 41900 1 270 0 cap-small-pol.sym
{
T 44400 41180 5 10 1 1 0 6 1
refdes=C15
T 44780 41500 5 10 0 0 270 0 1
device=Cap Small
T 44300 41900 5 10 0 0 270 0 1
footprint=6032
T 44100 41600 5 10 1 1 0 0 1
value=10u
}
C 45400 41000 1 90 0 cap-small.sym
{
T 44800 41320 5 10 1 1 180 6 1
refdes=C16
T 44920 41400 5 10 0 0 90 0 1
device=Cap Small
T 45400 41000 5 10 0 0 90 0 1
footprint=0603
T 45100 41700 5 10 1 1 180 0 1
value=1u
}
C 44400 40700 1 0 0 gnd-1.sym
{
T 44300 40500 5 10 1 1 0 0 1
netname=GND
}
N 44500 41000 44500 41300 4
N 45200 41300 45200 41000 4
C 43600 41900 1 270 0 cap-small-pol.sym
{
T 43700 41180 5 10 1 1 0 6 1
refdes=C14
T 44080 41500 5 10 0 0 270 0 1
device=Cap Small
T 43600 41900 5 10 0 0 270 0 1
footprint=7343
T 43300 41600 5 10 1 1 0 0 1
value=100u
}
N 43800 41300 43800 41000 4
N 43800 41000 45200 41000 4
N 43800 41900 43800 41600 4
N 44500 41600 44500 41900 4
N 45200 41600 45200 41900 4
T 40400 40500 9 10 1 0 0 0 1
+12V power circuit (regulated off-board)
C 48400 43400 1 270 0 vcc-small.sym
{
T 48940 43400 5 10 0 0 270 0 1
device=VCC Small
T 48500 43000 5 10 1 1 0 0 1
netname=+12V
}
N 48500 43300 48400 43300 4
{
T 48500 43300 5 10 0 0 0 0 1
netname=+12V
}
N 48400 43300 48400 42900 4
C 48400 43700 1 180 0 connector2-2.sym
{
T 47700 42400 5 10 1 1 180 6 1
refdes=J15
T 48100 42450 5 10 0 0 180 0 1
device=CONNECTOR_2
T 48100 42250 5 10 0 0 180 0 1
footprint=GND-LOOP
}
C 44100 42200 1 90 0 connector2-2.sym
{
T 42600 42900 5 10 1 1 180 6 1
refdes=J13
T 43200 43000 5 10 1 1 0 0 1
value=640452-2
T 42850 42500 5 10 0 0 90 0 1
device=CONNECTOR_2
T 42650 42500 5 10 0 0 90 0 1
footprint=JUMPER2
}
C 53600 43600 1 90 0 connector2-2.sym
{
T 52000 44300 5 10 1 1 180 6 1
refdes=J14
T 52700 44400 5 10 1 1 0 0 1
value=640452-2
T 52350 43900 5 10 0 0 90 0 1
device=CONNECTOR_2
T 52150 43900 5 10 0 0 90 0 1
footprint=JUMPER2
}
T 52400 44700 9 10 1 0 0 0 1
Current test port
N 41600 41900 43300 41900 4
{
T 41600 41700 5 10 1 1 0 0 1
netname=+12V_IN
}
N 43300 41900 43300 42200 4
N 43700 42200 43700 41900 4
N 43700 41900 45800 41900 4
{
T 45400 42000 5 10 1 1 0 0 1
netname=+12V
}
T 42900 43300 9 10 1 0 0 0 1
Current test port
N 52800 43200 52800 43600 4
N 53200 43600 53200 43200 4
N 53200 43200 55300 43200 4
{
T 54900 43300 5 10 1 1 0 0 1
netname=+3.3V
}
C 48000 47300 1 0 0 ds90lv047.sym
{
T 50000 49900 5 10 1 1 0 6 1
refdes=U1
T 48400 51300 5 10 0 0 0 0 1
device=ds90lv047
T 48400 51500 5 10 0 0 0 0 1
footprint=TSSOP-16
T 48400 49900 5 10 1 1 0 0 1
value=DS90LV047
}
N 47000 47800 47000 47500 4
C 47200 47500 1 90 0 cap-small.sym
{
T 47200 48220 5 10 1 1 180 6 1
refdes=C2
T 46720 47900 5 10 0 0 90 0 1
device=Cap Small
T 47700 47800 5 10 1 1 180 0 1
value=0.001u
T 47200 47500 5 10 0 0 90 0 1
footprint=0402
}
C 46900 47200 1 0 0 gnd-1.sym
{
T 47100 47200 5 10 1 1 0 0 1
netname=GND
}
C 46700 47500 1 90 0 cap-small.sym
{
T 46600 48220 5 10 1 1 180 6 1
refdes=C1
T 46220 47900 5 10 0 0 90 0 1
device=Cap Small
T 46900 47800 5 10 1 1 180 0 1
value=0.1u
T 46700 47500 5 10 0 0 90 0 1
footprint=0402
}
N 48100 47800 47800 47800 4
N 47800 47800 47800 47500 4
N 48100 48400 46500 48400 4
{
T 47900 48400 5 10 0 0 0 0 1
netname=+3.3V
}
N 48100 48100 47800 48100 4
N 47800 48100 47800 48400 4
N 47000 48100 47000 48400 4
N 46500 47800 46500 47500 4
N 46500 47500 48100 47500 4
N 46500 48100 46500 48400 4
C 46600 48300 1 90 0 vcc-small.sym
{
T 46060 48300 5 10 0 0 90 0 1
device=VCC Small
T 45900 48100 5 10 1 1 0 0 1
netname=+3.3V
}
N 51300 50000 52700 50000 4
N 50200 49300 50400 49600 4
N 50200 49000 50400 48800 4
N 50200 48700 50400 48400 4
N 50200 47500 50300 46900 4
N 54100 49500 54000 49500 4
N 54100 48700 54100 49500 4
{
T 54200 48900 5 10 1 1 270 6 1
netname=CGND
}
C 54200 49900 1 180 0 rj45.sym
{
T 53800 49800 5 10 1 1 0 0 1
refdes=J2
T 54200 47000 5 10 0 0 180 0 1
device=RJ45
T 54200 47200 5 10 0 0 180 0 1
footprint=RJ45_RA
T 53100 50000 5 10 1 1 0 0 1
value=SS-6488S-A-NF
}
N 54000 48700 54100 48700 4
N 52700 50000 52700 48700 4
N 52700 48700 52800 48700 4
N 51300 49600 51900 49600 4
N 51900 49600 51900 49300 4
N 51900 49300 52800 49300 4
N 51300 49200 52500 49200 4
N 52500 49200 52500 49700 4
N 52500 49700 52800 49700 4
N 52300 48600 52600 48600 4
N 52600 48600 52600 49500 4
N 52600 49500 52800 49500 4
N 51400 47800 52500 47800 4
N 51300 47800 51300 47900 4
N 52400 47900 52400 49100 4
N 52400 49100 52800 49100 4
N 52500 47800 52500 48900 4
N 52600 47500 52600 48500 4
N 52600 48500 52800 48500 4
N 52600 47100 52800 47100 4
N 52800 47100 52800 48300 4
N 52600 47300 54300 47300 4
{
T 53300 47300 5 10 0 0 0 0 1
netname=+12V
}
C 51400 47000 1 0 0 ttwb-1-b.sym
{
T 52000 46800 5 10 1 1 0 0 1
refdes=T4
T 51300 48300 5 10 0 1 0 0 1
device=TRANSFORMER 
T 50600 47000 5 10 1 1 0 0 1
value=TTWB-1-B
T 51300 46700 5 10 0 0 0 0 1
footprint=TF-6
}
N 50200 49600 50400 50000 4
C 53500 47200 1 0 0 vcc-small.sym
{
T 53500 47740 5 10 0 0 0 0 1
device=VCC Small
T 53200 47600 5 10 1 1 0 0 1
netname=+12V
}
C 53400 47400 1 270 0 cap-small-pol.sym
{
T 53500 46680 5 10 1 1 0 6 1
refdes=C17
T 53880 47000 5 10 0 0 270 0 1
device=Cap Small
T 53400 47400 5 10 0 0 270 0 1
footprint=6032
T 53200 47100 5 10 1 1 0 0 1
value=10u
}
N 53600 47300 53600 47100 4
N 53600 46800 53600 46600 4
N 54300 47300 54300 47100 4
N 54300 46800 54300 46600 4
C 54200 46300 1 0 0 gnd-1.sym
C 54500 46500 1 90 0 cap-small.sym
{
T 53900 46820 5 10 1 1 180 6 1
refdes=C18
T 54020 46900 5 10 0 0 90 0 1
device=Cap Small
T 54500 46500 5 10 0 0 90 0 1
footprint=0603
T 54200 47200 5 10 1 1 180 0 1
value=1u
}
N 52500 48900 52800 48900 4
C 50100 47300 1 0 0 ttwb-1-b.sym
{
T 50800 47800 5 10 1 1 0 0 1
refdes=T3
T 50100 48900 5 10 0 1 0 0 1
device=TRANSFORMER 
T 48800 46800 5 10 0 1 0 0 1
value=TTWB-1-B
T 50100 47300 5 10 0 0 0 0 1
footprint=TF-6
}
N 50200 47800 50300 47200 4
N 50300 47200 51500 47200 4
N 50200 48100 50400 47400 4
N 51400 47800 51400 47400 4
N 51400 47400 51300 47400 4
N 51300 47600 51300 47700 4
N 53600 46600 54300 46600 4
C 50100 48300 1 0 0 ttwb-1-b.sym
{
T 50800 48900 5 10 1 1 0 0 1
refdes=T2
T 50100 49900 5 10 0 1 0 0 1
device=TRANSFORMER 
T 50500 48100 5 10 1 1 0 0 1
value=TTWB-1-B
T 50100 48300 5 10 0 0 0 0 1
footprint=TF-6
}
N 50200 48400 50300 48400 4
N 50300 48400 50400 47800 4
N 52400 47900 51300 47900 4
N 52700 47300 52700 47700 4
N 52700 47700 51300 47700 4
N 52300 48600 52300 48400 4
N 52300 48400 51300 48400 4
N 51300 48600 51600 48600 4
C 51900 48500 1 90 0 gnd-1.sym
{
T 51900 48700 5 10 1 1 0 0 1
netname=GND
}
C 50100 49500 1 0 0 ttwb-1-b.sym
{
T 50800 50000 5 10 1 1 0 0 1
refdes=T1
T 50000 51000 5 10 0 1 0 0 1
device=TRANSFORMER 
T 50400 49300 5 10 1 1 0 0 1
value=TTWB-1-B
T 50000 49400 5 10 0 0 0 0 1
footprint=TF-6
}
N 51500 47200 51500 47500 4
N 51500 47500 51700 47500 4
N 50300 46900 51600 46900 4
N 51600 46900 51700 47100 4
N 51300 49200 51300 48800 4
C 51800 49700 1 90 0 gnd-1.sym
{
T 51900 49700 5 10 1 1 0 0 1
netname=GND
}
N 51300 49800 51500 49800 4
N 43000 45500 43100 45500 4
N 43100 44900 41700 44900 4
N 41700 44900 41700 49200 4
N 41800 45500 41700 45500 4
N 41800 45800 41700 45800 4
N 41800 46100 41700 46100 4
N 41800 46400 41700 46400 4
N 41800 46700 41700 46700 4
N 41800 47000 41700 47000 4
N 41700 49200 43100 49200 4
N 43100 49200 43100 44900 4
C 43200 49500 1 180 0 gnd-1.sym
{
T 43000 49500 5 10 1 1 180 0 1
netname=GND
}
N 41800 47300 41700 47300 4
N 41800 47600 41700 47600 4
N 41800 47900 41700 47900 4
N 41700 48200 41800 48200 4
N 41800 48500 41700 48500 4
N 41800 48800 41700 48800 4
C 41800 45400 1 0 0 header24-small.sym
{
T 42300 45200 5 10 1 1 0 0 1
refdes=J1
T 43400 50000 5 10 0 0 0 0 1
device=HEADER24
T 43400 49800 5 10 1 1 180 0 1
value=N2524-6V0C-RB-WE
T 41800 45400 5 10 0 0 180 0 1
footprint=HEADER12x2_SMT
}
N 43000 48500 43300 48500 4
{
T 44200 48600 5 10 1 1 180 0 1
netname=+3.3V_IN
}
N 43000 45800 43300 45800 4
{
T 44100 45900 5 10 1 1 180 0 1
netname=+12V_IN
}
N 43000 48800 43100 48800 4
N 43000 47900 43300 47900 4
{
T 44200 48000 5 10 1 1 180 0 1
netname=+3.3V_IN
}
N 43000 47300 43300 47300 4
{
T 44200 47400 5 10 1 1 180 0 1
netname=+3.3V_IN
}
N 43000 46100 43300 46100 4
{
T 44100 46200 5 10 1 1 180 0 1
netname=+12V_IN
}
N 43000 48200 44200 48200 4
{
T 44800 48300 5 10 1 1 180 0 1
netname=OUT1
}
N 47500 49600 48100 49600 4
{
T 46900 49500 5 10 1 1 0 0 1
netname=OUT1
}
N 47500 49300 48100 49300 4
{
T 46900 49200 5 10 1 1 0 0 1
netname=OUT2
}
N 47500 49000 48100 49000 4
{
T 46900 48900 5 10 1 1 0 0 1
netname=OUT3
}
N 47500 48700 48100 48700 4
{
T 46900 48600 5 10 1 1 0 0 1
netname=CLK
}
N 43000 47600 44200 47600 4
{
T 44800 47700 5 10 1 1 180 0 1
netname=OUT2
}
N 43000 47000 44200 47000 4
{
T 44800 47100 5 10 1 1 180 0 1
netname=OUT3
}
N 43000 46400 44200 46400 4
{
T 44800 46500 5 10 1 1 180 0 1
netname=CLK
}
N 43000 46700 43100 46700 4