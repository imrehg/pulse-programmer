#!/usr/bin/python
# package.py
# Copyright (C) 2005-2007 Darrell Harmon
# Generates footprints for PCB from text description
# The GPL applies only to the python scripts.
# the output of the program and the footprint definition files
# are public domain
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# Added dih patch from David Carr - 8/28/2005 Darrell Harmon

# 1/6/2007
# Bugfix from David Carr to correct row and col reversal in BGA omitballs
# Several improvements sent to me by Peter Baxendale, with some modification
# by DLH: Square pin 1 on all through hole, optional inside silkscreen on
# SO parts with diagonal corner for pin 1, to enable use silkstyle = "inside",
# disabled by default or use silkstyle = "none"

# list of attributes to be defined in file
def defattr():
    return {
        "elementdir"   :"",
        "part"         :"",
        "type"         :"",
        "pinshigh"     :0,
        "pins"         :0,
        "rows"         :0,
        "cols"         :0,
        "pitch"        :0,
        "silkoffset"   :0,
        "silkwidth"    :0,
        "silkboxwidth" :0,
        "silkboxheight":0,
        "silkstyle"    :"",
        "omitballs"    :"",
        "paddia"       :0,
        "dia"          :0,
        "maskclear"    :0,
        "polyclear"    :0,
        "ep"           :0,
        "rect"         :0,
        "padwidth"     :0,
        "padheight"    :0,
        "tabwidth"     :0,
        "tabheight"    :0,
        "width"        :0,
        "height"       :0,
        "silkcorner"   :0,
        "silkslot"     :0,
        "silkpolarity" :0,
        "silkcustom"   :[],
        "drill"        :0,
}

# BGA row names 20 total
rowname = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J',\
           'K', 'L', 'M', 'N', 'P', 'R', 'T', 'U', 'V', 'W', 'Y']

# generate ball name from row and column (for BGA)
def ballname(col, row):
    ball = ""
    # can handle up to ball YY
    while row>20:
        ball=rowname[(row/20) - 1]
        row = row%20
    return ball+rowname[row-1]+str(col)

# find X and Y position of ball from name
def ballpos(ball_name):
    col = ""
    row = 0
    for char in ball_name:
        if char.isdigit():
            col = col+char
        if char.isalpha():
            row = row * 20
            count = 1
            for val in rowname:
                if val==char:
                    row = row + count
                count = count +1
    col = int(col)
    return [col,row]
    
# expand B1:C5 to list of balls
def expandexpr(inputbuf):
    # single ball has no :
    if inputbuf.find(":")==-1:
        return " \"" + inputbuf + "\""
    # multiple balls
    expanded = ""
    pos1 = ballpos(inputbuf[:inputbuf.find(":")])
    pos2 = ballpos(inputbuf[inputbuf.find(":")+1:])
    # Make sure order is increasing 
    if pos1[0]>pos2[0]:
        tmp = pos1[0]
        pos1[0] = pos2[0]
        pos2[0] = tmp
    if pos1[1]>pos2[1]:
        tmp = pos1[1]
        pos1[1] = pos2[1]
        pos2[1] = tmp
    for col in range(pos1[0], pos2[0]+1):
        for row in range(pos1[1], pos2[1]+1):
            expanded = expanded + " " +"\""+ ballname(col, row)+"\""
    return expanded

def element(attrlist):
    desc = findattr(attrlist, "part")
    return "Element[\"\" \""+desc+"\" \"\" \"\" 0 0 0 0 0 100 \"\"]\n(\n"
    
# expand list of balls to omit
def expandomitlist(omitlist):
    expandedlist = ""
    tmpbuf = ""
    if not omitlist:
        return ""
    for character in omitlist:
        if character.isalpha() or character.isdigit() or character==":":
            tmpbuf = tmpbuf + character
        elif character == ',':
            expandedlist = expandedlist + expandexpr(tmpbuf)
            tmpbuf = ''
    #last value will be in tmpbuf
    expandedlist = expandedlist + expandexpr(tmpbuf)
    print expandedlist
    return expandedlist
    
def findattr(attrlist, name):
    if (name in attrlist):
        return attrlist[name]
    raise RuntimeError("Attribute not found: ["+str(name)+"]")

def changeattr(attrlist, name, newval):
    if (name in attrlist.keys()):
        attrlist[name] = newval
        return
    raise RuntimeError("Attribute not found: ["+str(name)+"]")

# Format of pad line:
# Pad[-17500 -13500 -17500 -7000 2000 1000 3000 "1" "1" 0x00000180]
# X1 Y1 X2 Y2 Width polyclear mask ....
def pad(x1, y1, x2, y2, width, clear, mask, pinname, shape):
    if shape=="round":
        flags = ""
    else:
        flags = "square"
    return "\tPad[%d %d %d %d %d %d %d \"%s\" \"%s\" \"%s\"]\n"\
           % (x1, y1, x2, y2, width, clear*2, mask+width, pinname, pinname, flags)

def padctr(x,y,height,width,clear,mask,pinname):
    linewidth = min(height,width)
    linelength = abs(height-width)
    if height>width:
        #vertcal pad
        x1 = x
        x2 = x
        y1 = y - linelength/2
        y2 = y + linelength/2
    else:
        #horizontal pad
        x1 = x - linelength/2
        x2 = x + linelength/2
        y1 = y
        y2 = y
    return pad(x1,y1,x2,y2,linewidth,clear,mask,pinname,"square")        

# ball is a zero length round pad
def ball(x, y, dia, clear, mask, name):
    return pad(x, y, x, y, dia, clear, mask, name, "round")

# draw silkscreen line
def silk(x1, y1, x2, y2, width):
    return "\tElementLine[%d %d %d %d %d]\n" % (x1, y1, x2, y2, width)

# draw silkscreen arc
def arc(x, y, width, radius, start, delta):
    return "\tElementArc[%d %d %d %d %d %d %d]\n" % \
           (x, y, radius, radius, start, delta, width)

# draw silkscreen box
def box(x1, y1, x2, y2, width):
    return silk(x1,y1,x2,y1,width)+\
           silk(x2,y1,x2,y2,width)+\
           silk(x2,y2,x1,y2,width)+\
           silk(x1,y2,x1,y1,width)

# draw inside box (PRB)
# draws silkscreen box for SO or QFP type parts with notched pin #1 corner
def insidebox(x1, y1, x2, y2, width, corner=1000):
    return silk(x1,y1,x2,y1,width)+\
           silk(x2,y1,x2,y2+corner,width)+\
           silk(x2,y2+corner,x2+corner,y2,width)+\
           silk(x2+corner,y2,x1,y2,width)+\
           silk(x1,y2,x1,y1,width)

# draws silkscreen box for SO or QFP type parts with slot near pin #1 side
def slotbox(x1, y1, x2, y2, width, radius=0):
    if (radius == 0):
        radius = int(abs(x2 - x1) / 5)
    midx = (x1 + x2) / 2
    return silk(x1,y2,midx+radius,y2,width)+\
           silk(midx-radius,y2,x2,y2,width)+\
           silk(x2,y1,x2,y2,width)+\
           silk(x2,y1,x1,y1,width)+\
           silk(x1,y2,x1,y1,width)+\
           arc(midx,y2,width,radius,0,180)

def bga(attrlist):
    # definitions needed to generate bga
    cols = findattr(attrlist, "cols")
    rows = findattr(attrlist, "rows")
    pitch = findattr(attrlist, "pitch")
    balldia = findattr(attrlist, "dia")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    silkoffset = findattr(attrlist, "silkoffset")
    silkboxwidth = findattr(attrlist, "silkboxwidth")
    silkboxheight = findattr(attrlist, "silkboxheight")
    omitlist = expandomitlist(findattr(attrlist, "omitballs"))
    width = (cols-1)*pitch+balldia
    height = (rows-1)*pitch+balldia
    # ensure silkscreen doesn't overlap balls
    if silkboxwidth<width or silkboxheight<height:
        silkboxx = width/2 + silkoffset
        silkboxy = height/2 + silkoffset
    else:
        silkboxx = silkboxwidth/2
        silkboxy = silkboxheight/2
    bgaelt = element(attrlist)
    # silkscreen outline
    bgaelt = bgaelt + box(silkboxx,silkboxy,-silkboxx,-silkboxy,silkwidth)
    # pin 1 indicator 1mm long tick
    bgaelt = bgaelt + silk(-silkboxx, -silkboxy, -(silkboxx+3940), -(silkboxy+3940), silkwidth)
    # position of ball A1
    xoff = -int((cols+1)*pitch/2)
    yoff = -int((rows+1)*pitch/2)
    for row in range(1, rows+1):
        for col in range(1, 1+cols):
            # found bug here row,col reversed
            if omitlist.find("\""+ballname(col,row)+"\"")==-1:
                x = xoff + (pitch*col)
                y = yoff + (pitch*row)
                bgaelt = bgaelt + ball(x, y, balldia, polyclear, maskclear, ballname(col,row))
    return bgaelt+")\n"

# draw a row of square pads
# pos is center position
# whichway can be up down left right
def rowofpads(pos, pitch, whichway, padlen, padheight, startnum, numpads, maskclear, polyclear):
    pads = ""
    rowlen = pitch * (numpads - 1)
    if whichway == "down":
        x = pos[0]
        y = pos[1] - rowlen/2
        for padnum in range (startnum, startnum+numpads):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,str(padnum))
            y = y + pitch
    elif whichway == "up":
        x = pos[0]
        y = pos[1] + rowlen/2
        for padnum in range (startnum, startnum+numpads):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,str(padnum))
            y = y - pitch
    elif whichway == "right":
        x = pos[0] - rowlen/2
        y = pos[1]
        for padnum in range (startnum, startnum+numpads):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,str(padnum))
            x = x + pitch
    elif whichway == "left":
        x = pos[0] + rowlen/2
        y = pos[1]
        for padnum in range (startnum, startnum+numpads):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,str(padnum))
            x = x - pitch
    return pads

def qfp(attrlist):
    qfpelt = element(attrlist)
    pins = findattr(attrlist, "pins")
    pinshigh = findattr(attrlist, "pinshigh")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    pitch = findattr(attrlist, "pitch")
    width = findattr(attrlist, "width")
    height = findattr(attrlist, "height")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    silkoffset = findattr(attrlist, "silkoffset")
    silkstyle = findattr(attrlist, "silkstyle")
    silkcorner = findattr(attrlist, "silkcorner")
    ep = findattr(attrlist, "ep")
    if pinshigh==0:
        pinshigh = pins/4
        pinswide = pins/4
        height = width
    else:
        pinswide = (pins-2*pinshigh)/2
    if pinshigh:
        # draw left side
        qfpelt = qfpelt + rowofpads([-(width+padwidth)/2,0], pitch, "down", padwidth,\
                                    padheight, 1, pinshigh, maskclear, polyclear)
        # draw right side
        qfpelt = qfpelt + rowofpads([(width+padwidth)/2,0], pitch, "up", padwidth,\
                                    padheight, pinshigh+pinswide+1, pinshigh,\
                                    maskclear, polyclear)
    if pinswide:
        # draw bottom
        qfpelt = qfpelt + rowofpads([0,(height+padwidth)/2], pitch, "right", padheight,\
                                    padwidth, pinshigh+1, pinswide, maskclear, polyclear)
        # draw top
        qfpelt = qfpelt + rowofpads([0,-(height+padwidth)/2], pitch, "left", padheight,\
                                    padwidth, 2*pinshigh+pinswide+1, pinswide, maskclear, polyclear)
    # exposed pad packages:
    if ep:
        qfpelt =qfpelt + pad(0,0,0,0,ep,polyclear,maskclear,str(pins+1),"square")
    if silkstyle == "inside":
        x = width/2 - silkoffset
        y = height/2 - silkoffset
        qfpelt = qfpelt + insidebox(x,y,-x,-y,silkwidth,silkcorner)
        #qfpelt = qfpelt + silk(-x,-y,-(x+3940),-(y+3940),silkwidth)
    elif silkstyle == "outside":
        x = (width+2*padwidth)/2 + silkoffset
        y = (height+2*padwidth)/2 + silkoffset
        qfpelt = qfpelt + box(x,y,-x,-y,silkwidth)
        qfpelt = qfpelt + silk(-x,-y,-(x+3940),-(y+3940),silkwidth)
    return qfpelt+")\n"
# def rowofpads(pos, pitch, whichway, padlen, padheight, startnum, numpads, maskclear, polyclear):
# uses pins, padwidth, padheight, pitch
def so(attrlist):
    pins = findattr(attrlist, "pins")
    pitch = findattr(attrlist, "pitch")
    width = findattr(attrlist, "width")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    silkoffset = findattr(attrlist, "silkoffset")
    silkboxheight = findattr(attrlist, "silkboxheight")
    silkstyle = findattr(attrlist, "silkstyle")
    silkslot = findattr(attrlist, "silkslot")
    if pins % 2:
        print "Odd number of pins: that is a problem"
        print "Skipping " + findattr(attrlist, "type")
        return ""
    rowpos = (width+padwidth)/2
    soelt = element(attrlist)
    soelt = soelt + rowofpads([-rowpos,0], pitch, "down", padwidth, padheight, 1, pins/2, maskclear, polyclear)
    soelt = soelt + rowofpads([rowpos,0], pitch, "up", padwidth, padheight, 1+pins/2, pins/2, maskclear, polyclear)
    if (silkstyle != "inside"):
        silkboxheight = max(pitch*(pins-2)/2+padheight+2*silkoffset,
                            silkboxheight)
    
    silky = silkboxheight/2
    
    # Inside box with notched corner as submitted in patch by PRB
    if(silkstyle == "inside"):
        silkx = width/2 - silkoffset
        if (silkslot != 0):
            soelt = soelt + slotbox(silkx,silky,-silkx,-silky,silkwidth)
        else:
            soelt = soelt + insidebox(silkx,silky,-silkx,-silky,silkwidth)
    else:
        silkx = width/2 + silkoffset + padwidth
        soelt = soelt + box(silkx,silky,-silkx,-silky,silkwidth)
        soelt = soelt + silk(0,-silky+2000,-2000,-silky,silkwidth)
        soelt = soelt + silk(0,-silky+2000,2000,-silky,silkwidth)
    return soelt+")\n"

def twopad(attrlist):
    width = findattr(attrlist, "width")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    silkboxwidth = findattr(attrlist, "silkboxwidth")
    silkboxheight = findattr(attrlist, "silkboxheight")
    silkoffset = findattr(attrlist, "silkoffset")
    silkpolarity = findattr(attrlist, "silkpolarity")
    silkcustom = findattr(attrlist, "silkcustom")
    
    twopadelt = element(attrlist)
    twopadelt = twopadelt + rowofpads([0,0], width+padwidth, "right", padwidth, padheight, 1, 2, maskclear, polyclear)
    silkx = max((width+2*padwidth)/2 + silkoffset,silkboxwidth/2)
    silky = max(padheight/2 + silkoffset, silkboxheight/2)
    twopadelt = twopadelt + box(silkx,silky,-silkx,-silky,silkwidth)
    if (silkpolarity == "yes"):
        polx = silkx + 2*silkoffset
        twopadelt = twopadelt + silk(silkx, silky, polx, silky, silkwidth)
        twopadelt = twopadelt + silk(silkx, -silky, polx, -silky, silkwidth)
        twopadelt = twopadelt + silk(polx, -silky, polx, silky, silkwidth)
    for line in silkcustom:
        twopadelt += "\t" + str(line) + "\n"
    return twopadelt+")\n"

# SOT223, DDPAK, TO-263, etc
def tabbed(attrlist):
    pins = findattr(attrlist, "pins")
    tabwidth = findattr(attrlist, "tabwidth")
    tabheight = findattr(attrlist, "tabheight")
    height = findattr(attrlist, "height")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    silkoffset = findattr(attrlist, "silkoffset")
    pitch = findattr(attrlist, "pitch")
    totalheight = height+tabheight+padheight
    totalwidth = max(tabwidth, (pins-1)*pitch+padwidth)
    silkx = totalwidth/2 + silkoffset
    silky = totalheight/2 + silkoffset
    taby = -(totalheight-tabheight)/2
    padsy = -(padheight - totalheight)/2
    tabbedelt = element(attrlist)
    tabbedelt = tabbedelt + rowofpads([0,padsy], pitch, "right", padwidth, padheight, 1, pins, maskclear, polyclear)
    tabbedelt = tabbedelt + padctr(0,taby,tabheight,tabwidth,polyclear,maskclear,str(pins+1))
    tabbedelt = tabbedelt + box(silkx,silky,-silkx,-silky,silkwidth)
    return tabbedelt+")\n"
#  Pin[17500 -24000 6400 2000 6400 3500 "" "1" 0x00000001]
# x,y,paddia,polyclear,maskclear,drill,name,name,flags

def pin(x,y,dia,drill,name,polyclear,maskclear):
    if name == "1":
        pinflags = "pin"
    else:
        pinflags = ""
    return "\tPin[ %d %d %d %d %d %d \"%s\" \"%s\" \"%s\"]\n" % (x,y,dia,polyclear*2,maskclear+dia,drill,name,name,pinflags)

def dip(attrlist):
    pins = findattr(attrlist, "pins")
    drill = findattr(attrlist, "drill")
    paddia = findattr(attrlist, "paddia")
    width = findattr(attrlist, "width")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    pitch = findattr(attrlist, "pitch")
    y = -(pins/2-1)*pitch/2
    x = width/2
    dipelt = element(attrlist)
    for pinnum in range (1,1+pins/2):
        dipelt = dipelt + pin(-x,y,paddia,drill,str(pinnum),polyclear,maskclear)
        y = y + pitch
    y = y - pitch
    for pinnum in range (1+pins/2, pins+1):
        dipelt = dipelt + pin(x,y,paddia,drill,str(pinnum),polyclear,maskclear)
        y = y - pitch
    silky = pins*pitch/4
    silkx = (width+pitch)/2
    dipelt = dipelt + box(silkx,silky,-silkx,-silky,silkwidth)
    dipelt = dipelt + box(-silkx,-silky,-silkx+pitch,-silky+pitch,silkwidth)
    return dipelt+")\n"

def dih(attrlist):
    pins = findattr(attrlist, "pins")
    drill = findattr(attrlist, "drill")
    paddia = findattr(attrlist, "paddia")
    width = findattr(attrlist, "width")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    pitch = findattr(attrlist, "pitch")
    y = -(pins/2-1)*pitch/2
    x = width/2
    dipelt = element(attrlist)
    for pinnum in range (1,1+pins,2):
        dipelt = dipelt + pin(-x,y,paddia,drill,str(pinnum),polyclear,maskclear)
        y = y + pitch
    y = -(pins/2-1)*pitch/2
    for pinnum in range (2,1+pins,2):
        dipelt = dipelt + pin(x,y,paddia,drill,str(pinnum),polyclear,maskclear)
        y = y + pitch
    silky = pins*pitch/4
    silkx = (width+pitch)/2
    dipelt = dipelt + box(silkx,silky,-silkx,-silky,silkwidth)
    dipelt = dipelt + box(-silkx,-silky,-silkx+pitch,-silky+pitch,silkwidth)
    return dipelt+")\n"

def sip(attrlist):
    pins = findattr(attrlist, "pins")
    drill = findattr(attrlist, "drill")
    paddia = findattr(attrlist, "paddia")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    pitch = findattr(attrlist, "pitch")
    y = -(pins-1)*pitch/2
    sipelt = element(attrlist)
    for pinnum in range (1,1+pins):
        sipelt = sipelt + pin(0,y,paddia,drill,str(pinnum),polyclear,maskclear)
        y = y + pitch
    silky = pins*pitch/2
    silkx = pitch/2
    sipelt = sipelt + box(silkx,silky,-silkx,-silky,silkwidth)
    sipelt = sipelt + box(-silkx,-silky,-silkx+pitch,-silky+pitch,silkwidth)
    return sipelt+")\n"

def genpart(attributes):
    parttype = findattr(attributes, "type")
    if parttype=='bga':
        return bga(attributes)
    elif parttype=='qfp':
        return qfp(attributes)
    elif parttype=='so':
        return so(attributes)
    elif parttype=='twopad':
        return twopad(attributes)
    elif parttype=='tabbed':
        return tabbed(attributes)
    elif parttype == 'dip':
        return dip(attributes)
    elif parttype == 'dih':
        return dih(attributes)
    elif parttype == 'sip':
        return sip(attributes)
    else:
        print "Unknown type "+parttype
    print ""
    return ""                                                                                                           

def inquotes(origstring):
    quotepos = re.search("\".*\"", origstring)
    if quotepos:
        return origstring[quotepos.start()+1:quotepos.end()-1]
    return ""

def str2pcbunits(dist):
    number = re.search('[0-9\.]+', dist)
    if number:
        val = float(number.group())
    else:
        return 0
    if dist[number.end():].find("mm")!=-1:
        return int(0.5 + 100000 * val/25.4)
    elif dist[number.end():].find("mil")!=-1:
        return int(0.5 + val * 100)
    elif dist[number.end():].find("in")!=-1:
        return int(0.5 + val * 100000)
    return int(val+0.5)	

import sys
#import string
import re

# open input file
if sys.argv[1:]:
    try:
        in_file = open(sys.argv[1], 'r')
    except IOError, msg:
        print 'Can\'t open "%s":' % sys.argv[1], msg
        sys.exit(1)
else:
    in_file = sys.stdin
    print "No file given so using stdin"

# list of attributes to be defined in file
attributes = defattr()
# main processing loop enter processing elements
linenum = 1
multiline = False
while True:
    validline = 0
    line = in_file.readline()
    linenum = linenum + 1
    if not line:
        break
    # strip comments
    if line.find("#") == 0:
        continue
    if line.find("#")!=-1:
        line = line[:line.find("#")-1]
    # strip whitespace
    line = line.strip()
    if line == "":
        continue
    if (line.find("silkcustomend") != -1):
        multiline = False
        attributes["silkcustom"] = silkcustomlines
        continue
    if (multiline):
        silkcustomlines.append(line)
        continue
    if (line.find("silkcustom") != -1):
        multiline = True
        silkcustomlines = []
        continue
    if line.find("clearall")!=-1:
        attributes = defattr()
        continue
    attrlist = attributes.keys()
    for attribute in attrlist:
        if (line.find(attribute) == 0):
            value = inquotes(line)
            if (value == ""):
                value = str2pcbunits(line)
            changeattr(attributes, attribute, value)
            validline = 1
            break
    if attribute == "part":
        filename = findattr(attributes,"elementdir")+"/"+findattr(attributes,"part")
        print "generated %s" % filename
        output_file = open(filename, "w")
        output_file.write(genpart(attributes))
        output_file.close()
        validline = 1
    if not validline:
        print "Ignoring garbage at line %d :%s" % (linenum, line)
			
print "%d lines read" % linenum
sys.exit(0)
