v 20070216 1
C 40000 40000 0 0 0 title-B.sym
N 50600 43600 50600 47400 4
N 51000 44100 51000 43600 4
N 51400 43600 51400 47400 4
C 54100 44100 1 0 0 island-fpga-east.sym
{
T 56600 44300 5 10 1 1 0 6 1
refdes=S3
T 54500 46400 5 10 0 0 0 0 1
device=ISLAND-FPGA-EAST
T 54500 44000 5 10 1 1 0 0 1
source=island-fpga-east.sch
}
C 43600 42800 1 270 0 cap-small-pol.sym
{
T 43900 41980 5 10 1 1 0 6 1
refdes=C1
T 44080 42400 5 10 0 0 270 0 1
device=Cap Small
T 43600 41800 5 10 1 1 0 0 1
value=1u
T 43600 42800 5 10 0 0 0 0 1
footprint=0603
}
C 42600 41900 1 0 0 gnd-1.sym
{
T 42400 41700 5 10 1 1 0 0 1
netname=GND
}
C 44100 42800 1 270 0 cap-small-pol.sym
{
T 44400 41980 5 10 1 1 0 6 1
refdes=C2
T 44580 42400 5 10 0 0 270 0 1
device=Cap Small
T 44100 41800 5 10 1 1 0 0 1
value=1u
T 44100 42800 5 10 0 0 0 0 1
footprint=0603
}
C 44600 42800 1 270 0 cap-small-pol.sym
{
T 44900 41980 5 10 1 1 0 6 1
refdes=C3
T 45080 42400 5 10 0 0 270 0 1
device=Cap Small
T 44600 41800 5 10 1 1 0 0 1
value=1u
T 44600 42800 5 10 0 0 0 0 1
footprint=0603
}
C 45100 42800 1 270 0 cap-small-pol.sym
{
T 45400 41980 5 10 1 1 0 6 1
refdes=C4
T 45580 42400 5 10 0 0 270 0 1
device=Cap Small
T 45100 41800 5 10 1 1 0 0 1
value=1u
T 45400 42300 5 10 0 1 0 0 1
footprint=0603
}
C 45600 42800 1 270 0 cap-small-pol.sym
{
T 45900 41980 5 10 1 1 0 6 1
refdes=C5
T 46080 42400 5 10 0 0 270 0 1
device=Cap Small
T 45600 41800 5 10 1 1 0 0 1
value=10u
T 45900 42300 5 10 0 1 0 0 1
footprint=6032
}
C 46100 42800 1 270 0 cap-small-pol.sym
{
T 46400 41980 5 10 1 1 0 6 1
refdes=C6
T 46580 42400 5 10 0 0 270 0 1
device=Cap Small
T 46100 41800 5 10 1 1 0 0 1
value=1u
T 46500 42300 5 10 0 1 0 0 1
footprint=0603
}
C 46600 42800 1 270 0 cap-small-pol.sym
{
T 46900 41980 5 10 1 1 0 6 1
refdes=C7
T 47080 42400 5 10 0 0 270 0 1
device=Cap Small
T 46600 41800 5 10 1 1 0 0 1
value=1u
T 46900 42300 5 10 0 1 0 0 1
footprint=0603
}
C 47100 42800 1 270 0 cap-small-pol.sym
{
T 47400 41980 5 10 1 1 0 6 1
refdes=C8
T 47580 42400 5 10 0 0 270 0 1
device=Cap Small
T 47100 41800 5 10 1 1 0 0 1
value=1u
T 47400 42300 5 10 0 1 0 0 1
footprint=0603
}
N 42700 42200 47800 42200 4
N 44300 42500 44300 44900 4
N 44800 42500 44800 44500 4
N 45300 42500 45300 44100 4
N 45800 42500 45800 43700 4
N 46300 42500 46300 43300 4
C 47600 42800 1 270 0 cap-small-pol.sym
{
T 47900 41980 5 10 1 1 0 6 1
refdes=C9
T 48080 42400 5 10 0 0 270 0 1
device=Cap Small
T 47600 41800 5 10 1 1 0 0 1
value=1u
T 47900 42300 5 10 0 1 0 0 1
footprint=0603
}
C 49400 47300 1 0 0 island-fpga-north.sym
{
T 52200 48900 5 10 1 1 0 6 1
refdes=S2
T 49800 48400 5 10 0 0 0 0 1
device=ISLAND-FPGA-NORTH
T 51900 47700 5 10 1 1 0 0 1
source=island-fpga-north.sch
}
N 54200 46100 42700 46100 4
C 40200 43000 1 0 0 island-fpga-west.sym
{
T 42900 42900 5 10 1 1 0 6 1
refdes=S1
T 40600 47600 5 10 0 0 0 0 1
device=island-fpga-west
T 40600 42800 5 10 1 1 0 0 1
source=island-fpga-west.sch
}
N 42700 46900 54200 46900 4
N 42700 46500 54200 46500 4
N 42700 47300 50200 47300 4
N 50200 47300 50200 47400 4
N 46500 43300 46500 49000 4
{
T 46700 47600 5 10 1 1 90 0 1
netname=+1.5V
}
N 42700 45700 50600 45700 4
N 42700 45300 44500 45300 4
N 44500 45300 44500 48200 4
{
T 44700 47400 5 10 1 1 90 0 1
netname=VCCIO_1
}
N 44900 44900 44900 48200 4
{
T 45100 47400 5 10 1 1 90 0 1
netname=VCCIO_2
}
N 45300 44500 45300 49000 4
{
T 45500 47700 5 10 1 1 90 0 1
netname=VCCIO_3
}
N 45700 44100 45700 49000 4
{
T 45900 47700 5 10 1 1 90 0 1
netname=VCCIO_4
}
N 43800 42500 43800 45300 4
N 44300 44900 51000 44900 4
{
T 48000 44700 5 10 1 1 0 0 1
netname=VCCIO_2
}
N 51000 44900 51000 47400 4
N 54200 44500 51800 44500 4
N 51800 43600 51800 44500 4
N 44800 44500 51200 44500 4
{
T 48000 44300 5 10 1 1 0 0 1
netname=VCCIO_3
}
N 51200 44500 51200 44900 4
N 51200 44900 54200 44900 4
N 45300 44100 51000 44100 4
{
T 48000 43900 5 10 1 1 0 0 1
netname=VCCIO_4
}
N 42700 43700 53000 43700 4
{
T 48000 43500 5 10 1 1 0 0 1
netname=+1.5V_PLL
}
N 53000 43700 53000 45300 4
N 53000 45300 54200 45300 4
N 50600 45700 54200 45700 4
C 49800 41600 1 0 0 island-fpga-south.sym
{
T 52600 43100 5 10 1 1 0 6 1
refdes=S4
T 50200 42600 5 10 0 0 0 0 1
device=ISLAND-FPGA-SOUTH
T 52300 41900 5 10 1 1 0 0 1
source=island-fpga-south.sch
}
N 47600 49100 47600 45700 4
{
T 47800 47600 5 10 1 1 90 0 1
netname=GND
}
C 46200 49000 1 90 0 inductor-1.sym
{
T 45700 49200 5 10 0 0 90 0 1
device=INDUCTOR
T 46000 49700 5 10 1 1 90 0 1
refdes=L5
T 45500 49200 5 10 0 0 90 0 1
symversion=0.1
T 46300 49200 5 10 1 1 90 0 1
value=FB
T 46200 49000 5 10 0 0 90 0 1
footprint=1206
}
N 46100 49000 46100 43700 4
{
T 46300 47600 5 10 1 1 90 0 1
netname=+1.5V_PLL
}
C 44600 48200 1 90 0 inductor-1.sym
{
T 44100 48400 5 10 0 0 90 0 1
device=INDUCTOR
T 44400 48900 5 10 1 1 90 0 1
refdes=L1
T 43900 48400 5 10 0 0 90 0 1
symversion=0.1
T 44700 48400 5 10 1 1 90 0 1
value=FB
T 44600 48200 5 10 0 0 90 0 1
footprint=1206
}
C 45000 48200 1 90 0 inductor-1.sym
{
T 44500 48400 5 10 0 0 90 0 1
device=INDUCTOR
T 44800 48900 5 10 1 1 90 0 1
refdes=L2
T 44300 48400 5 10 0 0 90 0 1
symversion=0.1
T 45100 48400 5 10 1 1 90 0 1
value=FB
T 45000 48200 5 10 0 0 90 0 1
footprint=1206
}
C 45400 49000 1 90 0 inductor-1.sym
{
T 44900 49200 5 10 0 0 90 0 1
device=INDUCTOR
T 45200 49700 5 10 1 1 90 0 1
refdes=L3
T 44700 49200 5 10 0 0 90 0 1
symversion=0.1
T 45500 49200 5 10 1 1 90 0 1
value=FB
T 45400 49000 5 10 0 0 90 0 1
footprint=1206
}
C 45800 49000 1 90 0 inductor-1.sym
{
T 45300 49200 5 10 0 0 90 0 1
device=INDUCTOR
T 45600 49700 5 10 1 1 90 0 1
refdes=L4
T 45100 49200 5 10 0 0 90 0 1
symversion=0.1
T 45900 49200 5 10 1 1 90 0 1
value=FB
T 45800 49000 5 10 0 0 90 0 1
footprint=1206
}
C 46600 49000 1 90 0 inductor-1.sym
{
T 46100 49200 5 10 0 0 90 0 1
device=INDUCTOR
T 46400 49700 5 10 1 1 90 0 1
refdes=L6
T 45900 49200 5 10 0 0 90 0 1
symversion=0.1
T 46700 49200 5 10 1 1 90 0 1
value=FB
T 46600 49000 5 10 0 0 90 0 1
footprint=1206
}
N 43800 49100 44500 49100 4
N 46500 50100 46500 49900 4
N 42700 43300 49000 43300 4
{
T 48000 43100 5 10 1 1 0 0 1
netname=+1.5V
}
N 49000 43300 49000 45300 4
N 49000 45300 51400 45300 4
N 46800 42500 46800 43300 4
N 47300 42500 47300 43300 4
N 47800 42500 47800 43300 4
C 43800 49900 1 180 0 connector2-2.sym
{
T 43100 48600 5 10 1 1 180 6 1
refdes=J8
T 43500 48650 5 10 0 0 180 0 1
device=CONNECTOR_2
T 43500 48450 5 10 0 0 180 0 1
footprint=MOLEX2
}
C 42200 50900 1 180 0 connector2-2.sym
{
T 41500 49600 5 10 1 1 180 6 1
refdes=J1
T 41900 49650 5 10 0 0 180 0 1
device=CONNECTOR_2
T 41900 49450 5 10 0 0 180 0 1
footprint=MOLEX2
}
N 44900 49100 44900 49500 4
N 44900 49500 43800 49500 4
N 45300 49900 45300 50100 4
N 45300 50100 42200 50100 4
N 45700 49900 45700 50500 4
N 45700 50500 42200 50500 4
N 46100 49900 46100 50500 4
N 46100 50500 49700 50500 4
N 48000 49100 47600 49100 4
N 49700 50100 46500 50100 4
C 48000 48700 1 0 0 connector2-2.sym
{
T 48700 48500 5 10 1 1 0 6 1
refdes=J9
T 48300 49950 5 10 0 0 0 0 1
device=CONNECTOR_2
T 48300 50150 5 10 0 0 0 0 1
footprint=MOLEX2
}
C 49700 49700 1 0 0 connector2-2.sym
{
T 50700 49700 5 10 1 1 0 6 1
refdes=J10
T 50000 50950 5 10 0 0 0 0 1
device=CONNECTOR_2
T 50000 51150 5 10 0 0 0 0 1
footprint=MOLEX2
}
N 42700 44900 43000 44900 4
N 43000 44900 43000 45100 4
N 43000 45100 51800 45100 4
{
T 47900 45200 5 10 1 1 0 0 1
netname=+3.3V
}
N 51800 45100 51800 47300 4
N 51800 47300 54200 47300 4
C 43100 42800 1 270 0 cap-small-pol.sym
{
T 43400 41980 5 10 1 1 0 6 1
refdes=C41
T 43580 42400 5 10 0 0 270 0 1
device=Cap Small
T 43100 41800 5 10 1 1 0 0 1
value=1u
T 43100 42800 5 10 0 0 0 0 1
footprint=0603
}
N 43300 42500 43300 45100 4
C 47100 48100 1 90 0 inductor-1.sym
{
T 46600 48300 5 10 0 0 90 0 1
device=INDUCTOR
T 46900 48800 5 10 1 1 90 0 1
refdes=L7
T 46400 48300 5 10 0 0 90 0 1
symversion=0.1
T 47200 48300 5 10 1 1 90 0 1
value=FB
T 47100 48100 5 10 0 0 90 0 1
footprint=1206
}
N 48000 49500 47000 49500 4
N 47000 49500 47000 49000 4
N 47000 48100 47000 45100 4
{
T 47200 47600 5 10 1 1 90 0 1
netname=+3.3V
}
