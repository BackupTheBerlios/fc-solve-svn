#!/usr/bin/perl

use strict;
use warnings;

use Games::Nurikabe::Solver::Board;

use Test::More tests => 4;

use Test::Differences;

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
    eq_or_diff(
        $board->_calc_vicinity(1,1),
        [[0,1],[1,0],[1,2],[2,1]],
        "Simple calc vicinity - 1,1",
    );

    # TEST
    eq_or_diff(
        $board->_calc_vicinity(4,3),
        [[3,3],[4,2],[4,4]],
        "calc vicinity bottom - 4,3",
    );

    # TEST
    eq_or_diff(
        $board->_calc_vicinity(0,0),
        [[0,1],[1,0]],
        "calc vicinity corner - 0,0",
    );

    # TEST
    eq_or_diff(
        $board->_calc_vicinity(0,2),
        [[0,1],[0,3],[1,2]],
        "calc vicinity up - 0,2",
    );

}
