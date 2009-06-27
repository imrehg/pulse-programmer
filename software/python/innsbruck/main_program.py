
from api import *
from pulses import *
from user_exceptions import *
from user_function import *
from pulse_handler import *
from sequence_parser import parse_sequence
from sequencer.api import *
import socket
import time
import sys , traceback
import string
import handle_commands
from innsbruck.get_devices import get_hardware
from server import *

# This is the one and only box server class which uses the compiler
# Right now it's a mess I'll try to clean it now
class MainProgram:
    """
    Class for program Management
    starts the tcp server and initializes the pulses
    """
    #generate the dummy program as the subroutines have to be at the end of the program
    # I need a better solution for that
    # I don't know what's gonna be the best way to do that :-(
    def generate_nop_prog(self,length):
        ins_nop(length)


    #add a pulse if it's not there - uses pulses.py
    def add_pulse(self,pulse):
        self.pulses.append(pulse)
        return pulse.sub_name

    # create all pulse subroutines
    def create_pulses(self):
        for pulse in self.pulses:
            debug_print("creating pulse: "+pulse.sub_name,1)
            pulse.generate_pulse_ramps()

    #create the real program
    #Needs MUCH more work - do YOU have time?

    def create_program(self):
        begin_sequence(reuse_subs=True)
        test_config.first_sequencer.machine.phase_registers={}
        test_config.first_sequencer.machine.current_phase_reg=0

        set_channel(self.done_signal,1)                                     # ch.15 is set to HIGH
        startup=self.init_sequence_file()
        exec(startup)
        if self.init_freq=="ONCE":
            for name in sequencer.main_program.transitions:                     #
                try:                                                            #
                    transition=sequencer.main_program.transitions[name]         #
                    transition.create_freq()                                    #
                    if not transition.freq_is_init:
                        transition.init_freq()                                      #

                except AttributeError :                                         #
                    print "error while initializing frequency: "+str(name)      #
                                                                            #
        begin_infinite_loop()                                               #<------------------------------------------------------
        triggerlabel=create_label("infinite_start")                         #                                                       |
                                                                            #                                                       |
        begin_infinite_loop()                                               #---                                                    |
        branch(triggerlabel,(Input_0_Trigger,Input_1_Trigger))              #   |leave loop                                         |
        branch(triggerlabel,(Input_1_Trigger,))                             #   |when Input 1 is HIGH                               |
        end_infinite_loop()                                                 #---                                                    |
                                                                            #                                                       |
        insert_label(triggerlabel)                                          #                                                       |
        set_channel(self.done_signal,0)                                     # ch.15 is set to LOW                                   |
                                                                            #                                                       |
        if (self.cycles > 1):                                               #                                                       |
            begin_finite_loop()                                             #<------------------------------                        |
        if self.init_freq=="CYCLE":
            for name in sequencer.main_program.transitions:                     #
                try:
                    transition=sequencer.main_program.transitions[name]         #
                    transition.create_freq()                                    #
                    if not transition.freq_is_init:
                        transition.init_freq()                                      #

                except AttributeError :                                         #
                    print "error while initializing frequency: "+str(name)      #
                                                                            #                               |This loop is repeated  |
                                                                            #                               |for the required       |
        if self.is_triggered:                                               #<--                            |number of cycles       |
            triggerlabel=create_label("infinite_start")                     #   |if line trigger is on,     |                       |
            insert_label(triggerlabel)                                      #   |wait until line trigger    |                       |                     |
            branch(triggerlabel,(Input_0_Trigger,Input_1_Trigger))          #   |is LOW                     |                       |
            branch(triggerlabel,(Input_0_Trigger,))                         #---                            |                       |
                                                                            #                               |implements a rising    |                                                            #
        if self.is_triggered:                                               #                               |edge trigger           |
            triggerlabel=create_label("infinite_start")                     #                               |for the line trigger   |
            begin_infinite_loop()                                           #<--                            |                       |
            branch(triggerlabel,(Input_0_Trigger,Input_1_Trigger))          #   |if line trigger is on,     |                       |
            branch(triggerlabel,(Input_0_Trigger,))                         #   |wait until line trigger    |                       |
            end_infinite_loop()                                             #--- is HIGH                    |                       |                      |
            insert_label(triggerlabel)                                      #                               |                       |
                                                                            #                               |                       |
        ttl_setall(self.ttloutputword,self.ttloutputmask)                   # sets initial TTL state acording to word and mask      |
        too_many_shapes=self.create_pulse_program()                         # creates the pulse program     |                       |
                                                                            # from the sequence file        |                       |
        if too_many_shapes==1:                                              #                               |                       |
            raise TooManyShapes("too many")                                 #                               |                       |
        if innsbruck.got_new_shape==1:                                      #                               |                       |
            debug_print("aborting execution",1)                             #                               |                       |
            innsbruck.got_new_shape=0                                       #                               |                       |
            raise ShapeNotKnown("got some new shape")                       #                               |                       |
        if innsbruck.got_exec_error==1:                                     #                               |                       |
            return                                                          #                               |                       |
                                                                            #                               |                       |
        try:                                                                #                               |                       |
            if (self.cycles>1):                                             #                               |                       |
                end_finite_loop(self.cycles)                                #------------------------------                         |
            set_channel(self.done_signal,1)                                 # ch.15 is set to HIGH (->qfp resumes)                  |
            wait(self.configuration.main_loop_wait)                         #                                                       |
            end_infinite_loop()                                             #                                                       |
            end_sequence()                                                  #<------------------------------------------------------
        except SyntaxError:                                                             #
            list1=traceback.extract_tb(sys.exc_info()[2])                   #
            list2=traceback.format_list(list1)                              #
            list2.reverse()                                                 #
            self.error_handler("error: unexpected error while compiling sequence : " +list2[0])


    #Due to a firmware bug we've to add some empty instructions to make loops work
    def fix_loop_bug(self,n=15):
        print "slow down --- we don't need to fix the loop bug anymore "

    #Clear some temporary variables when a sequcne is proecessed
    def clear_tmp_vars(self):

        self.return_dict={}
        self.script_vars={}
        self.error_string=""
        self.return_variables=[]
        #All of our transitions are not initialized anymore just to be coherent
        for key , transition in self.transitions.iteritems():
            self.transitions[key].freq_is_init=False
        try:
            self.default_transition.freq_is_init=False
        except AttributeError:
            debug_print("No default transition",2)

    #The functions for executing the program
    #Some exceptions are thrown if one or more shapes doesn't exist !!!
    def server_create(self,receivedData):
        self.dictionary={}
        if not self.parallel_mode:
            self.search_sequences()
        self.get_variables(receivedData)
        is_done=False
        innsbruck.answer=False
        while not is_done:
            try:
                if innsbruck.got_new_shape:
                    self.clear_tmp_vars()
                    self.start_server(is_server=False)
                    innsbruck.got_new_shape=0
                self.create_program()
                is_done=True
            except ShapeNotKnown:
                try:
                    self.clear_tmp_vars()
                    self.start_server(is_server=False)
                    self.create_program()
                    is_done=True
                except ShapeNotKnown:
                    is_done=False
                except TooManyShapes:
                    self.remove_unused_shapes()
                    is_done=False
            except TooManyShapes:
                try:
                    self.clear_tmp_vars()
                    self.start_server(is_server=False)
                    self.remove_unused_shapes()
                    self.create_program()
                    is_done=True
                except ShapeNotKnown:
                    innsbruck.got_new_shape=1
                    is_done=False
                except TooManyShapes:
                    self.remove_unused_shapes()
                    is_done=False

    # initialize the server
    # create the subroutines and the dummy program
    # maybe we've to save the length of the dummy program to compare it to the pulse program
    def start_server(self,is_server=True):
        begin_sequence()
        self.create_pulses()
        self.generate_nop_prog(self.fill_length)
        end_sequence()
        self.server=tcp_server()
        if is_server:
            self.server.server(parent=self,answer=innsbruck.configuration.answer_tcp
                               ,pre_return=innsbruck.configuration.send_pre_return)

    # generate a string for labview from  the return variables used in user_function
    def get_return_string(self,clear=True):
        print "getting return string"
        return_string=self.time_str
        for item in self.return_variables:
            for variable in item:
                return_string+=str(variable)+","
            return_string=return_string.rstrip(",")
            return_string+=";"
        if clear:
            self.clear_tmp_vars()
        print "string :"+ return_string
        return return_string


    #get the variables from the submitted string
    # we need some error checking here
    def get_variables(self,var_string):
        self.is_triggered=False
        variables=handle_commands.get_variables(var_string,self)
        self.variables=variables

    def set_variable(self,type,name,default,lower_limit=0,upper_limit=0):
        try:
            return self.variables[name]
        except:
            self.error_handler("Error while getting variable : "+str(name)+"  .... trying the default value")
            return default


    #checks if there is a new shape and creates it if necessary
    def get_slope_name(self,type,slope_duration,amplitude=1,amplitude2=-1,is_raising=True,device_nr=1):
        debug_print("got "+str(len(self.pulses))+" shapes in memory",2)
        for pulse in self.pulses:
            if (pulse.get_type()==type) and abs(pulse.slope_duration-slope_duration)<1e-9\
                and abs(pulse.amplitude-amplitude)<1e-9 and abs(pulse.amplitude2-amplitude2)<1e-9\
                and device_nr==pulse.dac_device:
                # We just retun some rubbish name if we've got a new shape
                if (innsbruck.got_new_shape==1):
                    return(self.pulses[0])
                pulse.counter +=1
                return pulse
        debug_print(" shape not in memory yet ... recompiling sequence",1)
        #create the slopes if they are not in memory yet
        #if (sequencer.program_size>self.max_program_size):
        if (len(self.pulses)>self.max_shape_count):
            debug_print("our_program is too big now - we delete some seldom used shapes",1)
            self.remove_unused_shapes()
            self.error_handler("warning I had to remove some shapes")
            raise TooManyShapes("too many")
#        print "device nr: "+str(device_nr)
        self.add_pulse(self.pulse_dictionary[type](slope_duration,amplitude,amplitude2,dac_device=device_nr))
        innsbruck.got_new_shape=1
        debug_print("returning dummy name: "+self.pulses[0].sub_name+"_up",1)
        return self.pulses[0] #.sub_name+"_up"

    #We should get more intelligence into this !!!!!
    def remove_unused_shapes(self):
        nr_shapes=len(self.pulses)
        i=0
        for i in range(int(nr_shapes)/2):
            del self.pulses[i]
            debug_print("removed "+self.pulses[i].sub_name,1)

    def add_transition(self,name):
        new_transition=transition(name,0,0)
        self.transitions[name]=new_transition

    def get_transition(number=None):
        if number==None:
            number=len(self.transitions)
        return self.transitions(number)


    #creates the pulse sequence
    def create_pulse_program(self):
#        file1=open(self.dictionary[self.pulse_program_name])
#        exec(file1)

        try:
            if self.parallel_mode:
                print "oh nein - parallelmode"
                file1=self.program_string
            else:
                try:
                    file1=self.handle_sequence_file()
                    debug_print("command string: "+str(file1),1)
                except KeyError:
                    self.error_handler("error: unknown sequence")
                include_all()
            exec(file1)
            innsbruck.got_exec_error=0
        except TooManyShapes:
            debug_print("TooManyShapes Error handler",1)
            return 1
        except :
            innsbruck.got_exec_error=1
            value= sys.exc_info()[1]
            type= sys.exc_info()[0]
            list1=traceback.extract_tb(sys.exc_info()[2])
            list2=traceback.format_list(list1)
            string1=""
            if self.parallel_mode:
                self.error_handler("parallel error: unexpected error while executing sequence : " + str(list1))
            else:
                for item in list2:
                    try:
                        result=item.find(self.pulse_program_name)
                    except AttributeError:
                        self.error_handler("cannot find pulse program variable, you might send me parallel data")
                        return
                    if result !=-1:
                        string1=item
                self.error_handler("error: unexpected error while executing sequence : " + str(string1)\
                                   +"    "+str(type)+"   "+str(value))
            #clean up the global variables
            del(sequencer.main_program.sequence_list)
            self.clear_tmp_vars()

    def handle_sequence_file(self):
        exec_string=""
        try:
        #    file1=open(self.dictionary[self.pulse_program_name])
        #except KeyError:
            file1=open(self.pulse_program_name)
        except :
            self.error_handler("error: unknown sequence")
        string1=file1.read()
        file1.close()
        sequence=parse_sequence(string1,self)
        return sequence

    def init_sequence_file(self):
        exec_string=""
        try:
        #    file1=open(self.dictionary[self.pulse_program_name])
        #except KeyError:
            file1=open(self.pulse_program_name)
        except :
            self.error_handler("error: unknown sequence")
            return
        string1=file1.read()
        file1.close()
        sequence=parse_sequence(string1,self,init_string=True)
        return sequence
    #search for sequences
    def search_sequences(self):
        import os, sys
        dir1=self.sequences_dir
        #sys.path.append(dir)
        for f in os.listdir(os.path.abspath(dir1)):
            module_name, ext = os.path.splitext(f) # Handles no-extension files, etc.
            if ((ext == '.py') and (module_name != "__init__")): # Important, ignore .pyc/other files.
                debug_print('imported module: %s' % (module_name),1)
                if self.dictionary.has_key(module_name):
                    self.error_handler("error: trying to add same sequence twice")
                else:
                    self.dictionary[module_name+ext]=dir1+module_name+ext

    def error_handler(self,error_string):
        self.error_string+="\n"+str(error_string)
        print error_string


    # WE've got some initialization
    # set the default port to 8880
    # set the default sequence dir to ./seqs
    #   maybe we should add recursive inclusion of dirs?
    def __init__(self,port=0,sequences_dir="",hardware_config="", parallel_mode=""):
        self.configuration=innsbruck.configuration
        if parallel_mode=="":
            parallel_mode=self.configuration.parallel_mode
        if port == 0:
            port=self.configuration.default_port
        if sequences_dir=="":
            sequences_dir=self.configuration.sequences_dir
        if hardware_config=="":
            hardware_config=self.configuration.hardware_config

        global error_handler
        error_handler=self.error_handler
        self.pulses=[]
        #this dictionary should be created somewhere eles
        innsbruck.got_new_shape=0
        self.parallel_mode=parallel_mode
        self.time=1
        self.pulse_dictionary=self.configuration.pulse_dictionary
        self.return_variables=[]
        self.script_vars={}
        self.return_dict={}
        self.error_string=""
        self.hardware_config=hardware_config
        self.sequences_dir=sequences_dir
        self.dictionary={}
        self.transitions={}
        if not self.parallel_mode:
            self.search_sequences()
        self.fill_length=10000
        self.cycles=0
        self.ttloutputmask=0
        self.ttloutputword=0
        self.port=port
        #self.max_program_size=40000
        self.max_shape_count=10
        sequencer.main_program=self
        self.channel_dict=get_hardware(self.hardware_config)
        debug_print("nr of channels: "+str(len(self.channel_dict)),1)
        self.done_signal=self.configuration.done_signal
        self.debug_print=debug_print
        self.init_freq="ONCE"
