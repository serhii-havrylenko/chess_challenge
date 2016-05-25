package Board;

use strict;
use warnings;
use threads;
use threads::shared;

use Digest::MD5 qw(md5);
use List::MoreUtils qw(uniq);
use Data::Dumper;
use Clone 'clone';

my @results : shared;

sub new {
	my ( $class, $args ) = @_;
	$class = ref $class if ref $class;

	return bless {
		vertical   => $args->{vertical} - 1,
		horizontal => $args->{horizontal} - 1,
		results    => [],
	}, $class;
}

sub init_board {
	my ( $self, $args ) = @_;

	my @board = map {
		[ map {undef} 0 .. $self->{horizontal} ]
	} 0 .. $self->{vertical};

	return \@board;
}

sub is_possible_place_queen {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = 1;
	$possible = $self->is_possible_place_rook( $board, $n, $m ) if $possible;
	$possible = $self->is_possible_place_bishop( $board, $n, $m ) if $possible;
	$possible = $self->is_possible_place_king( $board, $n, $m ) if $possible;

	return 1;
}

sub place_queen {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = $self->is_possible_place_queen( $board, $n, $m );
	if ($possible) {
		$self->place_rook( $board, $n, $m );
		$self->place_bishop( $board, $n, $m );
		$self->place_king( $board, $n, $m );

		$board->[$n]->[$m] = 'Q';

		return 1;
	}

	return 0;
}

sub is_possible_place_knight {
	my ( $self, $board, $n, $m ) = @_;

	return 0 if $n - 2 >= 0 && $m - 1 >= 0 && $board->[ $n - 2 ]->[ $m - 1 ];
	return 0 if $n - 2 >= 0 && $m + 1 <= $self->{horizontal} && $board->[ $n - 2 ]->[ $m + 1 ];

	return 0 if $n - 1 >= 0 && $m - 2 >= 0 && $board->[ $n - 1 ]->[ $m - 2 ];
	return 0 if $n - 1 >= 0 && $m + 2 <= $self->{horizontal} && $board->[ $n - 1 ]->[ $m + 2 ];

	return 0 if $n + 1 <= $self->{vertical} && $m - 2 >= 0 && $board->[ $n + 1 ]->[ $m - 2 ];
	return 0 if $n + 1 <= $self->{vertical} && $m + 2 <= $self->{horizontal} && $board->[ $n + 1 ]->[ $m + 2 ];

	return 0 if $n + 2 <= $self->{vertical} && $m - 1 >= 0 && $board->[ $n + 2 ]->[ $m - 1 ];
	return 0 if $n + 2 <= $self->{vertical} && $m + 1 <= $self->{horizontal} && $board->[ $n + 2 ]->[ $m + 1 ];

	return 1;
}

sub place_knight {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = $self->is_possible_place_knight( $board, $n, $m );
	if ($possible) {
		$board->[ $n - 2 ]->[ $m - 1 ] = '0' if $n - 2 >= 0 && $m - 1 >= 0 && !defined $board->[ $n - 2 ]->[ $m - 1 ];
		$board->[ $n - 2 ]->[ $m + 1 ] = '0'
			if $n - 2 >= 0 && $m + 1 <= $self->{horizontal} && !defined $board->[ $n - 2 ]->[ $m + 1 ];

		$board->[ $n - 1 ]->[ $m - 2 ] = '0' if $n - 1 >= 0 && $m - 2 >= 0 && !defined $board->[ $n - 1 ]->[ $m - 2 ];
		$board->[ $n - 1 ]->[ $m + 2 ] = '0'
			if $n - 1 >= 0 && $m + 2 <= $self->{horizontal} && !defined $board->[ $n - 1 ]->[ $m + 2 ];

		$board->[ $n + 1 ]->[ $m - 2 ] = '0'
			if $n + 1 <= $self->{vertical} && $m - 2 >= 0 && !defined $board->[ $n + 1 ]->[ $m - 2 ];
		$board->[ $n + 1 ]->[ $m + 2 ] = '0'
			if $n + 1 <= $self->{vertical} && $m + 2 <= $self->{horizontal} && !defined $board->[ $n + 1 ]->[ $m + 2 ];

		$board->[ $n + 2 ]->[ $m - 1 ] = '0'
			if $n + 2 <= $self->{vertical} && $m - 1 >= 0 && !defined $board->[ $n + 2 ]->[ $m - 1 ];
		$board->[ $n + 2 ]->[ $m + 1 ] = '0'
			if $n + 2 <= $self->{vertical} && $m + 1 <= $self->{horizontal} && !defined $board->[ $n + 2 ]->[ $m + 1 ];

		$board->[$n]->[$m] = 'N';

		return 1;
	}

	return 0;
}

sub is_possible_place_bishop {
	my ( $self, $board, $n, $m ) = @_;

	my $j = 1;
	for ( my $i = $n - 1; $i >= 0; $i-- ) {
		return 0 if $m - $j >= 0 && $board->[$i]->[ $m - $j ];
		return 0 if $m + $j <= $self->{horizontal} && $board->[$i]->[ $m + $j ];
		$j++;
	}

	$j = 1;
	foreach my $i ( $n + 1 .. $self->{vertical} ) {
		return 0 if $m - $j >= 0 && $board->[$i]->[ $m - $j ];
		return 0 if $m + $j <= $self->{horizontal} && $board->[$i]->[ $m + $j ];
		$j++;
	}

	return 1;
}

sub place_bishop {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = $self->is_possible_place_bishop( $board, $n, $m );
	if ($possible) {
		my $j = 1;
		for ( my $i = $n - 1; $i >= 0; $i-- ) {
			$board->[$i]->[ $m - $j ] = '0' if $m - $j >= 0 && !defined $board->[$i]->[ $m - $j ];
			$board->[$i]->[ $m + $j ] = '0' if $m + $j <= $self->{horizontal} && !defined $board->[$i]->[ $m + $j ];
			$j++;
		}

		$j = 1;
		foreach my $i ( $n + 1 .. $self->{vertical} ) {
			$board->[$i]->[ $m - $j ] = '0' if $m - $j >= 0 && !defined $board->[$i]->[ $m - $j ];
			$board->[$i]->[ $m + $j ] = '0' if $m + $j <= $self->{horizontal} && !defined $board->[$i]->[ $m + $j ];
			$j++;
		}

		$board->[$n]->[$m] = 'B';

		return 1;
	}

	return 0;
}

sub is_possible_place_rook {
	my ( $self, $board, $n, $m ) = @_;

	foreach my $i ( 0 .. $self->{horizontal} ) {
		return 0 if $board->[$n]->[$i];
	}

	foreach my $i ( 0 .. $self->{vertical} ) {
		return 0 if $board->[$i]->[$m];
	}

	return 1;
}

sub place_rook {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = $self->is_possible_place_rook( $board, $n, $m );
	if ($possible) {
		foreach my $i ( 0 .. $self->{horizontal} ) {
			$board->[$n]->[$i] = '0' unless defined $board->[$n]->[$i];
		}

		foreach my $i ( 0 .. $self->{vertical} ) {
			$board->[$i]->[$m] = '0' unless defined $board->[$i]->[$m];
		}

		$board->[$n]->[$m] = 'R';

		return 1;
	}

	return 0;
}

sub is_possible_place_king {
	my ( $self, $board, $n, $m ) = @_;

	if ( $n > 0 && $m > 0 && $board->[ $n - 1 ]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $n > 0 && $board->[ $n - 1 ]->[$m] ) {
		return 0;
	}
	if ( $n > 0 && $m < $self->{horizontal} && $board->[ $n - 1 ]->[ $m + 1 ] ) {
		return 0;
	}
	if ( $m > 0 && $board->[$n]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $m < $self->{horizontal} && $board->[$n]->[ $m + 1 ] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $m > 0 && $board->[ $n + 1 ]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $board->[ $n + 1 ]->[$m] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $m < $self->{horizontal} && $board->[ $n + 1 ]->[ $m + 1 ] ) {
		return 0;
	}

	return 1;
}

sub place_king {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = $self->is_possible_place_king( $board, $n, $m );
	if ($possible) {
		$board->[$n]->[$m] = 'K';
		$board->[ $n - 1 ]->[ $m - 1 ] = '0' if $n > 0 && $m > 0 && !defined $board->[ $n - 1 ]->[ $m - 1 ];
		$board->[ $n - 1 ]->[$m] = '0' if $n > 0 && !defined $board->[ $n - 1 ]->[$m];
		$board->[ $n - 1 ]->[ $m + 1 ] = '0'
			if $n > 0 && $m < $self->{horizontal} && !defined $board->[ $n - 1 ]->[ $m + 1 ];
		$board->[$n]->[ $m - 1 ] = '0' if $m > 0 && !defined $board->[$n]->[ $m - 1 ];
		$board->[$n]->[ $m + 1 ] = '0' if $m < $self->{horizontal} && !defined $board->[$n]->[ $m + 1 ];
		$board->[ $n + 1 ]->[ $m - 1 ] = '0'
			if $n < $self->{vertical} && $m > 0 && !defined $board->[ $n + 1 ]->[ $m - 1 ];
		$board->[ $n + 1 ]->[$m] = '0' if $n < $self->{vertical} && !defined $board->[ $n + 1 ]->[$m];
		$board->[ $n + 1 ]->[ $m + 1 ] = '0'
			if $n < $self->{vertical} && $m < $self->{horizontal} && !defined $board->[ $n + 1 ]->[ $m + 1 ];

		return 1;
	}

	return 0;
}

sub exist_figures {
	my ( $self, $figures ) = @_;

	return grep { $figures->{$_} && $figures->{$_} > 0 } qw/king queen bishop rook knight/;
}

sub place_all_figures {
	my ( $self, $figures, $board ) = @_;

	$self->place_figures( $figures, $board );

    threads->create(
		sub {
			sleep(1);
			while (1) {
				do { lock @results; @results = uniq @results; };
				threads->exit(0) if threads->list(threads::running) < 2;

				sleep(10);
			}
		}
	)->join();

WAIT_THREADS: while (1) {
		my $threads = threads->list(threads::running);
		if ( $threads == 0 ) {
			my @threads = threads->list();
			$_->detach() foreach @threads;

			last WAIT_THREADS;
		}
		sleep(1);
	}
}

sub place_figures {
	my ( $self, $figures, $board ) = @_;

PLACE_FIGURES: foreach my $n ( 0 .. $self->{vertical} ) {
		foreach my $m ( 0 .. $self->{horizontal} ) {
			next if $board->[$n]->[$m] || defined $board->[$n]->[$m];

			my $local_figures = clone($figures);
			my $local_board   = clone($board);
			my $run_deeply    = 0;

			if ( $figures->{queen} && $figures->{queen} > 0 ) {
				my $added = $self->place_queen( $local_board, $n, $m );

				if ($added) {
					$local_figures->{queen}--;
					$local_figures->{placed}++;
					$run_deeply = 1;
				}
			}
			elsif ( $figures->{rook} && $figures->{rook} > 0 ) {
				my $added = $self->place_rook( $local_board, $n, $m );

				if ($added) {
					$local_figures->{rook}--;
					$local_figures->{placed}++;
					$run_deeply = 1;
				}
			}
			elsif ( $figures->{bishop} && $figures->{bishop} > 0 ) {
				my $added = $self->place_bishop( $local_board, $n, $m );

				if ($added) {
					$local_figures->{bishop}--;
					$local_figures->{placed}++;
					$run_deeply = 1;
				}
			}
			elsif ( $figures->{knight} && $figures->{knight} > 0 ) {
				my $added = $self->place_knight( $local_board, $n, $m );

				if ($added) {
					$local_figures->{knight}--;
					$local_figures->{placed}++;
					$run_deeply = 1;
				}
			}
			elsif ( $figures->{king} && $figures->{king} > 0 ) {
				my $added = $self->place_king( $local_board, $n, $m );

				if ($added) {
					$local_figures->{king}--;
					$local_figures->{placed}++;
					$run_deeply = 1;
				}
			}

			if ($run_deeply) {
				if ( $local_figures->{placed} < 2 && threads->list() < 50 && $self->exist_figures($local_figures) ) {
					threads->create( sub { $self->place_figures( $local_figures, $local_board ) } );
				}
				elsif ( $self->exist_figures($local_figures) ) {
					$self->place_figures( $local_figures, $local_board );
				}
			}

			# save board and return
			unless ( $self->exist_figures($local_figures) ) {
				my $board_str = $self->write_board($local_board);
				lock @results;

				push @results, $board_str;

				last PLACE_FIGURES;
			}
		}
	}

}

sub write_board {
	my ( $self, $board ) = @_;

	my $str = "__" . join( '__', map {'_'} 0 .. $self->{horizontal} ) . "__\n";
	map {
		$str .= "| " . join( '| ', map { $_ || ' ' } @$_ ) . " |\n";
		$str .= "|_" . join( '__', map {'_'} 0 .. $self->{horizontal} ) . "_|\n"
	} @$board;

	$str .= "\n\n";

	return md5($str);
}

sub write_output {
	my ($self) = @_;

	@results = uniq @results;

	print "Number of combinations: " . ( $#results + 1 ) . "\n\n";
}

1;
