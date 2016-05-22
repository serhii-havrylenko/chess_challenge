#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';

use Input;
use Data::Dumper;

my $args = Input->new->parse_input;


warn Dumper $args;
