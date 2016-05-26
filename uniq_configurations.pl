#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Input;
use Board;
use Figure;
use Data::Dumper;

my $args = Input->new->parse_input;

my $board_obj = Board->new($args);
my $board     = $board_obj->init_board();

my $figure_obj = Figure->new($board, $args);

$board_obj->place_all_figures( $figure_obj, $board );
$board_obj->write_output;
