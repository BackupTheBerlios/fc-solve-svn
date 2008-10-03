#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Test::Differences;

use lib './t/lib';

use Games::Nurikabe::Solver::Test::BoardInput;

use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);
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
