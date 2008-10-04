#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 25;

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

{
    my $string_representation = <<"EOF";
Width=3 Height=3
[] []  []
[] [1] [] 
[] []  []
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
            [[0,1],[1,0], [1,2], [2,1]],
            "Verdicted cells is OK.",
        );

        # TEST
        is ($m->reason_param("island"), 0,
            "The island is 0 in the reason parameter",
        );
    }

    {
        my $moves = $board->_solve_using_surrounded_by_blacks({});

        my $m;
        
        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 0 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[0,0]],
            "Verdicted cells for 0 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 1 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[0,2]], 
            "Verdicted cells for 1 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 2 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[2,0]], 
            "Verdicted cells for 2 is OK.",
        );

        $m = shift(@$moves);
        # TEST
        is ($m->reason(), "surrounded_by_blacks", "reason for 3 is surrounded_by_blacks");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[2,2]], 
            "Verdicted cells for 3 is OK.",
        );

        # TEST
        eq_or_diff(
            $moves,
            [],
            "No more moves left",
        );
    }
}

{
    # http://www.logicgamesonline.com/nurikabe/archive.php?pid=983
    # Daily 9*9 Nurikabe for 2008-10-03
    my $string_representation = <<"EOF";
Width=9 Height=9
[1] [] [] [] [] [] [] [5] []
[] [6] [] [] [6] [] [] [] []
[] []  [] [3] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] [] [] [] [] []
[] [] [] [] []  [2] [] [] []
[] [] [] [] [3] [] [] [3] []
[] [2] [] [] [] [] [] [] [1]
EOF

    my $board =
        Games::Nurikabe::Solver::Board->load_from_string(
            $string_representation
        );

    {
        my $moves = $board->_solve_using_adjacent_whites({});

        my $m = shift(@$moves);

        # TEST
        is ($m->reason(), "adjacent_whites", "reason[0] is OK.");

        # TEST
        eq_or_diff(
            $m->get_verdict_cells($NK_BLACK),
            [[0,1],[1,0]],
            "Verdicted cells[0] are OK.",
        );

        # TEST
        eq_or_diff ($m->reason_param("offset"), [1,1], "Offset[0] is (1,1).");

        # TEST
        eq_or_diff ($m->reason_param("islands"), [0,2],
            "Islands of [0] are [0,2]",
        );

        # TEST
        eq_or_diff (
            $m->reason_param("base_coords"),
            [0,0],
            "Base coords[0] is (0,0)."
        );
    }
}
