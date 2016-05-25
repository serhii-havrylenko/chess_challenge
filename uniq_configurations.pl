#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Input;
use Board;
use Figure;
use Data::Dumper;

my $args = Input->new->parse_input;

my $board_obj = Board->new($args);
my $board     = $board_obj->init_board($args);
# my $figures   = { map { $_ => $args->{$_} } qw/king queen bishop rook knight/ };

my $figure_obj = Figure->new($board, $args);

$board_obj->place_all_figures( $figure_obj, $board );

$board_obj->write_output;
