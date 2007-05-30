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

sub rotatePoint($$$);
sub rotatePad($$);
sub determineOverlap($$);
sub determineRotationWithMaxOverlap($$);
sub testDetermineOneDOverlap();
sub testDetermineOverlap();
sub testDetermineRotationWithMaxOverlap();

my $numArgs = $#ARGV + 1;
if ($numArgs < 3) {
    print "usage: ./update_element.pl inputPCBFile elementFile outputPCBFile\n";
    exit;
}
my $inputPcbFile = shift;
my $elementFile = shift;
my $outputPcbFile = shift;
my $pnum = 1;            # modify this line to pin 2 if pin 1 is unsuitable
if ($numArgs == 4) {
    $pnum = shift;
}

open IN, $inputPcbFile or die "Can't open input PCB file $_\n";
open ELEMENT, $elementFile or die "Can't open element file $_\n";
open OUT, ">$outputPcbFile" or die "Can't open output PCB file $_\n";

# run built-in unit tests every time we start (they don't take long)

testDetermineOneDOverlap();
testDetermineOverlap();
testDetermineRotationWithMaxOverlap();

# load element details into an array

my @element = ();
my $description;
my $pnumFound = 0;
my @rotatedNewPad = ();
my $pad;

# Find a pad/pin that isn't centred on (0,0) as this upsets rotation detection.
# Rotating a square or cicrular pin that is centred on (0,0) gives the same
# pad location for every angle.

my $badRotPin;

do {
    $badRotPin = 0;
    while (<ELEMENT>) {
	if (/Pad\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) [\-0-9]+ [\-0-9]+ ".*?" "$pnum"/) {
	    # Pad detected with pin number that matchs $pnum
	    if (($1 == 0) && ($2 == 0)) {
		$badRotPin = 1;
	    }
	}
	if (/Pin\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) [\-0-9]+ [\-0-9]+ [\-0-9]+ ".*?" "$pnum"/) {
	    # Pin detected with pin number that matchs $pnum
	    if (($1 == 0) && ($2 == 0)) {
		$badRotPin = 1;
	    }
	}
    }

    seek(ELEMENT, 0, 0); 
    if ($badRotPin) {
	print "Mmmm, pin/pad $pnum not a good choice for rotation detection....\n";
	$pnum++;
    }
} while ($badRotPin);
print "OK, pin/pad $pnum chosen for rotation detection\n";

# load in the element file and generate rotated versions of $pnum

while (<ELEMENT>) {

    # extract description field for matching with PCB file

    if (/Element\[".*?" "(.*?)"/) {
	$description = $1;
    }
    elsif (/Pin/ || /ElementLine/ || /Pad/ || /ElementArc/) {
	push @element, $_; 
	if (/Pad\[\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*[\-0-9]+\s*[\-0-9]+\s*".*?" "$pnum"/) {
	    if (!$pnumFound) {
		# found pad $pnum - we use this to determine rotation
		$pad = {x1=>$1, y1=>$2, x2=>$3, y2=>$4, thickness=>$5};
		for(my $rot=0; $rot<4; $rot++) {
		    $rotatedNewPad[$rot] = rotatePad($pad, $rot);
		}
		$pnumFound = 1;
	    }
	}
	if (/Pin\[\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*[\-0-9]+\s*[\-0-9]+\s*[\-0-9]+\s*".*?"\s*"$pnum"/) {
	    if (!$pnumFound) {
		# found pin $pnum - we use this to determine rotation
		# note we model pin as a square pad
		my $r = $3/2;
		$pad = {x1=>$1-$r, y1=>$2, x2=>$1+$r, y2=>$2, thickness=>$3};
		#print "x1: $pad->{x1} y1: $pad->{y1} x2: $pad->{x2} y2: $pad->{y2} thickness: $pad->{thickness}\n";
		for(my $rot=0; $rot<4; $rot++) {
		    $rotatedNewPad[$rot] = rotatePad($pad, $rot);
		}
		$pnumFound = 1;
	    }
	}
    }
    elsif (/\w/) {
	print "I don't understand this line:\n\t$_";
	print "of the element file: $elementFile\n";   
	print "This probably means I need to be improved!\n";
	exit;
    }
}

if (!defined ($description) || (length($description) == 0)) {
    print "No valid description field in element file: $elementFile!\n";
    print "Should be defined:\n\tElement[\"\" \"here\" ......]\n";
    exit;
}

die "Pin/Pad $pnum not found in $elementFile, cant determine rotation....\n" unless $pnumFound;

print "OK, looking for instances of elements that match: \"$description\" .....\n\n";

# copy input PCB file straight to output until we get a
# component that matches the element description

my $state = "normal";
my ($nextState, $onsolder, $rotation, $line, $x, $y, $x1, $y1, $x2, $y2);
my $rotationFound;

while (<IN>) {
    
    $nextState = $state;

    if ($state eq "normal") {

	if (/Element\[(".*?") "$description" (".*?") ".*?" ([\-0-9]+) ([\-0-9]+)/) {
	    # output original element header, this contains coords, refdes,
	    # value, rotation
    
    	    print OUT $_;

	    print "found $1 \"$description\" at ($2, $3):\n";
            if ($1 =~ /"onsolder"/) {
                $onsolder = 1;
                print " onsolder ";
            }
            else {
                $onsolder = 0;
            }
            print "\n";
	    $rotation = 0;
	    $rotationFound = 0;
	    $nextState = "gotoEndofElement";
	}

	else {
	    print OUT $_;
	}
    }

    if ($state eq "gotoEndofElement") {
	# Read thru component in PCB file, looking for line
	# that contains pad labelled as pin 1

	if (/Pad\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) [\-0-9]+ [\-0-9]+ ".*?" "$pnum"/) {
	    if (!$rotationFound) {
		# now use this pad to determine the rotatation
		$pad = {x1=>$1, y1=>$2, x2=>$3, y2=>$4, thickness=>$5};
		$rotation = determineRotationWithMaxOverlap($pad, \@rotatedNewPad);
		print "\tfound Pad $pnum, rotation: $rotation\n";
		$rotationFound = 1;
	    }
	}

	if (/Pin\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) [\-0-9]+ [\-0-9]+ [\-0-9]+ ".*?" "$pnum"/) {
	    if (!$rotationFound) {
		# model Pin as a square Pad
		my $r = $3/2;
		$pad = {x1=>$1-$r, y1=>$2, x2=>$1+$r, y2=>$2, thickness=>$3};
		$rotation = determineRotationWithMaxOverlap($pad, \@rotatedNewPad);
		print "\tfound Pin $pnum, rotation: $rotation\n";
		$rotationFound = 1;
	    }
	}

	if (/\s\)/) {
	    if (!$rotationFound) {
		print "\tWarning - pad/pin $pnum NOT FOUND, can't determine rotation\n";
		print "\tAre you sure you have a labelled pin 1 in this component on the PCB?\n";
	    }
	    
	    # wait until end of component in PCB file, then output new element

	    # output each line of new element, translating according to rotation

	    print OUT "(\n";
	    foreach $line (@element) {
		if ($line =~ /Pin\[\s*([\-0-9]+)\s*([\-0-9]+)\s*(.*)\]/) {
		    ($x, $y) = rotatePoint($1, $2, $rotation);
		    #print "$1 $2\n"
		    print OUT "\tPin[$x $y $3]\n";
		}
		elsif ($line =~ /ElementLine\s*\[([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+) ([\-0-9]+) (.*)\]/) {
		    ($x1, $y1) = rotatePoint($1, $2, $rotation);
		    ($x2, $y2) = rotatePoint($3, $4, $rotation);
		    print OUT "\tElementLine[$x1 $y1 $x2 $y2 $5]\n";
		}
		elsif ($line =~ /ElementArc\s*\[([\-0-9]+)\s*([\-0-9]+)\s*(.*)\]/) {
		    ($x, $y) = rotatePoint($1, $2, $rotation);
		    print OUT "\tElementArc[$x $y $3]\n";
		}
		elsif ($line =~ /Pad\[\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+)\s*([\-0-9]+\s*[\-0-9]+\s*[\-0-9]+ \".*\" \".*\") \"([\w\,]*)\"\]/) {
		    ($x1, $y1) = rotatePoint($1, $2, $rotation);
		    ($x2, $y2) = rotatePoint($3, $4, $rotation);

                    my $flags = $6;
                    if ($onsolder == 1) {
                        $flags = "$6,onsolder";
                    }

		    print OUT "\tPad[$x1 $y1 $x2 $y2 $5 \"$flags\"]\n";
		}
	    }
	    print OUT "\n\t)\n";
    
	    $nextState = "normal";
	}
    }

    $state = $nextState;
}

printf "\nfinished!\n";

close IN;
close ELEMENT;
close OUT;

sub rotatePoint($$$) {
    # returns a new (x,y) point rotated about the origin

    my ($x, $y, $rotation) = @_;
    my ($outx, $outy);

    if ($rotation == 0) {
	$outx = $x; $outy = $y;
    }
    elsif ($rotation == 1) {
	$outx = -$y; $outy = $x;
    }
    elsif ($rotation == 2) {
	$outx = -$x; $outy = -$y;
    }
    elsif ($rotation == 3) {
	$outx = $y; $outy = -$x;
    }

    # remove any leading '+', as PCB doesn't like it
    # Perl seems to introduce these when it multiplies a -ve
    # number by another -ve number, I am not sure why....

    $outx =~ s/\+//;
    $outy =~ s/\+//;

    return $outx, $outy;
}

sub rotatePad($$) {
    my ($padin, $rotation) = @_;
    my ($x1, $y1, $x2, $y2);
 
    ($x1, $y1) = rotatePoint($padin->{x1}, $padin->{y1}, $rotation);
    ($x2, $y2) = rotatePoint($padin->{x2}, $padin->{y2}, $rotation);

    my $padout = {x1=>$x1, y1=>$y1, x2=>$x2, y2=>$y2, thickness=>$padin->{thickness}};
   
    return $padout;
}

sub determineOneDOverlap($$$$) {
    # return overlap of two pads in one dimension

    my ($x1, $x2, $x3, $x4) = @_;
    my (@sorted, $overlap);

    @sorted = sort { $a <=> $b } ($x1, $x2, $x3, $x4);

    if (($sorted[1] == $x2) && ($sorted[2] == $x3)) {
	$overlap = 0;
    }
    elsif (($sorted[1] == $x4) && ($sorted[2] == $x1)) {
	$overlap = 0;
    }
    else {
	$overlap = $sorted[2] - $sorted[1];
    }

    return $overlap;
}

sub convertPadToBoxCoords($) {
    # converts from the PCB Pad coordinate system
    # (a straight line with a thickness)
    # to two points that define the upper-LH and
    # lower RH corners of a box

    my ($pad) = @_;

    # first sort to get coords in ascending order

    my ($ytop, $ybot) =  sort { $a <=> $b } ($pad->{y1}, $pad->{y2});
    my ($xleft, $xright) = sort { $a <=> $b } ($pad->{x1}, $pad->{x2});

    # determine upper LH and lower RH coords of pad

    if ($xleft == $xright) {
	# vertical line
	$xleft  -= $pad->{thickness}/2;
	$xright += $pad->{thickness}/2;
    }
    if ($ytop == $ybot) {
	# horizontal line
	$ytop  -= $pad->{thickness}/2;
	$ybot += $pad->{thickness}/2;
    }

    return $xleft, $ytop, $xright, $ybot;
}

sub determineOverlap($$) {
    # returns % overlap of two pads, 100% is the area
    # of the first pad.

    my ($pad1, $pad2) = @_;
    my ($x1, $y1, $x2, $y2) = convertPadToBoxCoords($pad1);
    my ($x3, $y3, $x4, $y4) = convertPadToBoxCoords($pad2);
    
    my $deltaX = determineOneDOverlap($x1, $x2, $x3, $x4);
    my $deltaY = determineOneDOverlap($y1, $y2, $y3, $y4);

    return 100*$deltaX*$deltaY/(($x2-$x1)*($y2-$y1));
}

sub testDetermineOneDOverlap() {
    my $overlap;

    # case 1 - first pad to right of second with no overlap

    $overlap = determineOneDOverlap(4,6,0,2);
    die "case failed" unless ($overlap == 0);

    # case 2 - first pad to right of second with overlap

    $overlap = determineOneDOverlap(4,6,3,5);
    die "case failed" unless ($overlap == 1);

    # case 3 - Second overlaps first on both sides

    $overlap = determineOneDOverlap(0,4,-2,6);
    die "case failed" unless ($overlap == 4);

    # case 4 - first pad to left of second with overlap

    $overlap = determineOneDOverlap(0,4,4,6);
    die "case failed" unless ($overlap == 0);
}

sub testDetermineOverlap() {
    my $pad1;
    my $pad2;

    #  boxes derived from horizontal line
    $pad1 = {x1=>-5, y1=>0, x2=>5, y2=>0, thickness=>2};
    $pad2 = {x1=>0, y1=>0, x2=>5, y2=>0, thickness=>2};
    die "failed" unless (determineOverlap($pad1, $pad1) == 100);
    die "failed" unless (determineOverlap($pad1, $pad2) == 50);

    # boxes derived from vertical line
    $pad1 = {x1=>-2, y1=>0, x2=>2, y2=>0, thickness=>2};
    $pad2 = {x1=>1, y1=>0, x2=>1, y2=>2, thickness=>2};
    die "failed" unless (determineOverlap($pad1, $pad2) == 25);

    # boxes that don't overlap
    $pad1 = {x1=>-1, y1=>0, x2=>-1, y2=>-2, thickness=>2};
    $pad2 = {x1=>1, y1=>0, x2=>1, y2=>2, thickness=>2};
    die "failed" unless (determineOverlap($pad1, $pad2) == 0);

    # data from real PCB file
    $pad1 = {x1=>-3500, y1=>3500, x2=>-3500, y2=>5500, thickness=>3900};
    die "failed" unless (determineOverlap($pad1, $pad1) == 100);
}

sub determineRotationWithMaxOverlap($$) {
    my ($currentPad, $rotatedNewPad) = @_;
    my ($ol, $best);
    my $rot;

    $best = determineOverlap($currentPad, $rotatedNewPad->[0]);
    $rotation = 0;
    #print "\trot: 0 $best\n";

    for($rot=1; $rot<4; $rot++) {
	$ol = determineOverlap($currentPad, $rotatedNewPad->[$rot]);
	#print "\trot: $rot $ol\n";
	if ($ol > $best) {
	    $best = $ol;
	    $rotation = $rot;
	}
    }

    return $rotation;
}

sub testDetermineRotationWithMaxOverlap() {
    my $pad = {x1=>-3500, y1=>3500, x2=>-3500, y2=>5500, thickness=>3900};

    my $rot = 0;
    my @rotatedNewPad = ();
    my $rotation;

    # build table of new pad at various rotations

    for($rot=0; $rot<4; $rot++) {
	$rotatedNewPad[$rot] = rotatePad($pad, $rot);
    }

    # now use table as input test data

    for($rot=0; $rot<4; $rot++) {
	$rotation = determineRotationWithMaxOverlap($rotatedNewPad[$rot], 
						    \@rotatedNewPad);
	die "failed" unless ($rot == $rotation);
    }
}

