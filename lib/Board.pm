package Board;

use strict;
use warnings;

use Digest::MD5 qw(md5);
use List::MoreUtils qw(uniq);
use Data::Dumper;
use Clone 'clone';

my @results;
my @debug_results;

sub new {
	my ( $class, $args ) = @_;
	$class = ref $class if ref $class;

	return bless {
		vertical      => $args->{vertical} - 1,
		horizontal    => $args->{horizontal} - 1,
		debug         => $args->{debug},
		max_threads   => 1,
		results       => undef,
		debug_results => undef,
	}, $class;
}

sub init_board {
	my ($self) = @_;

	my @board = map {
		[ map {undef} 0 .. $self->{horizontal} ]
	} 0 .. $self->{vertical};

	return \@board;
}

sub place_all_figures {
	my ( $self, $figure_obj, $board ) = @_;

	$self->place_figures( $figure_obj, $board );

	$self->{results}       = [@results];
	$self->{debug_results} = [@debug_results];

	@results       = ();
	@debug_results = ();

	return 1;
}

sub place_figures {
	my ( $self, $figure_obj, $board, $start_n ) = @_;

	$start_n ||= 0;

	foreach my $n ( $start_n .. $self->{vertical} ) {
		foreach my $m ( 0 .. $self->{horizontal} ) {
			next if $board->[$n]->[$m] || defined $board->[$n]->[$m];

			my ( $run_deeply, $local_figures_obj, $local_board ) = $figure_obj->place_figure( $n, $m );

			if ($run_deeply) {
				if ( $local_figures_obj->{start_from_current} ) {
					$start_n = $n;
				}
				else {
					$start_n = 0;
				}

				if ( $local_figures_obj->exist_figures() ) {
					$self->place_figures( $local_figures_obj, $local_board, $start_n );
				}
			}

			# save board and return
			unless ( $local_figures_obj->exist_figures() ) {
				my $board_str = $self->write_board($local_board);
				push @results, $board_str;
			}

			if ( $run_deeply && $local_figures_obj->exist_figures() ) {
				undef %$local_figures_obj;
				undef @$local_board;
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

	if ( $self->{debug} && !grep { $_ eq $str } @debug_results ) {
		lock @debug_results;
		push @debug_results, $str;
		print $str;
	}

	return md5($str);
}

sub get_debug_results {
	return shift->{debug_results};
}

sub get_results {
	return shift->{results};
}

sub get_number_of_results {
	my @uniq_results = uniq @{ shift->{results} };
	return $#uniq_results + 1;
}

sub write_output {
	my ($self) = @_;

	my @results = uniq @{ $self->{results} };

	print "Number of combinations: " . ( $#results + 1 ) . "\n\n";
}

1;
