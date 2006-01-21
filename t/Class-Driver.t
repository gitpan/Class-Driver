#!perl

use strict;
use warnings;
use Test::More qw(no_plan);
use Test::Exception;
use lib 't/tlib';

use Class::Driver::Test;
use Class::Driver::Test5;
use Class::Driver::Test7;
use Class::Driver::TestB;
use Class::Driver::TestX;
use Class::Driver::TestAB;

my $foo;

ok(Class::Driver->driver_derived(), 'Class::Driver is driver derived');
ok(!Class::Driver->driver(), 'Class::Driver is not a driver');
ok(!Class::Driver->driver_hierarchy(), 'Class::Driver is not a hierarchy');
ok(!Class::Driver->driver_stub(), 'Class::Driver is not a stub');
ok(!Class::Driver->driver_base(), 'Class::Driver is not a base');
ok(!Class::Driver->driver_required(), 'Class::Driver does not require a driver');
ok(!Class::Driver->driver_required_here(), 'Class::Driver does not require an immediate driver');



throws_ok
    { $foo = Class::Driver::Test->new(driver => 'boo') }
    (
        qr/requires an immediate driver/,
        'driver_required_here cant find driver'
    );
    

lives_ok
    { $foo = Class::Driver::Test->new(driver => 'foo') }
    ('driver_required_here can find driver');

ok($foo, 'foo object exists');
ok($foo->isa('Class::Driver::Test::foo'), 'foo object is a foo driver');
ok($foo->isa('Class::Driver::Test'), 'foo object is a test object');
ok(!$foo->driver_stub, 'foo driver is not a stub');
is($foo->foo, 'foo', 'correct foo method');
ok(!$foo->can('bar'), 'no bar method');

lives_ok
    { $foo = Class::Driver::TestB->new(driver => 'boo') }
    ('!driver_required_here can find driver');

ok($foo, 'boo object exists');
ok($foo->isa('Class::Driver::TestB'), 'boo object is a testB object');
ok(!$foo->isa('Class::Driver::TestB::boo'), 'No stub needed, none created.');

ok($foo = Class::Driver::Test5->new(driver => 'foo'), 'Got a Test5 object');
ok($foo->can('bar'), 'bar method from Test5 available');
ok($foo->can('foo'), 'foo method from ::foo available');
ok($foo->can('baz'), 'baz method from Test5A available');
is($foo->foo, 'foo', 'correct foo method');
ok($foo->isa('Class::Driver::Test5::foo::_hierarchy'), 'Got hierarchy back from Test5');

ok($foo = $foo->new(driver => 'foo'), 'Got a another Test5::foo object');
throws_ok
    { $foo->new(driver => 'bar') }
    (
        qr/Class::Driver::Test5::foo::_hierarchy asked for bar, but already is foo/,
        "Can't get a bar object out of a foo object"
    );
    
ok($foo = Class::Driver::Test7->new(driver => 'foo'), 'Got a Test7 object');
ok($foo->can('bar'), 'bar method inherited');
ok($foo->can('baz'), 'baz method inherited');
ok($foo->can('foo'), 'foo method exists');
ok($foo->isa('Class::Driver::Test7::foo'), 'Test7 foo driver exists');
ok(Class::Driver::Test7::foo::driver_stub(), 'Test7 foo driver is a stub');
dies_ok
    { Class::Driver::foo::driver_stub() }
    ('No stub was created for Class::Driver base class');
ok(Class::Driver::Test2::foo::_hierarchy->can('foo'), 'base can foo');
is(Class::Driver::Test2::foo::_hierarchy->foo, 'foo', 'correct foo method');
is($foo->foo, 'foo foobie', 'foo method calling SUPER:: works');

ok(Class::Driver::Test5::foo->isa('Class::Driver::Test'), 'Test5::foo is a Test');
ok(Class::Driver::Test5::foo->isa('Class::Driver::Test5'), 'Test5::foo is a Test5');
is_deeply(
    \@Class::Driver::Test5::foo::_hierarchy::ISA,
    [ 'Class::Driver::Test5::foo::_base' ], 
    'Test5::foo::_hierarchy has correct parents'
);
is_deeply(
    \@Class::Driver::Test5::foo::_base::ISA,
    [
        'Class::Driver::Test5::foo99',
        'Class::Driver::Test5A',
        'Class::Driver::Test4::foo::_hierarchy',
        'Class::Driver::Test5::foo'
    ], 
    'Test5::foo::_base has correct parents'
);
ok(Class::Driver::Test5::foo::_base->driver_base, 'Test5::foo::_base is a base class');
is(
    Class::Driver::Test5::foo->_driver_create_base(),
    'Class::Driver::Test5::foo::_base',
    'We get base class from Test5::foo'
);
ok(
    !UNIVERSAL::isa('Class::Driver::Test5::foo', 'Class::Driver::Test::foo'),
    'Test5::foo is not a Test::foo'
);
ok(
    UNIVERSAL::isa(
        'Class::Driver::Test5::foo::_base', 'Class::Driver::Test::foo'
    ),
    'Test5::foo::_base is a Test::foo'
);
ok(Class::Driver::driver_has_superdriver('Class::Driver::Test5::foo', 'foo'), 'There is a foo above Test5:foo');
ok(Class::Driver::driver_has_superdriver('Class::Driver::Test5', 'foo'), 'There is a foo above Test5');
ok(Class::Driver::_driver_has_supersuperdriver('Class::Driver::Test5::foo', 'foo'), 'There is a foo above above Test5:foo');
ok(Class::Driver::_driver_has_supersuperdriver('Class::Driver::Test5', 'foo'), 'There is a foo above above Test5');
# Good reason not to name methods after drivers...
ok(!Class::Driver::driver_has_superdriver('Class::Driver::Test::foo', 'foo'), 'There is no foo above Test');
ok($foo = Class::Driver::Test->new(driver => 'foo'), 'Create a foo');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test::foo'), 'foo is a foo');
ok($foo = Class::Driver::Test7->new(driver => 'foo'), 'Create a Test7::foo');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test::foo'), 'Test7::foo is a Test::foo');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test5::foo'), 'Test7::foo is a Test5::foo');

ok(Class::Driver::Test5::foo::_hierarchy->isa('Class::Driver::Test4::foo'), 'Test4::foo was created');
ok($foo = Class::Driver::Test6->new(driver => 'foo'), 'Create a Test6::foo');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test::foo'), 'Test6::foo is a Test::foo');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test5::foo'), 'Test6::foo is a Test5::foo');
ok(UNIVERSAL::isa($foo, 'Exporter'), 'Test6::foo is a Exporter');
ok(UNIVERSAL::isa($foo, 'Class::Driver::Test5A'), 'Test6::foo is a Test5A');

    
throws_ok
    { $foo = Class::Driver::Test6->new(driver => 'bar'); }
    (
        qr/Class::Driver::Test requires an immediate driver/,
        "Can't load invalid driver"
    );

throws_ok
    { $foo = Class::Driver::Test7->new(driver => 'bar'); }
    (
        qr/Class::Driver::Test requires an immediate driver/,
        "Subclass enforces driver requirement"
    );

throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'bar'); }
    (
        qr/Class::Driver::TestX requires a driver/,
        "driver_required, but not here, still fails"
    );
    
ok(($foo = Class::Driver::TestX->new(driver => 'foo')), 'Got a driver object');
ok($foo->isa('Class::Driver::TestX::foo'), 'Got correct driver object');
ok(!$foo->driver_stub, 'Driver object is not a stub');
ok(!$foo->driver_hierarchy, 'Driver object is not a hierarchy');

throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'baz'); }
    (
        qr/Global symbol "\$invalid/,
        "Loading a bad driver fails"
    );

throws_ok
    { Class::Driver::TestX->_driver_create_stub('foo') }
    (
        qr/package Class::Driver::TestX::foo is already a driver class/,
        "Can't overwrite a driver with a stub"
    );

throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'bew'); }
    (
        qr/Got non-driver class/,
        "Loading a bad driver fails"
    );

throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'hmm'); }
    (
        qr/Class::Driver::TestX::hmm asked for hmm, but already is foo/,
        "Can't load a driver that's confused about who it is"
    );

throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'foo;bar'); }
    (
        qr/Bad package name "Class::Driver::TestX::foo;bar"/,
        "Can't load a driver with a bad characters in its name"
    );
    
throws_ok
    { $foo = Class::Driver::TestX->new(driver => 'foo:::bar'); }
    (
        qr/syntax error at .* near "package Class::Driver::TestX::foo:::"/,
        "Can't load a driver with a bad characters in its name"
    );
    
throws_ok
    { Class::Driver::Test5::foo::_hierarchy->_driver_create_hierarchy(); }
    (
        qr/driver_create_hierarchy called on hierarchy!/,
        "Can't make a hierarchy out of a hierarchy"
    );
    
throws_ok
    { Class::Driver::Test5->_driver_create_hierarchy(); }
    (
        qr/driver_create_hierarchy called on non-driver Class::Driver::Test5!.*\n.*throws_ok/ms,
        "Trying to create a hierarchy on a non-driver causes full backtrace"
    );
    
ok($foo = Class::Driver::TestAB->new(driver => 'bum'), 'Created a TestAB');
is(ref($foo), 'Class::Driver::TestAB', 'Optional, absent driver ignored');

ok($foo = Class::Driver::TestAB->new(driver => 'boo'), 'Created a TestAB');
is(ref($foo), 'Class::Driver::TestAB::boo', 'Optional, present driver used');

is($foo->driver_package_name('boo'), ref($foo), 'Got our own package name for driver_package_name');
throws_ok
    { $foo->driver_package_name('foo') }
    (
        qr/\Qdriver_package_name('foo') called on Class::Driver::TestAB::boo which is a driver for boo!\E/,
        'driver_package_name mismatch error'
    );
