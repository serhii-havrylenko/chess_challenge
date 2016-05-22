package Input;

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

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

	return bless {}, $class;
}

sub parse_input {
	my ($self) = @_;

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

	my ( $valid, $err_msg ) = $self->validate_parameters( \%params );
	croak($err_msg) unless $valid;

	return \%params;
}

sub validate_parameters {
	my ( $self, $args ) = @_;

	my ( $valid, $err_msg ) = ( 1, '' );

	unless ( $args->{vertical} ) {
		$valid = 0;
		$err_msg .= "Vertical dimention is not specified\n";
	}

	unless ( $args->{horizontal} ) {
		$valid = 0;
		$err_msg .= "Horizontal dimention is not specified\n";
	}

	unless ( grep { defined $args->{$_} } qw/king queen bishop rook knight/ ) {
		$valid = 0;
		$err_msg .= "At least one figure has to be specified\n";
	}

	$err_msg .= "\n" . $usage if $err_msg;

	return ( $valid, $err_msg );
}

1;
