#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;

use Test::Differences;

use lib './t/lib';

use Games::Nurikabe::Solver::Test::BoardInput;

use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
use Games::Nurikabe::Solver::Board;
use Games::Nurikabe::Solver::Island;

sub is_island_surround
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my ($board_s, $blurb) = @_;

    my $bi = BoardInput->from_s($board_s);

    my @cells =
    (
        map
        {
        [ 
            map { 
            Games::Nurikabe::Solver::Cell->new(
                { status => $NK_UNKNOWN }
                )
            } (0 .. ($bi->width() - 1))
        ]
        } (0 .. ($bi->height() -1))
    );

    my $board =
        Games::Nurikabe::Solver::Board->new(
            {
                width => $bi->width(),
                height => $bi->height(),
            }
        );

    $board->_cells(\@cells);

    my $white_cells = $bi->positions("W");

    my $island =
        Games::Nurikabe::Solver::Island->new(
            {
                idx => 0,
                order => scalar(@$white_cells),
                known_cells =>
                [ 
                    map 
                    {
                        $board->_new_coords( {y => $_->[0], x => $_->[1],} )
                    }
                    @$white_cells
                ],
            }
        );

    my $got_surrounded_cells =
        $island->surround(
            {
                board => $board,
            }
        );

    return eq_or_diff(
        [map { $_->to_aref() } @{$got_surrounded_cells}],
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
        "Surrounded Cells for an L Shape Island"
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
        "Surrounded Cells for an 5-Island"
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
        "Surrounded Cells for a long straight 10-Island"
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
        "Surrounded Cells for a vertical edgy 4-straight"
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
        "Surrounded Cells for a corner 2*2."
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
        "Surrounded Cells - corner squiglly",
    );
}
