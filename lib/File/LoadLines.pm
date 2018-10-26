#! perl

package File::LoadLines;

use warnings;
use strict;
use base 'Exporter';
our @EXPORT = qw( loadlines );
use Encode;

=head1 NAME

File::LoadLines - Load lines from file

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use File::LoadLines;

    my @lines = loadlines("mydata.txt");
    ...

=head1 DESCRIPTION

=head1 EXPORT

=head2 loadlines

=cut

sub loadlines {
    my ( $filename, $options ) = @_;

    my $data;			# slurped file data
    my $encoded;		# already encoded

    # Gather data from the input.
    if ( ref($filename) ) {
	if ( ref($filename) eq 'GLOB' ) {
	    binmode( $filename, ':raw' );
	    $data = do { local $/; <$filename> };
	    $filename = "__GLOB__";
	}
	else {
	    $data = $$filename;
	    $filename = "__STRING__";
	    $encoded++;
	}
    }
    elsif ( $filename eq '-' ) {
	$filename = "__STDIN__";
	$data = do { local $/; <STDIN> };
    }
    else {
	my $name = $filename;
	$filename = decode_utf8($name);
	open( my $fh, '<', $name)
	  or croak("$filename: $!\n");
	$data = do { local $/; <$fh> };
    }
    $options->{_filesource} = $filename if $options;

    my $name = encode_utf8($filename);
    if ( $encoded ) {
	# Nothing to do, already dealt with.
    }

    # Detect Byte Order Mark.
    elsif ( $data =~ /^\xEF\xBB\xBF/ ) {
	warn("$name is UTF-8 (BOM)\n") if $options->{debug};
	$data = decode( "UTF-8", substr($data, 3) );
    }
    elsif ( $data =~ /^\xFE\xFF/ ) {
	warn("$name is UTF-16BE (BOM)\n") if $options->{debug};
	$data = decode( "UTF-16BE", substr($data, 2) );
    }
    elsif ( $data =~ /^\xFF\xFE\x00\x00/ ) {
	warn("$name is UTF-32LE (BOM)\n") if $options->{debug};
	$data = decode( "UTF-32LE", substr($data, 4) );
    }
    elsif ( $data =~ /^\xFF\xFE/ ) {
	warn("$name is UTF-16LE (BOM)\n") if $options->{debug};
	$data = decode( "UTF-16LE", substr($data, 2) );
    }
    elsif ( $data =~ /^\x00\x00\xFE\xFF/ ) {
	warn("$name is UTF-32BE (BOM)\n") if $options->{debug};
	$data = decode( "UTF-32BE", substr($data, 4) );
    }

    # No BOM, did user specify an encoding?
    elsif ( $options->{encoding} ) {
	warn("$name is ", $options->{encoding}, " (--encoding)\n")
	  if $options->{debug};
	$data = decode( $options->{encoding}, $data, 1 );
    }

    # Try UTF8, fallback to ISO-8895.1.
    else {
	my $d = eval { decode( "UTF-8", $data, 1 ) };
	if ( $@ ) {
	    warn("$name is ISO-8859.1 (assumed)\n") if $options->{debug};
	    $data = decode( "iso-8859-1", $data );
	}
	else {
	    warn("$name is UTF-8 (detected)\n") if $options->{debug};
	    $data = $d;
	}
    }

    return $data if $options->{donotsplit};

    # Split in lines;
    my @lines;
    $data =~ s/^\s+//s;
    # Unless empty, make sure there is a final newline.
    $data .= "\n" if $data =~ /.(?!\r\n|\n|\r)\Z/;
    # We need to maintain trailing newlines.
    push( @lines, $1 ) while $data =~ /(.*?)(?:\r\n|\n|\r)/g;

    return wantarray ? @lines : \@lines;
}

=head1 AUTHOR

Johan Vromans, C<< <JV at cpan.org> >>

=head1 SUPPORT AND DOCUMENTATION

Development of this module takes place on GitHub:
https://github.com/sciurius/perl-File-LoadLines.

You can find documentation for this module with the perldoc command.

    perldoc File::LoadLines

Please report any bugs or feature requests using the issue tracker on
GitHub.

=head1 COPYRIGHT & LICENSE

Copyright 2018 Johan Vromans, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of File::LoadLines
