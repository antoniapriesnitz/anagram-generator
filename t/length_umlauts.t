use Test::More;
use Data::Dumper;
use Length_Umlauts;

use_ok("Length_Umlauts");

#my $cc = Coda_Cluster->new();
#isa_ok($cc, "Coda_Cluster");

can_ok('Length_Umlauts', 'len');

#ok(Foo::Bar::is_positive(1), "1 is a positive number");
is(Length_Umlauts::len("ohneumlaut"), 10, "Correct word length for 'ohneumlaut'");
is(Length_Umlauts::len("mädchen"), 7, "Correct word length for 'mädchen'");
is(Length_Umlauts::len("fuß"), 3, "Correct word length for 'fuß'");
is(Length_Umlauts::len("füße"), 4, "Correct word length for 'füße'");

#diag Dumper $cc;
#
#foreach (@{$cc->elements}) {
#   diag "Element: $_";
#}
#
done_testing();
