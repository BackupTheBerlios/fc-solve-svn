#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;

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

{
    my $board_s = <<'EOF';
+--------------------+
|                 B  |
|                BWB |
|               BWWWB|
|                BBWB|
|                  B |
|                    |
+--------------------+
EOF

    # TEST
    is_island_surround(
        $board_s, 
        "Sorrounded Cells for an 5-Island"
    );
}

{
    my $board_s = <<'EOF';
+--------------------+
|                    |
|    BBBBBBBBBB      |
|   BWWWWWWWWWWB     |
|    BBBBBBBBBB      |
|                    |
|                    |
+--------------------+
EOF

    # TEST
    is_island_surround(
        $board_s, 
        "Sorrounded Cells for a long straight 10-Island"
    );
}

{
    my $board_s = <<'EOF';
+------------+
|B           |
|WB          |
|WB          |
|WB          |
|WB          |
|B           |
|            |
|            |
|            |
+------------+
EOF

    # TEST
    is_island_surround(
        $board_s, 
        "Sorrounded Cells for a vertical edgy 4-straight"
    );
}

{
    my $board_s = <<'EOF';
+------------+
|WWB         |
|WWB         |
|BB          |
|            |
|            |
|            |
|            |
|            |
|            |
+------------+
EOF

    # TEST
    is_island_surround(
        $board_s, 
        "Sorrounded Cells for a corner 2*2."
    );
}

{
    my $board_s = <<'EOF';
+------------+
|WB          |
|WWB         |
|BWBB        |
|BWWWB       |
|BWBB        |
| B          |
|            |
|            |
|            |
+------------+
EOF

    # TEST
    is_island_surround(
        $board_s,
        "Sorrounded Cells - corner squiglly", 
    );
}
