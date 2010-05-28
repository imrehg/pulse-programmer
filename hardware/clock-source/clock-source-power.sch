v 20100214 2
C 40000 40000 0 0 0 title-B.sym
C 50700 48400 1 0 0 resistor-1.sym
{
T 51000 48800 5 10 0 0 0 0 1
device=RESISTOR
T 51000 48700 5 8 1 1 0 0 1
refdes=R57
T 51000 48200 5 8 1 1 0 0 1
value=330K
T 50700 48400 5 10 0 0 0 0 1
footprint=0603
}
C 50700 45300 1 0 0 resistor-1.sym
{
T 51000 45700 5 10 0 0 0 0 1
device=RESISTOR
T 50900 45600 5 8 1 1 0 0 1
refdes=R58
T 50900 45100 5 8 1 1 0 0 1
value=330K
T 50700 45300 5 10 0 0 0 0 1
footprint=0603
}
C 50800 49500 1 0 0 capacitor-1.sym
{
T 51000 50200 5 8 0 0 0 0 1
device=CAPACITOR
T 51400 49800 5 8 1 1 0 0 1
refdes=C44
T 51000 50400 5 8 0 0 0 0 1
symversion=0.1
T 50800 49800 5 8 1 1 0 0 1
value=10nF
T 50800 49500 5 10 0 0 0 0 1
footprint=0402
}
C 47300 48700 1 270 0 capacitor-2.sym
{
T 48000 48500 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 47000 48400 5 8 1 1 0 0 1
refdes=C42
T 48200 48500 5 10 0 0 270 0 1
symversion=0.1
T 47000 48200 5 8 1 1 0 0 1
value=1uF
T 47000 48000 5 8 1 1 0 0 1
voltage=16V
T 47300 48700 5 10 0 0 0 0 1
footprint=TANT_A
}
C 52200 45700 1 270 0 capacitor-2.sym
{
T 52900 45500 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 52700 45400 5 8 1 1 0 0 1
refdes=C48
T 53100 45500 5 10 0 0 270 0 1
symversion=0.1
T 52700 45200 5 8 1 1 0 0 1
value=4.7uF
T 52700 45000 5 8 1 1 0 0 1
voltage=10V
T 52200 45700 5 10 0 0 0 0 1
footprint=TANT_A
}
C 52200 48800 1 270 0 capacitor-2.sym
{
T 52900 48600 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 52700 48500 5 8 1 1 0 0 1
refdes=C45
T 53100 48600 5 10 0 0 270 0 1
symversion=0.1
T 52700 48300 5 8 1 1 0 0 1
value=4.7uF
T 52700 48100 5 8 1 1 0 0 1
volatage=10V
T 52200 48800 5 10 0 0 0 0 1
footprint=TANT_A
}
C 47300 45800 1 270 0 capacitor-2.sym
{
T 48000 45600 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 47000 45600 5 8 1 1 0 0 1
refdes=C43
T 48200 45600 5 10 0 0 270 0 1
symversion=0.1
T 47100 45300 5 8 1 1 0 0 1
value=1uF
T 47000 45000 5 8 1 1 0 0 1
voltage=16V
T 47300 45800 5 10 0 0 0 0 1
footprint=TANT_A
}
C 48000 47300 1 0 0 gnd-1.sym
C 47400 47300 1 0 0 gnd-1.sym
C 52300 47400 1 0 0 gnd-1.sym
C 48000 44400 1 0 0 gnd-1.sym
C 52300 44300 1 0 0 gnd-1.sym
C 47400 44400 1 0 0 gnd-1.sym
C 50700 46400 1 0 0 capacitor-1.sym
{
T 50900 47100 5 10 0 0 0 0 1
device=CAPACITOR
T 51300 46700 5 8 1 1 0 0 1
refdes=C47
T 50900 47300 5 10 0 0 0 0 1
symversion=0.1
T 50700 46700 5 8 1 1 0 0 1
value=10nF
T 50700 46400 5 10 0 0 0 0 1
footprint=0402
}
N 52400 47700 52400 47900 4
N 50400 49100 53000 49100 4
{
T 53100 49100 5 8 1 1 0 0 1
netname=VDD
}
N 51600 48500 51700 48500 4
N 51700 48500 51700 49100 4
N 48400 48500 48100 48500 4
N 47500 47600 47500 47800 4
N 47500 48700 47500 49700 4
N 47500 44700 47500 44900 4
N 52400 45700 52400 46000 4
N 52400 44600 52400 44800 4
C 48100 47700 1 0 0 ADP3300ART-3.3.sym
{
T 48795 48100 5 8 1 1 0 0 1
device=ADP3300ART-3.3
T 49295 50100 5 10 1 1 0 0 1
refdes=U4
T 48100 47700 5 10 0 0 0 0 1
footprint=SOT26
}
N 48100 47600 48100 48500 4
N 48400 49100 47500 49100 4
N 44500 49700 48400 49700 4
N 53000 46000 51600 46000 4
{
T 53100 46000 5 8 1 1 0 0 1
netname=VS
}
N 51600 45400 51600 46600 4
N 50400 46000 51600 46000 4
N 50700 45400 50400 45400 4
N 50700 46600 50400 46600 4
N 48400 46600 46600 46600 4
N 48400 46000 47500 46000 4
N 48400 45400 48100 45400 4
N 48100 45400 48100 44700 4
N 50400 48500 50700 48500 4
N 50400 49700 50800 49700 4
C 44500 49300 1 0 1 connector2-2.sym
{
T 43800 50600 5 10 1 1 0 0 1
refdes=CONN2
T 44200 50550 5 10 0 0 0 6 1
device=CONNECTOR_2
T 44200 50750 5 10 0 0 0 6 1
footprint=MOLEX2
}
C 45000 50000 1 90 0 gnd-1.sym
N 44700 50100 44500 50100 4
C 48100 44600 1 0 0 ADP3300ART-3.3.sym
{
T 48795 45000 5 8 1 1 0 0 1
device=ADP3300ART-3.3
T 49295 47000 5 10 1 1 0 0 1
refdes=U5
}
N 51700 49100 51700 49700 4
N 52400 48800 52400 49100 4
C 40400 48900 1 0 0 gnd-1.sym
N 40500 49200 40500 50000 4
{
T 40300 50100 5 10 1 1 0 0 1
netname=GND
}
C 48100 41800 1 0 0 ADP3300ART-3.3.sym
{
T 48795 42200 5 8 1 1 0 0 1
device=ADP3300ART-3.3
T 49295 44200 5 10 1 1 0 0 1
refdes=U6
}
C 50700 42500 1 0 0 resistor-1.sym
{
T 51000 42900 5 10 0 0 0 0 1
device=RESISTOR
T 50900 42800 5 8 1 1 0 0 1
refdes=R59
T 50900 42300 5 8 1 1 0 0 1
value=330K
T 50700 42500 5 10 0 0 0 0 1
footprint=0603
}
C 50700 43600 1 0 0 capacitor-1.sym
{
T 50900 44300 5 10 0 0 0 0 1
device=CAPACITOR
T 51300 43900 5 8 1 1 0 0 1
refdes=C49
T 50900 44500 5 10 0 0 0 0 1
symversion=0.1
T 50700 43900 5 8 1 1 0 0 1
value=10nF
T 50700 43600 5 10 0 0 0 0 1
footprint=0402
}
C 52100 42900 1 270 0 capacitor-2.sym
{
T 52800 42700 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 52600 42600 5 8 1 1 0 0 1
refdes=C50
T 53000 42700 5 10 0 0 270 0 1
symversion=0.1
T 52600 42400 5 8 1 1 0 0 1
value=4.7uF
T 52600 42200 5 8 1 1 0 0 1
voltage=10V
T 52100 42900 5 10 0 0 0 0 1
footprint=TANT_A
}
C 52200 41500 1 0 0 gnd-1.sym
N 52300 42900 52300 43200 4
N 52300 41800 52300 42000 4
N 52900 43200 51600 43200 4
{
T 53000 43200 5 8 1 1 0 0 1
netname=VCP
}
N 51600 42600 51600 43800 4
C 47300 43000 1 270 0 capacitor-2.sym
{
T 48000 42800 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 47000 42800 5 8 1 1 0 0 1
refdes=C46
T 48200 42800 5 10 0 0 270 0 1
symversion=0.1
T 47100 42500 5 8 1 1 0 0 1
value=1uF
T 47000 42200 5 8 1 1 0 0 1
voltage=16V
T 47300 43000 5 10 0 0 0 0 1
footprint=TANT_A
}
C 48000 41600 1 0 0 gnd-1.sym
C 47400 41600 1 0 0 gnd-1.sym
N 47500 41900 47500 42100 4
N 48100 42600 48100 41900 4
N 48400 42600 48100 42600 4
N 47500 45800 47500 46600 4
N 46600 43800 46600 49700 4
N 47500 43000 47500 43800 4
N 47500 43200 48400 43200 4
N 46600 43800 48400 43800 4
N 50700 43800 50400 43800 4
N 50400 42600 50700 42600 4
N 50400 43200 51600 43200 4
