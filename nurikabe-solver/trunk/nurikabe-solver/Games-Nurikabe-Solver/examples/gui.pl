#!/usr/bin/perl

use strict;
use warnings;

package NurikabeCanvas;

use Wx ':everything';
use Wx::Event qw(EVT_PAINT);
use base 'Wx::Window';

my $cell_width = 30;
my $cell_height = 30;

sub new
{
    my $class = shift;
    my $parent = shift;

    my $self = $class->SUPER::new(
        $parent,
        wxID_ANY(),
        Wx::Point->new(0, 0),
        Wx::Size->new($cell_width*9, $cell_height*9)
    );

    EVT_PAINT( $self, \&OnPaint );

    return $self;
}

sub OnPaint
{
    my $self = shift;

    my $dc = Wx::PaintDC->new($self);

    my $black_pen = Wx::Pen->new(Wx::Colour->new(0,0,0), 3, wxSOLID());

    $dc->SetPen( $black_pen );

    for my $y (0 .. 8)
    {
        for my $x (0 .. 8)
        {
            $dc->SetBrush(wxGREY_BRUSH());
            $dc->DrawRectangle($cell_width*$x, $cell_height*$y, $cell_width, $cell_height);
        }
    }
}

package NurikabeApp;

use base 'Wx::App';
use Wx ':everything';

sub OnInit
{
        my( $this ) = @_;

        my $frame = Wx::Frame->new( undef, -1, 'wxPerl', wxDefaultPosition, [ 200, 100 ] );
        $frame->{board} = NurikabeCanvas->new($frame);
        $frame->Show( 1 );
}

package main;

NurikabeApp->new()->MainLoop();

