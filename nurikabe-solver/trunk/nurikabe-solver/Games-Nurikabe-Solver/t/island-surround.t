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

sub is_island_surround
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($board_s, $blurb) = @_;

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

    return eq_or_diff(
        $got_surrounded_cells,
        $bi->positions("B"),
        $blurb
    );
}

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

    # TEST
    is_island_surround(
        $board_s, 
        "Sorrounded Cells for an L Shape Island"
    );
}
