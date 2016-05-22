package Board;

use strict;
use warnings;

use Data::Dumper;
use Data::Compare;
use Clone 'clone';

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

sub is_possible_place_rook {
	my ( $self, $board, $n, $m ) = @_;

	my $possible = 1;
	foreach my $i ( 0 .. $self->{horizontal} ) {
		$possible = 0 if $board->[$n]->[$i];
	}

	foreach my $i ( 0 .. $self->{vertical} ) {
		$possible = 0 if $board->[$i]->[$m];
	}

	return $possible;
}

sub place_rook {
	my ( $self, $board, $n, $m ) = @_;

	# my $possible = $self->is_possible_place_rook( $board, $n, $m );
	unless ( defined $board->[$n]->[$m] ) {
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

	my $possible = 1;

	if ( $n > 0 && $m > 0 && $board->[ $n - 1 ]->[ $m - 1 ] ) {
		$possible = 0;
	}
	if ( $n > 0 && $board->[ $n - 1 ]->[$m] ) {
		$possible = 0;
	}
	if ( $n > 0 && $m < $self->{horizontal} && $board->[ $n - 1 ]->[ $m + 1 ] ) {
		$possible = 0;
	}
	if ( $m > 0 && $board->[$n]->[ $m - 1 ] ) {
		$possible = 0;
	}
	if ( $m < $self->{horizontal} && $board->[$n]->[ $m + 1 ] ) {
		$possible = 0;
	}
	if ( $n < $self->{vertical} && $m > 0 && $board->[ $n + 1 ]->[ $m - 1 ] ) {
		$possible = 0;
	}
	if ( $n < $self->{vertical} && $board->[ $n + 1 ]->[$m] ) {
		$possible = 0;
	}
	if ( $n < $self->{vertical} && $m < $self->{horizontal} && $board->[ $n + 1 ]->[ $m + 1 ] ) {
		$possible = 0;
	}

	return $possible;
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

sub place_figures {
	my ( $self, $figures, $board ) = @_;

	foreach my $n ( 0 .. $self->{vertical} ) {
		foreach my $m ( 0 .. $self->{horizontal} ) {
			next if $board->[$n]->[$m] || defined $board->[$n]->[$m];

			my $local_figures = clone($figures);
			my $local_board   = clone($board);

			if ( $figures->{rook} && $figures->{rook} > 0 ) {
				my $added = $self->place_rook( $local_board, $n, $m );

				if ($added) {
					$local_figures->{rook}--;
					$self->place_figures( $local_figures, $local_board )
						if ( $self->exist_figures($local_figures) );
				}
			}
			elsif ( $figures->{king} && $figures->{king} > 0 ) {
				my $added = $self->place_king( $local_board, $n, $m );

				if ($added) {
					$local_figures->{king}--;
					$self->place_figures( $local_figures, $local_board )
						if ( $self->exist_figures($local_figures) );
				}
			}

			# save board and return
			unless ( $self->exist_figures($local_figures) ) {
				push @{ $self->{results} }, $local_board
					unless grep { Compare( $_, $local_board ) } @{ $self->{results} };
			}
		}
	}
}

sub write_output {
	my ($self) = @_;

	foreach my $board ( @{ $self->{results} } ) {
		print "|-" . join( '|-', map {'-'} 0 .. $self->{horizontal} ) . "-|\n";
		map {
			print "| " . join( '| ', map { $_ || ' ' } @$_ ) . " |\n";
			print "|_" . join( '__', map {'-'} 0 .. $self->{horizontal} ) . "_|\n"
		} @$board;

		print "\n\n";
	}

}

1;
