#!/usr/bin/perl -w

use strict;
#use File::stat;

use PDL;
use PDL::IO::FastRaw;

use MyInput;

my $num_boards = 32000;

my $script_filename = "-";

if (scalar(@ARGV))
{
    while (my $arg = shift(@ARGV))
    {
        if ($arg eq "-o")
        {
            $script_filename = shift;
        }
        elsif ($arg eq "-n")
        {
            $num_boards = shift;
        }
    }
}


my @scans;

open I, "<scans.txt";
while (my $line = <I>)
{
    chomp($line);
    my ($id, $cmd_line) = split(/\t/, $line);
    push @scans, { 'id' => $id, 'cmd_line' => $cmd_line };
}
close(I);

my @selected_scans = 
    grep 
    { 
        my @stat = stat("./data/".$_->{'id'}.".data.bin");
        scalar(@stat) && ($stat[7] >= 12+$num_boards*4);
    }
    @scans;
    
#my $scans_data = [];
#my $scans_data = zeroes($num_boards, scalar(@selected_scans));

my $scans_data = MyInput::get_scans_data($num_boards, \@selected_scans);

my @quotas = ((200) x 5000);
my @chosen_scans = ();

my $total = 0;
my $q = 0;
my $total_iters = 0;

foreach my $q_more (@quotas)
{
    $q += $q_more;
    my $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
    my ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
    if ($max == 0)
    {
        next;
    }
    if (0)
    {
        my $orig_max = $max;
        while ($max == $orig_max)
        {
            $q--;
            $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
            ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
        }
        $q++;
        $num_solved = sumover(($scans_data <= $q) & ($scans_data > 0));
        ($min, $max, $min_ind, $max_ind) = minmaximum($num_solved);
    }   
    push @chosen_scans, { 'q' => $q, 'ind' => $max_ind };
    $total += $max;
    print "$q \@ $max_ind ($total solved)\n";
    my $this_scan_result = ($scans_data->slice(":,$max_ind"));
    $total_iters += sum((($this_scan_result <= $q) & ($this_scan_result > 0)) * $this_scan_result);
    my $indexes = which(($this_scan_result > $q) | ($this_scan_result < 0));
    
    $total_iters += ($indexes->nelem() * $q);
    if ($total == $num_boards)
    {
        print "Solved all!\n";
        last;
    }    
    
    $scans_data = $scans_data->dice($indexes, "X");
    $this_scan_result = $scans_data->slice(":,$max_ind")->copy();
    $scans_data->slice(":,$max_ind") *= 0;
    $scans_data->slice(":,$max_ind") += (($this_scan_result - $q) * ($this_scan_result > 0)) +
        ($this_scan_result * ($this_scan_result < 0));

    $q = 0;
}

# print "scans_data = " , $scans_data, "\n";
print "total_iters = $total_iters\n";

if ($script_filename eq "-")
{
    open SCRIPT, ">&STDOUT";
}
else
{
    open SCRIPT, ">$script_filename";    
}


# Construct the command line
my $cmd_line = "freecell-solver-range-parallel-solve 1 $num_boards 1 \\\n" .
    join(" -nst \\\n", map { $_->{'cmd_line'} . " -step 500 --st-name " . $_->{'id'} } @selected_scans) . " \\\n" .
    "--prelude \"" . join(",", map { $_->{'q'} . "\@" . $selected_scans[$_->{'ind'}]->{'id'} } @chosen_scans) ."\"";
    
print SCRIPT $cmd_line;
print SCRIPT "\n\n\n";

close(SCRIPT);



