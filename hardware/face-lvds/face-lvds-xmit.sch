v 20070216 1
C 40000 40000 0 0 0 title-B.sym
T 50000 40700 9 10 1 0 0 0 3
Pulse Programmer
LVDS Face Board
Driver/Transformer Subsheet
T 50000 40400 9 10 1 0 0 0 1
face-lvds-xmit.sch
T 50000 40100 9 10 1 0 0 0 1
2
T 51500 40100 9 10 1 0 0 0 1
2
T 53000 40700 9 10 1 0 0 0 1
http://local-box.org
T 54000 40400 9 10 1 0 0 0 1
0
T 54000 40100 9 10 1 0 0 0 1
Paul T. Pham
C 42100 40500 1 0 0 ds90lv047.sym
{
T 44100 43100 5 10 1 1 0 6 1
refdes=U3
T 42500 44500 5 10 0 0 0 0 1
device=ds90lv047
T 42500 44700 5 10 0 0 0 0 1
footprint=TSSOP-16
T 42500 43100 5 10 1 1 0 0 1
value=DS90LV047
}
N 41700 42800 42200 42800 4
N 41700 42500 42200 42500 4
N 41700 42200 42200 42200 4
N 41700 41900 42200 41900 4
C 50300 47900 1 0 0 ds90lv047.sym
{
T 52300 50500 5 10 1 1 0 6 1
refdes=U4
T 50700 51900 5 10 0 0 0 0 1
device=ds90lv047
T 50700 52100 5 10 0 0 0 0 1
footprint=TSSOP-16
T 50700 50500 5 10 1 1 0 0 1
value=DS90LV047
}
N 50100 50200 50400 50200 4
N 50100 49900 50400 49900 4
N 50100 49600 50400 49600 4
N 50100 49300 50400 49300 4
N 49500 44700 49500 44400 4
C 49700 44400 1 90 0 cap-small.sym
{
T 49700 45120 5 10 1 1 180 6 1
refdes=C13
T 49220 44800 5 10 0 0 90 0 1
device=Cap Small
T 50200 44700 5 10 1 1 180 0 1
value=0.001u
T 49700 44400 5 10 0 0 90 0 1
footprint=0402
}
C 49400 44100 1 0 0 gnd-1.sym
{
T 49600 44100 5 10 1 1 0 0 1
netname=GND
}
C 49200 44400 1 90 0 cap-small.sym
{
T 49100 45120 5 10 1 1 180 6 1
refdes=C12
T 48720 44800 5 10 0 0 90 0 1
device=Cap Small
T 49400 44700 5 10 1 1 180 0 1
value=0.1u
T 49200 44400 5 10 0 0 90 0 1
footprint=0402
}
N 50400 44700 50300 44700 4
N 50300 44700 50300 44400 4
N 50400 45300 49000 45300 4
{
T 50400 45300 5 10 0 0 0 0 1
netname=+3.3V
}
N 50400 45000 50300 45000 4
N 50300 45000 50300 45300 4
N 49500 45000 49500 45300 4
N 49000 44700 49000 44400 4
N 49000 44400 50400 44400 4
N 49000 45000 49000 45300 4
N 50300 46500 50400 46500 4
N 50300 46200 50400 46200 4
N 50300 45900 50400 45900 4
N 50300 45600 50400 45600 4
C 50300 44200 1 0 0 ds90lv047.sym
{
T 50700 48200 5 10 0 0 0 0 1
device=ds90lv047
T 50700 48400 5 10 0 0 0 0 1
footprint=TSSOP-16
T 50700 46800 5 10 1 1 0 0 1
value=DS90LV047
T 52100 46800 5 10 1 1 0 0 1
refdes=U5
}
C 49100 45200 1 90 0 vcc-small.sym
{
T 48560 45200 5 10 0 0 90 0 1
device=VCC Small
T 48800 45500 5 10 1 1 90 0 1
netname=+3.3V
}
N 49500 48400 49500 48100 4
C 49700 48100 1 90 0 cap-small.sym
{
T 49700 48820 5 10 1 1 180 6 1
refdes=C9
T 49220 48500 5 10 0 0 90 0 1
device=Cap Small
T 50200 48400 5 10 1 1 180 0 1
value=0.001u
T 49700 48100 5 10 0 0 90 0 1
footprint=0402
}
C 49400 47800 1 0 0 gnd-1.sym
{
T 49600 47800 5 10 1 1 0 0 1
netname=GND
}
C 49200 48100 1 90 0 cap-small.sym
{
T 49100 48820 5 10 1 1 180 6 1
refdes=C7
T 48720 48500 5 10 0 0 90 0 1
device=Cap Small
T 49400 48400 5 10 1 1 180 0 1
value=0.1u
T 49200 48100 5 10 0 0 90 0 1
footprint=0402
}
N 50400 48400 50300 48400 4
N 50300 48400 50300 48100 4
N 50400 49000 49000 49000 4
{
T 50400 49000 5 10 0 0 0 0 1
netname=+3.3V
}
N 50400 48700 50300 48700 4
N 50300 48700 50300 49000 4
N 49500 48700 49500 49000 4
N 49000 48400 49000 48100 4
N 49000 48100 50400 48100 4
N 49000 48700 49000 49000 4
C 49100 48900 1 90 0 vcc-small.sym
{
T 48560 48900 5 10 0 0 90 0 1
device=VCC Small
T 48400 48700 5 10 1 1 0 0 1
netname=+3.3V
}
N 41300 41000 41300 40700 4
C 41500 40700 1 90 0 cap-small.sym
{
T 41500 41420 5 10 1 1 180 6 1
refdes=C6
T 41020 41100 5 10 0 0 90 0 1
device=Cap Small
T 42000 41000 5 10 1 1 180 0 1
value=0.001u
T 41500 40700 5 10 0 0 90 0 1
footprint=0402
}
C 41200 40400 1 0 0 gnd-1.sym
{
T 41400 40400 5 10 1 1 0 0 1
netname=GND
}
C 41000 40700 1 90 0 cap-small.sym
{
T 40900 41420 5 10 1 1 180 6 1
refdes=C5
T 40520 41100 5 10 0 0 90 0 1
device=Cap Small
T 41200 41000 5 10 1 1 180 0 1
value=0.1u
T 41000 40700 5 10 0 0 90 0 1
footprint=0402
}
N 42200 41000 42100 41000 4
N 42100 41000 42100 40700 4
N 42200 41600 40800 41600 4
{
T 42200 41600 5 10 0 0 0 0 1
netname=+3.3V
}
N 42200 41300 42100 41300 4
N 42100 41300 42100 41600 4
N 41300 41300 41300 41600 4
N 40800 41000 40800 40700 4
N 40800 40700 42200 40700 4
N 40800 41300 40800 41600 4
C 40900 41500 1 90 0 vcc-small.sym
{
T 40360 41500 5 10 0 0 90 0 1
device=VCC Small
T 40200 41300 5 10 1 1 0 0 1
netname=+3.3V
}
C 42100 47900 1 0 0 ds90lv047.sym
{
T 44100 50500 5 10 1 1 0 6 1
refdes=U1
T 42500 51900 5 10 0 0 0 0 1
device=ds90lv047
T 42500 52100 5 10 0 0 0 0 1
footprint=TSSOP-16
T 42500 50500 5 10 1 1 0 0 1
value=DS90LV047
}
C 42100 44200 1 0 0 ds90lv047.sym
{
T 44100 46800 5 10 1 1 0 6 1
refdes=U2
T 42500 48200 5 10 0 0 0 0 1
device=ds90lv047
T 42500 48400 5 10 0 0 0 0 1
footprint=TSSOP-16
T 42500 46800 5 10 1 1 0 0 1
value=DS90LV047
}
N 41700 46500 42200 46500 4
N 41700 46200 42200 46200 4
N 41700 45900 42200 45900 4
N 41700 45600 42200 45600 4
N 41300 44700 41300 44400 4
C 41500 44400 1 90 0 cap-small.sym
{
T 41500 45120 5 10 1 1 180 6 1
refdes=C4
T 41020 44800 5 10 0 0 90 0 1
device=Cap Small
T 42000 44700 5 10 1 1 180 0 1
value=0.001u
T 41500 44400 5 10 0 0 90 0 1
footprint=0402
}
C 41200 44100 1 0 0 gnd-1.sym
{
T 41400 44100 5 10 1 1 0 0 1
netname=GND
}
C 41000 44400 1 90 0 cap-small.sym
{
T 40900 45120 5 10 1 1 180 6 1
refdes=C3
T 40520 44800 5 10 0 0 90 0 1
device=Cap Small
T 41200 44700 5 10 1 1 180 0 1
value=0.1u
T 41000 44400 5 10 0 0 90 0 1
footprint=0402
}
N 42200 44700 42100 44700 4
N 42100 44700 42100 44400 4
N 42200 45300 40800 45300 4
{
T 42200 45300 5 10 0 0 0 0 1
netname=+3.3V
}
N 42200 45000 42100 45000 4
N 42100 45000 42100 45300 4
N 41300 45000 41300 45300 4
N 40800 44700 40800 44400 4
N 40800 44400 42200 44400 4
N 40800 45000 40800 45300 4
C 40900 45200 1 90 0 vcc-small.sym
{
T 40360 45200 5 10 0 0 90 0 1
device=VCC Small
T 40200 45000 5 10 1 1 0 0 1
netname=+3.3V
}
N 41100 48400 41100 48100 4
C 41300 48100 1 90 0 cap-small.sym
{
T 41300 48820 5 10 1 1 180 6 1
refdes=C2
T 40820 48500 5 10 0 0 90 0 1
device=Cap Small
T 41800 48400 5 10 1 1 180 0 1
value=0.001u
T 41300 48100 5 10 0 0 90 0 1
footprint=0402
}
C 41000 47800 1 0 0 gnd-1.sym
{
T 41200 47800 5 10 1 1 0 0 1
netname=GND
}
C 40800 48100 1 90 0 cap-small.sym
{
T 40700 48820 5 10 1 1 180 6 1
refdes=C1
T 40320 48500 5 10 0 0 90 0 1
device=Cap Small
T 41000 48400 5 10 1 1 180 0 1
value=0.1u
T 40800 48100 5 10 0 0 90 0 1
footprint=0402
}
N 42200 48400 41900 48400 4
N 41900 48400 41900 48100 4
N 42200 49000 40600 49000 4
{
T 42000 49000 5 10 0 0 0 0 1
netname=+3.3V
}
N 42200 48700 41900 48700 4
N 41900 48700 41900 49000 4
N 41100 48700 41100 49000 4
N 40600 48400 40600 48100 4
N 40600 48100 42200 48100 4
N 40600 48700 40600 49000 4
C 40700 48900 1 90 0 vcc-small.sym
{
T 40160 48900 5 10 0 0 90 0 1
device=VCC Small
T 40000 48700 5 10 1 1 0 0 1
netname=+3.3V
}
N 45400 50600 46800 50600 4
T 40800 46600 8 10 0 0 0 0 1
device=HEADER26
N 41500 50200 42200 50200 4
N 41500 49900 42200 49900 4
N 41500 49600 42200 49600 4
N 41500 49300 42200 49300 4
N 44300 49900 44500 50200 4
N 44300 49600 44500 49400 4
N 44300 49300 44500 49000 4
N 44300 48100 44400 47500 4
N 44300 46500 44600 47100 4
N 44300 45600 44600 45700 4
N 44300 45300 44400 45100 4
N 44300 45000 44400 45000 4
N 44300 42800 44500 43600 4
N 44300 42500 44500 43200 4
N 44300 42200 44500 42600 4
N 44300 41900 44500 42200 4
N 44300 41300 44400 41200 4
C 40700 50100 1 0 0 input-1.sym
{
T 40700 50400 5 10 0 0 0 0 1
device=INPUT
T 40100 50100 5 10 1 1 0 0 1
refdes=DO19
}
C 40700 49800 1 0 0 input-1.sym
{
T 40700 50100 5 10 0 0 0 0 1
device=INPUT
T 40100 49800 5 10 1 1 0 0 1
refdes=DO18
}
C 40700 49500 1 0 0 input-1.sym
{
T 40700 49800 5 10 0 0 0 0 1
device=INPUT
T 40100 49500 5 10 1 1 0 0 1
refdes=DO17
}
C 40700 49200 1 0 0 input-1.sym
{
T 40700 49500 5 10 0 0 0 0 1
device=INPUT
T 40100 49200 5 10 1 1 0 0 1
refdes=DO16
}
C 40900 46400 1 0 0 input-1.sym
{
T 40900 46700 5 10 0 0 0 0 1
device=INPUT
T 40300 46400 5 10 1 1 0 0 1
refdes=DO15
}
C 40900 46100 1 0 0 input-1.sym
{
T 40900 46400 5 10 0 0 0 0 1
device=INPUT
T 40300 46100 5 10 1 1 0 0 1
refdes=DO14
}
C 40900 45800 1 0 0 input-1.sym
{
T 40900 46100 5 10 0 0 0 0 1
device=INPUT
T 40300 45800 5 10 1 1 0 0 1
refdes=DO13
}
C 40900 45500 1 0 0 input-1.sym
{
T 40900 45800 5 10 0 0 0 0 1
device=INPUT
T 40300 45500 5 10 1 1 0 0 1
refdes=DO12
}
C 40900 42700 1 0 0 input-1.sym
{
T 40900 43000 5 10 0 0 0 0 1
device=INPUT
T 40300 42700 5 10 1 1 0 0 1
refdes=DO11
}
C 40900 42400 1 0 0 input-1.sym
{
T 40900 42700 5 10 0 0 0 0 1
device=INPUT
T 40300 42400 5 10 1 1 0 0 1
refdes=DO10
}
C 40900 42100 1 0 0 input-1.sym
{
T 40900 42400 5 10 0 0 0 0 1
device=INPUT
T 40300 42100 5 10 1 1 0 0 1
refdes=DO9
}
C 40900 41800 1 0 0 input-1.sym
{
T 40900 42100 5 10 0 0 0 0 1
device=INPUT
T 40300 41800 5 10 1 1 0 0 1
refdes=DO8
}
C 49500 46400 1 0 0 input-1.sym
{
T 49500 46700 5 10 0 0 0 0 1
device=INPUT
T 49000 46400 5 10 1 1 0 0 1
refdes=DO3
}
C 49500 46100 1 0 0 input-1.sym
{
T 49500 46400 5 10 0 0 0 0 1
device=INPUT
T 49000 46100 5 10 1 1 0 0 1
refdes=DO2
}
C 49500 45800 1 0 0 input-1.sym
{
T 49500 46100 5 10 0 0 0 0 1
device=INPUT
T 49000 45800 5 10 1 1 0 0 1
refdes=DO1
}
C 49500 45500 1 0 0 input-1.sym
{
T 49500 45800 5 10 0 0 0 0 1
device=INPUT
T 49000 45500 5 10 1 1 0 0 1
refdes=DO0
}
C 49300 49200 1 0 0 input-1.sym
{
T 49300 49500 5 10 0 0 0 0 1
device=INPUT
T 48800 49200 5 10 1 1 0 0 1
refdes=DO4
}
C 49300 49500 1 0 0 input-1.sym
{
T 49300 49800 5 10 0 0 0 0 1
device=INPUT
T 48800 49500 5 10 1 1 0 0 1
refdes=DO5
}
C 49300 49800 1 0 0 input-1.sym
{
T 49300 50100 5 10 0 0 0 0 1
device=INPUT
T 48800 49800 5 10 1 1 0 0 1
refdes=DO6
}
C 49300 50100 1 0 0 input-1.sym
{
T 49300 50400 5 10 0 0 0 0 1
device=INPUT
T 48800 50100 5 10 1 1 0 0 1
refdes=DO7
}
C 50200 42800 1 0 0 input-1.sym
{
T 50200 43100 5 10 0 0 0 0 1
device=INPUT
T 49700 42800 5 10 1 1 0 0 1
refdes=GND
}
C 50200 43200 1 0 0 input-1.sym
{
T 50200 43500 5 10 0 0 0 0 1
device=INPUT
T 49600 43200 5 10 1 1 0 0 1
refdes=+3.3V
}
C 51100 42600 1 0 0 gnd-1.sym
{
T 51300 42600 5 10 1 1 0 0 1
netname=GND
}
N 51000 43300 52100 43300 4
{
T 51600 43100 5 10 1 1 0 0 1
netname=+3.3V
}
N 51000 42900 51200 42900 4
C 50200 41900 1 0 0 input-1.sym
{
T 50200 42200 5 10 0 0 0 0 1
device=INPUT
T 49600 41900 5 10 1 1 0 0 1
refdes=CGND
}
C 50200 42300 1 0 0 input-1.sym
{
T 50200 42600 5 10 0 0 0 0 1
device=INPUT
T 49800 42300 5 10 1 1 0 0 1
refdes=+12V
}
N 51000 42400 52100 42400 4
{
T 51600 42200 5 10 1 1 0 0 1
netname=+12V
}
N 51000 42000 52100 42000 4
{
T 51500 41800 5 10 1 1 0 0 1
netname=CGND
}
N 45500 47100 46800 47100 4
N 45500 46700 46000 46700 4
T 57800 50800 8 10 0 0 270 0 1
device=RJ45
T 57600 50800 8 10 0 0 270 0 1
footprint=RJ45_VERT
T 57800 47800 8 10 0 0 270 0 1
device=RJ45
T 57600 47800 8 10 0 0 270 0 1
footprint=RJ45_VERT
N 46200 46100 45500 46100 4
N 45500 45700 46700 45700 4
N 48200 50100 48100 50100 4
N 48200 49300 48200 50100 4
{
T 48300 49500 5 10 1 1 270 6 1
netname=CGND
}
C 48300 50500 1 180 0 rj45.sym
{
T 47900 50400 5 10 1 1 0 0 1
refdes=J2
T 48300 47600 5 10 0 0 180 0 1
device=RJ45
T 48300 47800 5 10 0 0 180 0 1
footprint=RJ45_VERT
T 47200 50600 5 10 1 1 0 0 1
value=RJHSE-3380
}
N 48100 49300 48200 49300 4
N 46800 50600 46800 49300 4
N 46800 49300 46900 49300 4
N 45400 50200 46000 50200 4
N 46000 50200 46000 49900 4
N 46000 49900 46900 49900 4
N 45400 49800 46600 49800 4
N 46600 49800 46600 50300 4
N 46600 50300 46900 50300 4
N 46400 49200 46700 49200 4
N 46700 49200 46700 50100 4
N 46700 50100 46900 50100 4
N 45500 48400 46600 48400 4
N 45400 48400 45400 48500 4
N 46500 48500 46500 49700 4
N 46500 49700 46900 49700 4
N 46600 48400 46600 49500 4
N 46700 48100 46700 49100 4
N 46700 49100 46900 49100 4
N 46700 47700 46900 47700 4
N 46900 47700 46900 48900 4
N 46700 47900 48400 47900 4
{
T 47400 47900 5 10 0 0 0 0 1
netname=+12V
}
C 47600 44300 1 0 0 vcc-small.sym
{
T 47600 44840 5 10 0 0 0 0 1
device=VCC Small
T 47300 44700 5 10 1 1 0 0 1
netname=+12V
}
N 46600 44400 48400 44400 4
{
T 47400 44400 5 10 0 0 0 0 1
netname=+12V
}
C 47500 44500 1 270 0 cap-small-pol.sym
{
T 47600 43780 5 10 1 1 0 6 1
refdes=C19
T 47980 44100 5 10 0 0 270 0 1
device=Cap Small
T 47500 44500 5 10 0 0 270 0 1
footprint=6032
T 47300 44200 5 10 1 1 0 0 1
value=10u
}
C 48600 43600 1 90 0 cap-small.sym
{
T 48000 43920 5 10 1 1 180 6 1
refdes=C20
T 48120 44000 5 10 0 0 90 0 1
device=Cap Small
T 48600 43600 5 10 0 0 90 0 1
footprint=0603
T 48300 44300 5 10 1 1 180 0 1
value=1u
}
N 47700 44400 47700 44200 4
N 47700 43900 47700 43700 4
N 48400 44400 48400 44200 4
N 48400 43900 48400 43700 4
N 48200 46700 48100 46700 4
N 48200 45900 48200 46700 4
{
T 48300 46100 5 10 1 1 270 6 1
netname=CGND
}
C 48300 47100 1 180 0 rj45.sym
{
T 47900 45300 5 10 1 1 0 0 1
refdes=J5
T 48300 44200 5 10 0 0 180 0 1
device=RJ45
T 48300 44400 5 10 0 0 180 0 1
footprint=RJ45_VERT
T 47200 45100 5 10 1 1 0 0 1
value=RJHSE-3380
}
N 48100 45900 48200 45900 4
N 46800 44600 46800 45700 4
N 44300 46200 44600 46700 4
N 44600 46100 44300 45900 4
N 45300 45200 46500 45200 4
N 45600 44800 46600 44800 4
C 45400 44100 1 0 0 ttwb-1-b.sym
{
T 46100 44600 5 10 1 1 0 0 1
refdes=T8
T 45400 45500 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44700 44300 5 10 1 1 0 0 1
value=TTWB-1-B
T 45400 43900 5 10 0 0 0 0 1
footprint=TF-6
}
C 45500 47600 1 0 0 ttwb-1-b.sym
{
T 46100 47400 5 10 1 1 0 0 1
refdes=T4
T 45400 48900 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44700 47600 5 10 1 1 0 0 1
value=TTWB-1-B
T 45400 47300 5 10 0 0 0 0 1
footprint=TF-6
}
N 44300 44700 44500 44500 4
N 44500 44500 45700 44500 4
N 44300 44400 44500 44200 4
N 44500 44200 45700 44200 4
N 46800 44600 46600 44600 4
N 46900 44200 46900 45500 4
N 46900 44200 46600 44200 4
N 44300 50200 44500 50600 4
C 45400 40400 1 0 0 ttwb-1-b.sym
{
T 46000 40900 5 10 1 1 0 0 1
refdes=T15
T 45400 42000 5 10 0 1 0 0 1
device=TRANSFORMER 
T 45700 40200 5 10 1 1 0 0 1
value=TTWB-1-B
T 45400 40400 5 10 0 0 0 0 1
footprint=TF-6
}
N 45400 43600 46800 43600 4
N 45400 42600 46600 42600 4
N 45400 42200 46700 42200 4
N 48200 43100 48100 43100 4
N 48200 42300 48200 43100 4
{
T 48300 42500 5 10 1 1 270 6 1
netname=CGND
}
C 48300 43500 1 180 0 rj45.sym
{
T 47900 43200 5 10 1 1 0 0 1
refdes=J9
T 48300 40600 5 10 0 0 180 0 1
device=RJ45
T 48300 40800 5 10 0 0 180 0 1
footprint=RJ45_VERT
T 47200 41500 5 10 1 1 0 0 1
value=RJHSE-3380
}
N 48100 42300 48200 42300 4
N 46700 40900 46700 42100 4
N 45600 43000 45400 43200 4
N 45300 41600 46500 41600 4
N 45500 41100 46600 41100 4
N 46600 40900 46700 40900 4
N 46800 40500 46800 41900 4
N 46800 40500 46600 40500 4
N 44300 41000 45500 41000 4
N 45500 41000 45700 40900 4
N 44300 40700 45500 40700 4
N 45500 40700 45700 40500 4
C 48300 43400 1 0 0 gnd-1.sym
{
T 48700 43300 5 10 1 1 180 0 1
netname=GND
}
C 47600 40800 1 0 0 vcc-small.sym
{
T 47600 41340 5 10 0 0 0 0 1
device=VCC Small
T 47300 41200 5 10 1 1 0 0 1
netname=+12V
}
C 47500 41000 1 270 0 cap-small-pol.sym
{
T 47600 40280 5 10 1 1 0 6 1
refdes=C21
T 47980 40600 5 10 0 0 270 0 1
device=Cap Small
T 47500 41000 5 10 0 0 270 0 1
footprint=6032
T 47300 40700 5 10 1 1 0 0 1
value=10u
}
C 48600 40100 1 90 0 cap-small.sym
{
T 48000 40420 5 10 1 1 180 6 1
refdes=C22
T 48120 40500 5 10 0 0 90 0 1
device=Cap Small
T 48600 40100 5 10 0 0 90 0 1
footprint=0603
T 48300 40800 5 10 1 1 180 0 1
value=1u
}
N 47700 40900 47700 40700 4
N 47700 40400 47700 40200 4
N 48400 40900 48400 40700 4
N 48400 40400 48400 40200 4
C 48700 40100 1 90 0 gnd-1.sym
{
T 48800 40500 5 10 1 1 270 0 1
netname=GND
}
N 47000 40900 48400 40900 4
{
T 47400 40900 5 10 0 0 0 0 1
netname=+12V
}
C 47600 47800 1 0 0 vcc-small.sym
{
T 47600 48340 5 10 0 0 0 0 1
device=VCC Small
T 47300 48200 5 10 1 1 0 0 1
netname=+12V
}
C 47500 48000 1 270 0 cap-small-pol.sym
{
T 47600 47280 5 10 1 1 0 6 1
refdes=C17
T 47980 47600 5 10 0 0 270 0 1
device=Cap Small
T 47500 48000 5 10 0 0 270 0 1
footprint=6032
T 47300 47700 5 10 1 1 0 0 1
value=10u
}
N 47700 47900 47700 47700 4
N 47700 47400 47700 47200 4
N 48400 47900 48400 47700 4
N 48400 47400 48400 47200 4
C 48300 46900 1 0 0 gnd-1.sym
{
T 48700 46800 5 10 1 1 180 0 1
netname=GND
}
C 48600 47100 1 90 0 cap-small.sym
{
T 48000 47420 5 10 1 1 180 6 1
refdes=C18
T 48120 47500 5 10 0 0 90 0 1
device=Cap Small
T 48600 47100 5 10 0 0 90 0 1
footprint=0603
T 48300 47800 5 10 1 1 180 0 1
value=1u
}
N 53500 50600 55000 50600 4
N 52500 49900 52600 50200 4
N 52500 49600 52600 49600 4
N 52500 49300 52600 49200 4
N 52600 48600 52500 49000 4
N 52500 48700 52600 48200 4
N 52500 48400 52600 48000 4
N 52600 48000 53900 48000 4
N 52500 48100 52600 47500 4
N 52600 47500 53900 47500 4
N 52500 46500 52700 47100 4
N 52500 45600 52700 45700 4
N 52500 45300 52600 45100 4
N 52500 45000 52600 44700 4
N 53600 47100 55000 47100 4
N 53800 46500 55100 46500 4
N 54600 46100 53600 46100 4
N 54800 47900 55000 47900 4
N 56400 50100 56300 50100 4
N 56400 49300 56400 50100 4
{
T 56500 49500 5 10 1 1 270 6 1
netname=CGND
}
C 56500 50500 1 180 0 rj45.sym
{
T 56100 50400 5 10 1 1 0 0 1
refdes=J10
T 56500 47600 5 10 0 0 180 0 1
device=RJ45
T 56500 47800 5 10 0 0 180 0 1
footprint=RJ45_VERT
T 55400 48500 5 10 1 1 0 0 1
value=RJHSE-3380
}
N 56300 49300 56400 49300 4
N 53500 50200 54200 50200 4
N 53500 49600 54600 49600 4
N 53500 49200 54900 49200 4
N 53500 48700 54700 48700 4
N 54700 48700 54700 49700 4
N 55000 47900 55000 49100 4
N 54800 47500 55100 47500 4
N 55100 47500 55100 48900 4
N 55200 47900 56600 47900 4
{
T 55600 47900 5 10 0 0 0 0 1
netname=+12V
}
C 55800 44300 1 0 0 vcc-small.sym
{
T 55800 44840 5 10 0 0 0 0 1
device=VCC Small
T 55500 44700 5 10 1 1 0 0 1
netname=+12V
}
N 55300 44400 56600 44400 4
{
T 55600 44400 5 10 0 0 0 0 1
netname=+12V
}
C 55700 44500 1 270 0 cap-small-pol.sym
{
T 55800 43780 5 10 1 1 0 6 1
refdes=C23
T 56180 44100 5 10 0 0 270 0 1
device=Cap Small
T 55700 44500 5 10 0 0 270 0 1
footprint=6032
T 55500 44200 5 10 1 1 0 0 1
value=10u
}
C 56800 43600 1 90 0 cap-small.sym
{
T 56200 43920 5 10 1 1 180 6 1
refdes=C25
T 56320 44000 5 10 0 0 90 0 1
device=Cap Small
T 56800 43600 5 10 0 0 90 0 1
footprint=0603
T 56500 44300 5 10 1 1 180 0 1
value=1u
}
N 55900 44400 55900 44200 4
N 55900 43900 55900 43700 4
N 56600 44400 56600 44200 4
N 56600 43900 56600 43700 4
N 56400 46700 56300 46700 4
N 56400 45900 56400 46700 4
{
T 56500 46100 5 10 1 1 270 6 1
netname=CGND
}
C 56500 47100 1 180 0 rj45.sym
{
T 56100 45300 5 10 1 1 0 0 1
refdes=J11
T 56500 44200 5 10 0 0 180 0 1
device=RJ45
T 56500 44400 5 10 0 0 180 0 1
footprint=RJ45_VERT
T 55400 45100 5 10 1 1 0 0 1
value=RJHSE-3380
}
N 56300 45900 56400 45900 4
N 55000 44400 55000 45700 4
N 52500 46200 52700 46700 4
N 52700 46100 52500 45900 4
N 53800 46500 53600 46700 4
N 53600 45700 54900 45700 4
N 53500 45100 54700 45100 4
N 54700 45100 54700 46300 4
C 53600 43900 1 0 0 ttwb-1-b.sym
{
T 54200 44400 5 10 1 1 0 0 1
refdes=T19
T 53600 45500 5 10 0 1 0 0 1
device=TRANSFORMER 
T 52800 44300 5 10 1 1 0 0 1
value=TTWB-1-B
T 53600 43900 5 10 0 0 0 0 1
footprint=TF-6
}
C 53600 47400 1 0 0 ttwb-1-b.sym
{
T 54200 47900 5 10 1 1 0 0 1
refdes=T20
T 53600 49000 5 10 0 1 0 0 1
device=TRANSFORMER 
T 53000 47600 5 10 1 1 0 0 1
value=TTWB-1-B
T 53600 47400 5 10 0 0 0 0 1
footprint=TF-6
}
N 52500 44700 52700 44500 4
N 52700 44500 53900 44500 4
N 52500 44400 52600 44200 4
N 55000 44400 54800 44400 4
N 55100 44000 55100 45500 4
N 55100 44000 54800 44000 4
N 52500 50200 52600 50600 4
C 56500 43400 1 0 0 gnd-1.sym
{
T 56900 43300 5 10 1 1 180 0 1
netname=GND
}
C 55800 47800 1 0 0 vcc-small.sym
{
T 55800 48340 5 10 0 0 0 0 1
device=VCC Small
T 55500 48200 5 10 1 1 0 0 1
netname=+12V
}
C 55700 48000 1 270 0 cap-small-pol.sym
{
T 55800 47280 5 10 1 1 0 6 1
refdes=C24
T 56180 47600 5 10 0 0 270 0 1
device=Cap Small
T 55700 48000 5 10 0 0 270 0 1
footprint=6032
T 55500 47700 5 10 1 1 0 0 1
value=10u
}
N 55900 47900 55900 47700 4
N 55900 47400 55900 47200 4
N 56600 47900 56600 47700 4
N 56600 47400 56600 47200 4
C 56500 46900 1 0 0 gnd-1.sym
{
T 56500 47100 5 10 1 1 180 0 1
netname=GND
}
C 56800 47100 1 90 0 cap-small.sym
{
T 56200 47420 5 10 1 1 180 6 1
refdes=C26
T 56320 47500 5 10 0 0 90 0 1
device=Cap Small
T 56800 47100 5 10 0 0 90 0 1
footprint=0603
T 56500 47800 5 10 1 1 180 0 1
value=1u
}
N 46600 49500 46900 49500 4
N 46800 47100 46800 45900 4
N 46800 45900 46900 45900 4
N 46000 46700 46000 46500 4
N 46000 46500 46900 46500 4
N 46600 46400 46600 46900 4
N 46600 46900 46900 46900 4
N 46700 45700 46700 46700 4
N 46700 46700 46900 46700 4
N 46500 45200 46500 46300 4
N 46500 46300 46900 46300 4
N 46600 44800 46600 46100 4
N 46800 45700 46900 45700 4
N 46600 46100 46900 46100 4
N 46600 46400 46200 46400 4
N 46200 46400 46200 46100 4
N 46800 43600 46800 42300 4
N 46800 42300 46900 42300 4
N 46600 42600 46600 43300 4
N 46600 43300 46900 43300 4
N 46700 42200 46700 43100 4
N 46700 43100 46900 43100 4
N 46500 41600 46500 42700 4
N 46500 42700 46900 42700 4
N 46600 41100 46600 42500 4
N 46700 42100 46900 42100 4
N 46800 41900 46900 41900 4
N 46600 42500 46900 42500 4
N 46500 42900 46900 42900 4
N 46500 42900 46500 43000 4
N 45600 43000 46500 43000 4
N 55000 47100 55000 45900 4
N 55000 45900 55100 45900 4
N 54800 46400 54800 46900 4
N 54800 46900 55100 46900 4
N 54900 45700 54900 46700 4
N 54900 46700 55100 46700 4
N 54700 46300 55100 46300 4
N 54800 44700 54800 46100 4
N 55000 45700 55100 45700 4
N 54800 46100 55100 46100 4
N 54800 46400 54600 46400 4
N 54600 46400 54600 46100 4
N 55000 50600 55000 49300 4
N 55000 49300 55100 49300 4
N 54200 50200 54200 49900 4
N 54200 49900 55100 49900 4
N 54600 49600 54600 50300 4
N 54600 50300 55100 50300 4
N 54900 49200 54900 50100 4
N 54900 50100 55100 50100 4
N 54700 49700 55100 49700 4
N 54800 48200 54800 49500 4
N 55000 49100 55100 49100 4
N 54800 49500 55100 49500 4
C 44200 47900 1 0 0 ttwb-1-b.sym
{
T 44900 48400 5 10 1 1 0 0 1
refdes=T3
T 44200 49500 5 10 0 1 0 0 1
device=TRANSFORMER 
T 42900 47400 5 10 0 1 0 0 1
value=TTWB-1-B
T 44200 47900 5 10 0 0 0 0 1
footprint=TF-6
}
N 44300 48400 44400 47800 4
N 44400 47800 45600 47800 4
N 44300 48700 44500 48000 4
N 45500 48400 45500 48000 4
N 45500 48000 45400 48000 4
N 45400 48200 45400 48300 4
N 47700 47200 48400 47200 4
N 45700 44500 45700 44600 4
C 44100 44600 1 0 0 ttwb-1-b.sym
{
T 44800 45100 5 10 1 1 0 0 1
refdes=T7
T 44100 46200 5 10 0 1 0 0 1
device=TRANSFORMER 
T 45400 45000 5 10 1 1 0 0 1
value=TTWB-1-B
T 44100 44600 5 10 0 0 0 0 1
footprint=TF-6
}
N 44400 45000 44400 44700 4
N 45600 44800 45600 44700 4
N 45600 44700 45300 44700 4
N 45300 44900 47100 44900 4
N 47100 44900 47100 44400 4
N 47700 43700 48400 43700 4
C 44100 41100 1 0 0 ttwb-1-b.sym
{
T 44700 41600 5 10 1 1 0 0 1
refdes=T12
T 44100 42700 5 10 0 1 0 0 1
device=TRANSFORMER 
T 45500 41400 5 10 1 1 0 0 1
value=TTWB-1-B
T 44100 41100 5 10 0 0 0 0 1
footprint=TF-6
}
N 45300 41200 45500 41200 4
N 45500 41200 45500 41100 4
N 45300 41400 45400 41400 4
N 45400 41400 45400 41300 4
N 45400 41300 47100 41300 4
N 47100 41300 47100 40900 4
N 47700 40200 48400 40200 4
N 44400 41600 44300 41600 4
C 52300 48100 1 0 0 ttwb-1-b.sym
{
T 52900 48600 5 10 1 1 0 0 1
refdes=T14
T 52300 49700 5 10 0 1 0 0 1
device=TRANSFORMER 
T 53600 48500 5 10 1 1 0 0 1
value=TTWB-1-B
T 52300 48100 5 10 0 0 0 0 1
footprint=TF-6
}
N 53900 48000 53900 47900 4
N 54800 48200 53500 48200 4
N 53500 48400 55200 48400 4
N 55900 47200 56600 47200 4
C 52300 44600 1 0 0 ttwb-1-b.sym
{
T 52900 45100 5 10 1 1 0 0 1
refdes=T18
T 52300 46200 5 10 0 1 0 0 1
device=TRANSFORMER 
T 53600 44900 5 10 1 1 0 0 1
value=TTWB-1-B
T 52300 44600 5 10 0 0 0 0 1
footprint=TF-6
}
N 53900 44500 53900 44400 4
N 52600 44200 53900 44200 4
N 53900 44200 53900 44000 4
N 53500 44700 54800 44700 4
N 53500 44800 55300 44800 4
N 55900 43700 56600 43700 4
C 44200 48900 1 0 0 ttwb-1-b.sym
{
T 44900 49500 5 10 1 1 0 0 1
refdes=T2
T 44200 50500 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44600 48700 5 10 1 1 0 0 1
value=TTWB-1-B
T 44200 48900 5 10 0 0 0 0 1
footprint=TF-6
}
N 44300 49000 44400 49000 4
N 44400 49000 44500 48400 4
N 46500 48500 45400 48500 4
N 46800 47900 46800 48300 4
N 46800 48300 45400 48300 4
N 46400 49200 46400 49000 4
N 46400 49000 45400 49000 4
N 45400 49200 45700 49200 4
C 46000 49100 1 90 0 gnd-1.sym
{
T 46000 49300 5 10 1 1 0 0 1
netname=GND
}
C 44200 50100 1 0 0 ttwb-1-b.sym
{
T 44900 50600 5 10 1 1 0 0 1
refdes=T1
T 44100 51600 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44500 49900 5 10 1 1 0 0 1
value=TTWB-1-B
T 44100 50000 5 10 0 0 0 0 1
footprint=TF-6
}
N 45600 47800 45600 48100 4
N 45600 48100 45800 48100 4
N 44400 47500 45700 47500 4
N 45700 47500 45800 47700 4
N 45400 49800 45400 49400 4
C 45900 50300 1 90 0 gnd-1.sym
{
T 46000 50300 5 10 1 1 0 0 1
netname=GND
}
N 45400 50400 45600 50400 4
C 44300 46600 1 0 0 ttwb-1-b.sym
{
T 45000 47100 5 10 1 1 0 0 1
refdes=T5
T 44200 48100 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44700 46400 5 10 1 1 0 0 1
value=TTWB-1-B
T 44200 46500 5 10 0 0 0 0 1
footprint=TF-6
}
N 45500 46900 45600 46900 4
C 45900 46800 1 90 0 gnd-1.sym
{
T 46000 46800 5 10 1 1 0 0 1
netname=GND
}
N 45300 45200 45300 45100 4
C 44300 45600 1 0 0 ttwb-1-b.sym
{
T 45000 46100 5 10 1 1 0 0 1
refdes=T6
T 44200 47100 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44600 45400 5 10 1 1 0 0 1
value=TTWB-1-B
T 44200 45500 5 10 0 0 0 0 1
footprint=TF-6
}
N 45500 45900 45600 45900 4
C 45900 45800 1 90 0 gnd-1.sym
{
T 46000 45800 5 10 1 1 0 0 1
netname=GND
}
N 47000 40900 47000 40700 4
N 47000 40700 46600 40700 4
C 44200 42100 1 0 0 ttwb-1-b.sym
{
T 44800 42600 5 10 1 1 0 0 1
refdes=T10
T 44100 43600 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44500 41900 5 10 1 1 0 0 1
value=TTWB-1-B
T 44100 42000 5 10 0 0 0 0 1
footprint=TF-6
}
C 45800 42300 1 90 0 gnd-1.sym
{
T 45900 42300 5 10 1 1 0 0 1
netname=GND
}
N 45400 42400 45500 42400 4
C 44200 43100 1 0 0 ttwb-1-b.sym
{
T 44900 43600 5 10 1 1 0 0 1
refdes=T9
T 44100 44600 5 10 0 1 0 0 1
device=TRANSFORMER 
T 44500 42900 5 10 1 1 0 0 1
value=TTWB-1-B
T 44100 43000 5 10 0 0 0 0 1
footprint=TF-6
}
C 45800 43300 1 90 0 gnd-1.sym
{
T 45900 43300 5 10 1 1 0 0 1
netname=GND
}
N 45400 43400 45500 43400 4
C 52300 50100 1 0 0 ttwb-1-b.sym
{
T 52900 50600 5 10 1 1 0 0 1
refdes=T11
T 52200 51600 5 10 0 1 0 0 1
device=TRANSFORMER 
T 52600 49900 5 10 1 1 0 0 1
value=TTWB-1-B
T 52200 50000 5 10 0 0 0 0 1
footprint=TF-6
}
C 54000 50300 1 90 0 gnd-1.sym
{
T 54100 50300 5 10 1 1 0 0 1
netname=GND
}
N 53500 50400 53700 50400 4
C 52300 49100 1 0 0 ttwb-1-b.sym
{
T 52900 49600 5 10 1 1 0 0 1
refdes=T13
T 52200 50600 5 10 0 1 0 0 1
device=TRANSFORMER 
T 52600 48900 5 10 1 1 0 0 1
value=TTWB-1-B
T 52200 49000 5 10 0 0 0 0 1
footprint=TF-6
}
N 53500 49400 53700 49400 4
C 54000 49300 1 90 0 gnd-1.sym
{
T 54100 49300 5 10 1 1 0 0 1
netname=GND
}
N 54800 47700 55200 47700 4
N 55200 47700 55200 48400 4
N 53500 48700 53500 48600 4
N 55300 44200 55300 44800 4
N 55300 44200 54800 44200 4
N 53500 44800 53500 44900 4
C 52400 45600 1 0 0 ttwb-1-b.sym
{
T 53000 46100 5 10 1 1 0 0 1
refdes=T17
T 52300 47100 5 10 0 1 0 0 1
device=TRANSFORMER 
T 53400 45500 5 10 1 1 0 0 1
value=TTWB-1-B
T 52300 45500 5 10 0 0 0 0 1
footprint=TF-6
}
N 53600 45900 53700 45900 4
C 54000 45800 1 90 0 gnd-1.sym
{
T 54100 45800 5 10 1 1 0 0 1
netname=GND
}
N 53600 46900 53700 46900 4
C 54000 46800 1 90 0 gnd-1.sym
{
T 54100 46800 5 10 1 1 0 0 1
netname=GND
}
C 52400 46600 1 0 0 ttwb-1-b.sym
{
T 53000 47100 5 10 1 1 0 0 1
refdes=T16
T 52300 48100 5 10 0 1 0 0 1
device=TRANSFORMER 
T 52700 46400 5 10 1 1 0 0 1
value=TTWB-1-B
T 52300 46500 5 10 0 0 0 0 1
footprint=TF-6
}
