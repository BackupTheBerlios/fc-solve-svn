package Games::Nurikabe::Solver::Move;

use warnings;
use strict;

use base 'Games::Nurikabe::Solver::Base';
use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);

=head1 NAME

Games::Nurikabe::Solver::Move - a representation of a Nurikabe deduction move.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    _verdicted_cells
    reason
    _reason_params
    ));

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Move;

    my $nurikabe = Games::Nurikabe::Solver::Move->new();

    $nurikabe->load_from_string(<<"EOF")
    .
    .
    .
    EOF

=head1 FUNCTIONS

=cut

sub _init
{
    my ($self, $args) = @_;

    $self->reason($args->{reason});

    {
        my $verdict_cells = $args->{verdict_cells} || {};

        my %to_put;
        foreach my $color ($NK_BLACK, $NK_WHITE)
        {
            $to_put{$color} =
                $verdict_cells->{$color}
                ? $verdict_cells->{$color}
                : undef
                ;
        }
        $self->_verdicted_cells(\%to_put);
    }

    $self->_reason_params($args->{reason_params});

    return $self;
}

=head2 $self->get_verdict_cells($color)

This retrieves the verdict cells for the color that can be $NK_WHITE or
$NK_BLACK .

=cut

sub get_verdict_cells
{
    my ($self, $color) = @_;

    if (! ( ($color eq $NK_BLACK) || ($color eq $NK_WHITE) ))
    {
        die "Color should be black or white.";
    }
    
    return $self->_verdicted_cells()->{$color};
}

=head2 $self->reason_param($reason_param)

Returns the reason parameter for the string C<$reason_param> .

=cut

sub reason_param
{
    my ($self, $param) = @_;

    return $self->_reason_params()->{$param};
}

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-nurikabe-solver at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Nurikabe-Solver>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Nurikabe::Solver::Move


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
