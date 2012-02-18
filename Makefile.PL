use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Mojolicious::Command::generate::i18n',
    AUTHOR       => 'Epifanov Ivan <isage@aumi.ru>',
    VERSION_FROM => 'lib/Mojolicious/Command/generate/i18n.pm',
    ABSTRACT     => 'Mojolicious app generator',
    PL_FILES     => {},
    PREREQ_PM    => {
        'Test::More'  => 0,
        'version'     => 0,
        'Mojolicious' => 2.0,
    },
    dist  => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
);
