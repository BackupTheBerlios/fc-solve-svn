package Games::Nurikabe::Solver::Base;

use warnings;
use strict;

use base 'Class::Accessor';

=head1 NAME

Games::Nurikabe::Solver::Base - base class for Games::Nurikabe::Solver.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    ));

=head1 SYNOPSIS

    use base 'Games::Nurikabe::Solver::Base';

    EOF

=head1 FUNCTIONS

=head2 $self->new(\%args)

The constructor - one should override _init().

=cut

sub new
{
    my $class = shift;

    my $self = {};
    bless $self, $class;

    $self->_init(@_);

    return $self;
}

=head2 my $offset_coords = $self->add_offset($coords, $offset)

Returns the offset coords based on $coords (an [Y,X] coordinates
in the board) and $offset, which is a [Y,X] offset.

=cut

sub add_offset
{
    my ($self, $coords, $offset) = @_;

    return [$coords->[0] + $offset->[0], $coords->[1] + $offset->[1]];
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-nurikabe-solver at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Nurikabe-Solver>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Nurikabe::Solver::Base


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
