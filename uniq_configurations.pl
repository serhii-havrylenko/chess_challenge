#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long;
use Carp;

my $usage = << 'HELP';
Usage:
	./uniq_configurations.pl -n|--vertical N -m|--horizontal M -k|--king NUMBER -q|--queen NUMBER -b|--bishop NUMBER -r|--rook NUMBER -h|--knight NUMBER

		-n|--vertical NUMBER     - vertical dimention of the board
		-m|--horizontal NUMBER   - horizontal dimention of the board
		-k|--king NUMBER         - number of king's pieces on the board
		-q|--queen NUMBER        - number of queen's pieces on the board
		-b|--bishop NUMBER       - number of bishop's pieces on the board
		-r|--rook NUMBER         - number of rook's pieces on the board
		-h|--knight NUMBER       - number of knight's pieces on the board
HELP

my %params = (
	vertical   => undef,
	horizontal => undef,
	king       => undef,
	queen      => undef,
	bishop     => undef,
	rook       => undef,
	knight     => undef,
);

GetOptions(
	"n|vertical=i"   => \$params{vertical},
	"m|horizontal=i" => \$params{horizontal},
	"k|king=i"       => \$params{king},
	"q|queen=i"      => \$params{queen},
	"b|bishop=i"     => \$params{bishop},
	"r|rook=i"       => \$params{rook},
	"h|knight=i"     => \$params{knight},
) or croak($usage);

sub validate_input_parameters {
	my ($args) = @_;
	my ( $valid, $error ) = ( 1, '' );

	unless ( $args->{vertical} ) {
		$valid = 0;
		$error .= "Vertical dimention is not specified\n";
	}

	unless ( $args->{horizontal} ) {
		$valid = 0;
		$error .= "Horizontal dimention is not specified\n";
	}

	unless ( grep { defined $args->{$_} } qw/king queen bishop rook knight/ ) {
		$valid = 0;
		$error .= "At least one figure has to be specified\n";
	}

	$error .= "\n" . $usage if $error;

	return ( $valid, $error );
}

my ( $valid, $error ) = validate_input_parameters( \%params );
croak($error) unless $valid;
