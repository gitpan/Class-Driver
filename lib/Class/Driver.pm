package Class::Driver;

use 5.006;
use strict;
use warnings;
use Carp qw(croak confess);
use Class::Clone qw(class_clone class_subclass);
use Symbol::Table;

our $VERSION = '0.001';

return 1;

## PUBLIC

sub driver_derived { 1; }

sub driver { 0; }

sub driver_heiarchy { 0; }

sub driver_stub { 0; }

sub driver_base { 0; }

sub driver_required { 0; }

sub driver_required_here { 0; }

sub driver_package_name {
    my($class, $driver) = @_;
    my $class = ref($class) ? ref($class) : $class;
    if($class->driver && $class->driver eq $driver) {
        return $class;
    } elsif($class->driver) {
        croak "driver_package_name('$driver') called on $class which is a driver for ", $class->driver, "!";
    } else {
        return $class->driver_sane_package(join('::', $class, $driver));
    }
}

sub driver_load {
    my($class, $driver, @args) = @_;
    
    if(my $package = $class->_driver_create($driver)) {
        return $package->driver_new(@args);
    } else {
        return $class->_driver_load_base_class(@args);
    }
}

sub driver_has_driver {
    my($class, $driver) = @_;
    
    if($class->_driver_use($driver)) {
        return 1;
    }
    
    return $class->driver_has_superdriver($driver);
}

sub driver_has_superdriver {
    my($class, $driver) = @_;
    
    if($class->driver) {
        return $class->_driver_has_supersuperdriver($driver);
    } else {
        foreach my $isa ($class->_driver_isa($class)) {
            if($isa->can('driver_derived') && $isa->driver_has_driver($driver)) {
                return 1;
            }
        }

        return 0;
    }
}

sub driver_sane_package {
    my($class, $package) = @_;
    if($package !~ m{\A[a-zA-Z0-9_:]+\Z}) {
        croak qq{Bad package name "$package"};
    } elsif(eval "package $package; 1;") {
        return $package;
    } else {
        croak qq{Failed to create "$package": $@};
    }
}

## PRIVATE

sub _driver_load_base_class {
    my($class, @args) = @_;
    if($class->driver_required) {
        croak "$class requires a driver";
    } else {
        return $class->driver_new(@args);
    }
}

sub _driver_use {
    my($class, $driver) = @_;
    
    my $package = $class->driver_package_name($driver);
    if($package->can('driver_derived')) {
        return $package;
    } else {
        eval "use $package; 1;";
    
        if(my $error = $@) {
            if($error =~ m{^Can't locate .+? in \@INC }) {
                if($class->driver_required_here) {
                    croak "$class requires an immediate driver";
                } else {
                    return;
                }
            } else {
                croak $@;
            }
        } else {
            return $package;
        }
    }
}

sub _driver_isa {
    my($class, $package, @newisa) = @_;
    my $table = Symbol::Table->New('ARRAY', $package);
    my @isa = ();
    
    if($table->{ISA}) {
        @isa = @{$table->{ISA}};
    }
    
    if(@_ > 2) {
        $table->{ISA} = \@newisa;
    }
    
    return @isa;
}

sub _driver_has_supersuperdriver {
    my($class, $driver) = @_;

    foreach my $isa ($class->_driver_isa($class)) {
        if($isa->can('driver_derived') && $isa->driver_has_superdriver($driver)) {
                return 1;
        }
    }
    
    return 0;
}

sub _driver_sub {
    my($class, $method, $sub) = @_;
    my $table = Symbol::Table->New('CODE', $class);
    {
        no warnings 'redefine';
        $table->{$method} = $sub;
    }
    return $sub;
}

sub _driver_create_stub {
    my($class, $driver) = @_;

    my $package = $class->driver_package_name($driver);
    
    if(my $sub = $package->can('driver_derived')) {
        croak "package $package is already a driver class for ", $package->$sub, "!";
    }

    if($class->driver_has_superdriver($driver)) {
        class_subclass($class, $package);
        $package->_driver_sub('driver', sub { return $driver; });
        $package->_driver_sub('driver_stub', sub { return 1; });
        return $package;
    } else {
        return $class;
    }
}

sub _driver_base_name {
    my $class = shift;
    return $class->driver_sane_package(join('::', $class, '_base'));
}

sub _driver_create_base {
    my $class = shift;
    my $driver = $class->driver
        or confess "driver_create_base called on non-driver $class!";
    
    my $package = $class->_driver_base_name;
    if($package->can('driver_derived')) {
        return $package;
    }
    
    my(@isa, $isa);
    foreach $isa ($class->_driver_isa($class)) {
        if($isa->can('driver_derived')) {
            class_clone($isa, $package);
            push(@isa, $isa->_driver_isa($isa));
        } else {
            push(@isa, $isa);
        }
    }
    
    my @newisa;
    
    while($isa = shift(@isa)) {
        if($isa->can('driver_derived')) {
            if(my $superdriver = $isa->_driver_create($driver)) {
                push(@newisa, $superdriver);
            } else {
                push(@newisa, $isa);
            }
        } else {
            push(@newisa, $isa);
        }
    }

    $package->_driver_isa($package, @newisa, $class);
    $package->_driver_sub('driver_base', sub { 1; });

    return $package;
}

sub _driver_heiarchy_name {
    my $class = shift;
    return $class->driver_sane_package(join('::', $class, '_heiarchy'));
}

sub _driver_create_heiarchy {
    my $class = shift;
    my $driver = $class->driver
        or confess "driver_create_heiarchy called on non-driver $class!";
    
    if($class->driver_heiarchy) {
        croak "driver_create_heiarchy called on heiarchy!";
    }
    
    my $package = $class->_driver_heiarchy_name;
    
    if($package->can('driver_heiarchy')) {
        return $package;
    }
    
    my $base = $class->_driver_create_base;
    class_clone($class, $package);
    $package->_driver_isa($package, $base);
    $package->_driver_sub('driver_heiarchy', sub { 1; });
    return $package;
}

sub _driver_create {
    my($class, $driver) = @_;
    if($class->driver) {
        if($class->driver ne $driver) {
            croak qq{$class asked for $driver, but already is }, $class->driver;
        } else {
            if($class->driver_heiarchy) {
                return $class;
            } elsif($class->driver_has_superdriver($driver)) {
                return $class->_driver_create_heiarchy;
            } else {
                return $class;
            }
        }
    } else {
        my $package;

        if($package = $class->_driver_use($driver)) {
            if($package->driver) {
                return $package->_driver_create($driver);
            } else {
                croak qq{Got non-driver class "$package" for $driver in $class!};
            }
        } else {
            if(($package = $class->_driver_create_stub($driver)) ne $class) {
                return $package->_driver_create($driver);
            } else {
                return;
            }
        }
    }
}
