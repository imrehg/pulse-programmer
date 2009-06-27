import socket
from optparse import OptionParser
import time
from math import *

sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(('localhost',8880))
print "connected"
#filename="test_old_ramsey.py"
#filename="test_old_ttl.py"
filename="test_old_doppler.py"
file1=open("seqs/"+filename)
data=file1.read()
#data="acq_mode(10000,True)"
print data
file1.close()
try:
    #for line in data.splitlines():
    line=data
    sock.sendall(line)
    print "send: "+str(line)
    reply=sock.recv(8012)
    print "received: "+str(reply)
#    for i in range(1000000):
#        x=sin(i)
#    sock.sendall(line+"123!()")
#    print "send: "+str(line)
#    reply=sock.recv(8012)
#    print "received: "+str(reply)
finally:
    sock.close()

