package Games::Nurikabe::Solver::Board;

use warnings;
use strict;

use List::MoreUtils qw(all);

use base 'Games::Nurikabe::Solver::Base';

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
    _height
    _islands
    _moves
    _verdict_marked_cells
    _width
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

=head2 $class->new()

Should not be used directly.

=cut

sub _get_init_verdict_marked_cells
{
    my $self = shift;

    return {$NK_BLACK => [], $NK_WHITE => [],}
}

sub _clear_verdict_marked_cells
{
    my $self = shift;

    $self->_verdict_marked_cells($self->_get_init_verdict_marked_cells());

    return;
}

sub _flush_verdict_marked_cells
{
    my $self = shift;

    my $ret = $self->_verdict_marked_cells();

    $self->_clear_verdict_marked_cells();

    return $ret;
}

sub _exist_verdict_marked_cells
{
    my $self = shift;

    return @{$self->_verdict_marked_cells->{$NK_BLACK}} ||
           @{$self->_verdict_marked_cells->{$NK_WHITE}}
        ;
}

sub _flush_moves
{
    my $self = shift;

    my $ret = $self->_moves();

    $self->_moves([]);

    return $ret;
}

sub _init
{
    my $self = shift;
    my $args = shift;

    $self->_width($args->{width});
    $self->_height($args->{height});

    $self->_clear_verdict_marked_cells();

    $self->_moves([]);

    return 0;
}

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

    my $self = $class->new({width => $width, height => $height});

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

=head2 $self->get_cell( [$y,$x] )

Returns the cell in position ($y, $x). It is a
L<Games::Nurikabe::Solver::Cell> object.

=cut

sub get_cell
{
    my $self = shift;
    my $c = shift;

    return $self->_cells()->[$c->[0]]->[$c->[1]];
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

sub _add_move
{
    my $self = shift;
    my $args = shift;

    if ($self->_exist_verdict_marked_cells())
    {
        push @{$self->_moves()},
            Games::Nurikabe::Solver::Move->new(
                {
                    verdict_cells => $self->_flush_verdict_marked_cells(),
                    %$args,
                },
            );
    }

    return;
}


sub _actual_mark
{
    my ($self, $coords, $verdict) = @_;

    $self->get_cell($coords)->status($verdict);

    push @{$self->_verdict_marked_cells()->{$verdict}},
        $coords
        ;

    return;
}

sub _mark_as_black
{
    my ($self, $c) = @_;

    my $cell = $self->get_cell($c);

    if ($cell->status() eq $NK_WHITE)
    {
        die "Cell ($c->[0],$c->[1]) should not be white but it is";
    }

    if ($cell->status() eq $NK_BLACK)
    {
        # Do nothing - it's already black.
        return;
    }

    return $self->_actual_mark($c,$NK_BLACK);
}

sub _cells_loop
{
    my ($self, $callback) = @_;

    my $y = 0;
    foreach my $row (@{$self->_cells()})
    {
        my $x = 0;
        foreach my $cell (@$row)
        {
            $callback->([$y,$x], $cell);
        }
        continue
        {
            $x++;
        }
    }
    continue
    {
        $y++;
    }

    return;
}

sub _solve_using_surround_island
{
    my $self = shift;

    foreach my $island (@{$self->_islands()})
    {
        if ($island->order() == @{$island->known_cells()})
        {
            my $black_cells = $island->surround({ board => $self });

            foreach my $coords (@$black_cells)
            {
                $self->_mark_as_black($coords);
            }
            
            $self->_add_move(
                {
                    reason => "surround_island_when_full",
                    reason_params => { island => $island->idx(), },
                }
            );
        }
    }

    return $self->_flush_moves();
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

sub _is_in_bounds
{
    my ($self, $y, $x) = @_;

    return
        (
            ($y >= 0) && ($y < $self->_height())
         && ($x >= 0) && ($x < $self->_width())
        );
}

sub _solve_using_surrounded_by_blacks
{
    my $self = shift;

    $self->_cells_loop(
        sub {
            my ($coords, $cell) = @_;

            # We're only interested in unknowns.
            if ($cell->status() ne $NK_UNKNOWN)
            {
                return;
            }

            if (all { $self->get_cell($_)->status() eq $NK_BLACK }
                (@{$self->_calc_vicinity(@$coords)})
            )
            {
                # We got an unknown cell that's entirely surrounded by blacks -
                # let's do our thing.
                $self->_mark_as_black($coords);
                $self->_add_move(
                    {
                        reason => "surrounded_by_blacks",
                    }
                );
            }
        }
    );

    return $self->_flush_moves();
}

sub _adj_whites_handle_shape
{
    my ($self, $c, $cell, $shape) = @_;

    my $offset = $shape->{'offset'};
    my $blacks_offsets = $shape->{'blacks'};

    # Other [X,Y] 
    my $other_coords = $self->add_offset($c, $offset);
    
    if (! $self->_is_in_bounds(@$other_coords))
    {
        return;
    }

    my $other_cell = $self->get_cell($other_coords);
    
    if ($other_cell->not_same_island($cell))
    {
        # Bingo.
        foreach my $b_off (@$blacks_offsets)
        {
            $self->_mark_as_black($self->add_offset($c, $b_off));
        }

        $self->_add_move(
            {
                reason => "adjacent_whites",
                reason_params =>
                {
                    base_coords => [@$c],
                    offset => [@$offset],
                    islands =>
                    [
                        $cell->island(),
                        $other_cell->island(),
                    ],
                },
            }
        );
    }

    return;
}

sub _calc_adjacent_whites_shapes_list
{
    my $self = shift;

    return
    [
        {
            offset => [1,1],
            blacks => [[0,1],[1,0]],
        },
        {
            offset => [1,-1],
            blacks => [[0,-1],[1,0]],
        },
        {
            offset => [0,2],
            blacks => [[0,1]],
        },
        {
            offset => [2,0],
            blacks => [[1,0]],
        },
    ];
}

sub _solve_using_adjacent_whites
{
    my $self = shift;

    my $shapes_list = $self->_calc_adjacent_whites_shapes_list();

    $self->_cells_loop(
        sub {
            # $c is coordinates.
            my ($c, $cell) = @_;

            if (! $cell->belongs_to_island())
            {
                return;
            }

            foreach my $shape (@$shapes_list)
            {
                $self->_adj_whites_handle_shape($c, $cell, $shape);
            }
        }
    );

    return $self->_flush_moves();
}

sub _solve_using_distance_from_islands
{
    my $self = shift;

    # Mark non-traversable cells - these are cells that are too close 
    # to a white island cell.
    foreach my $island (@{$self->_islands()})
    {
        my $non_traverse = $island->surround({board => $self });

        foreach my $coords (@$non_traverse)
        {
            $self->get_cell($coords)->island_in_proximity($island->idx());
        }
    }

    # Now do a Breadth-First Search scan for every island and mark the
    # islands reachable by it.

    foreach my $island (@{$self->_islands()})
    {
        my @queue = (map { [0,$_] } @{$island->known_cells()});

        my $dist_limit = $island->order() - @{$island->known_cells()};

        QUEUE_LOOP:
        while (@queue)
        {
            my $item = shift(@queue);
            
            my ($dist, $c) = @$item;

            if ($dist == $dist_limit)
            {
                next QUEUE_LOOP;
            }
            
            OFFSET_LOOP:
            foreach my $offset ([-1,0],[0,-1],[0,1],[1,0])
            {
                my $to_check = $self->add_offset($c, $offset);

                if (!$self->_is_in_bounds(@$to_check))
                {
                    next OFFSET_LOOP;
                }

                my $cell = $self->get_cell($to_check);

                if (($cell->status() eq $NK_BLACK)
                    || (defined($cell->island()) 
                        && $cell->island() != $island->idx()
                    )
                )
                {
                    next OFFSET_LOOP;
                }

                if (defined($cell->island_in_proximity()) &&
                    $cell->island_in_proximity() != $island->idx()
                )
                {
                    next OFFSET_LOOP;
                }

                push @queue, $cell->set_island_reachable(
                    $island->idx(),
                    $dist+1,
                    $to_check
                );
            }
        }
    }

    # Now mark the unreachable states.
    $self->_cells_loop(
        sub {
            my ($coords, $cell) = @_;

            if ($cell->status() eq $NK_UNKNOWN && ! $cell->_reachable())
            {
                $self->_mark_as_black($coords);
            }
        },
    );

    $self->_add_move(
        {
            reason => "distance_from_islands",
        }
    );

    return $self->_flush_moves();
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

1; # End of Games::Nurikabe::Solver::Board
