#!/usr/bin/perl -w

use strict;
use Carp;

my $numArgs = $#ARGV + 1;
if ($numArgs < 3) {
    print "usage: ./mirror.pl inputfile [x|y]=axis outputfile\n";
    exit;
}
my $inputPcbFile = shift;
my $axis = shift;
my $outputPcbFile = shift;
my $y1 = 0;
my $y2 = 0;
my $x1 = 0;
my $x2 = 0;
my $x = 0;
my $y = 0;
if ($axis =~ /x=(.*)/) {
    $x = $1;
    print "X axis $x detected\n";
}
elsif ($axis =~ /y=(.*)/) {
    $y = $1;
    print "Y axis $y detected\n";
}
else {
    die "No axis detected\n";
}

open IN, $inputPcbFile or die "Can't open input PCB file $_\n";
open OUT, ">$outputPcbFile" or die "Can't open output PCB file $_\n";
while (<IN>) {
    
    if (/Line\[([\-0-9]+) ([\-0-9]+) ([\-0-9]+) ([\-0-9]+) (.*)\]/) {
        if ($x != 0) {
            $x1 = 2*$x - $1;
            $x2 = 2*$x - $3;
            $y1 = $2;
            $y2 = $4;
        }
        else {
            $y1 = 2*$y - $2;
            $y2 = 2*$y - $4;
            $x1 = $1;
            $x2 = $3;
        }
        print OUT "\tLine[$x1 $y1 $x2 $y2 $5]\n";
    }
    elsif (/Via\[([\-0-9]+) ([\-0-9]+) (.*)\]/) {
        if ($x != 0) {
            $x1 = 2*$x - $1;
            $y1 = $2;
        }
        else {
            $y1 = 2*$y - $2;
            $x1 = $1;
        }
        print OUT "\tVia[$x1 $y1 $3]\n";
    }
    else {
        print OUT $_;
    }
}

