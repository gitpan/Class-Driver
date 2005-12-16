#!perl

package Class::Driver::Test6;

use strict;
use warnings;
use Class::Driver::Test5;
use Exporter;
use base qw(Exporter Class::Driver::Test5);

our @EXPORT_OK = qw(hello);

return 1;

sub hello {
    return "hi";
}
