#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 10;

use Test::Differences;

use Games::Nurikabe::Solver::Cell;
use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;

sub _island_cells_dump
{
    my $island = shift;

    return [map { [$_->y,$_->x] } @{$island->known_cells()}];
}

{
    my $string_representation = <<"EOF";
Width=5 Height=5
[] [] [] [1] []
[] [1] [] [] []
[] [] [] [] []
[] [] [] [2] []
[] [6] [] [] []
EOF

    my $board = 
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    my $get_cell = sub {
        my $xy = shift;
        return $board->get_cell($board->_new_coords($xy));
    };

    # TEST
    is ($get_cell->({y => 0, x => 0})->status(),
        $NK_UNKNOWN,
        "Checking Status of Cell (0,0)",
    );

    # TEST
    is ($get_cell->({ y => 0, x => 2})->status(),
        $NK_UNKNOWN,
        "Checking Status of Cell (0,2)",
    );

    # TEST
    is ($get_cell->({ y => 0, x => 3})->status(),
        $NK_WHITE,
        "Status of Cell (0,3) - White"
    );

    # TEST
    is ($get_cell->({ y => 0, x => 3})->island(),
        0,
        "Island of Cell (0,4) - 0"
    );

    # TEST
    is ($board->get_island(0)->idx(), 0, "idx() of island 0 is 0");

    # TEST
    is ($board->get_island(0)->order(), 1, "order() of island 0 is 1");

    # TEST
    eq_or_diff (
        _island_cells_dump($board->get_island(0)),
        [[0,3]], 
        "known_cells of island 0",
    );
    
    # TEST
    is ($board->get_island(2)->idx(), 2, "idx() of island 2 is 2");

    # TEST
    is ($board->get_island(2)->order(), 2, "order() of island 2 is 2");

    # TEST
    eq_or_diff (
        _island_cells_dump($board->get_island(2)),
        [[3,3]], 
        "known_cells of island 2",
    );

}
