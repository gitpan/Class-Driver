#!perl

package Class::Driver::TestX::baz;

use strict;
use warnings;

use base q(Class::Driver::TestX);

return 1;

sub foo {
    return $invalid_variable;
}
