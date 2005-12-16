#!perl

package Class::Driver::TestX::foo;

use Class::Driver::TestX;
use Exporter;
use base qw(Class::Driver::TestX);

return 1;

sub driver { "foo"; }
