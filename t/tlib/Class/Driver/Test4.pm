#!perl

package Class::Driver::Test4;

use strict;
use warnings;
use Class::Driver::Test3;
our @ISA = qw(Class::Driver::Test3 Class::Driver::Test99);

return 1;

package Class::Driver::Test99;

return 1;
