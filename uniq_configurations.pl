#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Input;
use Board;
use Data::Dumper;

my $args = Input->new->parse_input;

warn Dumper $args;

my $board_obj = Board->new($args);
my $board     = $board_obj->init_board($args);
my $figures   = { map { $_ => $args->{$_} } qw/king queen bishop rook knight/ };
$board_obj->place_figures( $figures, $board );

$board_obj->write_output;
# warn Dumper $board;
