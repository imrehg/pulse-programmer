import socket
from optparse import OptionParser
import time

sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost',8880))
print "connected"
#data="NAME,test_shape.py;FLOAT,frequency,10.123"
#data="NAME,test_parallel.py;FLOAT,frequency,10.123"
#data="NAME,test_mult_ttl.py;FLOAT,frequency,10.123"
#data="NAME,test_super_parallell.py;FLOAT,frequency,10.123"
#data="NAME,PMTreadout_test.py;CYCLES,1;TRIGGER,YES;"
#data+="FLOAT,Duration,10.0;FLOAT,freq729,270.5;"
#data+="FLOAT,power729,0.6;BOOL,switch729,0;INT,word,0;INT,mask,1"


data="NAME,test_sweep.py;FLOAT,Pause,1.2;FLOAT,Tomomode,3;"
#data+="TRIGGER,NONE;"
#data+="INT,AnalysisMode,4;FLOAT,Echo3Phase,1.2;FLOAT,Spinechopause,43.1;"
#data+="BOOL,CameraOn,1;BOOL,Hide,1;BOOL,SpinEcho1,0;"
#data+="BOOL,SpinEcho3,0;BOOL,UseMotion,1;"
#data+="TRANSITION,carrier;FREQ,250.0;RABI,1:23,2:45,3:12;SLOPE_TYPE,blackman;"
#data+="SLOPE_DUR,1;IONS,1:201,2:202,3:203"
#data+=";FREQ2,10;AMPL2,1"
#data="NAME,test_old_ramsey.py"
#data="NAME,test_shape.py;FLOAT,frequency,10.123"

try:
    for line in data.splitlines():
        sock.sendall(line)
        print "send: "+str(line)
        reply=sock.recv(8012)
        print "received: "+str(reply)
        reply=sock.recv(8012)
        print "received: "+str(reply)
finally:
    sock.close()

