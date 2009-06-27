import sequencer
import innsbruck

from sequencer.pcp.events.separable_pulse import *

# sets TTL channel by channel key
def ttl_set_channel(device_key,value):
  try:
    device=innsbruck.ttl_device[device_key][0]
    #check if the channel is inverting
    if innsbruck.ttl_device[device_key][1]==1:
      value=1-value
    event_list = device.create_output_events(value = value)
    sequencer.current_sequence.add_event_list(event_list)
  except KeyError:
    debug_print("Error cannot find "+str(device_key),1)

# sets TTL channel by channel number
def TTL_set_channel(channel,value):
    device=innsbruck.TTL_Device(channel)
    event_list = device.create_output_events(value = value)
    sequencer.current_sequence.add_event_list(event_list)

# sets multiple TTL channels by channel keys
def ttl_set_multiple_channel(device_keys,values):
  event_list=[]
  for i in range(len(device_keys)):
    device_key=device_keys[i]
    value=values[i]
    device=innsbruck.ttl_device[device_key][0]
    #check if the channel is inverting
    if innsbruck.ttl_device[device_key][1]==1:
      value=1-value
    event_list+=device.create_output_events(value = value)
  event=SeparablePulse_Event(event_list)
  sequencer.current_sequence.add_event(event)

# sets multiple TTL channels by channel number
def TTL_set_multiple_channel(channels,values):
  event_list=[]
  for i in range(len(channels)):
    device=innsbruck.TTL_Device(channels[i])
    event_list+=device.create_output_events(value = values[i])
    print channels[i],values[i]
  event=SeparablePulse_Event(event_list)
  sequencer.current_sequence.add_event(event)

# sets TTL channels by 16 bit number and mask
def TTL_set_multiple_channels(word,mask):
  event_list=[]
  for i in range(16):
    mask_bit = (mask&pow(2,i))/pow(2,i)
    value_bit = (word&pow(2,i))/pow(2,i)
    if mask_bit==1:
      device = innsbruck.TTL_Device(i)
      event_list += device.create_output_events(value = value_bit)
  if event_list != []:
    event = SeparablePulse_Event(event_list)
    sequencer.current_sequence.add_event(event)
