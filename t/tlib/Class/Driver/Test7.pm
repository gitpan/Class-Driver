#!perl

package Class::Driver::Test7;

use strict;
use warnings;
use Class::Driver::Test6;
use base q(Class::Driver::Test6);

return 1;

sub driver_required { 0; }
sub driver_required_here { 0; }

sub foo {
    my $self = shift;
    return join(' ', $self->SUPER::foo, 'foobie');
}
