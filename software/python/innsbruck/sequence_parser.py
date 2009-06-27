#!/usr/bin/env python
# -*- mode: Python; coding: latin-1 -*-
# Time-stamp: "2007-05-03 14:15:08 c704271"

#  file      : sequence_parser.py
#  email     : philipp DOT schindler AT frog DOT uibk DOT ac DOT at
#            : remove the "green animal"
#  copyright : (c) 2006 Philipp Schindler
#  rcs       : $Id: sequence_parser.py,v 1.3 2007/12/16 23:26:47 viellieb Exp $

#_* Code

def parse_sequence(sequence_string,parent,init_string=False):
  current_tag=""
  sequence_dict={}
  for line in sequence_string.splitlines():
    try:
      if line[0]=="<":
        current_tag=line
        got_new_tag=True
      if line[0]=="</":
        current_tag=""
        got_new_tag=True
    except IndexError:
      continue
    if current_tag!="" and not got_new_tag:
      try:
        sequence_dict[current_tag]+=line+"\n"
      except KeyError:
        sequence_dict[current_tag]=line+"\n"
    got_new_tag=False

  if init_string:
    name_list=["<VARIABLES>","<TRANSITIONS>"]
  else:
    name_list=["<VARIABLES>","<TRANSITIONS>","<SEQUENCE>"]
  return_string=""
  for item in name_list:
    try:
      return_string+=sequence_dict[item]
    except KeyError:
      parent.debug_print("error while getting tag: "+str(item),1)

  return_string+="\n"+"end_sequential()"


  return return_string



#_* Local Variables

#  Local Variables:
#  allout-layout: (1 0 :)
#  End:

# sequence_parser.py ends here
