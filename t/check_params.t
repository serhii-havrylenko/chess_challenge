#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 16;

require_ok('Input');

my $input = Input->new;

is( ref $input, 'Input', 'Package name is Input' );

my ( $valid, $err_msg ) = $input->validate_parameters( { vertical => 1, horizontal => 2, king => 3, } );
ok( $valid, 'Params validated' );
is( $err_msg, '', 'Error message for valid parameters is empty' );

( $valid, $err_msg ) = $input->validate_parameters( { horizontal => 2, knight => 3, } );
ok( !$valid, 'Params validated' );
like( $err_msg, qr/Vertical dimention is not specified/, 'Error message for unspecified vertical dimention' );

( $valid, $err_msg ) = $input->validate_parameters( { vertical => 2, bishop => 3, } );
ok( !$valid, 'Params validated' );
like( $err_msg, qr/Horizontal dimention is not specified/, 'Error message for unspecified horizontal dimention' );

( $valid, $err_msg ) = $input->validate_parameters( { vertical => 1, horizontal => 2, } );
ok( !$valid, 'Params validated' );
like( $err_msg, qr/At least one figure has to be specified/, 'Error message for unspecified figures' );

@ARGV = qw/-n 1 -m 2 -k 3/;
my $args = $input->parse_input;

ok( $args, 'Params parsed' );
is_deeply(
	$args,
	{
		vertical   => 1,
		horizontal => 2,
		king       => 3,
		queen      => undef,
		bishop     => undef,
		rook       => undef,
		knight     => undef,
	},
	'Params parsed deeply'
);

@ARGV = qw/--vertical 2 --horizontal 3 --queen 4/;
$args = $input->parse_input;

ok( $args, 'Params parsed' );
is_deeply(
	$args,
	{
		vertical   => 2,
		horizontal => 3,
		king       => undef,
		queen      => 4,
		bishop     => undef,
		rook       => undef,
		knight     => undef,
	},
	'Params parsed deeply'
);

@ARGV = qw/--vertical 1 --horizontal 2 -k 3 --queen 4 -b 5 --rook 6 --knight 7/;
$args = $input->parse_input;

ok( $args, 'Params parsed' );
is_deeply(
	$args,
	{
		vertical   => 1,
		horizontal => 2,
		king       => 3,
		queen      => 4,
		bishop     => 5,
		rook       => 6,
		knight     => 7,
	},
	'Params parsed deeply'
);
