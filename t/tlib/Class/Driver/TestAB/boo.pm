#!perl

package Class::Driver::TestAB::boo;

use strict;
use warnings;
use Class::Driver::TestAB;
use base qw(Class::Driver::TestAB);

return 1;

sub driver { "boo"; }
