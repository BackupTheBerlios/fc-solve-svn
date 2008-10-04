#!/usr/bin/perl

use strict;
use warnings;

use blib;

package NurikabeCanvas;

use Wx ':everything';
use Wx::Event qw(EVT_PAINT);
use base 'Wx::Window';

use Games::Nurikabe::Solver::Board;
use Games::Nurikabe::Solver::Cell qw($NK_UNKNOWN $NK_WHITE $NK_BLACK);

my $cell_width = 30;
my $cell_height = 30;

sub slurp
{
    my $filename = shift;
    {
        local $/;
        open my $in, "<", $filename;
        my $text = <$in>;
        close($in);
        return $text;
    }
}

sub assign_board
{
    my $self = shift;
    my $filename = shift;

    $self->{board} = Games::Nurikabe::Solver::Board->load_from_string(
        slurp($filename),
    );

    $self->{numbers} = +{};
    foreach my $island (@{$self->{board}->_islands()})
    {
        my $cell = $island->known_cells->[0];
        $self->{numbers}->{join(",", @$cell)} = $island->order();
    }
}

sub new
{
    my $class = shift;
    my $parent = shift;

    my $self = $class->SUPER::new(
        $parent,
        wxID_ANY(),
        Wx::Point->new(20, 20),
        Wx::Size->new($cell_width*9, $cell_height*9)
    );

    EVT_PAINT( $self, \&OnPaint );

    return $self;
}

sub OnPaint
{
    my $self = shift;

    my $dc = Wx::PaintDC->new($self);

    my $black_pen = Wx::Pen->new(Wx::Colour->new(0,0,0), 4, wxSOLID());

    $dc->SetPen( $black_pen );

    for my $y (0 .. 8)
    {
        for my $x (0 .. 8)
        {
            my $status = $self->{board}->get_cell([$y,$x])->status();

            if ($status eq $NK_UNKNOWN)
            {
                $dc->SetBrush(wxGREY_BRUSH());
            }
            elsif ($status eq $NK_WHITE)
            {
                $dc->SetBrush(wxWHITE_BRUSH());
            }
            elsif ($status eq $NK_BLACK)
            {
                $dc->SetBrush(wxBLACK_BRUSH());
            }

            my $p_x = $cell_width*$x;
            my $p_y = $cell_height*$y;
            $dc->DrawRectangle(
                $p_x, $p_y, $cell_width, $cell_height
            );

            if (exists($self->{numbers}->{join(",",$y,$x)}))
            {
                my $s = $self->{numbers}->{join(",",$y,$x)};

                my $c_x = $p_x + $cell_width/2;
                my $c_y = $p_y + $cell_height/2;

                my ($w, $h) = $dc->GetTextExtent($s);
                $dc->DrawText(
                    $s,
                    $c_x - $w/2,
                    $c_y - $h/2,
                );
            }
        }
    }
}

package NurikabeApp;

use base 'Wx::App';
use Wx ':everything';

sub new
{
    my ($class, $filename) = @_;

    my $self = $class->SUPER::new();

    $self->assign_filename($filename);

    return $self;
}

sub OnInit
{
    my( $self ) = @_;

    my $frame = Wx::Frame->new( undef, -1, 'wxPerl', wxDefaultPosition, [ 200, 100 ] );

    my $sizer = Wx::BoxSizer->new(wxHORIZONTAL());

    $frame->SetSizer($sizer);

    $frame->{board} = NurikabeCanvas->new($frame);
    $sizer->Add($frame->{board}, 1, wxALL(), 10);
    $frame->{list} = Wx::ListBox->new(
        $frame,
        -1,
        wxDefaultPosition(),
        wxDefaultSize(),
        [qw(
            surround_island
            surrounded_by_blacks
            adjacent_whites
            distance_from_islands
        )]
    );
    $sizer->Add($frame->{list}, 1, wxALL(), 10);

    $frame->SetSize(Wx::Size->new(600,400));
    $frame->Show( 1 );

    $self->{frame} = $frame;

    return 1;
}

sub assign_filename
{
    my ($self, $filename) = @_;

    $self->{filename} = $filename;
    $self->{frame}->{board}->assign_board($self->{filename});

    return;
}

package main;

NurikabeApp->new(shift(@ARGV))->MainLoop();

