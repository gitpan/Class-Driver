#!perl

package Class::Driver::Test::foo;

use strict;
use warnings;
use Data::Dumper;

use base q(Class::Driver::Test);

return 1;

sub driver {
    return "foo";
}

sub foo {
    return "foo";
}
