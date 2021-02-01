#! perl

# Test non Latin filenames from file.

use strict;
use warnings;
use Test::More tests => 4;
use utf8;
use Encode qw(encode_utf8);
use File::LoadLines;
binmode( STDERR, ':utf8' );

-d "t" && chdir "t";

my $options = {};
my @lines = loadlines( "testW.dat", $options );
is( $options->{encoding}, "UTF-8", "returned encoding" );
is( $lines[0], "testň.dat", "correct data" );

$options = {};
@lines = loadlines( encode_utf8($lines[0]), $options );
is( $options->{encoding}, "ASCII", "returned encoding 2" );
is( $lines[0], "Hi There!", "correct data 2" );
