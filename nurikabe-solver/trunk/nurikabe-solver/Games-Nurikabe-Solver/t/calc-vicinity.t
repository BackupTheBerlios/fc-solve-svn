#!/usr/bin/perl

use strict;
use warnings;

use Games::Nurikabe::Solver::Board;

use Test::More tests => 1;

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
}
