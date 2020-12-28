#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Read_Language_Data' ) || print "Bail out!\n";
}

diag( "Testing Read_Language_Data $Read_Language_Data::VERSION, Perl $], $^X" );
