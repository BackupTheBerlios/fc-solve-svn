#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Test::Differences;

use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;

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

    # TEST
    is ($board->get_cell(0,0)->status(),
        $NK_UNKNOWN,
        "Checking Status of Cell (0,0)",
    );

    # TEST
    is ($board->get_cell(0,2)->status(),
        $NK_UNKNOWN,
        "Checking Status of Cell (0,2)",
    );

    # TEST
    is ($board->get_cell(0,3)->status(),
        $NK_WHITE,
        "Status of Cell (0,3) - White"
    );

    # TEST
    is ($board->get_cell(0,3)->island(),
        0,
        "Island of Cell (0,4) - 0"
    );

    # TEST
    is ($board->get_island(0)->idx(), 0, "idx() of island 0 is 0");

    # TEST
    is ($board->get_island(0)->order(), 1, "order() of island 0 is 1");

    # TEST
    eq_or_diff (
        $board->get_island(0)->known_cells(),
        [[0,3]], 
        "known_cells of island 0",
    );
}
