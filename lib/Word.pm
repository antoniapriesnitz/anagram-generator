package Word;

use 5.006;
use strict;
use warnings;
use Moose;
use Data::Dumper;

has 'name' => (is => 'ro', isa => 'Str'); #hallo (for info)
has 'length' => (is => 'ro', isa => 'Int', builder => '_set_length');#5 (for info)
has 'unique_letters' => (is => 'ro', isa => 'Str'); #halo
has 'quantities' => (is => 'rw', isa => 'Array');#1121 (mask)
has 'letters' => (is => 'ro', isa => 'Hash', builder => '_count_letters');#h:1, a:1, l:2; 0:1

# takes a word and returns its length
# necessary for info because length($word) is inaccurate, umlauts are counted twice 
# and eszett is counted as eszett and as umlaut
# not used as termination condition in sub concatenate because there, length($word) is accurate
sub _set_length { 
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

# Counts the occurences of all letters of a word
# Returns a hash of the form letter: occurences
sub _count_letters {
    my $w = shift;
    my @letters = split(//, $w);
    my %letter_count;
    for(@letters){
        if (exists $letter_count{$_}) {
       	    $letter_count{$_} += 1;
        } else {
	        $letter_count{$_} = 1;
        }
    }
    return %letter_count;
}

# Takes references of a list of letter clusters and a hash of letter occurences as parameters
# Counts how many instances of each cluster can be generated with the given number of letters
# Returns a hash containing the cluster: instances pairs
sub _count_clusters{
    my ($clusters_ref, $count_ref) = @_;
    my @clusters = @{$clusters_ref};
    my %count = %{$count_ref};
    my @item_count;
    my $min = 0;
    foreach my $c (@clusters) {
	    my %item_letter_count = letter_count($c);
	    my $min = 100;
	    foreach my $letter (keys %item_letter_count){
	        if (not exists($count{$letter})) {
		        $min = 0;
	            last;
	        } else {
	        	if ( int($count{$letter}/$item_letter_count{$letter}) < $min) {
		        $min = int($count{$letter}/$item_letter_count{$letter});
		        }
            }
        }
	    if ($min == 0 or $min == 100) {
	        next;
	    } else {
            push(@item_count, $c);
        }
    }
    return @item_count;
}
1;
