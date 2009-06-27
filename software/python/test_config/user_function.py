from test_config.api import *
from sequencer.api   import *
from sequencer.pcp.events.wait import Wait_Event

def read_pmt(duration):
    value_on=1
    value_off=0
    wait1=4
    event_list=[]
    event_list+=test_config.pmt_device.create_output_events(value = value_on)
    event_list.append(Wait_Event(wait1))
    event_list+=test_config.pmt_device.create_output_events(value = value_off)
    wait_steps=int(duration/test_config.cycle_time*1000)
    event_list.append(Wait_Event(wait_steps))
    event_list+=test_config.pmt_device.create_output_events(value = value_on)
    event_list.append(Wait_Event(wait1))
    event_list+=test_config.pmt_device.create_output_events(value = value_off)
    sequencer.current_sequence.add_event_list(event_list)
    
    
