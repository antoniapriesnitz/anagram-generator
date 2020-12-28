use Test::More;
use Data::Dumper;
use Read_Language_Data;

use_ok("Read_Language_Data");

#my $cc = Coda_Cluster->new();
#isa_ok($cc, "Coda_Cluster");

can_ok('Read_Language_Data', 'sort_clusters');

#ok(Foo::Bar::is_positive(1), "1 is a positive number");
$f = "german.txt";
#ok(Read_Language_Data::sort_clusters($f), returned output?);

#diag Dumper $cc;
#
#foreach (@{$cc->elements}) {
#   diag "Element: $_";
#}
#
done_testing();
