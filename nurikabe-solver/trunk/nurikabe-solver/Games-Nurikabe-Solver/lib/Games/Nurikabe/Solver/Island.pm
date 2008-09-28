package Games::Nurikabe::Solver::Island;

use strict;
use warnings;

use base 'Class::Accessor';

=head1 NAME

Games::Nurikabe::Solver::Island - a representation of a Nurikabe island.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    idx
    known_cells
    order
    ));

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Island;

    my $nurikabe = Games::Nurikabe::Island->new(
        {
            idx => $index,
            known_cells => $index,
        }
    );

=cut

sub _sort_coords
{
    my $self = shift;
    my $coords = shift;

    return
    [
        sort { ($a->[0] <=> $b->[0]) || ($a->[1] <=> $b->[1]) }
        @$coords
    ];
}

=head1 FUNCTIONS

=head2 $island = Games::Nurikabe::Solver::Island->new( {idx => $index, known_cells => [[0,0],[0,1]] })

Initialises a new island.

=cut

sub new
{
    my ($class, $args) = @_;

    my $self = $class->SUPER::new($args);

    $self->idx($args->{idx});
    $self->known_cells($self->_sort_coords($args->{known_cells}));

    return $self;
}


=head2 $island->idx()

Returns the index of the island.

=head2 [@coords] = $island->known_cells()

Returns an array of [$y,$x] coordinates of the island's known cells.

=head2 $island->order()

Returns the order (= number of cells) in the island.

=cut


=head2 \@black_cells = $island->surround( { board => $board } )

Surround the island of white cells with blacks cells according to the
geometry of the board $board .

This is useful to find out which black cells should be marked as such after
the island has been fully discovered.

=cut

sub surround
{
    my ($self, $args) = @_;

    my $board = $args->{'board'};

    my %exclude_coords =
        (map { join(",", @$_) => 1, }
            @{$self->known_cells()},
            @{$board->border_exclude_coords()},
        );

    my @ret;
    foreach my $cell (@{$self->known_cells()})
    {
        foreach my $offset ([-1,0],[0,-1],[0,1],[1,0])
        {
            my $to_check = [$cell->[0]+$offset->[0], $cell->[1]+$offset->[1]];
            my $s = join(",",@$to_check);
            if (!exists($exclude_coords{$s}))
            {
                push @ret, $to_check;
                # Make sure we don't repeat ourselves
                $exclude_coords{$s} = 1;
            }
        }
    }

    return $self->_sort_coords(\@ret);
}


=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-nurikabe-solver at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Nurikabe-Solver>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Nurikabe::Solver


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Games-Nurikabe-Solver>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Games-Nurikabe-Solver>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Games-Nurikabe-Solver>

=item * Search CPAN

L<http://search.cpan.org/dist/Games-Nurikabe-Solver>

=item * Version control repository:

L<http://svn.berlios.de/svnroot/repos/fc-solve/nurikabe-solver/trunk/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 Licence. 

=cut

1; # End of Games::Nurikabe::Solver
