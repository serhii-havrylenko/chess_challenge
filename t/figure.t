#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More tests => 51;
use Data::Dumper;
use Board;
use Clone 'clone';

require_ok('Figure');

can_ok(
	'Figure',
	qw/
		set_board
		place_figure
		is_possible_place_queen
		place_queen
		is_possible_place_knight
		place_knight
		is_possible_place_bishop
		place_bishop
		is_possible_place_rook
		place_rook
		is_possible_place_king
		place_king
		exist_figures
		/
);

my $board_obj = Board->new(
	{
		vertical   => 2,
		horizontal => 2,
	}
);
my $board      = $board_obj->init_board;
my $figure_obj = Figure->new(
	$board,
	{
		vertical   => 3,
		horizontal => 3,
		king       => 1,
		queen      => 2,
		bishop     => 3,
		rook       => 4,
		knight     => 5,
	}
);

is( ref $figure_obj,           'Figure', 'Package name is Figure' );
is( $figure_obj->{vertical},   2,        'Figure constructor init value for vertical' );
is( $figure_obj->{horizontal}, 2,        'Figure constructor init value for horizontal' );
is( $figure_obj->{king},       1,        'Figure constructor init value for king' );
is( $figure_obj->{queen},      2,        'Figure constructor init value for queen' );
is( $figure_obj->{bishop},     3,        'Figure constructor init value for bishop' );
is( $figure_obj->{rook},       4,        'Figure constructor init value for rook' );
is( $figure_obj->{knight},     5,        'Figure constructor init value for knight' );

is_deeply( $figure_obj->{board}, [ [ undef, undef ], [ undef, undef ] ], 'Figure object init board' );

$board_obj->{horizontal} = 2;
$board_obj->{vertical}   = 2;
$board                   = $board_obj->init_board;

$figure_obj->set_board($board);
is_deeply(
	$figure_obj->{board},
	[ [ undef, undef, undef ], [ undef, undef, undef ], [ undef, undef, undef ] ],
	'Set new board'
);

ok( $figure_obj->exist_figures, 'Figures exist' );
$figure_obj->{king}   = undef;
$figure_obj->{queen}  = undef;
$figure_obj->{bishop} = undef;
$figure_obj->{rook}   = undef;
$figure_obj->{knight} = undef;
ok( !$figure_obj->exist_figures, 'Figures exist return false for empty list' );

ok( $figure_obj->is_possible_place_king( 0, 0 ), 'Possible to place king on empty board' );
ok( $figure_obj->place_king( 0, 0 ), 'Place king on empty board' );
ok( !$figure_obj->is_possible_place_king( 1, 1 ), 'Impossible to place king on position near another king' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', undef ], [ '0', '0', undef ], [ undef, undef, undef ] ],
	'Board after placing king on 1x1'
);
ok( $figure_obj->place_king( 0, 2 ), 'Place king on 1x3' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ undef, undef, undef ] ],
	'Board after placing king on 1x1'
);

my $board_with_kings = clone( $figure_obj->{board} );

ok( !$figure_obj->is_possible_place_bishop( 1, 1 ), 'Impossible to place bishop on position near king' );
ok( $figure_obj->is_possible_place_bishop( 2, 1 ), 'Possible to place bishop on empty board' );
ok( $figure_obj->place_bishop( 2, 1 ), 'Place bishop on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ undef, 'B', undef ] ],
	'Board after placing bishop on 3x2'
);

$figure_obj->{board} = clone($board_with_kings);
ok( !$figure_obj->is_possible_place_rook( 1, 1 ), 'Impossible to place rook on position near king' );
ok( $figure_obj->is_possible_place_rook( 2, 1 ), 'Possible to place rook on empty board' );
ok( $figure_obj->place_rook( 2, 1 ), 'Place rook on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ '0', 'R', '0' ] ],
	'Board after placing rook on 3x2'
);

$figure_obj->{board} = clone($board_with_kings);
ok( !$figure_obj->is_possible_place_queen( 1, 1 ), 'Impossible to place queen on position near king' );
ok( $figure_obj->is_possible_place_queen( 2, 1 ), 'Possible to place queen on empty board' );
ok( $figure_obj->place_queen( 2, 1 ), 'Place queen on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ '0', 'Q', '0' ] ],
	'Board after placing queen on 3x2'
);

$figure_obj->{board} = clone($board_with_kings);
ok( !$figure_obj->is_possible_place_knight( 2, 1 ), 'Impossible to place knight on position near king' );
ok( $figure_obj->is_possible_place_knight( 2, 0 ), 'Possible to place knight on empty board' );
ok( $figure_obj->place_knight( 2, 0 ), 'Place knight on 3x1' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ 'N', undef, undef ] ],
	'Board after placing knight on 3x1'
);

$figure_obj->{board}  = clone($board_with_kings);
$figure_obj->{queen}  = 1;
$figure_obj->{bishop} = 1;
$figure_obj->{rook}   = 1;
$figure_obj->{knight} = 1;
ok( $figure_obj->place_figure( 2, 0 ), 'Place figure on 3x1' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ 'N', undef, undef ] ],
	'Board after placing figure on 3x1'
);
is( $figure_obj->{knight}, 0, 'Decrease number of knights after placing on board' );

ok( $figure_obj->place_figure( 2, 1 ), 'Place figure on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ 'N', 'B', undef ] ],
	'Board after placing figure on 3x2'
);
is( $figure_obj->{bishop}, 0, 'Decrease number of bishops after placing on board' );

$figure_obj->{board} = clone($board_with_kings);
ok( $figure_obj->place_figure( 2, 1 ), 'Place figure on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ '0', 'Q', '0' ] ],
	'Board after placing figure on 3x2'
);
is( $figure_obj->{queen}, 0, 'Decrease number of queens after placing on board' );

$figure_obj->{board} = clone($board_with_kings);
ok( $figure_obj->place_figure( 2, 1 ), 'Place figure on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ '0', 'R', '0' ] ],
	'Board after placing figure on 3x2'
);
is( $figure_obj->{rook}, 0, 'Decrease number of rooks after placing on board' );

$figure_obj->{board} = clone($board_with_kings);
ok( !$figure_obj->exist_figures, 'Figures exist return false for empty list' );
is( $figure_obj->place_figure( 2, 1 ), undef, 'Place figure on 3x2' );
is_deeply(
	$figure_obj->{board},
	[ [ 'K', '0', 'K' ], [ '0', '0', '0' ], [ undef, undef, undef ] ],
	'Board after calling place figure with empty list of figures'
);
