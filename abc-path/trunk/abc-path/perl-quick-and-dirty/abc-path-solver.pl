#!/usr/bin/perl

use strict;
use warnings;

use Carp;

my $ABCP_VERDICT_NO = 0;
my $ABCP_VERDICT_MAYBE = 1;
my $ABCP_VERDICT_YES = 2;

# This will handle 25*25 2-bit cells and the $ABCP_VERDICT_MAYBE / etc.
# verdicts above.
my $verdicts_matrix = '';

sub get_verdict
{
    my ($letter, $x, $y) = @_;

    if (($letter < 0) or ($letter >= 25))
    {
        confess "Letter $letter out of range.";
    }

    if (($x < 0) or ($x >= 5))
    {
        confess "X $x out of range.";
    }

    if (($y < 0) or ($y >= 5))
    {
        confess "X $y out of range.";
    }


    return vec($verdicts_matrix, $letter*25+$y*5+$x, 2);
}

sub set_verdict
{
    my ($letter, $x, $y, $verdict) = @_;

    if (($letter < 0) or ($letter >= 25))
    {
        confess "Letter $letter out of range.";
    }

    if (($x < 0) or ($x >= 5))
    {
        confess "X $x out of range.";
    }

    if (($y < 0) or ($y >= 5))
    {
        confess "X $y out of range.";
    }

    if (not
        ($verdict == $ABCP_VERDICT_NO)
        || ($verdict == $ABCP_VERDICT_MAYBE)
        || ($verdict == $ABCP_VERDICT_YES)
    )
    {
        confess "Invalid verdict $verdict .";
    }

    vec($verdicts_matrix, $letter*25+$y*5+$x, 2) = $verdict;

    return;
}

my @letters = (qw(A B C D E F G H I J K L M N O P Q R S T U V W X Y));

# Input the board.

my $board_fn = shift(@ARGV);

open my $in_fh, "<", $board_fn
    or die "Cannot open '$board_fn' - $!";

my $first_line = <$in_fh>;
chomp($first_line);

my $magic = 'ABC Path Solver Layout Version 1:';
if ($first_line !~ m{\A\Q$magic\E\s*\z})
{
    die "Can only process files whose first line is '$magic'!";
}

my $layout_string = '';
foreach my $line_idx (1 .. 7)
{
    chomp(my $line = <$in_fh>);
    $layout_string .= "$line\n";
}
close($in_fh);

print $layout_string;
