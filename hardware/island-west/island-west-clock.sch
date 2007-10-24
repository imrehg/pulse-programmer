v 20070216 1
C 40000 40000 0 0 0 title-B.sym
T 50000 40700 9 10 1 0 0 0 3
Pulse Programmer
West Island Board
Clock Fanout Buffer Subsheet
T 50000 40400 9 10 1 0 0 0 1
island-west-clock.sch
T 50000 40100 9 10 1 0 0 0 1
3
T 51500 40100 9 10 1 0 0 0 1
3
T 53300 40700 9 10 1 0 0 0 1
http://local-box.org
T 54000 40400 9 10 1 0 0 0 1
A
T 54000 40100 9 10 1 0 0 0 1
Paul T. Pham
T 40800 46600 8 10 0 0 0 0 1
device=HEADER26
T 57800 50800 8 10 0 0 270 0 1
device=RJ45
T 57600 50800 8 10 0 0 270 0 1
footprint=RJ45_VERT
T 57800 47800 8 10 0 0 270 0 1
device=RJ45
T 57600 47800 8 10 0 0 270 0 1
footprint=RJ45_VERT
C 42700 50100 1 0 0 input-1.sym
{
T 42700 50400 5 10 0 0 0 0 1
device=INPUT
T 42200 50100 5 10 1 1 0 0 1
refdes=GND
}
C 42700 50500 1 0 0 input-1.sym
{
T 42700 50800 5 10 0 0 0 0 1
device=INPUT
T 42100 50500 5 10 1 1 0 0 1
refdes=+3.3V
}
C 43600 49900 1 0 0 gnd-1.sym
{
T 43800 49900 5 10 1 1 0 0 1
netname=GND
}
N 43500 50600 44600 50600 4
{
T 44100 50400 5 10 1 1 0 0 1
netname=+3.3V
}
N 43500 50200 43700 50200 4
C 44400 43000 1 0 0 PCK9446.sym
{
T 48200 46600 5 10 1 1 0 6 1
refdes=U2
T 44800 48300 5 10 0 0 0 0 1
device=PCK9446
T 44800 48500 5 10 0 0 0 0 1
footprint=LQFP-32
}
C 43600 45300 1 0 0 input-1.sym
{
T 43600 45600 5 10 0 0 0 0 1
device=INPUT
T 42700 45300 5 10 1 1 0 0 1
refdes=CLK_IN0
}
N 44400 45400 44500 45400 4
N 45600 43100 45600 43000 4
N 46200 43100 46200 43000 4
N 46800 43100 46800 43000 4
N 47400 43100 47400 43000 4
N 48200 44500 48300 44500 4
N 48200 45100 48300 45100 4
N 48200 45700 48500 45700 4
N 47200 47100 47200 47300 4
N 46600 47100 46600 47300 4
N 46000 47100 46000 47300 4
N 44500 45700 41700 45700 4
{
T 41700 45800 5 10 1 1 0 0 1
netname=+3.3V
}
N 46500 43100 46500 40800 4
{
T 46600 40100 5 10 1 1 90 0 1
netname=+3.3V
}
N 48200 44200 51100 44200 4
{
T 51700 44300 5 10 1 1 180 0 1
netname=+3.3V
}
N 48200 43900 49500 43900 4
{
T 48800 43800 5 10 1 1 180 0 1
netname=+3.3V
}
N 48200 45400 51100 45400 4
{
T 51700 45500 5 10 1 1 180 0 1
netname=+3.3V
}
N 47500 47100 47500 48800 4
{
T 47600 48800 5 10 1 1 270 0 1
netname=+3.3V
}
N 46300 47100 46300 48800 4
{
T 46400 48800 5 10 1 1 270 0 1
netname=+3.3V
}
C 44000 43600 1 0 0 gnd-1.sym
{
T 44200 43600 5 10 1 1 0 0 1
netname=GND
}
C 47000 40600 1 0 0 gnd-1.sym
{
T 47200 40100 5 10 1 1 90 0 1
netname=GND
}
C 45800 40600 1 0 0 gnd-1.sym
{
T 46000 40100 5 10 1 1 90 0 1
netname=GND
}
N 45300 43100 45300 40700 4
{
T 45400 40100 5 10 1 1 90 0 1
netname=+3.3V
}
C 51100 44700 1 90 0 gnd-1.sym
{
T 51600 44900 5 10 1 1 180 0 1
netname=GND
}
C 51100 45900 1 90 0 gnd-1.sym
{
T 51600 46100 5 10 1 1 180 0 1
netname=GND
}
C 47000 48900 1 180 0 gnd-1.sym
{
T 46800 49400 5 10 1 1 270 0 1
netname=GND
}
C 45800 48900 1 180 0 gnd-1.sym
{
T 45600 49400 5 10 1 1 270 0 1
netname=GND
}
N 45900 43100 45900 40900 4
N 47100 43100 47100 40900 4
N 48200 44800 50800 44800 4
N 48200 46000 50800 46000 4
N 46900 48600 46900 47100 4
N 45700 48600 45700 47100 4
C 45100 41100 1 0 0 cap-small.sym
{
T 45520 41000 5 10 1 1 90 6 1
refdes=C4
T 45500 41580 5 10 0 0 0 0 1
device=Cap Small
T 45800 40800 5 10 1 1 90 0 1
value=0.1u
T 45100 41100 5 10 0 0 0 0 1
footprint=0402
}
N 45300 41300 45400 41300 4
N 45700 41300 45900 41300 4
C 45700 41100 1 0 0 cap-small.sym
{
T 46120 41000 5 10 1 1 90 6 1
refdes=C5
T 46100 41580 5 10 0 0 0 0 1
device=Cap Small
T 46400 40800 5 10 1 1 90 0 1
value=0.1u
T 45700 41100 5 10 0 0 0 0 1
footprint=0402
}
N 45900 41300 46000 41300 4
N 46300 41300 46500 41300 4
C 48600 42800 1 270 0 cap-small.sym
{
T 48500 42380 5 10 1 1 0 6 1
refdes=C7
T 49080 42400 5 10 0 0 270 0 1
device=Cap Small
T 48300 42100 5 10 1 1 0 0 1
value=0.1u
T 48600 42800 5 10 0 0 270 0 1
footprint=0402
}
N 48800 42500 48800 43900 4
N 48800 42200 48800 41200 4
N 48800 41200 47100 41200 4
C 50700 44000 1 90 0 cap-small.sym
{
T 50800 44420 5 10 1 1 180 6 1
refdes=C9
T 50220 44400 5 10 0 0 90 0 1
device=Cap Small
T 51000 44700 5 10 1 1 180 0 1
value=0.1u
T 50700 44000 5 10 0 0 90 0 1
footprint=0402
}
N 50500 44300 50500 44200 4
N 50500 44600 50500 44800 4
C 50700 45200 1 90 0 cap-small.sym
{
T 50800 45620 5 10 1 1 180 6 1
refdes=C6
T 50220 45600 5 10 0 0 90 0 1
device=Cap Small
T 51000 45900 5 10 1 1 180 0 1
value=0.1u
T 50700 45200 5 10 0 0 90 0 1
footprint=0402
}
N 50500 45500 50500 45400 4
N 50500 45800 50500 46000 4
C 47700 48400 1 180 0 cap-small.sym
{
T 47280 48500 5 10 1 1 270 6 1
refdes=C3
T 47300 47920 5 10 0 0 180 0 1
device=Cap Small
T 47000 48700 5 10 1 1 270 0 1
value=0.1u
T 47700 48400 5 10 0 0 180 0 1
footprint=0402
}
N 47400 48200 47500 48200 4
N 47100 48200 46900 48200 4
C 46500 48400 1 180 0 cap-small.sym
{
T 46080 48500 5 10 1 1 270 6 1
refdes=C2
T 46100 47920 5 10 0 0 180 0 1
device=Cap Small
T 45800 48700 5 10 1 1 270 0 1
value=0.1u
T 46500 48400 5 10 0 0 180 0 1
footprint=0402
}
N 46200 48200 46300 48200 4
N 45900 48200 45700 48200 4
C 44900 47200 1 90 0 connector2-2.sym
{
T 43400 47900 5 10 1 1 180 6 1
refdes=J19
T 44000 48000 5 10 1 1 0 0 1
value=640452-2
T 43650 47500 5 10 0 0 90 0 1
device=CONNECTOR_2
T 43450 47500 5 10 0 0 90 0 1
footprint=JUMPER2
}
C 42000 45300 1 270 0 cap-small.sym
{
T 41900 44880 5 10 1 1 0 6 1
refdes=C1
T 42480 44900 5 10 0 0 270 0 1
device=Cap Small
T 41700 44600 5 10 1 1 0 0 1
value=0.1u
T 42000 45300 5 10 0 0 270 0 1
footprint=0402
}
N 42200 45700 42200 45000 4
N 42200 44700 42200 43900 4
N 42200 43900 44500 43900 4
N 44500 46000 44400 46000 4
N 44500 45100 44400 45100 4
N 45400 47100 45400 47200 4
N 45400 47200 44500 47200 4
N 44100 47200 42900 47200 4
N 42900 47200 42900 45700 4
C 45500 43000 1 270 0 output-1.sym
{
T 45800 42900 5 10 0 0 270 0 1
device=OUTPUT
T 45700 41600 5 10 1 1 90 0 1
refdes=CLK0
}
C 46100 43000 1 270 0 output-1.sym
{
T 46400 42900 5 10 0 0 270 0 1
device=OUTPUT
T 46300 41600 5 10 1 1 90 0 1
refdes=CLK1
}
C 46700 43000 1 270 0 output-1.sym
{
T 47000 42900 5 10 0 0 270 0 1
device=OUTPUT
T 46900 41600 5 10 1 1 90 0 1
refdes=CLK2
}
C 47300 43000 1 270 0 output-1.sym
{
T 47600 42900 5 10 0 0 270 0 1
device=OUTPUT
T 47500 41600 5 10 1 1 90 0 1
refdes=CLK3
}
C 48300 44400 1 0 0 output-1.sym
{
T 48400 44700 5 10 0 0 0 0 1
device=OUTPUT
T 49700 44600 5 10 1 1 180 0 1
refdes=CLK4
}
C 48300 45000 1 0 0 output-1.sym
{
T 48400 45300 5 10 0 0 0 0 1
device=OUTPUT
T 49700 45200 5 10 1 1 180 0 1
refdes=CLK5
}
C 43900 44700 1 0 0 nc-left-1.sym
{
T 43900 45100 5 10 0 0 0 0 1
value=NoConnection
T 43900 45500 5 10 0 0 0 0 1
device=DRC_Directive
}
C 43900 44400 1 0 0 nc-left-1.sym
{
T 43900 44800 5 10 0 0 0 0 1
value=NoConnection
T 43900 45200 5 10 0 0 0 0 1
device=DRC_Directive
}
C 43900 44100 1 0 0 nc-left-1.sym
{
T 43900 44500 5 10 0 0 0 0 1
value=NoConnection
T 43900 44900 5 10 0 0 0 0 1
device=DRC_Directive
}
N 44400 44800 44500 44800 4
N 44500 44500 44400 44500 4
N 44400 44200 44500 44200 4
C 43900 45900 1 0 0 nc-left-1.sym
{
T 43900 46300 5 10 0 0 0 0 1
value=NoConnection
T 43900 46700 5 10 0 0 0 0 1
device=DRC_Directive
}
C 43900 45000 1 0 0 nc-left-1.sym
{
T 43900 45400 5 10 0 0 0 0 1
value=NoConnection
T 43900 45800 5 10 0 0 0 0 1
device=DRC_Directive
}
C 48500 45600 1 0 0 nc-right-1.sym
{
T 48600 46100 5 10 0 0 0 0 1
value=NoConnection
T 48600 46300 5 10 0 0 0 0 1
device=DRC_Directive
}
C 47000 47300 1 0 0 nc-top-1.sym
{
T 47400 47800 5 10 0 0 0 0 1
value=NoConnection
T 47400 48000 5 10 0 0 0 0 1
device=DRC_Directive
}
C 46400 47300 1 0 0 nc-top-1.sym
{
T 46800 47800 5 10 0 0 0 0 1
value=NoConnection
T 46800 48000 5 10 0 0 0 0 1
device=DRC_Directive
}
C 45800 47300 1 0 0 nc-top-1.sym
{
T 46200 47800 5 10 0 0 0 0 1
value=NoConnection
T 46200 48000 5 10 0 0 0 0 1
device=DRC_Directive
}
