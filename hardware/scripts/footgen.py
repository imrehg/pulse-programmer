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
        "masktent"     :0,
        "tentpadheight":0,
        "bankwidth"    :0,
        "bankpins"     :0,
        "mirror"       :0,
        "tabx"         :0,
        "edgey"        :0,
        "edgex"        :0,
        "edgewidth"    :0,
        "headernum"    :0,
        "bankpinstwo"  :0,
        "banksep"      :0,
        "edgedip"      :0,
        "silkheight"   :0,
        "receptm"      :0,
        "receptb"      :0,
        "lccnum"       :0,
        "pinkey"       :0,
        "series"       :0,
        "sepone"         :0,
        "septwo"         :0,
        "gndwidth"     :0,
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
def pad(x1, y1, x2, y2, width, clear, mask, pinname, shape, tent=False,
        onsolder=False):
    if shape=="round":
        flags = ""
    else:
        flags = "square"
    if (onsolder):
        flags += ",onsolder"
    if (not tent):
        mask += width
    return "\tPad[%d %d %d %d %d %d %d \"\" \"%s\" \"%s\"]\n"\
           % (x1, y1, x2, y2, width, clear*2, mask, pinname, flags)

def padctr(x,y,height,width,clear,mask,pinname,tent,onsolder):
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
    return pad(x1,y1,x2,y2,linewidth,clear,mask,pinname,"square",tent,onsolder)

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
    return bgaelt

# draw a row of square pads
# pos is center position
# whichway can be up down left right
def rowofpads(pos, pitch, whichway, padlen, padheight, startnum, numpads,
              maskclear, polyclear, prefix="", tent=False, onsolder=False,
              headernum=False, lccnum=False):
    pads = ""
    rowlen = pitch * (numpads - 1)
    step = 1
    if (headernum == True):
        step = 2
        rowlen = pitch * ((numpads/2) - 1)
    if whichway == "down":
        x = pos[0]
        y = pos[1] - rowlen/2
        for padnum in range (startnum, startnum+numpads, step):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,\
                                 prefix + str(padnum), \
                                 tent=tent, onsolder=onsolder)
            y = y + pitch
    elif whichway == "up":
        x = pos[0]
        y = pos[1] + rowlen/2
        for padnum in range (startnum, startnum+numpads, step):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,\
                                 prefix + str(padnum), \
                                 tent=tent, onsolder=onsolder)
            y = y - pitch
    elif whichway == "right":
        x = pos[0] - rowlen/2
        y = pos[1]
        for padnum in range (startnum, startnum+numpads, step):
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,\
                                 prefix + str(padnum), \
                                 tent=tent, onsolder=onsolder)
            x = x + pitch
    elif whichway == "left":
        x = pos[0] + rowlen/2
        y = pos[1]
        for padnum in range (startnum, startnum+numpads, step):
            if (lccnum):
                if (padnum > (numpads * 4)):
                    padnum = padnum % (numpads * 4)
            pads = pads + padctr(x,y,padheight,padlen,polyclear,maskclear,\
                                 prefix + str(padnum), \
                                 tent=tent, onsolder=onsolder)
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
    lccnum = findattr(attrlist, "lccnum")
    ep = findattr(attrlist, "ep")
    if pinshigh==0:
        pinshigh = pins/4
        pinswide = pins/4
        height = width
    else:
        pinswide = (pins-2*pinshigh)/2
    if pinshigh:
        left_start = 1
        right_start = pinshigh+pinswide+1
        if (lccnum == "yes"):
            left_start += (pinshigh/2) + 1
            right_start += (pinshigh/2) + 1
        # draw left side
        qfpelt = qfpelt + \
                 rowofpads([-(width+padwidth)/2,0], pitch, "down", padwidth,\
                           padheight, left_start, pinshigh, \
                           maskclear, polyclear)
        # draw right side
        qfpelt = qfpelt + \
                 rowofpads([(width+padwidth)/2,0], pitch, "up", padwidth,\
                           padheight, right_start, pinshigh,\
                           maskclear, polyclear)
    if pinswide:
        top_start = pinshigh + 1
        bottom_start = (2 * pinshigh) + pinswide + 1
        if (lccnum == "yes"):
            top_start += (pinshigh/2) + 1
            bottom_start += (pinshigh/2) + 1
        # draw bottom
        qfpelt = qfpelt + \
                 rowofpads([0,(height+padwidth)/2], pitch, "right", padheight,\
                           padwidth, top_start, pinswide, \
                           maskclear, polyclear)
        # draw top
        qfpelt = qfpelt + \
                 rowofpads([0,-(height+padwidth)/2], pitch, "left", padheight,\
                           padwidth, bottom_start, pinswide, \
                           maskclear, polyclear, lccnum = (lccnum =="yes"))
    # exposed pad packages:
    if ep:
        qfpelt = qfpelt + \
                 pad(0,0,0,0,ep,polyclear,maskclear,str(pins+1),"square")
    if silkstyle == "inside":
        x = width/2 - silkoffset
        y = height/2 - silkoffset
        qfpelt = qfpelt + insidebox(x,y,-x,-y,silkwidth,silkcorner)
    elif silkstyle == "outside":
        x = (width+2*padwidth)/2 + silkoffset
        y = (height+2*padwidth)/2 + silkoffset
        qfpelt = qfpelt + insidebox(x,y,-x,-y,silkwidth,silkcorner)
    return qfpelt

def edgecard(attrlist):
    edgeelt = element(attrlist)
    bankpins1 = findattr(attrlist, "bankpins")
    bankpins2 = findattr(attrlist, "bankpinstwo")
    banksep = findattr(attrlist, "banksep")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    pitch = findattr(attrlist, "pitch")
    height = findattr(attrlist, "height")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    edgedip = findattr(attrlist, "edgedip")
    paddia = findattr(attrlist, "paddia")
    drill = findattr(attrlist, "drill")
    silkheight = findattr(attrlist, "silkheight")
    startpin = 1
    startx = 0
    
    for bankpins in [bankpins1, bankpins2]:
        if (edgedip == "yes"):
            x = startx
            pn = startpin
            for pinnum in range(bankpins):
              edgeelt = edgeelt + pin(x,0,paddia,drill,"T"+str(pn),
                                  polyclear,maskclear)
              edgeelt = edgeelt + pin(x,height,paddia,drill,"B"+str(pn),
                                  polyclear,maskclear)
              pn += 1
              x += pitch
        else:
            edgeelt += rowofpads([startx + (pitch*(bankpins-1)/2), 0],\
                                 pitch, "left", padwidth, padheight,\
                                 startpin, bankpins, \
                                 maskclear, polyclear, prefix="T")
            edgeelt += rowofpads([startx + (pitch*(bankpins-1)/2), 0],\
                                 pitch, "left", padwidth, padheight,\
                                 startpin, bankpins, \
                                 maskclear, polyclear, prefix="B", onsolder=True)
        startpin += bankpins
        startx += banksep + (pitch*(bankpins+1))

    if (edgedip == "yes"):
        edgeelt += box(-pitch, -(silkheight - height)/2,
                       pitch*(bankpins1+bankpins2+1)+banksep,
                       (silkheight + height)/2, silkwidth)
    else:
        # Left edge
        edgeelt += silk(-pitch, -padheight/2, -pitch,
                        -(padheight/2)+height, silkwidth)
        # Bottom left edge
        edgeelt += silk(-pitch, -padheight/2, pitch*(bankpins1), -padheight/2,
                       silkwidth)

        # Middle left edge
        edgeelt += silk(pitch*(bankpins1), -padheight/2, pitch*(bankpins1),
                       -(padheight/2)+height, silkwidth)
        # Middle right edge
        edgeelt += silk(pitch*(bankpins1)+banksep, -padheight/2,
                       pitch*(bankpins1)+banksep, -(padheight/2)+height,
                       silkwidth)

        # Bottom right edge
        edgeelt += silk(pitch*(bankpins1)+banksep, -padheight/2,
                        banksep+(pitch*(bankpins1+bankpins2+1)), -padheight/2,
                        silkwidth)
        # Top edge
        edgeelt += silk(-pitch, -(padheight/2)+height,
                        banksep + (pitch*(bankpins1+bankpins2+1)),
                        -(padheight/2)+height, silkwidth)
        # Right edge
        edgeelt += silk(banksep+(pitch*(bankpins1+bankpins2+1)),
                        -(padheight/2),
                        banksep+(pitch*(bankpins1+bankpins2+1)),
                        -(padheight/2)+height, silkwidth)
    return edgeelt

def samtec(attrlist):
    samelt = element(attrlist)
    pins = findattr(attrlist, "pins")
    padwidth = findattr(attrlist, "padwidth")
    padheight = findattr(attrlist, "padheight")
    pitch = findattr(attrlist, "pitch")
    height = findattr(attrlist, "height")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    masktent = findattr(attrlist, "masktent")
    silkwidth = findattr(attrlist, "silkwidth")
    silkboxheight = findattr(attrlist, "silkboxheight")

    tentpadheight = findattr(attrlist, "tentpadheight")
    bankwidth = findattr(attrlist, "bankwidth")
    bankpins = findattr(attrlist, "bankpins")
    mirror = findattr(attrlist, "mirror")
    tabx = findattr(attrlist, "tabx")
    edgey = findattr(attrlist, "edgey")
    edgex = findattr(attrlist, "edgex")
    edgewidth = findattr(attrlist, "edgewidth")
    series = findattr(attrlist, "series")
    paddia = findattr(attrlist, "paddia")
    drill = findattr(attrlist, "drill")
    #width = bankwidth * (pins / bankpins)
    width = findattr(attrlist, "width")
    gndwidth = findattr(attrlist, "gndwidth")
    sep1 = findattr(attrlist, "sepone")
    sep2 = findattr(attrlist, "septwo")
    silkoffset = findattr(attrlist, "silkoffset")
    banks = pins / bankpins
    overlap = 150 # 4 mil overlap to consider separate copper connected
    tentpadbase = -(padheight/2) - (tentpadheight/2)
    padbase = -(overlap/2)

    if (pins % bankpins) != 0:
        raise RuntimeError("Number of pins not a multiple of bankpins")

    yaxis = 1
    if (mirror == "yes"):
        yaxis = -1

    # Edgemount connector
    if (series == "qxe"):
      # Compensate pad extension height with the mask tent
      tentpadheight += (padwidth - masktent)
      padbase *= yaxis
      edgey = yaxis * ((padheight/2) + edgey)
      padheight += overlap
      tabx = -tabx # distance from pin 1 left to alignment tab

      # Base pins with completely exposed pad
      for i in range(banks):
          startpin = (i*bankpins)+1
          bankstart = (bankwidth*(banks-i-1))
          bankcenter = bankstart + (pitch*(bankpins-1)/2)
          samelt += rowofpads([bankcenter, padbase], pitch, "left", \
                              padwidth, padheight, startpin, bankpins, \
                              maskclear, polyclear, prefix="T")
          samelt += rowofpads([bankcenter, padbase], pitch, "left", \
                              padwidth, padheight, startpin, bankpins, \
                              maskclear, polyclear, prefix="B", onsolder=True)
      # Pad extensions that are partially exposed (soldermask tent)
      tentpadbase *= yaxis
      for i in range(banks):
          startpin = (i*bankpins)+1
          samelt += rowofpads([(bankwidth*(banks-i-1))+(pitch*(bankpins-1)/2),\
                               tentpadbase], \
                              pitch, "left", padwidth, tentpadheight,\
                              startpin, bankpins, masktent, \
                              polyclear, prefix="T", tent=True)
          samelt += rowofpads([(bankwidth*(banks-i-1))+(pitch*(bankpins-1)/2),\
                               tentpadbase], \
                              pitch, "left", padwidth, tentpadheight,\
                              startpin, bankpins, masktent, \
                              polyclear, prefix="B", tent=True, onsolder=True)
    elif (series == "qxss"):
      # Half of separation between inner edges of row pads
      halfsep = (width - (2*padheight)) / 2
      for i in range(banks):
          startpin = (i*bankpins)+1
          bankstart = (bankwidth*(banks-i-1))
          bankcenter = bankstart + (pitch*(bankpins-1)/2)
          samelt += rowofpads([bankcenter, halfsep], pitch, "left", \
                              padwidth, padheight, startpin, bankpins, \
                              maskclear, polyclear, prefix="L")
          samelt += rowofpads([bankcenter, -halfsep], pitch, "left", \
                              padwidth, padheight, startpin, bankpins, \
                              maskclear, polyclear, prefix="R")

    # Plated edge ground pad
    if (series == "qxe"):
      edgestart = -edgex
      edgeend = edgestart + (78750*banks) + edgewidth
      samelt += pad(edgestart, edgey, edgeend, edgey, 1000, polyclear,
                    maskclear, "TGND", shape="square")
      samelt += pad(edgestart, edgey, edgeend, edgey, 1000, polyclear,
                    maskclear, "BGND", shape="square", onsolder=True)
      # Alignment tab drill guide
      holedrill = 4300
      taby = [-9350 * yaxis, -4050 * yaxis, 1250 * yaxis]
      for i in range(3):
          samelt += pin(tabx, taby[i], holedrill, holedrill, "", polyclear,
                        maskclear, ishole = True)
      # Silkscreen lines
      silky1 = yaxis * 6000
      silky2 = yaxis * -6500
      samelt += silk(tabx + 2450, silky1, tabx + 2450, silky2, silkwidth)
      samelt += silk(-31000, silky1, -31000, silky2, silkwidth)

      silkstart = (bankwidth * (banks-1)) + 79000
      silkend = silkstart + 12000
      samelt += silk(silkstart, silky1, silkstart, silky2, silkwidth)
      samelt += silk(silkend, silky1, silkend, silky2, silkwidth)

    elif (series == "qxss"):
        bankstart = (bankwidth*(banks-1))
        # Power pins
        sep2a =  sep2 + sep1
        lastpin = (bankwidth * (banks-1)) + (pitch * (bankpins-1))
        sep3 = lastpin + sep1
        sep4 = sep3 + sep2
        samelt += pin(-sep1, -5000, paddia, drill, "PL3", \
                      polyclear, maskclear)
        samelt += pin(-sep2a, -5000, paddia, drill, "PL4", \
                      polyclear, maskclear)
        samelt += pin(-sep1, 5000, paddia, drill, "PR3", \
                      polyclear, maskclear)
        samelt += pin(-sep2a, 5000, paddia, drill, "PR4", \
                      polyclear, maskclear)
        samelt += pin(sep3, -5000, paddia, drill, "PL2", \
                      polyclear, maskclear)
        samelt += pin(sep4, -5000, paddia, drill, "PL1", \
                      polyclear, maskclear)
        samelt += pin(sep3, 5000, paddia, drill, "PR2", \
                      polyclear, maskclear)
        samelt += pin(sep4, 5000, paddia, drill, "PR1", \
                      polyclear, maskclear)
        # Center ground blades
        for i in range(banks):
          bankstart = (bankwidth*(banks-i-1))
          bankcenter = bankstart + (pitch*(bankpins-1)/2)
          halfgndwidth = gndwidth / 2
          edgestart = bankcenter - halfgndwidth
          edgeend = bankcenter + halfgndwidth
          samelt += pad(edgestart, 0, edgeend, 0, 2000, polyclear,
                        maskclear, "CGND", shape="square")

        diff = bankwidth - (pitch * (bankpins-1))
        offset2 = (silkoffset - diff) / 2
        silkx1 = offset2 + diff
        silkx2 = (bankwidth * banks) + offset2
        silky = silkboxheight / 2
        samelt += silk(-silkx1, silky, silkx2, silky, silkwidth)
        samelt += silk(-silkx1, -silky, silkx2, -silky, silkwidth)
        samelt += silk(-silkx1, silky, -silkx1, -silky, silkwidth)
        samelt += silk(silkx2, silky, silkx2, -silky, silkwidth)

    return samelt

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
    headernum = findattr(attrlist, "headernum")
    receptm = findattr(attrlist, "receptm")
    receptb = findattr(attrlist, "receptb")
    if pins % 2:
        print "Odd number of pins: that is a problem"
        print "Skipping " + findattr(attrlist, "type")
        return ""
    rowpos = (width+padwidth)/2
    soelt = element(attrlist)
    if (headernum == "yes"):
        soelt = soelt + \
                rowofpads([-rowpos,0], pitch, "down", padwidth, padheight,
                          1, pins, maskclear, polyclear, headernum = True)
        soelt = soelt + \
                rowofpads([rowpos,0], pitch, "down", padwidth, padheight,
                          2, pins, maskclear, polyclear, headernum = True)
    else:
        soelt = soelt + \
                rowofpads([-rowpos,0], pitch, "down", padwidth, padheight,
                          1, pins/2, maskclear, polyclear)
        soelt = soelt + \
                rowofpads([rowpos,0], pitch, "down", padwidth, padheight,
                          1+pins/2, pins/2, maskclear, polyclear)

    if (silkstyle != "inside"):
        silkboxheight = max(pitch*(pins-2)/2+padheight+2*silkoffset,
                            silkboxheight)
    
    silky = silkboxheight/2
    
    # Inside box with notched corner as submitted in patch by PRB
    if(silkstyle == "inside"):
        silkx = width/2 - silkoffset
        if (silkslot == "yes"):
            soelt = soelt + slotbox(silkx,silky,-silkx,-silky,silkwidth)
        else:
            soelt = soelt + insidebox(silkx,silky,-silkx,-silky,silkwidth)
    else:
        silkx = width/2 + silkoffset + padwidth
        if (headernum == "yes"):
            silky = ((pins / 4) * receptm) + receptb
            if (silkslot == "yes"):
                soelt = soelt + box(-silkx,-10000,-silkx-2500,10000,silkwidth)

        
        soelt = soelt + box(silkx,silky,-silkx,-silky,silkwidth)
        soelt = soelt + silk(0,-silky+2000,-2000,-silky,silkwidth)
        soelt = soelt + silk(0,-silky+2000,2000,-silky,silkwidth)
    return soelt

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
    return twopadelt

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
    return tabbedelt
#  Pin[17500 -24000 6400 2000 6400 3500 "" "1" 0x00000001]
# x,y,paddia,polyclear,maskclear,drill,name,name,flags

def pin(x,y,dia,drill,name,polyclear,maskclear,ishole=False):
    if name == "1":
        pinflags = "pin"
    else:
        pinflags = ""
    if (ishole):
        if (pinflags != ""):
            pinflags += ","
        pinflags += "hole"
    return "\tPin[ %d %d %d %d %d %d \"\" \"%s\" \"%s\"]\n" % (x,y,dia,polyclear*2,maskclear+dia,drill,name,pinflags)

def dip(attrlist):
    pins = findattr(attrlist, "pins")
    drill = findattr(attrlist, "drill")
    paddia = findattr(attrlist, "paddia")
    width = findattr(attrlist, "width")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    pitch = findattr(attrlist, "pitch")
    silkslot = findattr(attrlist, "silkslot")
    headernum = findattr(attrlist, "headernum")
    silkboxwidth = findattr(attrlist, "silkboxwidth")
    silkboxheight = findattr(attrlist, "silkboxheight")
    y = -(pins/2-1)*pitch/2
    x = width/2
    dipelt = element(attrlist)
    if (headernum == "yes"):
        for pinnum in range(1,(pins/2)+1):
            num = 2*pinnum - 1
            dipelt = dipelt + pin(-x,y,paddia,drill,str(num),
                                  polyclear,maskclear)
            num = 2*pinnum
            dipelt = dipelt + pin(x,y,paddia,drill,str(num),
                                  polyclear,maskclear)
            y = y + pitch
    else:
        for pinnum in range (1,1+pins/2):
            dipelt = dipelt + pin(-x,y,paddia,drill,str(pinnum),
                                  polyclear,maskclear)
            y = y + pitch
        y = y - pitch
        for pinnum in range (1+pins/2, pins+1):
            dipelt = dipelt + pin(x,y,paddia,drill,str(pinnum),
                                  polyclear,maskclear)
            y = y - pitch

    if (silkboxheight == 0):
        silky = pins*pitch/4
    else:
        silky = silkboxheight / 2

    if (silkboxwidth == 0):
        silkx = (width+pitch)/2
    else:
        silkx = silkboxwidth / 2
        
    dipelt = dipelt + box(silkx,silky,-silkx,-silky,silkwidth)
#    dipelt = dipelt + box(-silkx,-silky,-silkx+pitch,-silky+pitch,silkwidth)
    if (silkslot == "yes"):
        dipelt = dipelt + box(-silkx,-10000,-silkx-2500,10000,silkwidth)
    return dipelt

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
    return dipelt

def sip(attrlist):
    pins = findattr(attrlist, "pins")
    drill = findattr(attrlist, "drill")
    paddia = findattr(attrlist, "paddia")
    polyclear = findattr(attrlist, "polyclear")
    maskclear = findattr(attrlist, "maskclear")
    silkwidth = findattr(attrlist, "silkwidth")
    pinkey = findattr(attrlist, "pinkey")
    silkboxwidth = findattr(attrlist, "silkboxwidth")
    silkboxheight = findattr(attrlist, "silkboxheight")
    pitch = findattr(attrlist, "pitch")
    y = -(pins-1)*pitch/2
    sipelt = element(attrlist)
    for pinnum in range (1,1+pins):
        sipelt = sipelt + pin(0,y,paddia,drill,str(pinnum),polyclear,maskclear)
        if ((pinkey == "yes") and (pinnum == pins - 1)):
            y = y + (pitch*1.5)
        else:
            y = y + pitch

    if (silkboxheight == 0):
        silky = pins*pitch/2
    else:
        silky = silkboxheight / 2

    if (silkboxwidth == 0):
        silkx = pitch/2
    else:
        silkx = silkboxwidth / 2
        
    sipelt = sipelt + box(silkx,silky,-silkx,-silky,silkwidth)
    sipelt = sipelt + box(-silkx,-silky,-silkx+pitch,-silky+pitch,silkwidth)

    return sipelt

def genpart(attributes):
    parttype = findattr(attributes, "type")
    silkcustom = findattr(attributes, "silkcustom")
    newpart = ""
    if parttype=='bga':
        newpart = bga(attributes)
    elif parttype=='qfp':
        newpart = qfp(attributes)
    elif parttype=='so':
        newpart = so(attributes)
    elif parttype=='twopad':
        newpart = twopad(attributes)
    elif parttype=='tabbed':
        newpart = tabbed(attributes)
    elif parttype == 'dip':
        newpart = dip(attributes)
    elif parttype == 'dih':
        newpart = dih(attributes)
    elif parttype == 'sip':
        newpart = sip(attributes)
    elif parttype == 'samtec':
        newpart = samtec(attributes)
    elif parttype == 'edgecard':
        newpart = edgecard(attributes)
    else:
        print "Unknown type "+parttype
    for line in silkcustom:
        newpart += "\t" + str(line) + "\n"
    newpart +=")\n"        
    return newpart                                                                                                          

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
