v 20070216 1
C 40000 40000 0 0 0 title-B.sym
C 42900 44300 1 0 0 ispGAL22V10.sym
{
T 46300 44700 5 10 1 1 0 6 1
refdes=U1
T 43300 49600 5 10 0 0 0 0 1
device=ispGAL22V10
T 43300 49800 5 10 0 0 0 0 1
footprint=QFN-32
}
T 50000 40700 9 10 1 0 0 0 3
Pulse Programmer
GAL Island
Main Schematic Sheet
T 50000 40400 9 10 1 0 0 0 1
island-gal.sch
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
N 43000 46200 42000 46200 4
{
T 41500 46100 5 10 1 1 0 0 1
netname=TMS
}
N 44500 47700 44500 48700 4
{
T 44300 48700 5 10 1 1 270 0 1
netname=TCK
}
N 44800 44400 44800 43400 4
{
T 45000 43400 5 10 1 1 90 0 1
netname=TDI
}
N 46300 46200 47300 46200 4
{
T 47800 46200 5 10 1 1 180 0 1
netname=TDO
}
N 47300 46500 46300 46500 4
{
T 46900 46300 5 10 1 1 0 0 1
netname=IO22
}
N 43900 44400 43900 43400 4
{
T 44100 43400 5 10 1 1 90 0 1
netname=I10
}
N 43600 44400 43600 43400 4
{
T 43800 43400 5 10 1 1 90 0 1
netname=I9
}
N 45100 44400 45100 43400 4
{
T 45300 43400 5 10 1 1 90 0 1
netname=I14
}
N 45400 44400 45400 43400 4
{
T 45600 43400 5 10 1 1 90 0 1
netname=IO15
}
N 45700 44400 45700 43400 4
{
T 45900 43400 5 10 1 1 90 0 1
netname=IO16
}
N 46300 45600 47300 45600 4
{
T 47300 45500 5 10 1 1 180 0 1
netname=IO19
}
N 46300 45300 47300 45300 4
{
T 47300 45200 5 10 1 1 180 0 1
netname=IO18
}
N 46300 45000 47300 45000 4
{
T 47300 44900 5 10 1 1 180 0 1
netname=IO17
}
N 43000 45300 42000 45300 4
{
T 42000 45100 5 10 1 1 0 0 1
netname=I7
}
N 43000 45000 42000 45000 4
{
T 42000 44800 5 10 1 1 0 0 1
netname=I8
}
N 43900 47700 43900 48700 4
{
T 43700 48700 5 10 1 1 270 0 1
netname=I31
}
N 43600 47700 43600 48700 4
{
T 43400 48700 5 10 1 1 270 0 1
netname=I32
}
N 45400 47700 45400 48700 4
{
T 45200 48700 5 10 1 1 270 0 1
netname=IO26
}
N 45700 47700 45700 48700 4
{
T 45500 48700 5 10 1 1 270 0 1
netname=IO25
}
C 41200 46000 1 90 1 vcc-small.sym
{
T 40660 46000 5 10 0 0 270 2 1
device=VCC Small
T 40200 45900 5 10 1 1 180 6 1
netname=+3.3V
}
N 41100 45900 43000 45900 4
{
T 42900 45900 5 10 0 0 0 0 1
netname=+3.3V
}
C 44600 43800 1 0 1 gnd-1.sym
{
T 44700 43600 5 10 1 1 0 6 1
netname=GND
}
N 44500 44400 44500 44100 4
N 44200 44400 44200 44300 4
N 44200 44300 44500 44300 4
C 47600 46000 1 90 1 gnd-1.sym
{
T 47700 45900 5 10 1 1 180 6 1
netname=GND
}
N 46300 45900 47300 45900 4
C 44900 49900 1 0 1 vcc-small.sym
{
T 44900 50440 5 10 0 0 180 2 1
device=VCC Small
T 44900 50900 5 10 1 1 90 6 1
netname=+3.3V
}
N 44800 47700 44800 50000 4
N 45100 47700 45100 47900 4
N 45100 47900 44800 47900 4
N 43000 45600 42000 45600 4
{
T 42000 45400 5 10 1 1 0 0 1
netname=I6
}
C 56000 50200 1 90 1 vcc-small.sym
{
T 55460 50200 5 10 0 0 270 2 1
device=VCC Small
T 55000 50100 5 10 1 1 180 6 1
netname=+3.3V
}
N 55900 50100 56000 50100 4
{
T 55900 50100 5 10 0 0 0 0 1
netname=+3.3V
}
N 56000 49700 55000 49700 4
{
T 55000 49500 5 10 1 1 0 0 1
netname=TDO
}
N 56000 49300 55000 49300 4
{
T 55000 49100 5 10 1 1 0 0 1
netname=TDI
}
C 55300 48800 1 0 0 nc-left-1.sym
{
T 55300 49200 5 10 0 0 0 0 1
value=NoConnection
T 55300 49600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 55300 48400 1 0 0 nc-left-1.sym
{
T 55300 48800 5 10 0 0 0 0 1
value=NoConnection
T 55300 49200 5 10 0 0 0 0 1
device=DRC_Directive
}
C 55300 46800 1 0 0 nc-left-1.sym
{
T 55300 47200 5 10 0 0 0 0 1
value=NoConnection
T 55300 47600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 55300 46400 1 0 0 nc-left-1.sym
{
T 55300 46800 5 10 0 0 0 0 1
value=NoConnection
T 55300 47200 5 10 0 0 0 0 1
device=DRC_Directive
}
C 56000 46100 1 0 0 connector10-2.sym
{
T 56700 50600 5 10 1 1 0 6 1
refdes=J6
T 56300 50550 5 10 0 0 0 0 1
device=CONNECTOR_10
T 56300 50750 5 10 0 0 0 0 1
footprint=HEADER10
}
N 56000 47300 55000 47300 4
{
T 55000 47100 5 10 1 1 0 0 1
netname=TCK
}
C 54700 47600 1 270 1 gnd-1.sym
{
T 54600 47700 5 10 1 1 0 6 1
netname=GND
}
N 56000 47700 55000 47700 4
N 56000 48100 55000 48100 4
{
T 54500 48000 5 10 1 1 0 0 1
netname=TMS
}
N 55800 48900 56000 48900 4
N 55800 48500 56000 48500 4
N 55800 46900 56000 46900 4
N 55800 46500 56000 46500 4
C 46700 48800 1 0 1 cap-small.sym
{
T 45980 48900 5 10 1 1 270 0 1
refdes=C3
T 46300 49280 5 10 0 0 180 2 1
device=Cap Small
T 46400 48600 5 10 1 1 270 6 1
value=0.1u
T 46700 48800 5 10 0 0 180 2 1
footprint=0402
}
C 46700 49500 1 0 1 cap-small.sym
{
T 45980 49600 5 10 1 1 270 0 1
refdes=C2
T 46300 49980 5 10 0 0 180 2 1
device=Cap Small
T 46400 49300 5 10 1 1 270 6 1
value=0.1u
T 46700 49500 5 10 0 0 180 2 1
footprint=0402
}
C 41200 44900 1 270 1 cap-small.sym
{
T 41300 45620 5 10 1 1 180 0 1
refdes=C1
T 41680 45300 5 10 0 0 90 2 1
device=Cap Small
T 41000 45200 5 10 1 1 180 6 1
value=0.1u
T 41200 44900 5 10 0 0 90 2 1
footprint=0402
}
N 41400 45500 41400 45900 4
C 41500 44700 1 0 1 gnd-1.sym
{
T 41600 44500 5 10 1 1 0 6 1
netname=GND
}
N 41400 45000 41400 45200 4
C 47100 48600 1 0 1 gnd-1.sym
{
T 47200 48400 5 10 1 1 0 6 1
netname=GND
}
N 46400 49700 47000 49700 4
N 47000 49700 47000 48900 4
N 46400 49000 47000 49000 4
N 46100 49000 44800 49000 4
N 46100 49700 44800 49700 4
C 50000 41400 1 0 0 qxe-020-01-x-d-em2.sym
{
T 51500 46500 5 10 1 1 180 2 1
refdes=J5
T 48500 40600 5 10 0 1 180 8 1
device=QxE-020-01-x-D-EM2
T 51300 42100 5 10 1 1 180 8 1
value=QxE-020-01-x-D-EM2
T 50000 41400 5 10 0 0 0 0 1
footprint=QTE-020-01-x-D-EM2
}
N 43000 46500 42000 46500 4
{
T 42000 46300 5 10 1 1 0 0 1
netname=I3
}
N 43000 46800 42000 46800 4
{
T 42000 46600 5 10 1 1 0 0 1
netname=I2
}
N 43000 47100 42000 47100 4
{
T 42000 46900 5 10 1 1 0 0 1
netname=I1
}
N 47300 46800 46300 46800 4
{
T 46900 46600 5 10 1 1 0 0 1
netname=IO23
}
N 47300 47100 46300 47100 4
{
T 46900 46900 5 10 1 1 0 0 1
netname=IO24
}
N 44200 47700 44200 48700 4
{
T 44000 48700 5 10 1 1 270 0 1
netname=ICLK
}
N 51500 44200 52100 44200 4
{
T 52600 44300 5 10 1 1 180 0 1
netname=I3
}
N 51500 44600 52100 44600 4
{
T 52600 44700 5 10 1 1 180 0 1
netname=I2
}
N 51500 45000 52100 45000 4
{
T 52600 45100 5 10 1 1 180 0 1
netname=I1
}
N 51500 45400 52100 45400 4
{
T 52600 45500 5 10 1 1 180 0 1
netname=I32
}
N 51500 46000 52100 46000 4
{
T 52600 46100 5 10 1 1 180 0 1
netname=ICLK
}
N 50100 46000 49500 46000 4
{
T 49000 45900 5 10 1 1 0 0 1
netname=IO26
}
N 50100 45800 49500 45800 4
{
T 49000 45700 5 10 1 1 0 0 1
netname=IO25
}
N 50100 45400 49500 45400 4
{
T 49000 45300 5 10 1 1 0 0 1
netname=IO24
}
N 50100 45000 49500 45000 4
{
T 49000 44900 5 10 1 1 0 0 1
netname=IO23
}
N 50100 44600 49500 44600 4
{
T 49000 44500 5 10 1 1 0 0 1
netname=IO22
}
N 50100 44200 49500 44200 4
{
T 49000 44100 5 10 1 1 0 0 1
netname=IO19
}
N 51500 45600 52100 45600 4
{
T 52600 45700 5 10 1 1 180 0 1
netname=I31
}
N 51500 43800 52100 43800 4
{
T 52600 43900 5 10 1 1 180 0 1
netname=I6
}
N 51500 43600 52100 43600 4
{
T 52600 43700 5 10 1 1 180 0 1
netname=I7
}
N 51500 43400 52100 43400 4
{
T 52600 43500 5 10 1 1 180 0 1
netname=I8
}
N 51500 43000 52100 43000 4
{
T 52600 43100 5 10 1 1 180 0 1
netname=I9
}
N 51500 42600 52100 42600 4
{
T 52600 42700 5 10 1 1 180 0 1
netname=I10
}
N 50100 43800 49500 43800 4
{
T 49000 43700 5 10 1 1 0 0 1
netname=IO18
}
N 50100 43400 49500 43400 4
{
T 49000 43300 5 10 1 1 0 0 1
netname=IO17
}
N 50100 43000 49500 43000 4
{
T 49000 42900 5 10 1 1 0 0 1
netname=IO16
}
N 50100 42800 49500 42800 4
{
T 49000 42700 5 10 1 1 0 0 1
netname=IO15
}
N 50100 42600 49500 42600 4
{
T 49000 42500 5 10 1 1 0 0 1
netname=I14
}
N 49900 42300 49900 46800 4
N 49900 46800 51700 46800 4
N 51700 46800 51700 42400 4
N 51700 42400 51500 42400 4
N 51500 42800 51700 42800 4
N 51500 43200 51700 43200 4
N 51500 44000 51700 44000 4
N 51500 44400 51700 44400 4
N 51500 44800 51700 44800 4
N 51500 45200 51700 45200 4
N 51500 45800 51700 45800 4
N 50100 45600 49900 45600 4
N 50100 46200 49900 46200 4
N 50100 45200 49900 45200 4
N 50100 44800 49900 44800 4
N 50100 44400 49900 44400 4
N 50100 44000 49900 44000 4
N 50100 43600 49900 43600 4
N 50100 43200 49900 43200 4
C 50000 42000 1 0 1 gnd-1.sym
{
T 49700 41900 5 10 1 1 180 6 1
netname=GND
}
N 50100 42400 49900 42400 4
C 46900 41700 1 270 0 cap-small-pol.sym
{
T 47000 40980 5 10 1 1 0 6 1
refdes=C5
T 47380 41300 5 10 0 0 270 0 1
device=Cap Small
T 46900 41700 5 10 0 0 270 0 1
footprint=6032
T 46700 41400 5 10 1 1 0 0 1
value=10u
}
C 48000 40800 1 90 0 cap-small.sym
{
T 47400 41120 5 10 1 1 180 6 1
refdes=C6
T 47520 41200 5 10 0 0 90 0 1
device=Cap Small
T 48000 40800 5 10 0 0 90 0 1
footprint=0603
T 47700 41500 5 10 1 1 180 0 1
value=1u
}
C 47000 40500 1 0 0 gnd-1.sym
{
T 46900 40300 5 10 1 1 0 0 1
netname=GND
}
N 47100 40800 47100 41100 4
N 47800 41100 47800 40800 4
C 46200 41700 1 270 0 cap-small-pol.sym
{
T 46300 40980 5 10 1 1 0 6 1
refdes=C4
T 46680 41300 5 10 0 0 270 0 1
device=Cap Small
T 46200 41700 5 10 0 0 270 0 1
footprint=7343
T 45900 41400 5 10 1 1 0 0 1
value=100u
}
N 46400 41100 46400 40800 4
N 45600 41700 48500 41700 4
{
T 48000 41500 5 10 1 1 0 0 1
netname=+3.3V
}
N 46400 41700 46400 41400 4
N 47100 41400 47100 41700 4
N 47800 41400 47800 41700 4
C 44900 42100 1 180 0 connector2-2.sym
{
T 44200 40800 5 10 1 1 180 6 1
refdes=J4
T 43000 41000 5 10 1 1 0 0 1
value=22-27-2021
T 44600 40850 5 10 0 0 180 0 1
device=CONNECTOR_2
T 44600 40650 5 10 0 0 180 0 1
footprint=MOLEX2
}
C 46000 41700 1 90 0 connector2-2.sym
{
T 44500 42400 5 10 1 1 180 6 1
refdes=J3
T 44750 42000 5 10 0 0 90 0 1
device=CONNECTOR_2
T 44550 42000 5 10 0 0 90 0 1
footprint=JUMPER2
T 45100 42500 5 10 1 1 0 0 1
value=640452-2
}
N 45200 41700 44900 41700 4
N 44900 40800 44900 41300 4
N 44900 40800 47800 40800 4
T 44700 42700 9 10 1 0 0 0 1
Current test port
T 43300 40500 9 10 1 0 0 0 1
+3.3V power circuit (regulated off-board)
C 41200 42600 1 180 0 connector2-2.sym
{
T 40500 41300 5 10 1 1 180 6 1
refdes=J1
T 40900 41350 5 10 0 0 180 0 1
device=CONNECTOR_2
T 40900 41150 5 10 0 0 180 0 1
footprint=GND-LOOP
}
C 42500 42600 1 180 0 connector2-2.sym
{
T 41800 41300 5 10 1 1 180 6 1
refdes=J2
T 42200 41350 5 10 0 0 180 0 1
device=CONNECTOR_2
T 42200 41150 5 10 0 0 180 0 1
footprint=GND-LOOP
}
C 41100 41400 1 0 0 gnd-1.sym
{
T 41400 41300 5 10 1 1 180 0 1
netname=GND
}
C 42500 42300 1 270 0 vcc-small.sym
{
T 43040 42300 5 10 0 0 270 0 1
device=VCC Small
T 42600 41900 5 10 1 1 0 0 1
netname=+3.3V
}
N 42600 42200 42500 42200 4
{
T 42600 42200 5 10 0 0 0 0 1
netname=+3.3V
}
N 42500 42200 42500 41800 4
N 41200 41700 41200 42200 4
T 40500 42700 9 10 1 0 0 0 1
Ground Loop
T 41800 42700 9 10 1 0 0 0 1
Power Loop
N 51500 46200 51700 46200 4
