package Games::Nurikabe::Solver::Constants;

use warnings;
use strict;

use base 'Exporter';

=head1 NAME

Games::Nurikabe::Solver::Constants - export constants.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Games::Nurikabe::Solver::Constants;

    # Do something with $NK_UNKNOWN , $NK_BLACK and $NK_WHITE .

=head1 FUNCTIONS

=cut

our $NK_UNKNOWN = 0;
our $NK_WHITE = 1;
our $NK_BLACK = 2;

our @EXPORT_OK = (qw($NK_BLACK $NK_WHITE $NK_UNKNOWN));
our @EXPORT = (@EXPORT_OK);

=head1 AUTHOR

Shlomi Fish, C<< <shlomif at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-games-nurikabe-solver at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Nurikabe-Solver>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Games::Nurikabe::Solver::Constants


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Games-Nurikabe-Solver>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Games-Nurikabe-Solver>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Games-Nurikabe-Solver>

=item * Search CPAN

L<http://search.cpan.org/dist/Games-Nurikabe-Solver>

=item * Version control repository:

L<http://svn.berlios.de/svnroot/repos/fc-solve/nurikabe-solver/trunk/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Shlomi Fish, all rights reserved.

This program is released under the following license: MIT/X11 Licence. 

=cut

1; # End of Games::Nurikabe::Solver
