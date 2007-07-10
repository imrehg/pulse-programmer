v 20070216 1
C 40000 40000 0 0 0 title-B.sym
C 41000 41700 1 0 0 dp83843bvje.sym
{
T 48900 49600 5 10 1 1 0 6 1
refdes=U3
T 44800 54200 5 10 0 0 0 0 1
device=DP83843BVJE
T 44800 54400 5 10 0 0 0 0 1
footprint=PQFP-80
T 47900 41800 5 10 1 1 0 0 1
value=DP83843BVJE
}
C 41800 49900 1 0 0 nc-top-1.sym
{
T 42200 50400 5 10 0 0 0 0 1
value=NoConnection
T 42200 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 42100 49900 1 0 0 nc-top-1.sym
{
T 42500 50400 5 10 0 0 0 0 1
value=NoConnection
T 42500 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 42700 49900 1 0 0 nc-top-1.sym
{
T 43100 50400 5 10 0 0 0 0 1
value=NoConnection
T 43100 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 43000 49900 1 0 0 nc-top-1.sym
{
T 43400 50400 5 10 0 0 0 0 1
value=NoConnection
T 43400 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 40500 48200 1 0 0 nc-left-1.sym
{
T 40500 48600 5 10 0 0 0 0 1
value=NoConnection
T 40500 49000 5 10 0 0 0 0 1
device=DRC_Directive
}
C 41900 41300 1 0 0 nc-bottom-1.sym
{
T 41900 41900 5 10 0 0 0 0 1
value=NoConnection
T 41900 42300 5 10 0 0 0 0 1
device=DRC_Directive
}
N 42100 41700 42100 41800 4
N 41000 48300 41100 48300 4
N 42000 49800 42000 49900 4
N 42300 49800 42300 49900 4
N 42900 49800 42900 49900 4
N 43200 49800 43200 49900 4
C 52400 48300 1 0 0 rj45-1.sym
{
T 52400 51200 5 10 0 0 0 0 1
device=RJ45
T 52400 51000 5 10 0 0 0 0 1
footprint=RJ45_VERT
T 52400 50200 5 10 1 1 0 0 1
refdes=J4
}
C 49800 49800 1 0 0 led-small.sym
{
T 50000 50000 5 10 1 1 0 0 1
refdes=D2
T 49900 50400 5 10 0 0 0 0 1
device=LED
T 49800 49800 5 10 0 0 0 0 1
footprint=0603_LED
}
C 49800 50200 1 0 0 led-small.sym
{
T 50000 50400 5 10 1 1 0 0 1
refdes=D1
T 49900 50800 5 10 0 0 0 0 1
device=LED
T 49800 50200 5 10 0 0 0 0 1
footprint=0603_LED
}
C 49800 49400 1 0 0 led-small.sym
{
T 50000 49600 5 10 1 1 0 0 1
refdes=D3
T 49900 50000 5 10 0 0 0 0 1
device=LED
T 49800 49400 5 10 0 0 0 0 1
footprint=0603_LED
}
C 49800 49000 1 0 0 led-small.sym
{
T 50000 49200 5 10 1 1 0 0 1
refdes=D4
T 49900 49600 5 10 0 0 0 0 1
device=LED
T 49800 49000 5 10 0 0 0 0 1
footprint=0603_LED
}
C 49800 48600 1 0 0 led-small.sym
{
T 50000 48800 5 10 1 1 0 0 1
refdes=D5
T 49900 49200 5 10 0 0 0 0 1
device=LED
T 49800 48600 5 10 0 0 0 0 1
footprint=0603_LED
}
C 54200 41400 1 0 0 ecs-3951.sym
{
T 55600 41600 5 10 1 1 0 6 1
refdes=X1
T 54600 43000 5 10 0 0 0 0 1
device=Oscillator
T 54200 41400 5 10 0 0 0 0 1
footprint=XTAL
}
C 50600 50200 1 0 0 resistor-1.sym
{
T 50900 50600 5 10 0 0 0 0 1
device=RESISTOR
T 51400 50400 5 10 1 1 0 0 1
refdes=R6
T 50600 50100 5 10 1 1 0 0 1
value=1k
T 50600 50200 5 10 0 0 0 0 1
footprint=0402
}
C 51700 48300 1 0 0 gnd-1.sym
{
T 51600 48100 5 10 1 1 0 0 1
netname=GND
}
N 47400 49800 47400 49900 4
N 47400 49900 50000 49900 4
N 47100 49800 47100 50300 4
N 47100 50300 50000 50300 4
N 49200 47900 49300 47900 4
N 49300 47900 49300 49500 4
N 49300 49500 50000 49500 4
N 49200 47600 49500 47600 4
N 49500 47600 49500 49100 4
N 49500 49100 50000 49100 4
N 49200 47300 49700 47300 4
N 49700 47300 49700 48700 4
N 49700 48700 50000 48700 4
N 50500 50300 50600 50300 4
N 50500 49900 50600 49900 4
N 50500 49500 50600 49500 4
N 50500 49100 50600 49100 4
N 50500 48700 50600 48700 4
N 51500 48700 51800 48700 4
N 51500 49100 51800 49100 4
N 51500 49500 51800 49500 4
N 51500 49900 51800 49900 4
N 51500 50300 51800 50300 4
{
T 51500 50300 5 10 0 0 0 0 1
netname=+5V
}
N 51800 48600 51800 49900 4
C 51700 50400 1 270 0 vcc-small.sym
{
T 52240 50400 5 10 0 0 270 0 1
device=VCC Small
T 51700 50400 5 10 1 1 0 0 1
netname=+5V
}
C 49700 46400 1 90 0 cap-small.sym
{
T 49900 46920 5 10 1 1 180 6 1
refdes=C8
T 49220 46800 5 10 0 0 90 0 1
device=Cap Small
T 51300 46900 5 10 1 1 180 0 1
value=0.001u
T 49700 46400 5 10 0 0 90 0 1
footprint=0402
}
C 46000 41400 1 0 0 cap-small.sym
{
T 46520 40600 5 10 1 1 90 6 1
refdes=C14
T 46400 41880 5 10 0 0 0 0 1
device=Cap Small
T 46500 40700 5 10 1 1 90 0 1
value=0.001u
T 46000 41400 5 10 0 0 0 0 1
footprint=0402
}
C 43000 41500 1 0 0 cap-small.sym
{
T 43520 40600 5 10 1 1 90 6 1
refdes=C9
T 43400 41980 5 10 0 0 0 0 1
device=Cap Small
T 43500 40800 5 10 1 1 90 0 1
value=0.001u
T 43000 41500 5 10 0 0 0 0 1
footprint=0402
}
C 43700 41300 1 0 0 nc-bottom-1.sym
{
T 43700 41900 5 10 0 0 0 0 1
value=NoConnection
T 43700 42300 5 10 0 0 0 0 1
device=DRC_Directive
}
N 43900 41800 43900 41700 4
N 49200 43400 50100 43400 4
N 49200 44300 50100 44300 4
N 49200 44600 50100 44600 4
N 49200 44900 50100 44900 4
N 49200 45200 50100 45200 4
N 49200 45800 50100 45800 4
N 49200 46100 50100 46100 4
N 49200 46400 50100 46400 4
C 49300 43000 1 0 0 resistor-1.sym
{
T 49600 43400 5 10 0 0 0 0 1
device=RESISTOR
T 49500 43200 5 10 1 1 0 0 1
refdes=R14
T 50000 43200 5 10 1 1 0 0 1
value=10k
T 49300 43000 5 10 0 0 0 0 1
footprint=0402
}
C 50600 43000 1 90 0 gnd-1.sym
{
T 50700 43000 5 10 1 1 0 0 1
netname=GND
}
N 49200 43100 49300 43100 4
N 50200 43100 50300 43100 4
C 41000 48100 1 180 0 resistor-1.sym
{
T 40700 47700 5 10 0 0 180 0 1
device=RESISTOR
T 40400 47900 5 10 1 1 180 0 1
refdes=R5
T 41000 47900 5 10 1 1 180 0 1
value=10k
T 41000 48100 5 10 0 0 0 0 1
footprint=0402
}
N 40100 48000 40100 49000 4
N 41100 48000 41000 48000 4
C 40500 46100 1 0 0 nc-left-1.sym
{
T 40500 46500 5 10 0 0 0 0 1
value=NoConnection
T 40500 46900 5 10 0 0 0 0 1
device=DRC_Directive
}
N 41000 46200 41100 46200 4
C 49300 42400 1 0 0 nc-right-1.sym
{
T 49400 42900 5 10 0 0 0 0 1
value=NoConnection
T 49400 43100 5 10 0 0 0 0 1
device=DRC_Directive
}
N 49200 42500 49300 42500 4
C 49300 42100 1 0 0 nc-right-1.sym
{
T 49400 42600 5 10 0 0 0 0 1
value=NoConnection
T 49400 42800 5 10 0 0 0 0 1
device=DRC_Directive
}
N 49200 42200 49300 42200 4
C 54200 41700 1 90 0 cap-small.sym
{
T 53900 42520 5 10 1 1 180 6 1
refdes=C22
T 53720 42100 5 10 0 0 90 0 1
device=Cap Small
T 53900 42000 5 10 1 1 180 0 1
value=0.0033u
T 54200 41700 5 10 0 0 90 0 1
footprint=0402
}
C 53000 42200 1 0 0 inductor-1.sym
{
T 53200 42700 5 10 0 0 0 0 1
device=INDUCTOR
T 53400 42500 5 10 1 1 0 0 1
refdes=L2
T 53200 42900 5 10 0 0 0 0 1
symversion=0.1
T 53300 42100 5 10 1 1 0 0 1
value=600
T 53000 42200 5 10 0 0 0 0 1
footprint=1206
}
N 54000 41900 54300 41900 4
C 53900 41600 1 0 0 gnd-1.sym
{
T 54100 41600 5 10 1 1 0 0 1
netname=GND
}
C 56300 42200 1 90 0 gnd-1.sym
{
T 56400 42200 5 10 1 1 0 0 1
netname=GND
}
N 55900 42300 56000 42300 4
N 55900 41900 56800 41900 4
{
T 56000 41700 5 10 1 1 0 0 1
netname=ETH_CLK
}
C 47000 41300 1 0 0 nc-bottom-1.sym
{
T 47000 41900 5 10 0 0 0 0 1
value=NoConnection
T 47000 42300 5 10 0 0 0 0 1
device=DRC_Directive
}
N 47200 41800 47200 41700 4
N 47500 41800 47500 41700 4
N 46900 41800 46900 41700 4
N 45100 41800 45100 41700 4
N 45400 41800 45400 41700 4
N 45700 41800 45700 41700 4
N 46000 41800 46000 41700 4
C 52900 42300 1 0 0 vcc-small.sym
{
T 52900 42840 5 10 0 0 0 0 1
device=VCC Small
T 52900 42800 5 10 1 1 0 0 1
netname=+5V
}
N 53000 42400 53000 42300 4
{
T 53000 42400 5 10 0 0 0 0 1
netname=+5V
}
C 42300 41400 1 0 0 gnd-1.sym
{
T 42100 41100 5 10 1 1 0 0 1
netname=GND
}
N 42400 41700 42400 41800 4
C 42800 41800 1 180 0 vcc-small.sym
{
T 42800 41260 5 10 0 0 180 0 1
device=VCC Small
T 43000 41300 5 10 1 1 180 0 1
netname=+5V
}
N 42700 41700 42700 41800 4
{
T 42700 41700 5 10 0 0 0 0 1
netname=+5V
}
N 41100 48600 41000 48600 4
C 41000 48700 1 180 0 resistor-1.sym
{
T 40700 48300 5 10 0 0 180 0 1
device=RESISTOR
T 40400 48900 5 10 1 1 180 0 1
refdes=R4
T 41100 48900 5 10 1 1 180 0 1
value=4.87k
T 41000 48700 5 10 0 0 0 0 1
footprint=0402
}
C 40200 49300 1 180 0 gnd-1.sym
{
T 40800 49400 5 10 1 1 180 0 1
netname=GND
}
N 41700 49800 41700 49900 4
N 41700 50800 41600 50800 4
C 41800 49900 1 90 0 resistor-1.sym
{
T 41400 50200 5 10 0 0 90 0 1
device=RESISTOR
T 42000 50600 5 10 1 1 90 0 1
refdes=R3
T 41500 50100 5 10 1 1 90 0 1
value=69.8k
T 41800 49900 5 10 0 0 0 0 1
footprint=0402
}
C 41300 50900 1 270 0 gnd-1.sym
{
T 40800 50700 5 10 1 1 0 0 1
netname=GND
}
C 44500 49900 1 0 0 nc-top-1.sym
{
T 44900 50400 5 10 0 0 0 0 1
value=NoConnection
T 44900 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 44800 49900 1 0 0 nc-top-1.sym
{
T 45200 50400 5 10 0 0 0 0 1
value=NoConnection
T 45200 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 45100 49900 1 0 0 nc-top-1.sym
{
T 45500 50400 5 10 0 0 0 0 1
value=NoConnection
T 45500 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 45400 49900 1 0 0 nc-top-1.sym
{
T 45800 50400 5 10 0 0 0 0 1
value=NoConnection
T 45800 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 46300 49900 1 0 0 nc-top-1.sym
{
T 46700 50400 5 10 0 0 0 0 1
value=NoConnection
T 46700 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 46600 49900 1 0 0 nc-top-1.sym
{
T 47000 50400 5 10 0 0 0 0 1
value=NoConnection
T 47000 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
N 44700 49900 44700 49800 4
N 45000 49900 45000 49800 4
N 45300 49900 45300 49800 4
N 45600 49900 45600 49800 4
N 46500 49900 46500 49800 4
N 46800 49900 46800 49800 4
C 55100 49300 1 180 0 cap-small.sym
{
T 55700 49120 5 10 1 1 180 6 1
refdes=C16
T 54700 48820 5 10 0 0 180 0 1
device=Cap Small
T 55600 49200 5 10 1 1 180 0 1
value=10p
T 55100 49300 5 10 0 0 180 0 1
footprint=0402
}
N 53300 49100 54500 49100 4
C 55200 49000 1 90 0 gnd-1.sym
{
T 55200 49000 5 10 0 0 90 0 1
netname=GND
}
N 54900 49100 54800 49100 4
C 53500 50100 1 0 0 resistor-1.sym
{
T 53800 50500 5 10 0 0 0 0 1
device=RESISTOR
T 53700 50300 5 10 1 1 0 0 1
refdes=R11
T 53600 50000 5 10 1 1 0 0 1
value=49.9
T 53500 50100 5 10 0 0 0 0 1
footprint=0402
}
C 54500 50100 1 0 0 resistor-1.sym
{
T 54800 50500 5 10 0 0 0 0 1
device=RESISTOR
T 54700 50300 5 10 1 1 0 0 1
refdes=R12
T 54600 50000 5 10 1 1 0 0 1
value=49.9
T 54500 50100 5 10 0 0 0 0 1
footprint=0402
}
C 53500 48600 1 0 0 resistor-1.sym
{
T 53800 49000 5 10 0 0 0 0 1
device=RESISTOR
T 53700 48200 5 10 1 1 0 0 1
refdes=R13
T 53700 48400 5 10 1 1 0 0 1
value=49.9
T 53500 48600 5 10 0 0 0 0 1
footprint=0402
}
C 54500 48600 1 0 0 resistor-1.sym
{
T 54800 49000 5 10 0 0 0 0 1
device=RESISTOR
T 54700 48200 5 10 1 1 0 0 1
refdes=R15
T 54700 48400 5 10 1 1 0 0 1
value=49.9
T 54500 48600 5 10 0 0 0 0 1
footprint=0402
}
N 41100 45000 40300 45000 4
{
T 40300 44800 5 10 1 1 0 0 1
netname=TPTD-
}
N 41100 44700 40300 44700 4
{
T 40300 44500 5 10 1 1 0 0 1
netname=TPTD+
}
N 41100 46800 40100 46800 4
{
T 40100 46600 5 10 1 1 0 0 1
netname=TPRD+
}
N 41100 47400 40100 47400 4
{
T 40100 47200 5 10 1 1 0 0 1
netname=TPRD-
}
N 41100 47100 40100 47100 4
{
T 40100 46900 5 10 1 1 0 0 1
netname=VCM_CAP
}
C 40500 43400 1 0 0 nc-left-1.sym
{
T 40500 43800 5 10 0 0 0 0 1
value=NoConnection
T 40500 44200 5 10 0 0 0 0 1
device=DRC_Directive
}
N 41100 43500 41000 43500 4
C 42800 41300 1 0 0 nc-bottom-1.sym
{
T 42800 41900 5 10 0 0 0 0 1
value=NoConnection
T 42800 42300 5 10 0 0 0 0 1
device=DRC_Directive
}
N 43000 41800 43000 41700 4
C 50900 46500 1 180 0 input-1.sym
{
T 50900 46200 5 10 0 0 180 0 1
device=INPUT
T 51000 46400 5 10 1 1 0 0 1
refdes=MDC
}
C 50900 46200 1 180 0 input-1.sym
{
T 50900 45900 5 10 0 0 180 0 1
device=INPUT
T 51000 46100 5 10 1 1 0 0 1
refdes=MDIO
}
C 50900 45300 1 180 0 input-1.sym
{
T 50900 45000 5 10 0 0 180 0 1
device=INPUT
T 51000 45100 5 10 1 1 0 0 1
refdes=TXD[0]
}
C 50900 45000 1 180 0 input-1.sym
{
T 50900 44700 5 10 0 0 180 0 1
device=INPUT
T 51000 44800 5 10 1 1 0 0 1
refdes=TXD[1]
}
C 50900 44700 1 180 0 input-1.sym
{
T 50900 44400 5 10 0 0 180 0 1
device=INPUT
T 51000 44500 5 10 1 1 0 0 1
refdes=TXD[2]
}
C 50900 44400 1 180 0 input-1.sym
{
T 50900 44100 5 10 0 0 180 0 1
device=INPUT
T 51000 44200 5 10 1 1 0 0 1
refdes=TXD[3]
}
C 50900 43500 1 180 0 input-1.sym
{
T 50900 43200 5 10 0 0 180 0 1
device=INPUT
T 51000 43300 5 10 1 1 0 0 1
refdes=TX_EN
}
C 49300 42700 1 0 0 resistor-1.sym
{
T 49600 43100 5 10 0 0 0 0 1
device=RESISTOR
T 49900 42400 5 10 1 1 0 0 1
refdes=R16
T 50100 42600 5 10 1 1 0 0 1
value=10k
T 49300 42700 5 10 0 0 0 0 1
footprint=0402
}
C 50200 42900 1 270 0 vcc-small.sym
{
T 50740 42900 5 10 0 0 270 0 1
device=VCC Small
T 50700 42700 5 10 1 1 0 0 1
netname=+5V
}
N 50200 42800 50300 42800 4
{
T 50200 42800 5 10 0 1 0 0 1
netname=+5V
}
N 49200 42800 49300 42800 4
C 49600 45400 1 90 0 gnd-1.sym
{
T 49700 45400 5 10 1 1 0 0 1
netname=GND
}
N 49200 45500 49300 45500 4
N 49200 47000 51800 47000 4
C 49700 43400 1 90 0 cap-small.sym
{
T 49900 43920 5 10 1 1 180 6 1
refdes=C12
T 49220 43800 5 10 0 0 90 0 1
device=Cap Small
T 51300 43900 5 10 1 1 180 0 1
value=0.001u
T 49700 43400 5 10 0 0 90 0 1
footprint=0402
}
C 52000 46800 1 270 0 vcc-small.sym
{
T 52540 46800 5 10 0 0 270 0 1
device=VCC Small
T 52500 46600 5 10 1 1 0 0 1
netname=+5V
}
C 42700 50200 1 180 0 gnd-1.sym
{
T 42700 50200 5 10 0 0 270 0 1
netname=GND
}
N 42600 49900 42600 49800 4
C 40700 43900 1 270 0 gnd-1.sym
{
T 40700 43900 5 10 0 0 0 0 1
netname=GND
}
N 41000 43800 41100 43800 4
N 41100 45900 40100 45900 4
{
T 40100 45700 5 10 1 1 0 0 1
netname=TW_AGND
}
N 41100 46500 40100 46500 4
{
T 40100 46300 5 10 1 1 0 0 1
netname=TW_AVDD
}
N 41100 47700 40100 47700 4
{
T 40100 47500 5 10 1 1 0 0 1
netname=TW_AGND
}
C 45700 49900 1 0 0 nc-top-1.sym
{
T 46100 50400 5 10 0 0 0 0 1
value=NoConnection
T 46100 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
C 46000 49900 1 0 0 nc-top-1.sym
{
T 46400 50400 5 10 0 0 0 0 1
value=NoConnection
T 46400 50600 5 10 0 0 0 0 1
device=DRC_Directive
}
N 45900 49900 45900 49800 4
N 46200 49900 46200 49800 4
N 44100 49800 44100 50800 4
{
T 44300 50000 5 10 1 1 90 0 1
netname=CP_AVDD
}
N 44400 49800 44400 50800 4
{
T 44600 50000 5 10 1 1 90 0 1
netname=CP_AGND
}
N 43500 49800 43500 50800 4
{
T 43700 49800 5 10 1 1 90 0 1
netname=CPTW_DVDD
}
N 43800 49800 43800 50800 4
{
T 44000 49800 5 10 1 1 90 0 1
netname=CPTW_DVSS
}
N 41100 45600 40200 45600 4
N 41100 45300 40100 45300 4
N 41100 44400 40200 44400 4
N 41100 44100 40100 44100 4
N 41100 43200 40100 43200 4
N 41100 42900 40200 42900 4
N 44200 41800 44200 40400 4
{
T 44400 40400 5 10 1 1 90 0 1
netname=ETH_CLK
}
C 40800 40200 1 90 0 vcc-small.sym
{
T 40260 40200 5 10 0 0 90 0 1
device=VCC Small
T 40100 40300 5 10 1 1 0 0 1
netname=+5V
}
C 40400 40200 1 270 0 gnd-1.sym
{
T 40300 40200 5 10 0 1 180 0 1
netname=GND
}
N 40700 40200 46300 40200 4
{
T 41200 40200 5 10 0 0 0 0 1
netname=+5V
}
N 46300 40200 46300 41800 4
N 40700 40100 46600 40100 4
N 46600 40100 46600 41800 4
N 43300 41800 43300 40200 4
N 43600 41800 43600 40100 4
C 44200 41400 1 0 0 cap-small.sym
{
T 44720 40600 5 10 1 1 90 6 1
refdes=C11
T 44600 41880 5 10 0 0 0 0 1
device=Cap Small
T 44700 41000 5 10 1 1 90 0 1
value=0.1u
T 44200 41400 5 10 0 0 0 0 1
footprint=0402
}
N 44500 41800 44500 40200 4
N 44800 41800 44800 40100 4
N 40700 40200 40700 40600 4
{
T 40700 40200 5 10 0 0 0 0 1
netname=+5V
}
N 40700 40600 40100 40600 4
N 40100 40600 40100 45300 4
N 40800 40100 40800 40700 4
N 40800 40700 40200 40700 4
N 40200 40700 40200 45600 4
C 41100 43800 1 90 0 cap-small.sym
{
T 40300 44020 5 10 1 1 180 6 1
refdes=C7
T 40620 44200 5 10 0 0 90 0 1
device=Cap Small
T 40600 44300 5 10 1 1 180 0 1
value=0.1u
T 41100 43800 5 10 0 0 90 0 1
footprint=0402
}
C 41100 45000 1 90 0 cap-small.sym
{
T 40300 45220 5 10 1 1 180 6 1
refdes=C6
T 40620 45400 5 10 0 0 90 0 1
device=Cap Small
T 40600 45500 5 10 1 1 180 0 1
value=0.1u
T 41100 45000 5 10 0 0 90 0 1
footprint=0402
}
C 41900 40900 1 90 0 input-1.sym
{
T 41600 40900 5 10 0 0 90 0 1
device=INPUT
T 41900 40200 5 10 1 1 90 0 1
refdes=RESET
T 41900 40900 5 10 0 0 0 0 1
netname=RESET
}
C 51500 45800 1 0 0 cap-small.sym
{
T 52020 45600 5 10 1 1 90 6 1
refdes=C15
T 51900 46280 5 10 0 0 0 0 1
device=Cap Small
T 52000 46300 5 10 1 1 90 0 1
value=0.1u
T 51500 45800 5 10 0 0 0 0 1
footprint=0402
}
C 51500 44200 1 0 0 cap-small.sym
{
T 52020 44100 5 10 1 1 90 6 1
refdes=C18
T 51900 44680 5 10 0 0 0 0 1
device=Cap Small
T 52000 44700 5 10 1 1 90 0 1
value=10u
T 51500 44200 5 10 0 0 0 0 1
footprint=6032
}
N 51800 47000 51800 44000 4
N 51800 44000 49200 44000 4
N 49200 43700 52100 43700 4
N 52100 43700 52100 46700 4
N 49200 46700 52100 46700 4
{
T 49200 46700 5 10 0 1 0 0 1
netname=+5V
}
C 50600 49800 1 0 0 resistor-1.sym
{
T 50900 50200 5 10 0 0 0 0 1
device=RESISTOR
T 51400 50000 5 10 1 1 0 0 1
refdes=R7
T 50600 49700 5 10 1 1 0 0 1
value=1k
T 50600 49800 5 10 0 0 0 0 1
footprint=0402
}
C 50600 49400 1 0 0 resistor-1.sym
{
T 50900 49800 5 10 0 0 0 0 1
device=RESISTOR
T 51400 49600 5 10 1 1 0 0 1
refdes=R8
T 50600 49300 5 10 1 1 0 0 1
value=1k
T 50600 49400 5 10 0 0 0 0 1
footprint=0402
}
C 50600 49000 1 0 0 resistor-1.sym
{
T 50900 49400 5 10 0 0 0 0 1
device=RESISTOR
T 51400 49200 5 10 1 1 0 0 1
refdes=R9
T 50600 48900 5 10 1 1 0 0 1
value=1k
T 50600 49000 5 10 0 0 0 0 1
footprint=0402
}
C 50600 48600 1 0 0 resistor-1.sym
{
T 50900 49000 5 10 0 0 0 0 1
device=RESISTOR
T 51400 48800 5 10 1 1 0 0 1
refdes=R10
T 50600 48500 5 10 1 1 0 0 1
value=1k
T 50600 48600 5 10 0 0 0 0 1
footprint=0402
}
C 55500 45200 1 0 0 inductor-1.sym
{
T 55700 45700 5 10 0 0 0 0 1
device=INDUCTOR
T 55900 45500 5 10 1 1 0 0 1
refdes=L3
T 55700 45900 5 10 0 0 0 0 1
symversion=0.1
T 55800 45100 5 10 1 1 0 0 1
value=600
T 55500 45200 5 10 0 0 0 0 1
footprint=1206
}
C 56400 45400 1 270 0 vcc-small.sym
{
T 56940 45400 5 10 0 0 270 0 1
device=VCC Small
T 57000 45100 5 10 1 1 90 0 1
netname=+5V
}
C 55000 44700 1 90 0 cap-small.sym
{
T 54700 45520 5 10 1 1 180 6 1
refdes=C20
T 54520 45100 5 10 0 0 90 0 1
device=Cap Small
T 55100 44900 5 10 1 1 180 0 1
value=0.001u
T 55000 44700 5 10 0 0 90 0 1
footprint=0402
}
C 55600 44700 1 90 0 cap-small.sym
{
T 55300 45520 5 10 1 1 180 6 1
refdes=C21
T 55120 45100 5 10 0 0 90 0 1
device=Cap Small
T 55700 44900 5 10 1 1 180 0 1
value=0.01u
T 55600 44700 5 10 0 0 90 0 1
footprint=0402
}
N 56500 45300 56400 45300 4
{
T 56400 45400 5 10 0 1 0 0 1
netname=+5V
}
N 55500 45300 53400 45300 4
{
T 53400 45100 5 10 1 1 0 0 1
netname=CP_AVDD
}
N 53400 45000 56400 45000 4
{
T 53400 44800 5 10 1 1 0 0 1
netname=CP_AGND
}
C 56300 44700 1 0 0 gnd-1.sym
{
T 56200 44500 5 10 1 1 0 0 1
netname=GND
}
C 55500 43900 1 0 0 inductor-1.sym
{
T 55700 44400 5 10 0 0 0 0 1
device=INDUCTOR
T 55900 44200 5 10 1 1 0 0 1
refdes=L4
T 55700 44600 5 10 0 0 0 0 1
symversion=0.1
T 56200 44100 5 10 1 1 0 0 1
value=600
T 55500 43900 5 10 0 0 0 0 1
footprint=1206
}
C 56400 44100 1 270 0 vcc-small.sym
{
T 56940 44100 5 10 0 0 270 0 1
device=VCC Small
T 57000 43800 5 10 1 1 90 0 1
netname=+5V
}
C 55000 43400 1 90 0 cap-small.sym
{
T 54700 44220 5 10 1 1 180 6 1
refdes=C23
T 54520 43800 5 10 0 0 90 0 1
device=Cap Small
T 55100 43600 5 10 1 1 180 0 1
value=0.001u
T 55000 43400 5 10 0 0 90 0 1
footprint=0402
}
C 55600 43400 1 90 0 cap-small.sym
{
T 55300 44220 5 10 1 1 180 6 1
refdes=C24
T 55120 43800 5 10 0 0 90 0 1
device=Cap Small
T 55700 43600 5 10 1 1 180 0 1
value=0.01u
T 55600 43400 5 10 0 0 90 0 1
footprint=0402
}
N 56500 44000 56400 44000 4
{
T 56400 44100 5 10 0 1 0 0 1
netname=+5V
}
N 55500 44000 53400 44000 4
{
T 53400 43800 5 10 1 1 0 0 1
netname=TW_AVDD
}
N 53400 43700 55500 43700 4
{
T 53400 43500 5 10 1 1 0 0 1
netname=TW_AGND
}
C 56700 43400 1 0 0 gnd-1.sym
{
T 56600 43200 5 10 1 1 0 0 1
netname=GND
}
C 53200 47900 1 0 0 gnd-1.sym
{
T 52900 47700 5 10 1 1 0 0 1
netname=GND
}
N 53300 48500 53300 48200 4
C 54000 50500 1 0 0 cap-small.sym
{
T 54800 50780 5 10 1 1 0 6 1
refdes=C10
T 54400 50980 5 10 0 0 0 0 1
device=Cap Small
T 54000 50800 5 10 1 1 0 0 1
value=10p
T 54000 50500 5 10 0 0 0 0 1
footprint=0402
}
N 54300 50700 53500 50700 4
N 54600 50700 55400 50700 4
N 54400 50200 54500 50200 4
N 53300 49900 56800 49900 4
{
T 56300 49900 5 10 1 1 0 0 1
netname=TPTD+
}
C 55100 49900 1 180 0 cap-small.sym
{
T 55700 49720 5 10 1 1 180 6 1
refdes=C13
T 54700 49420 5 10 0 0 180 0 1
device=Cap Small
T 55600 49800 5 10 1 1 180 0 1
value=10p
T 55100 49900 5 10 0 0 180 0 1
footprint=0402
}
C 55200 49600 1 90 0 gnd-1.sym
N 54900 49700 54800 49700 4
N 53300 49700 54500 49700 4
N 53300 49500 56800 49500 4
{
T 56300 49500 5 10 1 1 0 0 1
netname=TPTD-
}
N 53300 49300 56800 49300 4
{
T 56300 49300 5 10 1 1 0 0 1
netname=TPRD+
}
N 53300 48900 56800 48900 4
{
T 56300 48900 5 10 1 1 0 0 1
netname=TPRD-
}
N 53500 49500 53500 50700 4
N 55400 49900 55400 50700 4
N 54400 50200 54400 49700 4
N 54500 48700 54400 48700 4
N 53500 48700 53500 49300 4
N 55400 48700 55400 48900 4
N 54400 47800 54400 49100 4
N 54400 47800 56900 47800 4
{
T 56000 47900 5 10 1 1 0 0 1
netname=VCM_CAP
}
C 55100 47200 1 90 0 cap-small.sym
{
T 54400 47720 5 10 1 1 180 6 1
refdes=C17
T 54620 47600 5 10 0 0 90 0 1
device=Cap Small
T 54900 47400 5 10 1 1 180 0 1
value=0.1u
T 55100 47200 5 10 0 0 90 0 1
footprint=0402
}
C 55700 47200 1 90 0 cap-small.sym
{
T 55800 47720 5 10 1 1 180 6 1
refdes=C19
T 55220 47600 5 10 0 0 90 0 1
device=Cap Small
T 55900 47400 5 10 1 1 180 0 1
value=0.0033u
T 55700 47200 5 10 0 0 90 0 1
footprint=0402
}
N 54400 47500 56900 47500 4
{
T 56100 47300 5 10 1 1 0 0 1
netname=TW_AVDD
}
C 47400 41700 1 270 0 output-1.sym
{
T 47700 41600 5 10 0 0 270 0 1
device=OUTPUT
T 47400 41700 5 10 0 0 0 0 1
netname=RX_DV
T 47600 40200 5 10 1 1 90 0 1
refdes=RX_DV
}
C 46800 41700 1 270 0 output-1.sym
{
T 47100 41600 5 10 0 0 270 0 1
device=OUTPUT
T 46800 41700 5 10 0 0 0 0 1
netname=RX_CLK
T 47000 40100 5 10 1 1 90 0 1
refdes=RX_CLK
}
C 45900 41700 1 270 0 output-1.sym
{
T 46200 41600 5 10 0 0 270 0 1
device=OUTPUT
T 45900 41700 5 10 0 0 0 0 1
netname=RXD[0]
T 46100 40200 5 10 1 1 90 0 1
refdes=RXD[0]
}
C 45600 41700 1 270 0 output-1.sym
{
T 45900 41600 5 10 0 0 270 0 1
device=OUTPUT
T 45600 41700 5 10 0 0 0 0 1
netname=RXD[1]
T 45800 40200 5 10 1 1 90 0 1
refdes=RXD[1]
}
C 45300 41700 1 270 0 output-1.sym
{
T 45600 41600 5 10 0 0 270 0 1
device=OUTPUT
T 45300 41700 5 10 0 0 0 0 1
netname=RXD[2]
T 45500 40200 5 10 1 1 90 0 1
refdes=RXD[2]
}
C 45000 41700 1 270 0 output-1.sym
{
T 45300 41600 5 10 0 0 270 0 1
device=OUTPUT
T 45000 41700 5 10 0 0 0 0 1
netname=RXD[3]
T 45200 40200 5 10 1 1 90 0 1
refdes=RXD[3]
}
C 50100 45700 1 0 0 output-1.sym
{
T 50200 46000 5 10 0 0 0 0 1
device=OUTPUT
T 50100 45700 5 10 0 0 90 0 1
netname=TX_CLK
T 51700 45900 5 10 1 1 180 0 1
refdes=TX_CLK
}
C 52400 42300 1 180 0 input-1.sym
{
T 52400 42000 5 10 0 0 180 0 1
device=INPUT
T 52500 42100 5 10 1 1 0 0 1
refdes=+5V
}
C 52400 41900 1 180 0 input-1.sym
{
T 52400 41600 5 10 0 0 180 0 1
device=INPUT
T 52500 41700 5 10 1 1 0 0 1
refdes=GND
}
C 51300 42100 1 90 0 vcc-small.sym
{
T 50760 42100 5 10 0 0 90 0 1
device=VCC Small
T 50800 42300 5 10 1 1 180 0 1
netname=+5V
}
N 51600 42200 51200 42200 4
{
T 51600 42200 5 10 0 0 0 0 1
netname=+5V
}
C 51100 41500 1 0 0 gnd-1.sym
{
T 50600 41500 5 10 1 1 0 0 1
netname=GND
}
C 41100 42600 1 90 0 cap-small.sym
{
T 40300 42820 5 10 1 1 180 6 1
refdes=C25
T 40620 43000 5 10 0 0 90 0 1
device=Cap Small
T 40600 43100 5 10 1 1 180 0 1
value=0.1u
T 41100 42600 5 10 0 0 90 0 1
footprint=0402
}
C 55500 46400 1 0 0 inductor-1.sym
{
T 55700 46900 5 10 0 0 0 0 1
device=INDUCTOR
T 55900 46700 5 10 1 1 0 0 1
refdes=L5
T 55700 47100 5 10 0 0 0 0 1
symversion=0.1
T 56200 46600 5 10 1 1 0 0 1
value=600
T 55500 46400 5 10 0 0 0 0 1
footprint=1206
}
C 56400 46600 1 270 0 vcc-small.sym
{
T 56940 46600 5 10 0 0 270 0 1
device=VCC Small
T 57000 46300 5 10 1 1 90 0 1
netname=+5V
}
C 55000 45900 1 90 0 cap-small.sym
{
T 54700 46720 5 10 1 1 180 6 1
refdes=C26
T 54520 46300 5 10 0 0 90 0 1
device=Cap Small
T 55100 46100 5 10 1 1 180 0 1
value=0.001u
T 55000 45900 5 10 0 0 90 0 1
footprint=0402
}
C 55600 45900 1 90 0 cap-small.sym
{
T 55300 46720 5 10 1 1 180 6 1
refdes=C27
T 55120 46300 5 10 0 0 90 0 1
device=Cap Small
T 55700 46100 5 10 1 1 180 0 1
value=0.01u
T 55600 45900 5 10 0 0 90 0 1
footprint=0402
}
N 56400 46500 56500 46500 4
{
T 56400 46600 5 10 0 1 0 0 1
netname=+5V
}
N 55500 46500 53400 46500 4
{
T 53100 46300 5 10 1 1 0 0 1
netname=CPTW_DVDD
}
N 53400 46200 55500 46200 4
{
T 53100 46000 5 10 1 1 0 0 1
netname=CPTW_DVSS
}
C 56700 45900 1 0 0 gnd-1.sym
{
T 56600 45700 5 10 1 1 0 0 1
netname=GND
}
C 55500 46100 1 0 0 inductor-1.sym
{
T 55700 46600 5 10 0 0 0 0 1
device=INDUCTOR
T 55900 46000 5 10 1 1 0 0 1
refdes=L6
T 55700 46800 5 10 0 0 0 0 1
symversion=0.1
T 56200 46000 5 10 1 1 0 0 1
value=600
T 55500 46100 5 10 0 0 0 0 1
footprint=1206
}
N 56400 46200 56800 46200 4
C 55500 43600 1 0 0 inductor-1.sym
{
T 55700 44100 5 10 0 0 0 0 1
device=INDUCTOR
T 55900 43500 5 10 1 1 0 0 1
refdes=L7
T 55700 44300 5 10 0 0 0 0 1
symversion=0.1
T 56200 43500 5 10 1 1 0 0 1
value=600
T 55500 43600 5 10 0 0 0 0 1
footprint=1206
}
N 56400 43700 56800 43700 4
N 41800 41800 41800 41700 4
N 53300 48700 53400 48700 4
N 53400 48700 53400 48400 4
N 53400 48400 53600 48400 4
N 53600 48400 53600 48000 4
C 53400 47600 1 0 0 nc-bottom-1.sym
{
T 53400 48200 5 10 0 0 0 0 1
value=NoConnection
T 53400 48600 5 10 0 0 0 0 1
device=DRC_Directive
}
N 53900 42300 54300 42300 4
N 54000 42000 54000 41900 4
N 51600 41800 51200 41800 4
C 52100 46900 1 90 0 gnd-1.sym
{
T 52200 46900 5 10 1 1 0 0 1
netname=GND
}
