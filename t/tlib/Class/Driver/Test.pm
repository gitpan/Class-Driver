#!perl

package Class::Driver::Test;

use strict;
use warnings;
use Class::Driver;
use base qw(Class::Driver);

return 1;

sub driver_required { 1; }

sub driver_required_here { 1; }

sub driver_new {
    my($class, %args) = @_;
    return bless \%args, $class;
}

sub new {
    my($class, %args) = @_;
    $class = ref($class) if ref($class);
    my $driver = $args{driver};
    return $class->driver_load($driver, %args);
}

sub foo {
    die "foo must be overridden";
}

sub isatree {
    my($self, $class) = @_;

    my @rv;
    no strict 'refs';
    my @isa = @{"$class\::ISA"};
    use strict 'refs';
    
    foreach my $isa (@isa) {
        push(@rv, $isa, [ $self->isatree($isa) ]);
    }
    
    return \@rv;
}
