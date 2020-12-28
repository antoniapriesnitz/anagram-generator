#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Length_Umlauts' ) || print "Bail out!\n";
}

diag( "Testing Length_Umlauts $Length_Umlauts::VERSION, Perl $], $^X" );
