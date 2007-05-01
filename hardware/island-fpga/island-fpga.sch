v 20070216 1
C 40000 40000 0 0 0 title-B.sym
C 49800 48100 1 0 0 island-fpga-north.sym
{
T 50500 50000 5 10 1 1 0 6 1
refdes=S2
T 50200 49200 5 10 0 0 0 0 1
device=ISLAND-FPGA-NORTH
T 53800 48500 5 10 1 1 0 0 1
source=island-fpga-north.sch
}
C 49800 42100 1 0 0 island-fpga-south.sym
{
T 50400 42100 5 10 1 1 0 6 1
refdes=S3
T 50200 43100 5 10 0 0 0 0 1
device=ISLAND-FPGA-SOUTH
T 53900 42400 5 10 1 1 0 0 1
source=island-fpga-south.sch
}
N 42700 47700 54200 47700 4
N 54200 47700 54200 46900 4
N 50600 47700 50600 48200 4
N 50600 47700 50600 44100 4
N 42700 47300 51000 47300 4
N 51000 44100 51000 48200 4
N 42700 46900 51400 46900 4
N 51400 46900 51400 48200 4
N 42700 46500 51800 46500 4
N 51800 46500 51800 48200 4
N 51400 44100 51400 46500 4
N 54200 45300 51400 45300 4
N 42700 46100 51800 46100 4
N 51800 46100 51800 44100 4
N 42700 45700 54200 45700 4
N 42700 45300 49400 45300 4
N 52600 46300 54200 46300 4
N 54200 46300 54200 46100 4
N 42700 44500 52200 44500 4
N 52200 44100 52200 48200 4
N 42700 44100 50200 44100 4
N 50200 44100 50200 44900 4
N 50200 44900 54200 44900 4
N 49600 44900 49600 46700 4
N 49600 46700 54200 46700 4
N 54200 46700 54200 46500 4
C 54100 44000 1 0 0 island-fpga-east.sym
{
T 56800 44100 5 10 1 1 0 6 1
refdes=S4
T 54500 47200 5 10 0 0 0 0 1
device=ISLAND-FPGA-EAST
T 54500 43900 5 10 1 1 0 0 1
source=island-fpga-east.sch
}
C 40200 43200 1 0 0 island-fpga-west.sym
{
T 42900 43300 5 10 1 1 0 6 1
refdes=S1
T 40600 48000 5 10 0 0 0 0 1
device=island-fpga-west
T 40600 43000 5 10 1 1 0 0 1
source=island-fpga-west.sch
}
N 42700 43700 49900 43700 4
N 49900 43700 49900 47900 4
N 49900 47900 53400 47900 4
N 53400 47900 53400 48200 4
N 54200 44500 53400 44500 4
N 53400 44500 53400 44100 4
N 49400 45100 49400 45300 4
N 49400 45100 52600 45100 4
N 53000 45700 53000 44100 4
N 52600 44100 52600 48200 4
N 53000 48200 53000 45700 4
C 42800 44800 1 0 0 inductor-1.sym
{
T 43000 45300 5 10 0 0 0 0 1
device=INDUCTOR
T 43000 45100 5 10 1 1 0 0 1
refdes=L1
T 43000 45500 5 10 0 0 0 0 1
symversion=0.1
T 42800 44800 5 10 0 0 0 0 1
footprint=1206
}
C 43600 43600 1 270 0 cap-small-pol.sym
{
T 43900 42780 5 10 1 1 0 6 1
refdes=C1
T 44080 43200 5 10 0 0 270 0 1
device=Cap Small
T 43600 42600 5 10 1 1 0 0 1
value=10u
T 43600 43600 5 10 0 0 0 0 1
footprint=6032
}
N 43700 44900 49600 44900 4
N 42800 44900 42700 44900 4
N 43800 44900 43800 43300 4
C 43100 42700 1 0 0 gnd-1.sym
C 44100 43600 1 270 0 cap-small-pol.sym
{
T 44400 42780 5 10 1 1 0 6 1
refdes=C2
T 44580 43200 5 10 0 0 270 0 1
device=Cap Small
T 44100 42600 5 10 1 1 0 0 1
value=1u
T 44100 43600 5 10 0 0 0 0 1
footprint=0603
}
C 44600 43600 1 270 0 cap-small-pol.sym
{
T 44900 42780 5 10 1 1 0 6 1
refdes=C3
T 45080 43200 5 10 0 0 270 0 1
device=Cap Small
T 44600 42600 5 10 1 1 0 0 1
value=1u
T 44600 43600 5 10 0 0 0 0 1
footprint=0603
}
C 45100 43600 1 270 0 cap-small-pol.sym
{
T 45400 42780 5 10 1 1 0 6 1
refdes=C4
T 45580 43200 5 10 0 0 270 0 1
device=Cap Small
T 45100 42600 5 10 1 1 0 0 1
value=1u
T 45400 43100 5 10 0 1 0 0 1
footprint=0603
}
C 45600 43600 1 270 0 cap-small-pol.sym
{
T 45900 42780 5 10 1 1 0 6 1
refdes=C5
T 46080 43200 5 10 0 0 270 0 1
device=Cap Small
T 45600 42600 5 10 1 1 0 0 1
value=1u
T 45900 43100 5 10 0 1 0 0 1
footprint=0603
}
C 46100 43600 1 270 0 cap-small-pol.sym
{
T 46400 42780 5 10 1 1 0 6 1
refdes=C6
T 46580 43200 5 10 0 0 270 0 1
device=Cap Small
T 46100 42600 5 10 1 1 0 0 1
value=1u
T 46500 43100 5 10 0 1 0 0 1
footprint=0603
}
C 46600 43600 1 270 0 cap-small-pol.sym
{
T 46900 42780 5 10 1 1 0 6 1
refdes=C7
T 47080 43200 5 10 0 0 270 0 1
device=Cap Small
T 46600 42600 5 10 1 1 0 0 1
value=1u
T 46900 43100 5 10 0 1 0 0 1
footprint=0603
}
C 47100 43600 1 270 0 cap-small-pol.sym
{
T 47400 42780 5 10 1 1 0 6 1
refdes=C8
T 47580 43200 5 10 0 0 270 0 1
device=Cap Small
T 47100 42600 5 10 1 1 0 0 1
value=1u
T 47400 43100 5 10 0 1 0 0 1
footprint=0603
}
N 43200 43000 47800 43000 4
N 44300 43300 44300 44500 4
N 44800 43300 44800 44500 4
N 45300 43300 45300 44500 4
N 45800 43300 45800 44500 4
N 46300 43300 46300 46100 4
N 46800 43300 46800 46500 4
N 47300 43300 47300 46900 4
C 47600 43600 1 270 0 cap-small-pol.sym
{
T 47900 42780 5 10 1 1 0 6 1
refdes=C9
T 48080 43200 5 10 0 0 270 0 1
device=Cap Small
T 47600 42600 5 10 1 1 0 0 1
value=1u
T 47900 43100 5 10 0 1 0 0 1
footprint=0603
}
N 47800 47300 47800 43300 4
