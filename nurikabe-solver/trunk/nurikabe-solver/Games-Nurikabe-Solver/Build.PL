use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
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
