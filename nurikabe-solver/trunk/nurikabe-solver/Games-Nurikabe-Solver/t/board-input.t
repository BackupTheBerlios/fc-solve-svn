#!/usr/bin/perl

use strict;
use warnings;

use lib './t/lib';
use Games::Nurikabe::Solver::Test::BoardInput;

use Test::More tests => 3;

use Test::Differences;

{
    my $board_s = <<"EOF";
+---+
| 11|
|1  |
+---+
EOF

    my $b = BoardInput->from_s($board_s);

    # TEST
    is ($b->width(), 3, "Width is 3");

    # TEST
    is ($b->height(), 2, "Height is 2");

    # TEST
    eq_or_diff ($b->positions("1"), [[0,1],[0,2],[1,0]]);
}
