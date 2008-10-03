package Games::Nurikabe::Solver::Board;

use warnings;
use strict;

use List::MoreUtils qw(all);

use base 'Class::Accessor';

use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Island;
use Games::Nurikabe::Solver::Move;

=head1 NAME

Games::Nurikabe::Solver::Board - a representation of the board.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

__PACKAGE__->mk_accessors(qw(
    _cells
    _islands
    _width
    _height
    ));

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Board;

    my $nurikabe = Games::Nurikabe::Solver->new();

    $nurikabe->load_from_string(<<"EOF")
    .
    .
    .
    EOF

=head1 FUNCTIONS

=head2 $class->load_from_string($string)

Loads from the string. A string is something like 

    Width=5 Height=5
    [] [] [] [1] []
    [] [1] [] [] []
    [] [] [] [] []
    [] [] [] [2] []
    [] [6] [] [] []

=cut

sub load_from_string
{
    my $class = shift;
    my $string = shift;
    
    if ($string !~ m{\AWidth=(\d+)\s*Height=(\d+)\n}gms)
    {
        die "Cannot read string";
    }
    my ($width, $height) = ($1, $2);

    my $self = $class->new();

    $self->_width($width);
    $self->_height($height);

    my @cells;
    my @islands;

    for my $y (0 .. ($height-1))
    {
        push @cells, [];
        for my $x (0 .. ($width-1))
        {
            if ($string !~ m{\G\s*\[\s*(\d+|)\s*\]}cgms)
            {
                die "Incorrect cell contents at position" . pos($string);
            }
            my $cell_contents = $1;
            my $cell_obj;
            if ($cell_contents eq "")
            {
                $cell_obj =
                    Games::Nurikabe::Solver::Cell->new(
                        {
                            status => $NK_UNKNOWN,
                        },
                    );
            }
            else
            {
                my $num_cells = $cell_contents;
                my $index = scalar(@islands);

                push @islands, 
                    Games::Nurikabe::Solver::Island->new(
                        {
                            idx => $index,
                            known_cells => [[$y,$x]],
                            order => $num_cells,
                        },
                    );
                
                $cell_obj =
                    Games::Nurikabe::Solver::Cell->new(
                        {
                            status => $NK_WHITE,
                            island => $index,
                        }
                    );
            }
            push @{$cells[$y]}, $cell_obj;
        }
    }

    $self->_cells(\@cells);
    $self->_islands(\@islands);

    return $self;
}

=head2 $self->get_cell($y,$x)

Returns the cell in position ($y, $x). It is a
L<Games::Nurikabe::Solver::Cell> object.

=cut

sub get_cell
{
    my ($self, $y, $x) = @_;

    return $self->_cells()->[$y]->[$x];
}

=head2 $self->get_island($idx)

Returns the Island handle for the index of $idx.

=cut

sub get_island
{
    my ($self, $idx) = @_;

    return $self->_islands()->[$idx];
}

=head2 \@coords = $self->border_exclude_coords()

Returns the coordinates of the cells directly outside the board's borders so
they can be excluded. 

=cut

sub border_exclude_coords
{
    my $self = shift;

    return
    [
        (map { [-1,$_],[$self->_height(),$_] } (0 .. $self->_width() - 1)),
        (map { [$_,-1],[$_,$self->_width()] } (0 .. $self->_height() - 1)),
    ];
}

sub _solve_using_surround_island
{
    my $self = shift;

    my @moves;

    foreach my $island (@{$self->_islands()})
    {
        if ($island->order() == @{$island->known_cells()})
        {
            my $black_cells = $island->surround({ board => $self });

            my @marked_cells;

            foreach my $coords (@$black_cells)
            {
                my $cell = $self->get_cell(@$coords);
                if ($cell->status() eq $NK_WHITE)
                {
                    die "Cell ($coords->[0],$coords->[1]) should be black but it's white";
                }
                elsif ($cell->status eq $NK_BLACK)
                {
                    # Do nothing.
                }
                else
                {
                    $cell->status($NK_BLACK);
                    push @marked_cells, $coords;
                }
            }
            
            push @moves,
                Games::Nurikabe::Solver::Move->new(
                    {
                        reason => "surround_island_when_full",
                        verdict_cells => {$NK_BLACK => \@marked_cells,},
                        reason_params => { island => $island->idx(), },
                    }
                );
        }
    }

    return \@moves;
}

sub _calc_vicinity
{
    my ($self, $y, $x) = @_;

    my @ret;

    if ($y > 0)
    {
        push @ret, [$y-1,$x];
    }

    if ($x > 0)
    {
        push @ret, [$y,$x-1];
    }

    if ($x+1 < $self->_width())
    {
        push @ret, [$y, $x+1];
    }

    if ($y+1 < $self->_height())
    {
        push @ret, [$y+1, $x];
    }

    return \@ret;
}

sub _solve_using_surrounded_by_blacks
{
    my $self = shift;

    my @moves;

    foreach my $y (0 .. ($self->_height()-1))
    {
        X_LOOP:
        foreach my $x (0 .. ($self->_width()-1))
        {
            # We're only interested in unknowns.
            if ($self->get_cell($y,$x)->status() ne $NK_UNKNOWN)
            {
                next X_LOOP;
            }
            if (all { $self->get_cell(@$_)->status() eq $NK_BLACK }
                (@{$self->_calc_vicinity($y,$x)})
            )
            {
                # We got an unknown cell that's entirely surrounded by blacks -
                # let's do our thing.
                $self->get_cell($y,$x)->status($NK_BLACK);
                push @moves,
                    Games::Nurikabe::Solver::Move->new(
                        {
                            reason => "surrounded_by_blacks",
                            verdict_cells => {$NK_BLACK => [[$y,$x]]},
                        }
                    );
            }
        }
    }

    return \@moves;
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
