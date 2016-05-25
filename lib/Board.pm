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
		vertical      => $args->{vertical} - 1,
		horizontal    => $args->{horizontal} - 1,
		results       => [],
		debug         => $args->{debug},
		debug_results => [],
	}, $class;
}

sub init_board {
	my ( $self, $args ) = @_;

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
}

sub place_figures {
	my ( $self, $figure_obj, $board ) = @_;

PLACE_FIGURES: foreach my $n ( 0 .. $self->{vertical} ) {
		foreach my $m ( 0 .. $self->{horizontal} ) {
			next if $board->[$n]->[$m] || defined $board->[$n]->[$m];

			my $local_figures_obj = clone($figure_obj);
			my $local_board       = clone($board);
			$local_figures_obj->set_board($local_board);

			my $run_deeply = $local_figures_obj->place_figure( $n, $m );

			if ($run_deeply) {
				if (   $local_figures_obj->{placed} < 2
					&& threads->list(threads::running) < 50
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

    if ($self->{debug} && !grep { $_ eq $str } @{ $self->{debug_results} }) {
        push  @{ $self->{debug_results} }, $str;
        print $str;
    }

	return md5($str);
}

sub write_output {
	my ($self) = @_;

	@results = uniq @results;

	print "Number of combinations: " . ( $#results + 1 ) . "\n\n";
}

1;
