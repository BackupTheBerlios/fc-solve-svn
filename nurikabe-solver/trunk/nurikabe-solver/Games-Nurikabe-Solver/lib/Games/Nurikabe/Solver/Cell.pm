package Games::Nurikabe::Solver::Cell;

use warnings;
use strict;

use base 'Games::Nurikabe::Solver::Base';
use base 'Exporter';

=head1 NAME

Games::Nurikabe::Solver::Cell - a representation of a Nurikabe cell.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    status
    island
    island_in_proximity
    _reachable
    _island_reachable
    ));

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Cell;

    my $nurikabe = Games::Nurikabe::Solver->new();

    $nurikabe->load_from_string(<<"EOF")
    .
    .
    .
    EOF

=head1 FUNCTIONS

=cut

our $NK_UNKNOWN = 0;
our $NK_WHITE = 1;
our $NK_BLACK = 2;

our @EXPORT_OK = (qw($NK_BLACK $NK_WHITE $NK_UNKNOWN));

sub _init
{
    my $self = shift;
    my $args = shift;

    $self->status($args->{status});
    $self->island($args->{island});
    $self->_reachable(0);
    $self->_island_reachable([]);

    return 0;
}

=head2 my $bool = $self->belongs_to_island()

Returns true if the cell is white and belongs to an island (i.e: it isn't
marked as white but its island is not yet known).

=cut

sub belongs_to_island
{
    my $self = shift;

    return ( ($self->status() eq $NK_WHITE) && defined($self->island()) );
}

=head2 my $bool = $cell->not_same_island($other_cell);

Sees if the two cells belong to different islands.

=cut

sub not_same_island
{
    my $self = shift;
    my $other = shift;

    return 
    (
           $self->belongs_to_island() 
        && ($self->island() != $other->island())
    );
}

=head2 $self->set_island_reachable($island_idx, $distance, $coords)

Sets the island-related reachable distance from $island_idx. If we already
have a suitable distance (lower or equal) - does nothing and returns false.

Else sets and returns the [$distance, $coords] of the new point.

=cut

sub set_island_reachable
{
    my ($self, $island, $dist, $c) = @_;

    if (defined($self->_island_reachable->[$island]) &&
        ($self->_island_reachable->[$island] <= $dist)
    )
    {
        return;
    }

    $self->_island_reachable->[$island] = $dist;
    $self->_reachable(1);

    return ([$dist, $c]);
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
