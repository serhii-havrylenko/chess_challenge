#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 14;
use Data::Dumper;
use Figure;

require_ok('Board');

can_ok( 'Board',
	qw/
        init_board
        place_all_figures
        place_figures
        write_board
        write_output
        get_debug_results
        get_results
        get_number_of_results
    /
);

my $board_obj = Board->new(
	{
		vertical   => 3,
		horizontal => 3,
		debug      => 1,
	}
);

is( ref $board_obj,           'Board', 'Package name is Board' );
is( $board_obj->{vertical},   2,       'Board constructor init value for vertical' );
is( $board_obj->{horizontal}, 2,       'Board constructor init value for horizontal' );
is( $board_obj->{debug},      1,       'Board constructor init value for debug' );

my $board = $board_obj->init_board;
is_deeply( $board, [ [ undef, undef, undef ], [ undef, undef, undef ], [ undef, undef, undef ] ], 'Init board 3x3' );
$board_obj->{vertical} = 1;
is_deeply( $board_obj->init_board, [ [ undef, undef, undef ], [ undef, undef, undef ] ], 'Init board 2x3' );
$board_obj->{vertical} = 2;

my $figure_obj = Figure->new(
	$board,
	{
		vertical   => 3,
		horizontal => 3,
		king       => 2,
		queen      => undef,
		bishop     => undef,
		rook       => 1,
		knight     => undef,
		debug      => 1,
	}
);

ok( $board_obj->place_all_figures( $figure_obj, $board ), 'Place all figures' );
is( $board_obj->get_number_of_results, 4, 'Number of uniq combinations for 2 kings and 1 rook' );

$board_obj = Board->new(
	{
		vertical   => 3,
		horizontal => 3,
	}
);
$board = $board_obj->init_board;
$figure_obj = Figure->new(
	$board,
	{
		vertical   => 3,
		horizontal => 3,
		king       => 2,
		queen      => undef,
		bishop     => undef,
		rook       => 2,
		knight     => 1,
		debug      => undef,
	}
);

ok( $board_obj->place_all_figures( $figure_obj, $board ), 'Place all figures' );
is( $board_obj->get_number_of_results, 0, 'Number of uniq combinations for 2 kings, 2 rooks and 1 knight' );

$board_obj = Board->new(
	{
		vertical   => 3,
		horizontal => 3,
	}
);
$board = $board_obj->init_board;
$figure_obj = Figure->new(
	$board,
	{
		vertical   => 3,
		horizontal => 3,
		king       => 1,
		queen      => undef,
		bishop     => undef,
		rook       => undef,
		knight     => undef,
		debug      => undef,
	}
);

ok( $board_obj->place_all_figures( $figure_obj, $board ), 'Place all figures' );
is( $board_obj->get_number_of_results, 9, 'Number of uniq combinations for 1 king' );
