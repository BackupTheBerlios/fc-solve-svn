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

    my $test_calc_vicinity = sub {
        local $Test::Builder::Level = $Test::Builder::Level + 1;
        my ($coords, $vicinity, $blurb) = @_;

        eq_or_diff(
            [ map { $_->_to_pair() } @{$board->_calc_vicinity(
                    Games::Nurikabe::Solver::Coords->new($coords)
                ) }
            ],
            $vicinity,
            $blurb
        );
    };

    # TEST
    $test_calc_vicinity->(
        {y => 1, x => 1},
        [[0,1],[1,0],[1,2],[2,1]],
        "Simple calc vicinity - 1,1",
    );

    # TEST
    $test_calc_vicinity->(
        {y => 4, x => 3},
        [[3,3],[4,2],[4,4]],
        "calc vicinity bottom - 4,3",
    );

    # TEST
    $test_calc_vicinity->(
        { y => 0, x => 0 },
        [[0,1],[1,0]],
        "calc vicinity corner - 0,0",
    );

    # TEST
    $test_calc_vicinity->(
        { y => 0, x => 2},
        [[0,1],[0,3],[1,2]],
        "calc vicinity up - 0,2",
    );

}
