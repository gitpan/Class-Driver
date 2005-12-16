use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Class::Driver',
    VERSION_FROM      => 'lib/Class/Driver.pm', # finds $VERSION
    PREREQ_PM         => {
        'Symbol::Table'         =>  1.01,
        'B::Deparse'            =>  0.59,
        'Class::Clone'          =>  0.02,
        'Test::Exception'       =>  0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Class/Driver.pod', # retrieve abstract from module
       AUTHOR         => 'Tyler MacDonald <japh@crackerjack.net>') : ()),
);
