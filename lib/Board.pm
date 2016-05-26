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
my @debug_results : shared;

sub new {
	my ( $class, $args ) = @_;
	$class = ref $class if ref $class;

	return bless {
		vertical      => $args->{vertical} - 1,
		horizontal    => $args->{horizontal} - 1,
		debug         => $args->{debug},
		max_threads   => 50,
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

	threads->create(
		sub {
			# sleep(2);
			while (1) {
				do { lock @results; @results = uniq @results; };
				threads->exit(0) if threads->list(threads::running) < 3;
				sleep(2);
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

	$self->{results}       = [@results];
	$self->{debug_results} = [@debug_results];

	@results       = ();
	@debug_results = ();

	return 1;
}

sub place_figures {
	my ( $self, $figure_obj, $board ) = @_;

	foreach my $n ( 0 .. $self->{vertical} ) {
		foreach my $m ( 0 .. $self->{horizontal} ) {
			next if $board->[$n]->[$m] || defined $board->[$n]->[$m];

			my $local_figures_obj = clone($figure_obj);
			my $local_board       = clone($board);
			$local_figures_obj->set_board($local_board);

			my $run_deeply = $local_figures_obj->place_figure( $n, $m );

			if ($run_deeply) {
				if (   $local_figures_obj->{placed} < 2
					&& threads->list(threads::running) < $self->{max_threads}
					&& $local_figures_obj->exist_figures() )
				{
					threads->create( sub { $self->place_figures( $local_figures_obj, $local_board ) } );
				}
				elsif ( $local_figures_obj->exist_figures() ) {
					$self->place_figures( $local_figures_obj, $local_board );
				}
			}

			# save board and return
			unless ( $local_figures_obj->exist_figures() ) {
				my $board_str = $self->write_board($local_board);
				lock @results;
				push @results, $board_str;
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
