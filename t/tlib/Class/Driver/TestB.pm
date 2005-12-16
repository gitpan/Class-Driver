#!perl

package Class::Driver::TestB;

use strict;
use warnings;
use Class::Driver;
use base q(Class::Driver);

return 1;

sub driver_required { 0; }

sub driver_required_here { 0; }

sub driver_new {
    my($class, %args) = @_;
    return bless \%args, $class;
}

sub new {
    my($class, %args) = @_;
    my $driver = $args{driver};
    return $class->driver_load($driver, %args);
}

sub foo {
    die "foo must be overridden";
}
