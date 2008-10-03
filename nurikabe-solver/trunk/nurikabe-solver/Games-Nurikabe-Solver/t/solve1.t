#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

use Test::Differences;

use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;

{
    my $string_representation = <<"EOF";
Width=2 Height=2
[1] []
[]  []
EOF

    my $board = 
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    {
        my $moves = $board->_solve_using_surround_island({});

        # TEST
        is (scalar(@$moves), 1, "There is 1 move");

        my $m = $moves->[0];

        # TEST
        is ($m->reason(), "surround_island_when_full", "reason is OK.");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[0,1],[1,0]],
            "Verdicted cells is OK.",
        );

        # TEST
        is ($m->reason_param("island"), 0,
            "The island is 0 in the reason parameter",
        );
    }

    {
        my $moves = $board->_solve_using_surrounded_by_blacks({});

        # TEST
        is (scalar(@$moves), 1, "There is 1 move");

        my $m = $moves->[0];

        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason is OK.");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[1,1]],
            "Verdicted cells is OK.",
        );
    }
}
