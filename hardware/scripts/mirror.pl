#!/usr/bin/perl -w
# update_element.pl 
#
# David Rowe (david_at_rowtel_dot_com) 7 April 2006
#
# Distributed under the GNU Public License
#
# Updates all instances of an element in a PCB, automatically handling
# rotatation, refdes, and value fields.
#
# PCB uses "elements" (small fragments of a PCB layout) to define the
# footpint of each component used on a layout.  Typically you may use
# one element many times in a PCB layout, giving each instance of the
# element a unique refdes and value. For example you might use
# an element my_0805 for components R1 (1k), R2 (1M), R3 (180).   
#
# This script handles the case where you change your element and
# then wish to update all instances of that element in your PCB file.
#
# All occurances of an element in a PCB file are replaced
# with a new definition of that element.  Useful in the case where you
# have used a footprint X times in a PCB design and want to avoid
# manual replacement of the component X times, with manual rotation,
# refdes, and description entry.  
#
# This script assumes that each instance of the element used in the
# PCB has the same "description" field, and that the same
# "description" field is used in the element file. The "description"
# field is used to identify each instance of the element in the PCB
# file.  
#
# We use the location of a single pin (usually pin 1) to determine the
# rotation of the component relative to the element.  It tests all of
# the possible rotations of pin 1 and chooses the rotation that best
# matches the component on the board.  This works well as long as pin
# 1 hasn't changed much.  If you move pin 1 well away from the orginal
# position in the new element this algorithm will fail and you will
# have to rotate the component manually.  However even in this case
# the location and refdes/value information should be updated OK so it
# will be a good start.
#
# Note that some manual editing (using PCB) will still be required,
# for example if you have moved pins around you will need to re-route
# tracks.  
#
# CREDITS: 
#
# Thanks to Dean Powell for designing the algorithm to determine
# the overlap of two rectangles.

use strict;
use Carp;

my $numArgs = $#ARGV + 1;
if ($numArgs < 3) {
    print "usage: ./mirror.pl inputfile yaxis outputfile\n";
    exit;
}
my $inputPcbFile = shift;
my $yaxis = shift;
my $outputPcbFile = shift;
my $y1 = 0;
my $y2 = 0;

open IN, $inputPcbFile or die "Can't open input PCB file $_\n";
open OUT, ">$outputPcbFile" or die "Can't open output PCB file $_\n";
while (<IN>) {
    
    if (/Line\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) (.*)\]/) {
        $y1 = 2*$yaxis - $2;
        $y2 = 2*$yaxis - $4;
        print OUT "\tLine[$1 $y1 $3 $y2 $5]\n";
    }
    elsif (/Via\[([\-0-9]+) ([\-0-9]+) (.*)\]/) {
        $y1 = 2*$yaxis - $2;
        print OUT "\tVia[$1 $y1 $3]\n";
    }
    else {
        print OUT $_;
    }
}

