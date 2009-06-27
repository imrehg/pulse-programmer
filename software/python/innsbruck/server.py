#!/usr/bin/env python
# -*- mode: Python; coding: latin-1 -*-
# Time-stamp: "2006-06-20 11:44:46 c704271"

#  file      : server.py
#  email     : philipp DOT emacs DOT schindler AT uibk DOT ac DOT at
#            : remove the "One And Only Editor"
#  copyright : (c) 2006 Philipp Schindler
#  rcs       : $Id: server.py,v 1.6 2007/12/16 23:26:47 viellieb Exp $

#_* Code

import socket
import time
from innsbruck import *


class tcp_server:

  #The one and only TCP server
  #just calls get_variables and create_program with the received string
  # we need definitely some error checking here

  def pre_return(self,parent):
    self.time_str=""
    if parent.error_string=="":
      return_string="executing ok ;"
    else:
      return_string=parent.error_string
    return_string+=parent.get_return_string(clear=False)+"\n"
    self.tcp_socket.sendall(return_string)
    print "sending pre_return"


  def server(self,parent,answer=False,pre_return=False):
    while True:
        print "server started"
        sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('',parent.port))
        sock.listen(5)
        try:
            while True:
                newSocket, address = sock.accept()
                debug_print("ip address: "+str(address),1)
                while True:
                  try:
                    print "ready to receive:"
                    receivedData=newSocket.recv(4*8192)#maybe we should increase the max receive data
                  except:
                    print "socket error"
                  if not receivedData:
                    print "no data"
                    break
                  if receivedData=="alive?":
                    print "alive"
                    newSocket.sendall("alive!"+";\r\n") #added TK
                    break
                  if pre_return:
                    try:
                      newSocket.sendall("RECEIVED!"+";\r\n") #added TK
                    except:
                      debug_print("error while sending return string",1)
                  debug_print("received data: " + str(receivedData),1)
                  start_time=time.time()
                  parent.server_create(receivedData)
                  stop_time=time.time()
                  used_time=round((stop_time-start_time)*1000)
                  parent.time_str="OK, execution_time, " +str(used_time)+";\n"

                  if (parent.error_string==""):
                    if answer:
                      print "trying to send"
                      string=parent.get_return_string()
                      try:
                        newSocket.sendall(string+"\r\n")
                      except:
                        debug_print("error while returning value",1)
                        debug_print("returned value"+str(parent.get_return_string())+"\r\n",1)
                  else:
                    print"trying to send error"
                    if answer:
                      newSocket.sendall(parent.error_string+"\r\n")
                    parent.error_string=""
                    print "sended error"
                print "finish connected"
                newSocket.close()

        finally:

            print "disconnected"
            try:
                socket.close()
            except AttributeError:
                debug_print("server crashed - restarting",1)





#_* Local Variables

#  Local Variables:
#  allout-layout: (1 0 :)
#  End:

# server.py ends here
