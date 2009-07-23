#! /bin/perl

my $group_name  = $ARGV[0];
my $group_count = $ARGV[1];
my $interval    = $ARGV[2];
my $waveform    = $ARGV[3];
my $next_level = 0;
my $waveform_length = length($waveform);
my $i;

for ($i = 0; $i < $group_count; $i++) {
    print "TRANSITION_LIST(\"".$group_name."[".$i."]\")\n{\n";
    print "     NODE\n";
    print "     {\n";
    print "          REPEAT = 1;\n";
    my $current_level = 0;
    my $current_interval = 0;
    for ($j = 0; $j < $waveform_length; $j+=2) {
        my $hex_value = (translate_hex(substr($waveform, $j, 1)) << 4) |
                        (translate_hex(substr($waveform, $j+1, 1)));
        $next_level = (($hex_value >> ($group_count-1-$i)) & 0x1);
        if ($j == 0) {
            $current_level = $next_level;
        }
        if ($next_level ne $current_level) {
            printf("         LEVEL %d FOR %.1f;\n", $current_level, $current_interval);
            $current_level = $next_level;
            $current_interval = $interval;
        }
        elsif  ($j >= $waveform_length -2) {
            printf("         LEVEL %d FOR %.1f;\n", $next_level, $current_interval);
        }
        else {
            $current_interval += $interval;
        }
    }
    print "     }\n";
    print "}\n\n";
}

exit;

sub translate_hex {
SWITCH: {
	if ($_[0] eq '0') { return 0; }
	if ($_[0] eq '1') { return 1; }
	if ($_[0] eq '2') { return 2; }
	if ($_[0] eq '3') { return 3; }
	if ($_[0] eq '4') { return 4; }
	if ($_[0] eq '5') { return 5; }
	if ($_[0] eq '6') { return 6; }
	if ($_[0] eq '7') { return 7; }
	if ($_[0] eq '8') { return 8; }
	if ($_[0] eq '9') { return 9; }
	if ($_[0] eq 'a') { return 10; }
	if ($_[0] eq 'b') { return 11; }
	if ($_[0] eq 'c') { return 12; }
	if ($_[0] eq 'd') { return 13; }
	if ($_[0] eq 'e') { return 14; }
	if ($_[0] eq 'f') { return 15; }
        return -1;
    }     
}
