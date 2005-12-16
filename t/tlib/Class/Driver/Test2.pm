#!perl

package Class::Driver::Test2;

use strict;
use warnings;
use Class::Driver::Test;
use base qw(Class::Driver::Test);

return 1;

sub driver_required_here { 0; }
