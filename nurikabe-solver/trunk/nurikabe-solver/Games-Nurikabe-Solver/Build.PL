# This file is under the MIT X11 License:
# http://www.opensource.org/licenses/mit-license.php

use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Test::Run::Builder;

my $builder = Test::Run::Builder->new(
    module_name         => 'Games::Nurikabe::Solver',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/Games/Nurikabe/Solver.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires =>
    {
        'Class::Accessor' => 0,
    },
    add_to_cleanup      => [ 'Games-Nurikabe-Solver-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
