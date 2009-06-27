from sequencer.constants import *

def get_variables(var_string,parent):
    print var_string
    if parent.parallel_mode:
        parent.program_string=var_string
        return
    command_dict=get_command_dict()
    parent.variables={}
    splitted_list=[]
    frame=var_string.split(";")
    for frame_item in frame:
        splitted=frame_item.split(",")
        splitted_list.append(splitted)
        try:
            command_dict[splitted[0]](splitted,parent)
        except KeyError:
            if str(splitted)=="['']":
                parent.debug_print("got a blank as command - please check your command",2)
            else:
                parent.error_handler("error: cannot identify command"+str(splitted))
        except SyntaxError:
            parent.error_handler("error while executing command"+str(splitted))
    return parent.variables

def get_command_dict():
    command_dict={}
    # The commands understood by the server
    command_dict["NAME"]=get_name
    command_dict["CYCLES"]=get_cycles
    command_dict["TRIGGER"]=get_trigger
    command_dict["TTLMASK"]=get_ttlmask
    command_dict["TTLWORD"]=get_ttlword
    command_dict["INIT_FREQ"]=get_init_freq
    
    #Some boring ordinary variables
    command_dict["FLOAT"]=get_vars
    command_dict["INT"]=get_vars
    command_dict["BOOL"]=get_vars
    command_dict["STRING"]=get_vars

    # The transition variables:
    command_dict["TRANSITION"]=get_transition
    command_dict["DEFAULT_TRANSITION"]=get_transition
    command_dict["RABI"]=get_transition
    command_dict["SLOPE_TYPE"]=get_transition
    command_dict["SLOPE_DUR"]=get_transition
    command_dict["FREQ"]=get_transition
    command_dict["SWEEP"]=get_transition
    command_dict["AMPL"]=get_transition
    command_dict["IONS"]=get_transition
    command_dict["FREQ2"]=get_transition
    command_dict["AMPL2"]=get_transition
    command_dict["PORT"]=get_transition
    command_dict["OFFSET"]=get_transition
    command_dict["MULTIPLIER"]=get_transition
    command_dict["SIDEBAND"]=get_transition

    #return the dict to the handler !
    return command_dict

def get_name(splitted,parent):
    parent.pulse_program_name=splitted[1]

def get_cycles(splitted,parent):
    parent.cycles=int(splitted[1])

def get_ttlmask(splitted,parent):
    parent.ttloutputmask=int(splitted[1])

def get_ttlword(splitted,parent):
    parent.ttloutputword=int(splitted[1])

def get_vars(splitted,parent):
    if (splitted[0]=="FLOAT"):
        parent.variables[splitted[1]]=float(splitted[2])
    elif (splitted[0]=="INT"):
        parent.variables[splitted[1]]=int(splitted[2])
    elif (splitted[0]=="STRING"):
        parent.variables[splitted[1]]=str(splitted[2])
    elif (splitted[0]=="BOOL"):
        parent.variables[splitted[1]]=bool(int(splitted[2]))


def get_trigger(splitted,parent):
    trig_string=splitted[1]
    if (trig_string!="NONE"):
        parent.start_trigger=parent.configuration.line_trigger
        parent.is_triggered=True


def get_init_freq(splitted,parent):
    init_string=splitted[1]
    if init_string=="CYCLE":
        parent.init_freq="CYCLE"
    else:
        parent.init_freq="ONCE"

def get_transition(splitted,parent):
    global last_transition

    if splitted[0]=="TRANSITION":
        parent.add_transition(splitted[1])
        last_transition=splitted[1]
    if splitted[0]=="DEFAULT_TRANSITION":
        parent.add_transition(splitted[1])
        last_transition=splitted[1]
        parent.default_transition=parent.transitions[last_transition]

    transition=parent.transitions[last_transition]
    if splitted[0]=="RABI":
        transition.t_rabi=get_dictionary(splitted)
    elif splitted[0]=="SLOPE_TYPE":
        transition.slope_type=splitted[1]
    elif splitted[0]=="SLOPE_DUR":
        transition.slope_duration=float(splitted[1])
    elif splitted[0]=="AMPL":
        transition.amplitude=float(splitted[1])
    elif splitted[0]=="SWEEP":
        transition.sweeprange=float(splitted[1])
    elif splitted[0]=="FREQ":
        transition.frequency=float(splitted[1])
        transition.freq_is_init=False
    elif splitted[0]=="AMPL2":
        transition.amplitude2=float(splitted[1])
    elif splitted[0]=="FREQ2":
        transition.frequency2=float(splitted[1])
        transition.freq_is_init=False
    elif splitted[0]=="IONS":
        transition.ion_list=get_dictionary(splitted)
    elif splitted[0]=="PORT":
        transition.port=int(splitted[1])
    elif splitted[0]=="MULTIPLIER":
        transition.multiplier=int(splitted[1])
    elif splitted[0]=="OFFSET":
        transition.offset=int(splitted[1])
    elif splitted[0]=="SIDEBAND":
        transition.sideband=int(splitted[1])
        
        
    parent.transitions[last_transition]=transition



def get_dictionary(splitted):
    dict_string="this_dict={"
    for i in range(1,len(splitted)):
        dict_string+=splitted[i]+" , "
    dict_string+="}"
    try:
        exec(dict_string)
    except:
        parent.error_handler("Error while getting dictionary"+str(splitted))
    return this_dict
