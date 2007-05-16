v 20070216 1
C 40000 40000 0 0 0 title-B.sym
C 42600 46000 1 0 0 inductor-1.sym
{
T 42800 46500 5 10 0 0 0 0 1
device=INDUCTOR
T 43300 46200 5 10 1 1 0 0 1
refdes=L5
T 42800 46700 5 10 0 0 0 0 1
symversion=0.1
T 42800 45900 5 10 1 1 0 0 1
value=FB
T 42600 46000 5 10 0 0 0 0 1
footprint=1206
}
C 51200 46000 1 0 0 inductor-1.sym
{
T 51400 46500 5 10 0 0 0 0 1
device=INDUCTOR
T 51900 46200 5 10 1 1 0 0 1
refdes=L4
T 51400 46700 5 10 0 0 0 0 1
symversion=0.1
T 51400 45900 5 10 1 1 0 0 1
value=FB
T 51200 46000 5 10 0 0 0 0 1
footprint=1206
}
C 47000 46000 1 0 0 inductor-1.sym
{
T 47200 46500 5 10 0 0 0 0 1
device=INDUCTOR
T 47700 46200 5 10 1 1 0 0 1
refdes=L6
T 47200 46700 5 10 0 0 0 0 1
symversion=0.1
T 47200 45900 5 10 1 1 0 0 1
value=FB
T 47000 46000 5 10 0 0 0 0 1
footprint=1206
}
C 41500 45600 1 180 0 connector2-2.sym
{
T 40800 44300 5 10 1 1 180 6 1
refdes=J1
T 41200 44350 5 10 0 0 180 0 1
device=CONNECTOR_2
T 41200 44150 5 10 0 0 180 0 1
footprint=MOLEX2
}
C 52500 46000 1 0 0 inductor-1.sym
{
T 52700 46500 5 10 0 0 0 0 1
device=INDUCTOR
T 53200 46200 5 10 1 1 0 0 1
refdes=L7
T 52700 46700 5 10 0 0 0 0 1
symversion=0.1
T 52700 45900 5 10 1 1 0 0 1
value=FB
T 52500 46000 5 10 0 0 0 0 1
footprint=1206
}
C 53400 45100 1 0 0 lt1963.sym
{
T 54900 45400 5 10 1 1 0 6 1
refdes=U6
T 53800 46700 5 10 0 0 0 0 1
device=Oscillator
T 53800 46500 5 10 1 1 0 0 1
value=LT1129-3.3
T 53400 45100 5 10 0 0 0 0 1
footprint=SOT223-3
}
C 43500 45100 1 0 0 lt1963.sym
{
T 45000 45400 5 10 1 1 0 6 1
refdes=U2
T 43900 46700 5 10 0 0 0 0 1
device=Oscillator
T 43900 46500 5 10 1 1 0 0 1
value=LT1963-2.5
T 43500 45100 5 10 0 0 0 0 1
footprint=SOT223-3
}
C 47900 45100 1 0 0 lt1963.sym
{
T 49400 45400 5 10 1 1 0 6 1
refdes=U3
T 48300 46700 5 10 0 0 0 0 1
device=Oscillator
T 48300 46500 5 10 1 1 0 0 1
value=LT1963-1.5
T 47900 45100 5 10 0 0 0 0 1
footprint=SOT223-3
}
N 41500 45200 42500 45200 4
{
T 41600 45000 5 10 1 1 0 0 1
netname=VCC_unreg
}
N 45200 46100 46500 46100 4
{
T 45300 46200 5 10 1 1 0 0 1
netname=VCCIO
}
N 49600 46100 51200 46100 4
{
T 49900 46200 5 10 1 1 0 0 1
netname=+1.5V
}
N 55100 46100 56500 46100 4
{
T 56000 46200 5 10 1 1 0 0 1
netname=+3.3V
}
C 55200 46200 1 270 0 cap-small-pol.sym
{
T 55500 44980 5 10 1 1 0 6 1
refdes=C49
T 55680 45800 5 10 0 0 270 0 1
device=Cap Small
T 55200 44800 5 10 1 1 0 0 1
value=33u
T 55500 45700 5 10 0 1 0 0 1
footprint=7343
}
N 55400 45200 55400 45600 4
N 55400 46100 55400 45900 4
N 53500 46100 53400 46100 4
C 54100 44900 1 0 0 gnd-1.sym
{
T 53900 44700 5 10 1 1 0 0 1
netname=GND
}
N 55400 45200 54200 45200 4
N 54500 45300 54500 45200 4
N 54200 45300 54200 45200 4
C 47700 46200 1 270 0 cap-small-pol.sym
{
T 48000 44980 5 10 1 1 0 6 1
refdes=C45
T 48180 45800 5 10 0 0 270 0 1
device=Cap Small
T 47700 44800 5 10 1 1 0 0 1
value=33u
T 48000 45700 5 10 0 1 0 0 1
footprint=7343
}
C 49700 46200 1 270 0 cap-small-pol.sym
{
T 50000 44980 5 10 1 1 0 6 1
refdes=C46
T 50180 45800 5 10 0 0 270 0 1
device=Cap Small
T 49700 44800 5 10 1 1 0 0 1
value=33u
T 50000 45700 5 10 0 1 0 0 1
footprint=7343
}
N 49900 45200 49900 45600 4
C 48600 44900 1 0 0 gnd-1.sym
{
T 48400 44700 5 10 1 1 0 0 1
netname=GND
}
N 49900 45200 47900 45200 4
N 47900 45200 47900 45600 4
N 49000 45300 49000 45200 4
N 48700 45300 48700 45200 4
C 43300 46200 1 270 0 cap-small-pol.sym
{
T 43600 44980 5 10 1 1 0 6 1
refdes=C42
T 43780 45800 5 10 0 0 270 0 1
device=Cap Small
T 43300 44800 5 10 1 1 0 0 1
value=33u
T 43600 45700 5 10 0 1 0 0 1
footprint=7343
}
C 45300 46200 1 270 0 cap-small-pol.sym
{
T 45600 44980 5 10 1 1 0 6 1
refdes=C43
T 45780 45800 5 10 0 0 270 0 1
device=Cap Small
T 45300 44800 5 10 1 1 0 0 1
value=33u
T 45600 45700 5 10 0 1 0 0 1
footprint=7343
}
N 45500 45200 45500 45600 4
C 44200 44900 1 0 0 gnd-1.sym
{
T 44000 44700 5 10 1 1 0 0 1
netname=GND
}
N 45500 45200 43500 45200 4
N 43500 45200 43500 45600 4
N 44600 45300 44600 45200 4
N 44300 45300 44300 45200 4
N 45500 45900 45500 46100 4
N 49900 45900 49900 46100 4
N 47900 45900 47900 46100 4
N 47900 46100 48000 46100 4
N 42500 46100 42600 46100 4
N 43500 45900 43500 46100 4
N 43600 46100 43500 46100 4
N 52100 46100 52100 44000 4
{
T 52300 44800 5 10 1 1 90 0 1
netname=+1.5V_PLL
}
N 52500 46800 52500 46100 4
N 47000 46100 47000 46800 4
N 42500 45200 42500 46800 4
N 42500 46800 52500 46800 4
C 46400 44000 1 270 0 output-1.sym
{
T 46700 43900 5 10 0 0 270 0 1
device=OUTPUT
T 46700 43200 5 10 1 1 0 0 1
refdes=VCCIO_PORT
T 46400 44000 5 10 0 0 0 0 1
netname=VCCIO
}
C 51000 44000 1 270 0 output-1.sym
{
T 51300 43900 5 10 0 0 270 0 1
device=OUTPUT
T 49800 43200 5 10 1 1 0 0 1
refdes=+1.5V_PORT
}
C 52000 44000 1 270 0 output-1.sym
{
T 52300 43900 5 10 0 0 270 0 1
device=OUTPUT
T 52300 43200 5 10 1 1 0 0 1
refdes=+1.5V_PLL_PORT
T 52000 44000 5 10 0 0 0 0 1
netname=+1.5V_PLL
}
C 42900 44000 1 270 0 output-1.sym
{
T 43200 43900 5 10 0 0 270 0 1
device=OUTPUT
T 43300 43200 5 10 1 1 0 0 1
refdes=GND_PORT
}
C 56400 44000 1 270 0 output-1.sym
{
T 56700 43900 5 10 0 0 270 0 1
device=OUTPUT
T 55200 43200 5 10 1 1 0 0 1
refdes=+3.3V_PORT
T 56400 44000 5 10 0 0 0 0 1
netname=+3.3V
}
N 56500 46100 56500 44000 4
{
T 56400 44100 5 10 1 1 90 0 1
netname=+3.3V
}
N 51100 44000 51100 46100 4
{
T 51300 44000 5 10 1 1 90 0 1
netname=+1.5V
}
N 46500 46100 46500 44000 4
{
T 46700 44100 5 10 1 1 90 0 1
netname=VCCIO
}
N 41500 44800 43000 44800 4
{
T 42100 44600 5 10 1 1 0 0 1
netname=GND
}
N 43000 44800 43000 44000 4
