package Games::ABC_Path::Solver::Move::LettersNotInVicinity;

use strict;
use warnings;

use base 'Games::ABC_Path::Solver::Move';

=head1 NAME

Games::ABC_Path::Solver::Move::LettersNotInVicinity - an ABC Path move
that indicates that letters are not in vicinity to one another in a certain
cell.

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';

=head1 SYNOPSIS

    use Games::ABC_Path::Solver::Move::LettersNotInVicinity;

    my $move = Games::ABC_Path::Solver::Move::LettersNotInVicinity->new(
        {
            vars =>
            {
                target => 6
                coords => [1,2],
                source => 5,
            },
        }
    );

=head1 DESCRIPTION

This is a move that indicates that the C<'letter'> has the last remaining cell
as C<'coords'>.

=cut

sub _get_text {
    my $self = shift;

    my $text = $self->_format;

    $text =~ s/%\((\w+)\)\{(\w+)\}/
        $self->_expand_format($1,$2)
        /ge;

    return $text;
}

sub _format {
    return "%(target){letter} cannot be at %(coords){coords} due to lack of vicinity from %(source){letter}.";
}

1;

