v 20081231 1
C 40000 40000 0 0 0 title-B.sym
C 41900 49100 1 0 0 zener-2.sym
{
T 42300 49600 5 10 0 0 0 0 1
device=ZENER_DIODE
T 42200 49400 5 8 1 1 0 0 1
refdes=D3
T 42000 48900 5 8 1 1 0 0 1
model=SD103C
T 41900 49100 5 10 0 0 0 0 1
footprint=DIODE
}
C 44500 49200 1 0 1 switch-spst-1.sym
{
T 44100 49900 5 10 0 0 0 6 1
device=SPST
T 44100 49500 5 8 1 1 0 0 1
refdes=SW1
T 44500 49200 5 10 0 0 0 0 1
footprint=SIP3
}
C 50700 47900 1 0 0 resistor-1.sym
{
T 51000 48300 5 10 0 0 0 0 1
device=RESISTOR
T 51000 48200 5 8 1 1 0 0 1
refdes=R16
T 51000 47700 5 8 1 1 0 0 1
value=330K
T 50700 47900 5 10 0 0 0 0 1
footprint=0603
}
C 53800 43500 1 90 0 resistor-1.sym
{
T 53400 43800 5 10 0 0 90 0 1
device=RESISTOR
T 54200 44200 5 8 1 1 180 0 1
refdes=R15
T 53900 43800 5 8 1 1 0 0 1
value=4K7
T 53800 43500 5 10 0 0 0 0 1
footprint=0603
}
C 50400 43500 1 0 0 resistor-1.sym
{
T 50700 43900 5 10 0 0 0 0 1
device=RESISTOR
T 50600 43800 5 8 1 1 0 0 1
refdes=R14
T 50600 43300 5 8 1 1 0 0 1
value=330K
T 50400 43500 5 10 0 0 0 0 1
footprint=0603
}
C 50800 49000 1 0 0 capacitor-1.sym
{
T 51000 49700 5 8 0 0 0 0 1
device=CAPACITOR
T 51400 49300 5 8 1 1 0 0 1
refdes=C24
T 51000 49900 5 8 0 0 0 0 1
symversion=0.1
T 50800 49300 5 8 1 1 0 0 1
value=10nF
T 50800 49000 5 10 0 0 0 0 1
footprint=0402
}
C 47300 48200 1 270 0 capacitor-2.sym
{
T 48000 48000 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 47000 47900 5 8 1 1 0 0 1
refdes=C23
T 48200 48000 5 10 0 0 270 0 1
symversion=0.1
T 47000 47700 5 8 1 1 0 0 1
value=1uF
T 47000 47500 5 8 1 1 0 0 1
voltage=16V
T 47300 48200 5 10 0 0 0 0 1
footprint=TANT_A
}
C 52000 43800 1 270 0 capacitor-2.sym
{
T 52700 43600 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 52500 43500 5 8 1 1 0 0 1
refdes=C22
T 52900 43600 5 10 0 0 270 0 1
symversion=0.1
T 52500 43300 5 8 1 1 0 0 1
value=4.7uF
T 52500 43100 5 8 1 1 0 0 1
voltage=10V
T 52000 43800 5 10 0 0 0 0 1
footprint=TANT_A
}
C 52200 48300 1 270 0 capacitor-2.sym
{
T 52900 48100 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 51900 47900 5 8 1 1 0 0 1
refdes=C25
T 53100 48100 5 10 0 0 270 0 1
symversion=0.1
T 51800 47700 5 8 1 1 0 0 1
value=4.7uF
T 51900 47500 5 8 1 1 0 0 1
volatage=10V
T 52200 48300 5 10 0 0 0 0 1
footprint=TANT_A
}
C 46400 43800 1 270 0 capacitor-2.sym
{
T 47100 43600 5 10 0 0 270 0 1
device=POLARIZED_CAPACITOR
T 46100 43600 5 8 1 1 0 0 1
refdes=C20
T 47300 43600 5 10 0 0 270 0 1
symversion=0.1
T 46200 43300 5 8 1 1 0 0 1
value=1uF
T 46100 43000 5 8 1 1 0 0 1
voltage=16V
T 46400 43800 5 10 0 0 0 0 1
footprint=TANT_A
}
C 48000 46800 1 0 0 gnd-1.sym
C 47400 46800 1 0 0 gnd-1.sym
C 52300 46900 1 0 0 gnd-1.sym
C 56100 47500 1 0 0 gnd-1.sym
C 47300 42400 1 0 0 gnd-1.sym
C 53600 41700 1 0 0 gnd-1.sym
C 52100 42200 1 0 0 gnd-1.sym
C 46500 42400 1 0 0 gnd-1.sym
C 53600 43300 1 270 0 led-2.sym
{
T 53300 42900 5 8 1 1 0 0 1
refdes=D4
T 54200 43200 5 10 0 0 270 0 1
device=LED
T 53600 43300 5 10 0 0 0 0 1
footprint=0603_LED
}
C 54900 46600 1 0 0 vdd-1.sym
{
T 54900 47000 5 8 1 1 0 0 1
netname=VVCO
}
C 54900 48800 1 0 0 vdd-1.sym
C 52900 49100 1 0 0 3.3V-plus-1.sym
C 53500 44800 1 0 0 5V-plus-1.sym
C 56700 49000 1 180 0 coax.sym
{
T 56000 48900 5 8 1 1 180 0 1
refdes=J5
T 56700 49000 5 10 0 0 0 0 1
footprint=SMA_VERT
}
C 56700 46700 1 180 0 coax.sym
{
T 56000 46600 5 8 1 1 180 0 1
refdes=J6
T 56700 46700 5 10 0 0 0 0 1
footprint=SMA_VERT
}
C 56100 45200 1 0 0 gnd-1.sym
C 50400 44600 1 0 0 capacitor-1.sym
{
T 50600 45300 5 10 0 0 0 0 1
device=CAPACITOR
T 51000 44900 5 8 1 1 0 0 1
refdes=C21
T 50600 45500 5 10 0 0 0 0 1
symversion=0.1
T 50400 44900 5 8 1 1 0 0 1
value=10nF
T 50400 44600 5 10 0 0 0 0 1
footprint=0402
}
N 53100 46300 53100 49100 4
N 55100 48800 55100 48600 4
N 55100 46600 55100 46300 4
N 52400 47200 52400 47400 4
N 53100 48600 52400 48600 4
N 51700 49200 52400 49200 4
N 52400 48300 52400 49200 4
N 52400 48600 50400 48600 4
N 51600 48000 51700 48000 4
N 51700 48000 51700 48600 4
N 48400 48000 48100 48000 4
N 47500 47100 47500 47300 4
N 47500 48200 47500 49200 4
N 43700 49200 42700 49200 4
N 46600 42700 46600 42900 4
N 46600 43800 46600 49200 4
N 53700 42000 53700 42400 4
N 53700 43300 53700 43500 4
N 53700 44400 53700 44800 4
N 52200 43800 52200 44600 4
N 52200 42500 52200 42900 4
N 51300 43600 51700 43600 4
C 48100 47200 1 0 0 ADP3300ART-3.3.sym
{
T 48795 47600 5 8 1 1 0 0 1
device=ADP3300ART-3.3
T 49295 49600 5 10 1 1 0 0 1
refdes=U3
T 48100 47200 5 10 0 0 0 0 1
footprint=SOT26
}
C 47800 42800 1 0 0 ADP3300ART-5.sym
{
T 48495 43200 5 8 1 1 0 0 1
device=ADP3300ART-5
T 48995 45200 5 10 1 1 0 0 1
refdes=U2
T 47800 42800 5 10 0 0 0 0 1
footprint=SOT26
}
N 48100 47100 48100 48000 4
N 48400 48600 47500 48600 4
N 44500 49200 48400 49200 4
N 53700 44600 51700 44600 4
N 51300 44800 51700 44800 4
N 51700 43600 51700 44800 4
N 50100 44200 51700 44200 4
N 50400 43600 50100 43600 4
N 50400 44800 50100 44800 4
N 48100 44800 46600 44800 4
N 48100 44200 46600 44200 4
N 48100 43600 47400 43600 4
N 47400 43600 47400 42700 4
N 50400 48000 50700 48000 4
N 50400 49200 50800 49200 4
N 56200 47800 56200 48100 4
N 56200 45500 56200 45800 4
N 55800 48600 54600 48600 4
N 55800 46300 54600 46300 4
N 53100 46300 53600 46300 4
N 53100 48600 53600 48600 4
T 42900 49300 9 10 1 0 0 0 1
8.6V
T 46800 49300 9 10 1 0 0 0 1
+8.6V
N 41900 49200 41400 49200 4
T 41200 49300 9 10 1 0 0 0 1
+9.0V
T 40200 48500 9 10 1 0 0 0 2
This is where the 
battery used to be
C 54600 46200 1 90 0 jumper-1.sym
{
T 54100 46500 5 8 0 0 90 0 1
device=JUMPER
T 54300 46600 5 8 1 1 180 0 1
refdes=LK2
T 54600 46200 5 10 0 0 0 0 1
footprint=SIP2
}
C 54600 48500 1 90 0 jumper-1.sym
{
T 54100 48800 5 8 0 0 90 0 1
device=JUMPER
T 54300 48900 5 8 1 1 180 0 1
refdes=LK1
T 54600 48500 5 10 0 0 0 0 1
footprint=SIP2
}
C 40900 49100 1 0 0 nc-left-1.sym
{
T 40900 49500 5 10 0 0 0 0 1
value=NoConnection
T 40900 49900 5 10 0 0 0 0 1
device=DRC_Directive
}
