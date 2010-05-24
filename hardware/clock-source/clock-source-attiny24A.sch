v 20081231 1
C 40000 40000 0 0 0 title-B.sym
C 49100 45500 1 90 0 gnd-1.sym
N 48800 45600 48600 45600 4
N 46600 45600 46400 45600 4
{
T 46300 45700 5 8 1 1 180 0 1
netname=VS
}
C 50200 47000 1 90 0 header6-small.sym
{
T 50450 47250 5 10 0 1 90 0 1
device=HEADER10
T 49100 47600 5 10 1 1 90 0 1
refdes=J31
}
N 49700 48200 49700 48600 4
N 50000 48200 50000 48400 4
N 46500 43800 46600 43800 4
N 49700 43100 49700 47000 4
N 50000 47000 50000 46700 4
{
T 50000 46400 5 8 1 1 90 0 1
netname=VS
}
N 49400 46700 49400 47000 4
N 45800 44700 46600 44700 4
C 49300 46400 1 0 0 gnd-1.sym
C 44900 44600 1 0 0 resistor-1.sym
{
T 45200 45000 5 10 0 0 0 0 1
device=RESISTOR
T 45100 44900 5 10 1 1 0 0 1
refdes=R65
}
N 44900 44700 44700 44700 4
{
T 44400 44700 5 8 1 1 0 0 1
netname=VS
}
C 46600 43400 1 0 0 attiny24A.sym
{
T 47295 43400 5 8 1 1 0 0 1
device=ATtiny24A
T 47495 45900 5 10 1 1 0 0 1
refdes=U4
}
N 48600 45300 49100 45300 4
{
T 49200 45300 5 8 1 1 0 0 1
netname=DATA
}
N 48600 45000 49100 45000 4
{
T 49200 45000 5 8 1 1 0 0 1
netname=LE
}
N 56500 49400 56500 50400 4
{
T 56500 49700 5 8 1 1 0 0 1
netname=ISP_SCK
}
N 56500 47600 56500 47400 4
{
T 56400 47200 5 8 1 1 0 0 1
netname=SCK
}
N 57000 48000 57100 48000 4
N 57000 49000 57100 49000 4
N 56500 48400 56500 48600 4
C 57000 48400 1 180 0 Transistor_PNP-2.sym
{
T 56550 47600 5 10 1 1 180 6 1
refdes=Q3
T 56900 46350 5 10 0 0 180 0 1
device=Transistor PNP
}
C 57000 48600 1 0 1 Transistor_NPN-2.sym
{
T 56550 49400 5 10 1 1 0 0 1
refdes=Q1
T 56900 50650 5 10 0 0 0 6 1
device=Transistor NPN
}
N 57100 48000 57100 49000 4
C 58200 46400 1 270 0 jumper-1.sym
{
T 58700 46100 5 8 0 0 270 0 1
device=JUMPER
T 58700 46100 5 10 1 1 270 0 1
refdes=J32
}
N 59200 46300 59500 46300 4
{
T 59600 46300 5 8 1 1 0 0 1
netname=VS
}
C 58100 45300 1 90 0 resistor-1.sym
{
T 57700 45600 5 10 0 0 90 0 1
device=RESISTOR
T 57800 45500 5 10 1 1 90 0 1
refdes=R69
}
C 57900 44900 1 0 0 gnd-1.sym
N 58000 45200 58000 45300 4
N 58000 46200 58000 46300 4
N 55700 47200 55700 49600 4
{
T 55000 47500 5 8 1 1 0 0 1
netname=ISP_MISO
}
N 55700 45400 55700 45200 4
{
T 55600 45000 5 8 1 1 0 0 1
netname=SDO
}
N 56200 45800 56300 45800 4
N 56200 46800 56300 46800 4
N 55700 46200 55700 46400 4
C 56200 46200 1 180 0 Transistor_PNP-2.sym
{
T 55750 45400 5 10 1 1 180 6 1
refdes=Q4
T 56100 44150 5 10 0 0 180 0 1
device=Transistor PNP
}
C 56200 46400 1 0 1 Transistor_NPN-2.sym
{
T 55750 47200 5 10 1 1 0 0 1
refdes=Q2
T 56100 48450 5 10 0 0 0 6 1
device=Transistor NPN
}
N 56300 45800 56300 46800 4
N 56500 43900 56500 44200 4
{
T 55600 44000 5 8 1 1 0 0 1
netname=ISP_MOSI
}
N 56500 42100 56500 41900 4
{
T 56400 41700 5 8 1 1 0 0 1
netname=SDIO
}
N 57000 42500 57100 42500 4
N 57000 43500 57100 43500 4
N 56500 42900 56500 43100 4
C 57000 42900 1 180 0 Transistor_PNP-2.sym
{
T 56550 42100 5 10 1 1 180 6 1
refdes=Q6
T 56900 40850 5 10 0 0 180 0 1
device=Transistor PNP
}
C 57000 43100 1 0 1 Transistor_NPN-2.sym
{
T 56550 43900 5 10 1 1 0 0 1
refdes=Q5
T 56900 45150 5 10 0 0 0 6 1
device=Transistor NPN
}
N 57100 42500 57100 43500 4
N 56300 46300 58200 46300 4
N 57100 43000 57500 43000 4
N 57500 43000 57500 46300 4
N 57100 48500 57500 48500 4
N 57500 48500 57500 46300 4
N 46500 43800 46500 43100 4
N 49700 48600 50900 48600 4
N 50000 48400 50600 48400 4
N 49400 48200 46000 48200 4
N 46000 48200 46000 44700 4
N 46500 43100 51200 43100 4
C 51200 43000 1 0 0 resistor-1.sym
{
T 51500 43400 5 10 0 0 0 0 1
device=RESISTOR
T 51400 42800 5 10 1 1 0 0 1
refdes=R68
}
C 51200 43500 1 0 0 resistor-1.sym
{
T 51500 43900 5 10 0 0 0 0 1
device=RESISTOR
T 51200 43400 5 10 1 1 0 0 1
refdes=R67
}
C 51200 44000 1 0 0 resistor-1.sym
{
T 51500 44400 5 10 0 0 0 0 1
device=RESISTOR
T 51400 44300 5 10 1 1 0 0 1
refdes=R66
}
N 50600 48400 50600 43600 4
N 50900 48600 50900 44100 4
N 48600 44100 51200 44100 4
N 52100 43100 52400 43100 4
{
T 52500 43100 5 8 1 1 0 0 1
netname=SDIO
}
N 52100 43600 52400 43600 4
{
T 52500 43600 5 8 1 1 0 0 1
netname=SDO
}
N 52100 44100 52400 44100 4
{
T 52500 44100 5 8 1 1 0 0 1
netname=SCK
}
N 51200 43600 48600 43600 4
N 48600 43600 48600 43800 4
