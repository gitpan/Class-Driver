#!perl

package Class::Driver::Test5;

use strict;
use warnings;
use Class::Driver::Test4;
use Class::Driver::Test5A;
our @ISA = qw(Class::Driver::Test5A Class::Driver::Test4);

return 1;
