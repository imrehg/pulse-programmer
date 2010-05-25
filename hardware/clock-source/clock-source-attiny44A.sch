v 20100214 2
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
refdes=J?
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
refdes=R?
}
N 44900 44700 44700 44700 4
{
T 44400 44700 5 8 1 1 0 0 1
netname=VS
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
refdes=R?
}
C 51200 43500 1 0 0 resistor-1.sym
{
T 51500 43900 5 10 0 0 0 0 1
device=RESISTOR
T 51200 43400 5 10 1 1 0 0 1
refdes=R?
}
C 51200 44000 1 0 0 resistor-1.sym
{
T 51500 44400 5 10 0 0 0 0 1
device=RESISTOR
T 51400 44300 5 10 1 1 0 0 1
refdes=R?
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
C 46600 43400 1 0 0 attiny44A.sym
{
T 47295 43400 5 8 1 1 0 0 1
device=ATtiny44A
T 47495 45900 5 10 1 1 0 0 1
refdes=U?
}
