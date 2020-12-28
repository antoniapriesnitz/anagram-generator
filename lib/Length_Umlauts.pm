package Length_Umlauts;

use 5.006;
use strict;
use warnings;
use Data::Dumper;

# takes a word and returns its length
# necessary for info because length($word) is inaccurate, umlauts are counted twice 
# and eszett is counted as eszett and as umlaut
# not used as termination condition in sub concatenate because there, length($word) is accurate
sub len { 
    my $w = shift; 
    my @letters = split(//, $w);
    my $count = 0;
    my $umlauts = 0;
    my $eszett = 0;
    for(@letters) {
        if (/[\x9f]/) {
            $eszett += 1;
            $umlauts -= 1;
        } elsif (/[äöü]/) {
            $umlauts += 1;
        } else {
            $count += 1;
        }
   }
   return $count + $eszett + $umlauts/2;
}
1;
