package BoardInput;

use strict;
use warnings;

use base 'Class::Accessor';

__PACKAGE__->mk_accessors(qw(
    width
    height
    _char_positions
    ));

sub from_s
{
    my $class = shift;
    my $string = shift;

    chomp($string);

    my @lines = split(/\n/, $string, -1);

    my $first = shift(@lines);
    if ($first !~ m{\A\+(-+)\+\z}ms)
    {
        die "First line does not match +---------...+ pattern";
    }

    my $width = length($1);

    my $inner_re = qr/\A\|[ \w]{$width}\|\z/;

    my $line;
    my $y = 0;

    my %char_positions;

    LINES_LOOP:
    while (defined($line = shift(@lines)))
    {
        if ($line eq $first)
        {
            if (@lines)
            {
                die "Junk after terminating line";
            }
            last LINES_LOOP;
        }

        if ($line !~ m{$inner_re}ms)
        {
            die "Line '$line' does not match |...| pattern";
        }

        for my $x (0 .. ($width-1))
        {
            push @{ $char_positions{substr($line, 1+$x, 1)} }, [$y, $x];
        }
    }
    continue
    {
        $y++;
    }

    return $class->new(
        {
            width => $width,
            height => $y,
            _char_positions => \%char_positions,
        }
    );
}

sub positions
{
    my ($self, $c) = @_;

    return $self->_char_positions()->{$c};
}

1;
