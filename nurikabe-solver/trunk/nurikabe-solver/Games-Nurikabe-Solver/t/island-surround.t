#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use Test::Differences;

use lib './t/lib';

use Games::Nurikabe::Solver::Test::BoardInput;

use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;
use Games::Nurikabe::Solver::Island;

{
    my $board_s = <<'EOF';
+--------------------+
|                 BBB|
|                BWWW|
|                 BBW|
|                   B|
|                    |
|                    |
+--------------------+
EOF

    my $bi = BoardInput->from_s($board_s);

    my $board =
        Games::Nurikabe::Solver::Board->new(
            {
                _width => $bi->width(),
                _height => $bi->height(),
            }
        );

    my $white_cells = $bi->positions("W");

    my $island =
        Games::Nurikabe::Solver::Island->new(
            {
                idx => 0,
                order => scalar(@$white_cells),
                known_cells => $white_cells,
            }
        );

    my $got_surrounded_cells =
        $island->surround(
            {
                board => $board,
            }
        );

    # TEST
    eq_or_diff(
        $got_surrounded_cells,
        $bi->positions("B"),
        "Sorrounded Cells for an L Shape Island"
    );
}
