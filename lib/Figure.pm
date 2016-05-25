package Figure;

use strict;
use warnings;

sub new {
	my ( $class, $board, $args ) = @_;
	$class = ref $class if ref $class;

	my $self = bless {
		board      => $board,
		king       => $args->{king},
		queen      => $args->{queen},
		rook       => $args->{rook},
		bishop     => $args->{bishop},
		knight     => $args->{knight},
		horizontal => $args->{horizontal}-1,
		vertical   => $args->{vertical}-1,
		placed     => 0,
	}, $class;
	$self;
}

sub set_board {
	my ( $self, $board ) = @_;

	$self->{board} = $board;
}

sub place_figure {
	my ( $self, $n, $m ) = @_;

	my ( $run_deeply, $added );

	foreach my $figure (qw/queen rook bishop knight king/) {
		if ( $self->{$figure} && $self->{$figure} > 0 ) {
			my $method = 'place_' . $figure;
			my $added = $self->$method( $n, $m );

			if ($added) {
				$self->{$figure}--;
				$self->{placed}++;
				$run_deeply = 1;
                last;
			}
		}
	}

	return $run_deeply;
}

sub is_possible_place_queen {
	my ( $self, $n, $m ) = @_;

	my $possible = 1;
	$possible = $self->is_possible_place_rook( $n, $m ) if $possible;
	$possible = $self->is_possible_place_bishop( $n, $m ) if $possible;
	$possible = $self->is_possible_place_king( $n, $m ) if $possible;

	return 1;
}

sub place_queen {
	my ( $self, $n, $m ) = @_;

	my $possible = $self->is_possible_place_queen( $n, $m );
	if ($possible) {
		$self->place_rook( $n, $m );
		$self->place_bishop( $n, $m );
		$self->place_king( $n, $m );

		$self->{board}->[$n]->[$m] = 'Q';

		return 1;
	}

	return 0;
}

sub is_possible_place_knight {
	my ( $self, $n, $m ) = @_;

	return 0 if $n - 2 >= 0 && $m - 1 >= 0 && $self->{board}->[ $n - 2 ]->[ $m - 1 ];
	return 0 if $n - 2 >= 0 && $m + 1 <= $self->{horizontal} && $self->{board}->[ $n - 2 ]->[ $m + 1 ];

	return 0 if $n - 1 >= 0 && $m - 2 >= 0 && $self->{board}->[ $n - 1 ]->[ $m - 2 ];
	return 0 if $n - 1 >= 0 && $m + 2 <= $self->{horizontal} && $self->{board}->[ $n - 1 ]->[ $m + 2 ];

	return 0 if $n + 1 <= $self->{vertical} && $m - 2 >= 0 && $self->{board}->[ $n + 1 ]->[ $m - 2 ];
	return 0 if $n + 1 <= $self->{vertical} && $m + 2 <= $self->{horizontal} && $self->{board}->[ $n + 1 ]->[ $m + 2 ];

	return 0 if $n + 2 <= $self->{vertical} && $m - 1 >= 0 && $self->{board}->[ $n + 2 ]->[ $m - 1 ];
	return 0 if $n + 2 <= $self->{vertical} && $m + 1 <= $self->{horizontal} && $self->{board}->[ $n + 2 ]->[ $m + 1 ];

	return 1;
}

sub place_knight {
	my ( $self, $n, $m ) = @_;

	my $possible = $self->is_possible_place_knight( $n, $m );
	if ($possible) {
		$self->{board}->[ $n - 2 ]->[ $m - 1 ] = '0'
			if $n - 2 >= 0 && $m - 1 >= 0 && !defined $self->{board}->[ $n - 2 ]->[ $m - 1 ];
		$self->{board}->[ $n - 2 ]->[ $m + 1 ] = '0'
			if $n - 2 >= 0 && $m + 1 <= $self->{horizontal} && !defined $self->{board}->[ $n - 2 ]->[ $m + 1 ];

		$self->{board}->[ $n - 1 ]->[ $m - 2 ] = '0'
			if $n - 1 >= 0 && $m - 2 >= 0 && !defined $self->{board}->[ $n - 1 ]->[ $m - 2 ];
		$self->{board}->[ $n - 1 ]->[ $m + 2 ] = '0'
			if $n - 1 >= 0 && $m + 2 <= $self->{horizontal} && !defined $self->{board}->[ $n - 1 ]->[ $m + 2 ];

		$self->{board}->[ $n + 1 ]->[ $m - 2 ] = '0'
			if $n + 1 <= $self->{vertical} && $m - 2 >= 0 && !defined $self->{board}->[ $n + 1 ]->[ $m - 2 ];
		$self->{board}->[ $n + 1 ]->[ $m + 2 ] = '0'
			if $n + 1 <= $self->{vertical}
			&& $m + 2 <= $self->{horizontal}
			&& !defined $self->{board}->[ $n + 1 ]->[ $m + 2 ];

		$self->{board}->[ $n + 2 ]->[ $m - 1 ] = '0'
			if $n + 2 <= $self->{vertical} && $m - 1 >= 0 && !defined $self->{board}->[ $n + 2 ]->[ $m - 1 ];
		$self->{board}->[ $n + 2 ]->[ $m + 1 ] = '0'
			if $n + 2 <= $self->{vertical}
			&& $m + 1 <= $self->{horizontal}
			&& !defined $self->{board}->[ $n + 2 ]->[ $m + 1 ];

		$self->{board}->[$n]->[$m] = 'N';

		return 1;
	}

	return 0;
}

sub is_possible_place_bishop {
	my ( $self, $n, $m ) = @_;

	my $j = 1;
	for ( my $i = $n - 1; $i >= 0; $i-- ) {
		return 0 if $m - $j >= 0 && $self->{board}->[$i]->[ $m - $j ];
		return 0 if $m + $j <= $self->{horizontal} && $self->{board}->[$i]->[ $m + $j ];
		$j++;
	}

	$j = 1;
	foreach my $i ( $n + 1 .. $self->{vertical} ) {
		return 0 if $m - $j >= 0 && $self->{board}->[$i]->[ $m - $j ];
		return 0 if $m + $j <= $self->{horizontal} && $self->{board}->[$i]->[ $m + $j ];
		$j++;
	}

	return 1;
}

sub place_bishop {
	my ( $self, $n, $m ) = @_;

	my $possible = $self->is_possible_place_bishop( $n, $m );
	if ($possible) {
		my $j = 1;
		for ( my $i = $n - 1; $i >= 0; $i-- ) {
			$self->{board}->[$i]->[ $m - $j ] = '0' if $m - $j >= 0 && !defined $self->{board}->[$i]->[ $m - $j ];
			$self->{board}->[$i]->[ $m + $j ] = '0'
				if $m + $j <= $self->{horizontal} && !defined $self->{board}->[$i]->[ $m + $j ];
			$j++;
		}

		$j = 1;
		foreach my $i ( $n + 1 .. $self->{vertical} ) {
			$self->{board}->[$i]->[ $m - $j ] = '0' if $m - $j >= 0 && !defined $self->{board}->[$i]->[ $m - $j ];
			$self->{board}->[$i]->[ $m + $j ] = '0'
				if $m + $j <= $self->{horizontal} && !defined $self->{board}->[$i]->[ $m + $j ];
			$j++;
		}

		$self->{board}->[$n]->[$m] = 'B';

		return 1;
	}

	return 0;
}

sub is_possible_place_rook {
	my ( $self, $n, $m ) = @_;

	foreach my $i ( 0 .. $self->{horizontal} ) {
		return 0 if $self->{board}->[$n]->[$i];
	}

	foreach my $i ( 0 .. $self->{vertical} ) {
		return 0 if $self->{board}->[$i]->[$m];
	}

	return 1;
}

sub place_rook {
	my ( $self, $n, $m ) = @_;

	my $possible = $self->is_possible_place_rook( $n, $m );
	if ($possible) {
		foreach my $i ( 0 .. $self->{horizontal} ) {
			$self->{board}->[$n]->[$i] = '0' unless defined $self->{board}->[$n]->[$i];
		}

		foreach my $i ( 0 .. $self->{vertical} ) {
			$self->{board}->[$i]->[$m] = '0' unless defined $self->{board}->[$i]->[$m];
		}

		$self->{board}->[$n]->[$m] = 'R';

		return 1;
	}

	return 0;
}

sub is_possible_place_king {
	my ( $self, $n, $m ) = @_;

	if ( $n > 0 && $m > 0 && $self->{board}->[ $n - 1 ]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $n > 0 && $self->{board}->[ $n - 1 ]->[$m] ) {
		return 0;
	}
	if ( $n > 0 && $m < $self->{horizontal} && $self->{board}->[ $n - 1 ]->[ $m + 1 ] ) {
		return 0;
	}
	if ( $m > 0 && $self->{board}->[$n]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $m < $self->{horizontal} && $self->{board}->[$n]->[ $m + 1 ] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $m > 0 && $self->{board}->[ $n + 1 ]->[ $m - 1 ] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $self->{board}->[ $n + 1 ]->[$m] ) {
		return 0;
	}
	if ( $n < $self->{vertical} && $m < $self->{horizontal} && $self->{board}->[ $n + 1 ]->[ $m + 1 ] ) {
		return 0;
	}

	return 1;
}

sub place_king {
	my ( $self, $n, $m ) = @_;

	my $possible = $self->is_possible_place_king( $n, $m );
	if ($possible) {
		$self->{board}->[$n]->[$m] = 'K';
		$self->{board}->[ $n - 1 ]->[ $m - 1 ] = '0'
			if $n > 0 && $m > 0 && !defined $self->{board}->[ $n - 1 ]->[ $m - 1 ];
		$self->{board}->[ $n - 1 ]->[$m] = '0' if $n > 0 && !defined $self->{board}->[ $n - 1 ]->[$m];
		$self->{board}->[ $n - 1 ]->[ $m + 1 ] = '0'
			if $n > 0 && $m < $self->{horizontal} && !defined $self->{board}->[ $n - 1 ]->[ $m + 1 ];
		$self->{board}->[$n]->[ $m - 1 ] = '0' if $m > 0 && !defined $self->{board}->[$n]->[ $m - 1 ];
		$self->{board}->[$n]->[ $m + 1 ] = '0' if $m < $self->{horizontal} && !defined $self->{board}->[$n]->[ $m + 1 ];
		$self->{board}->[ $n + 1 ]->[ $m - 1 ] = '0'
			if $n < $self->{vertical} && $m > 0 && !defined $self->{board}->[ $n + 1 ]->[ $m - 1 ];
		$self->{board}->[ $n + 1 ]->[$m] = '0' if $n < $self->{vertical} && !defined $self->{board}->[ $n + 1 ]->[$m];
		$self->{board}->[ $n + 1 ]->[ $m + 1 ] = '0'
			if $n < $self->{vertical} && $m < $self->{horizontal} && !defined $self->{board}->[ $n + 1 ]->[ $m + 1 ];

		return 1;
	}

	return 0;
}

sub exist_figures {
	my ($self) = @_;

	return grep { $self->{$_} && $self->{$_} > 0 } qw/king queen bishop rook knight/;
}

1;
