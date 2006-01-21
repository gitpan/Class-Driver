#!/usr/bin/perl

use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Class::Driver',
    VERSION_FROM      => 'lib/Class/Driver.pm', # finds $VERSION
    PREREQ_PM         => {
        'Symbol::Table'     =>  1.01,
        'Class::Clone'      =>  0.05,
        'Test::Exception'   =>  0.20,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Class/Driver.pod', # retrieve abstract from module
       AUTHOR         => 'Tyler MacDonald <japh@crackerjack.net>') : ()),
);
