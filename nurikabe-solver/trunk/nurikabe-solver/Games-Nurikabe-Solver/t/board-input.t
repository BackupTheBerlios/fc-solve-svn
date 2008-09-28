#!/usr/bin/perl

use strict;
use warnings;

use lib './t/lib';
use Games::Nurikabe::Solver::Test::BoardInput;

use Test::More tests => 9;

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

{
    my $board_s = <<'EOF';
+----+
|312 |
|1   |
| 2  |
|4  3|
+----+
EOF

    my $b = BoardInput->from_s($board_s);

    # TEST
    is ($b->width(), 4, "Width is 4");

    # TEST
    is ($b->height(), 4, "Height is 4");

    # TEST
    eq_or_diff ($b->positions("1"), [[0,1],[1,0]]);

    # TEST
    eq_or_diff ($b->positions("2"), [[0,2],[2,1]]);

    # TEST
    eq_or_diff ($b->positions("3"), [[0,0],[3,3]]);

    # TEST
    eq_or_diff ($b->positions("4"), [[3,0]]);
}
