#!perl

package Class::Driver::TestX;

use Class::Driver;
use base qw(Class::Driver);

return 1;

sub driver_required { 1; }
sub driver_required_here { 0; }

sub new {
    my($class, %args) = @_;
    my $driver = $args{driver};
    return $class->driver_load($driver, %args);
}

sub driver_new {
    my($class, %args) = @_;
    return bless \%args, $class;
}
