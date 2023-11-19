#! perl

# Test blob reading.

use strict;
use warnings;
use Test::More tests => 3;
use utf8;

use File::LoadLines;

-d "t" && chdir "t";

# Testing not-touching.
my $data = "\x{EF}\x{BB}\x{BF}first\0\nsecond\r\nthird\0\r\n";
my @lines = loadlines( \$data, { blob => 1 } );
is( scalar(@lines), 1, "single lines" );
is( $lines[0], $data, "data\@ ok" );
my $d = loadlines( \$data, { blob => 1 } );
is( $d, $data, "data\$ ok" );
