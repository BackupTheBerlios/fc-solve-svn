package Games::Nurikabe::Solver::Coords;

use strict;
use warnings;

use base 'Games::Nurikabe::Solver::Base';

__PACKAGE__->mk_accessors(qw(
    x
    y
    ));

=head1 NAME

Games::Nurikabe::Solver::Coords - an object representing a coordinates pair
in the Nurikabe board.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Coords;

    my $coords = Games::Nurikabe::Solver::Coords->new({x => $x, y => $y);

    print "X = ", $coords->x();
    print "Y = ", $coords->y();

=head1 METHODS

=head2 ->new({y => $y, x => $x})

Creates a new object with $y and $x as coordinates.

=cut

sub _init
{
    my ($self, $args) = @_;

    $self->y($args->{'y'});
    $self->x($args->{'x'});

    return;
}

=head2 x()

Returns the column (or "x") coordinate.

=head2 y()

Returns the row (or "y") coordinate.

=head2 to_s()

Convert the coordinates to a string representation.

=cut

sub to_s
{
    my $self = shift;

    return $self->y() . ',' . $self->x();
}

=head2 [$y, $x] = $coords->to_aref()

Returns an array reference containing the y and x coordinates (in that order).

=cut

sub to_aref
{
    my ($self) = @_;

    return [$self->y(), $self->x()];
}

1;

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-nurikabe-solver at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Nurikabe-Solver>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Nurikabe::Solver::Coords

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

1; # End of Games::Nurikabe::Solver::Coords
