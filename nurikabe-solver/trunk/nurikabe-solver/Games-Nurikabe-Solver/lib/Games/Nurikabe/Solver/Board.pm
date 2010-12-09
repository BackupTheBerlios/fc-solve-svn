package Games::Nurikabe::Solver::Board;

use warnings;
use strict;

use List::MoreUtils qw(all);

use base 'Games::Nurikabe::Solver::Base';

use Games::Nurikabe::Solver::Cell;
use Games::Nurikabe::Solver::Constants;

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
    _expected_totals
    _found_totals
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

sub _vicinity_loop
{
    my ($board, $coords, $callback) = @_;

    my $cell = $board->get_cell($coords);

    foreach my $off_coords (
        grep { $board->_is_in_bounds($_) }
        map { $board->add_offset($coords->_to_pair, $_) }
        ([-1,0],[0,-1],[0,1],[1,0])
    )
    {
        $callback->(
            Games::Nurikabe::Solver::Coords->new(
                {
                    y => $off_coords->[0], x => $off_coords->[1]
                }
            )
        );
    }

    return;
}

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

sub _num_expected_cells
{
    my $self = shift;
    my $color = shift;

    return $self->_expected_totals()->{$color};
}

sub _num_found_cells
{
    my $self = shift;
    my $color = shift;

    return $self->_found_totals()->{$color};
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

    $self->_expected_totals
    (
        {
            $NK_BLACK => ($self->_width()*$self->_height()),
            $NK_WHITE => 0,
        },
    );

    $self->_found_totals(
        {
            $NK_UNKNOWN => ($self->_width()*$self->_height()),
            $NK_BLACK => 0,
            $NK_WHITE => 0,
        }
    );

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
                            known_cells => [
                                Games::Nurikabe::Solver::Coords->new(
                                    { y => $y, x => $x}
                                )
                            ],
                            order => $num_cells,
                        },
                    );

                $self->_expected_totals()->{$NK_WHITE} += $num_cells;
                $self->_expected_totals()->{$NK_BLACK} -= $num_cells;

                $cell_obj =
                    Games::Nurikabe::Solver::Cell->new(
                        {
                            status => $NK_WHITE,
                            island => $index,
                        }
                    );

                $self->_found_totals()->{$NK_WHITE}++;
                $self->_found_totals()->{$NK_UNKNOWN}--;
            }
            push @{$cells[$y]}, $cell_obj;
        }
    }

    $self->_cells(\@cells);
    $self->_islands(\@islands);

    return $self;
}

=head2 $self->get_cell( $coords )

Returns the cell in position of $coords where $coords is a
L<Games::Nurikabe::Solver::Coords> object. It is a
L<Games::Nurikabe::Solver::Cell> object.

=cut

sub get_cell
{
    my $self = shift;
    my $c = shift;

    return $self->_cells()->[$c->y]->[$c->x];
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

    $self->get_cell(
        Games::Nurikabe::Solver::Coords->new(
            {
                y => $coords->[0],
                x => $coords->[1],
            }
        )
    )->status($verdict);

    push @{$self->_verdict_marked_cells()->{$verdict}},
        $coords
        ;

    return;
}

sub _mark_as_black
{
    my ($self, $c) = @_;

    my $cell = $self->get_cell(
        Games::Nurikabe::Solver::Coords->new
        (
            { y => $c->[0], x => $c->[1] }
        )
    );

    if ($cell->status() eq $NK_WHITE)
    {
        die "Cell ($c->[0],$c->[1]) should not be white but it is";
    }

    if ($cell->status() eq $NK_BLACK)
    {
        # Do nothing - it's already black.
        return;
    }

    $self->_found_totals()->{$NK_BLACK}++;
    $self->_found_totals()->{$NK_UNKNOWN}--;

    return $self->_actual_mark($c,$NK_BLACK);
}

sub _mark_as_white
{
    my ($self, $c, $idx) = @_;

    my $cell = $self->get_cell(
        Games::Nurikabe::Solver::Coords->new(
            {
                y => $c->[0],
                x => $c->[1],
            }
        ),
    );

    if ($cell->status() eq $NK_BLACK)
    {
        die "Cell ($c->[0],$c->[1]) should not be black but it is";
    }

    if ($cell->status() eq $NK_WHITE)
    {
        # Do nothing - it's already black.
        return;
    }

    $cell->island($idx);

    $self->_found_totals()->{$NK_WHITE}++;
    $self->_found_totals()->{$NK_UNKNOWN}--;

    return $self->_actual_mark($c,$NK_WHITE);
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
                $self->_mark_as_black($coords->_to_pair);
            }
            
            $self->_add_move(
                {
                    reason => "surround_island_when_full",
                    reason_params => { island => $island->idx(), },
                }
            );
        }
    }

    return;
}

sub _calc_vicinity
{
    my $self = shift;
    my ($y, $x) = @{shift()};

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
    my $self = shift;
    my ($y, $x) = @{shift()};

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

            if (all { $self->get_cell(Games::Nurikabe::Solver::Coords->new({y => $_->[1], x => $_->[0] } ))->status() eq $NK_BLACK }
                (@{$self->_calc_vicinity($coords)})
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

    return;
}

sub _adj_whites_handle_shape
{
    my ($self, $c, $cell, $shape) = @_;

    my $offset = $shape->{'offset'};
    my $blacks_offsets = $shape->{'blacks'};

    # Other [X,Y] 
    my $other_coords = $self->add_offset($c, $offset);
    
    if (! $self->_is_in_bounds($other_coords))
    {
        return;
    }

    my $other_cell = $self->get_cell(Games::Nurikabe::Solver::Coords->new({y => $other_coords->[0], x => $other_coords->[1]}));
    
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

    return;
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
    # cells reachable by it.

    foreach my $island (@{$self->_islands()})
    {
        $island->mark_reachable_brfs_scan({board => $self});
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

    return;
}

sub _solve_using_fully_expand_island
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
    # cells reachable by it.

    foreach my $island (@{$self->_islands()})
    {
        $island->mark_reachable_brfs_scan({board => $self});
    }

    my @island_reachable_cells = (map { [] } @{$self->_islands()});

    # Now mark the unreachable states.
    $self->_cells_loop(
        sub {
            my ($coords, $cell) = @_;

            if (($cell->status() eq $NK_UNKNOWN)
                && $cell->_reachable()
            )
            {
                foreach my $idx (0 .. $#{$self->_islands()})
                {
                    if (defined($cell->_island_reachable->[$idx]))
                    {
                        push @{$island_reachable_cells[$idx]}, [@$coords];
                    }
                }
            }
        },
    );

    my $moved = 0;

    foreach my $idx (0 .. $#{$self->_islands()})
    {
        my $island = $self->_islands->[$idx];

        my $count = @{$island_reachable_cells[$idx]} + @{$island->known_cells};

        # We can mark all these cells as white, since the island is full.
        if ($count == $island->order())
        {
            $moved = 1;
            $island->add_white_cells({
                    board => $self,
                    cells => $island_reachable_cells[$idx]
                }
            );
        }
    }

    if ($moved)
    {
        $self->_add_move(
            {
                reason => "fully_expand_island",
            }
        );
    }

    return;
}

sub _solve_using_expand_black_regions
{
    my $self = shift;

    $self->_cells_loop(
        sub {
            my ($coords, $cell) = @_;

            if ($cell->status() eq $NK_BLACK)
            {
                $cell->already_processed(0);
            }
        }
    );

    my $found = 0;

    $self->_cells_loop(
        sub {
            my ($cell_pair, $cell) = @_;

            my $cell_coords = Games::Nurikabe::Solver::Coords->new(
                {
                    y => $cell_pair->[0], x => $cell_pair->[1]
                }
            );

            if (($cell->status() eq $NK_BLACK) && (! $cell->already_processed))
            {
                # Perform a BrFS scan on the cell to find all adjacent black
                # cells and the unknown cells that are adjacent to them.
                
                my @queue = ($cell_coords);

                my %adjacent_unknowns;

                # TODO : abstract all BrFS searches into a common code.
                QUEUE_LOOP:
                while (my $coords = shift(@queue))
                {
                    my $q_c = $self->get_cell($coords);

                    if ($q_c->already_processed)
                    {
                        next QUEUE_LOOP;
                    }

                    $q_c->already_processed(1);
                    $self->_vicinity_loop(
                        $coords,
                        sub {
                            my $to_check = shift;

                            my $c = $self->get_cell($to_check);

                            if ($c->status() eq $NK_BLACK)
                            {
                                if (! $c->already_processed())
                                {
                                    push @queue, $to_check;
                                }
                            }
                            elsif ($c->status() eq $NK_UNKNOWN)
                            {
                                $adjacent_unknowns{$to_check->to_s} = 1;
                            }
                        }
                    );
                }

                my @k = keys(%adjacent_unknowns);
                if (@k == 1)
                {
                    # Bingo - this black region only has one cell to expand to.
                    $self->_mark_as_black([split/,/,$k[0]]);
                    $found = 1;
                }
            }
        }
    );

    if ($found)
    {
        $self->_add_move(
            {
                reason => "expand_black_regions",
            }
        );
    }

    return;
}

sub _solve_using
{
    my $self = shift;
    my $args = shift;

    my $name = $args->{name};
    my $move_params = $args->{params};

    my $move_method = "_solve_using_$name";

    $self->$move_method($move_params);

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
