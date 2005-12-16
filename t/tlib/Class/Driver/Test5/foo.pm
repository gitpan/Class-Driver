#!perl

package Class::Driver::Test5::foo;

use strict;
use warnings;
use Class::Driver::Test5;
our @ISA = qw(Class::Driver::Test5::foo99 Class::Driver::Test5);

return 1;

sub driver {
    return 'foo';
}

sub bar {
    return 'bar';
}

package Class::Driver::Test5::foo99;

return 1;
