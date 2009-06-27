from api import *
from sequencer.api import *
import socket
import time

class MainProgram:
    """
    Class for program Management
    starts the tcp server and initializes the pulses
    """
    #generate the dummy program as the subroutines have to be at the end of the program
    def generate_nop_prog(self,length):
        for i in range(0,length):
            first_dac_value(0)
    #add a pulse
    def add_pulse(self,pulse):
        self.pulses.append(pulse)

    # create all pulse subroutines
    def create_pulses(self):
        for pulse in self.pulses:
            pulse.generate_pulse_ramps()

    #create the real program
    def create_program(self):
        begin_sequence(reuse_subs=True)
        #check if we have a finite number of cycles for the program to run
        if (self.cycles>0):
            begin_finite_loop()
        #create the pulse program from the sequence file
        self.create_pulse_program()
        #end the finite loop if self.cycles is set
        if (self.cycles>0):
            end_finite_loop(self.cycles)
        end_sequence()

    # initialize the server
    # create the subroutines and the dummy program
    # maybe we've to save the length of the dummy program to compare it to the pulse program
    def start_server(self):
        begin_sequence()
        self.create_pulses()
        self.generate_nop_prog(self.fill_length)
        end_sequence()
        self.server()

    #The one and only TCP server
    #just calls get_variables and create_program with the received string
    # we need definitely some error checking here
    def server(self):

        sock=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('',self.port))
        sock.listen(5)

        try:
            while True:
                newSocket, address = sock.accept()
                debug_print("ip address: "+str(address),1)
                while True:
                    receivedData=newSocket.recv(8192)#maybe we should increase the max receive data
                    debug_print("received data: " + str(receivedData),2)
                    if not receivedData:
                        break
#                    newSocket.sendall(receivedData)
                    start_time=time.time()
                    self.get_variables(receivedData)
                    self.create_program()
                    stop_time=time.time()
                    time_str=" / execution_time:" +str(stop_time-start_time)
                    newSocket.sendall("OK"+time_str)
                        
                newSocket.close()
        finally:
            print "disconnected"
            sock.close()

    #get the variables from the submitted string
    # we need some error checking here
    def get_variables(self,var_string):
        variables={}
        splitted_list=[]
        frame=var_string.split(";")
        for frame_item in frame:
            splitted=frame_item.split(",")
            splitted_list.append(splitted)
            if (splitted[0]=="NAME"):
                self.pulse_program_name=splitted[1]
            elif (splitted[0]=="CYCLES"):
                self.cycles=int(splitted[1])
            elif (splitted[0]=="TRIGGER"):
                print "trigger value: "+splitted[1]
            elif (splitted[0]=="FLOAT"):
                variables[splitted[1]]=float(splitted[2])
            elif (splitted[0]=="INT"):
                variables[splitted[1]]=int(splitted[2])
            elif (splitted[0]=="BOOL"):
                variables[splitted[1]]=bool(int(splitted[2]))
            else:
                print "error: cannot identify command"
        self.variables=variables

    #creates the pulse sequence
    def create_pulse_program(self):
        self.dictionary[self.pulse_program_name](self.variables)
        
    #search for sequences
    def search_sequences(self):
        import os, sys
        dir=os.getcwd()+self.sequences_dir
        sys.path.append(dir)
        for f in os.listdir(os.path.abspath(dir)):       
            module_name, ext = os.path.splitext(f) # Handles no-extension files, etc.
            if ((ext == '.py') and (module_name != "__init__")): # Important, ignore .pyc/other files.
                debug_print('imported module: %s' % (module_name),1)
                module = __import__(module_name)
                if self.dictionary.has_key(module_name):
                    self.error_handler("error: trying to add same sequence twice")
                else:
                    self.dictionary[module_name]=module.get_events

    def error_handler(error_string):
        self.error_string.append(error_string)
 

    # WE've got some initialization
    # set the default port to 8880
    # set the default sequence dir to ./seqs
    #   maybe we should add recursive inclusion of dirs?
    def __init__(self,port=8880,sequences_dir="./seqs"):
        self.pulses=[]
        self.error_string=[]
        self.sequences_dir=sequences_dir
        self.dictionary={}
        self.search_sequences()
        self.fill_length=1000
        self.cycles=0
        self.port=port
