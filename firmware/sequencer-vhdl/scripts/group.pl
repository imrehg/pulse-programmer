#! /bin/perl

my $group_name = $ARGV[0];
my $group_count = $ARGV[1];
my $i;

print "GROUP(\"".$group_name."\")\n{\n";
print "	MEMBERS=";

for ($i=0; $i < $group_count; $i++) {
    print "\"".$group_name."[".$i."]\"";
    if ($i == $group_count-1) {
        print ";\n";
    }
    else {
        print ", ";
    }
}

print "}\n";
