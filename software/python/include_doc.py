#!/usr/bin/env python
# -*- mode: Python; coding: latin-1 -*-
# Time-stamp: "2006-09-19 14:55:16 c704271"

#  file      : include_doc.py
#  email     : philipp DOT schindler AT uibk DOT frog DOT ac DOT at
#            : remove the "green animal"
#  copyright : (c) 2006 Philipp Schindler
#  rcs       : $Id: include_doc.py,v 1.2 2006/11/16 13:30:43 koerbert Exp $

#_* Code

#_* Local Variables

#  Local Variables:
#  allout-layout: (1 0 :)
#  End:

from innsbruck import *
from math import *


def print_error(string1):
  print string1

def include_doc(file_name,absolute_path=False):
    error_handler = print_error
    includes_dir=innsbruck.configuration.includes_dir
    print "including "+str(file_name)
    if absolute_path:
        absolute_file_name=file_name
    else:
        absolute_file_name=includes_dir+file_name
    try:
        file1=open(absolute_file_name)
        string1=file1.read()
        file1.close()
    except:
        error_handler("error couldn't open include file: "+str(file_name))
    try:
      description1="No description avaible"
      arguments="no arguments known"
      function_name="No function known"
      exec(string1)
      array1=[]
      array1.append(description)
      array1.append(arguments)
      array1.append(function_name)
      return array1
    except SyntaxError:
        error_handler("error while executing include file: "+str(file_name))




include_desc={}
dir1=innsbruck.configuration.std_includes_dir
for f in os.listdir(dir1):
  module_name, ext = os.path.splitext(f) # Handles no-extension files, etc.
  if ((ext == '.py') and (module_name != "__init__")): # Important, ignore .pyc/other files.
    desc_item=include_doc(dir1+module_name+ext,absolute_path=True)
    include_desc[module_name+ext]=desc_item

for key in include_desc:
  item=include_desc[key]
  str1="\n Filename: "+key+"\n\t Description: "+item[0] \
        +"\n\t Arguments: "+item[1]+"\n\t Function name: "+item[2]
  print str1


# include_doc.py ends here
