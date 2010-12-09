#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;

use Test::Differences;

use lib './t/lib';

use Games::Nurikabe::Solver::Test::BoardInput;

use Games::Nurikabe::Solver::Cell;
use Games::Nurikabe::Solver::Constants qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);

use Games::Nurikabe::Solver::Move;

{
    my $move = Games::Nurikabe::Solver::Move->new(
        {
            reason => "surround_island_when_full",
            verdict_cells => {$NK_BLACK => [[0,1],[1,0]]},
            reason_params => { island => 0, },
        }
    );

    # TEST
    is ($move->reason(), "surround_island_when_full", "->reason is OK.");

    # TEST
    eq_or_diff(
        $move->get_verdict_cells($NK_BLACK),
        [[0,1],[1,0]],
        "Verdicted cells is OK.",
    );

    # TEST
    is ($move->reason_param("island"), 0,
        "The island is 0 in the reason parameter",
    );
}

{
    my $move = Games::Nurikabe::Solver::Move->new(
        {
            reason => "surrounded_by_blacks",
            verdict_cells => {$NK_BLACK => [[1,1]]},
        }
    );

    # TEST
    is ($move->reason(), "surrounded_by_blacks", "->reason is OK.");

    # TEST
    eq_or_diff(
        $move->get_verdict_cells($NK_BLACK),
        [[1,1]],
        "Verdicted cells is OK.",
    );
}
