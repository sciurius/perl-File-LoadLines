#! perl

# Test return of lines in array.

use strict;
use warnings;
use Test::More tests => 6 * 9;
use utf8;

use File::LoadLines;

-d "t" && chdir "t";

my @lengths = ( 24, 28, 18, 18 );
my $delta;

sub testlines {
    my ( $file, $options ) = @_;
    $options->{chomp} = 0;
    my @lines = loadlines( $file, $options );
    is( scalar(@lines), 4, "lines $file" );
    my $tally = 0;
    my $line = 0;
    foreach ( @lines ) {
	is( length($_), $delta+$lengths[$line], "line $line" );
	$line++;
	$tally++ if /€urø/;
    }
    is( $tally, 4, "matches" );
}

$delta = 1;
# test1.dat: UTF-8 Unicode text
testlines("test1.dat");
# test3.dat: UTF-8 Unicode (with BOM) text
testlines("test3.dat");
# test5.dat: Little-endian UTF-16 Unicode text
testlines("test5.dat");
# test7.dat: UTF-8 Unicode text, with CR line terminators
testlines("test7.dat");
# test8.dat: UTF-8 Unicode (with BOM) text, with CR line terminators
testlines("test8.dat");
# test9.dat: Little-endian UTF-16 Unicode text, with CR line terminators
testlines("test9.dat");

$delta = 2;
# test2.dat: UTF-8 Unicode text, with CRLF line terminators
testlines("test2.dat");
# test4.dat: UTF-8 Unicode (with BOM) text, with CRLF line terminators
testlines("test4.dat");
# test6.dat: Little-endian UTF-16 Unicode text, with CRLF, CR line terminators
testlines("test6.dat");
