#! perl

# Test soft failure.

use strict;
use warnings;
use Test::More tests => 12*4;
use utf8;

use File::LoadLines;
use MIME::Base64 qw(encode_base64);
use Encode qw(encode);
use URI::Escape;

-d "t" && chdir "t";

my $ref;

sub test {
    my ( $enc, $mime, $charset ) = @_;
    $enc ||= "";

    my $d = "data:";
    $d .= $mime if $mime;
    $mime ||= "";

    $d .= ";charset=$charset" if $charset;
    $charset ||= "";

    my $t = encode( $charset||"US-ASCII", $ref );
    if ( $enc eq "base64" ) {
	$d .= ";$enc" . "," . encode_base64($t);
    }
    else {
	$d .= "," . uri_escape($t);
    }
    my $opt = { fail => "soft" };
    #note($d);
    my @lines = loadlines( $d, $opt );
    ok( !defined $opt->{error}, "no error" );
    is( scalar(@lines), 1, "one line" );
    is( $lines[0], $ref, "content $enc|$charset|$mime" );
    my $x; $x = $mime if $mime;
    $x .= ";charset=$charset" if $charset;
    is( $opt->{mediatype}//"", $x//"", "mediatype" );
}

$ref = "<h1>Hello, World</h1>";
test();
test( "base64" );
test( undef, "text/html" );
test( undef, "text/html", "UTF-8" );

$ref = "Hello, \x{2661}World\x{266b}";
test( undef, undef, "UTF-8" );
test( "base64", undef, "UTF-32BE" );
test( undef, "text/html", "UTF-16LE" );
test( undef, "text/html", "UTF-16BE" );

$ref = "Hello, ♡World♫";
test( undef, undef, "UTF-8" );
test( "base64", undef, "UTF-32BE" );
test( undef, "text/html", "UTF-16LE" );
test( "base64", "text/html", "UTF-16BE" );
