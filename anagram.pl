#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max);

my ($file, $word) = @ARGV;
my $length = length($word);
print "Input word: $word, length = $length\n";

#my @single_vowels = (); # a, e, i, o, u, ä
#my @vowel_clusters = (); # aa, ai, ah, äh, au
my %all = ();
my @vowels = (); # solitary or clusters
#my @double_consonants = (); # bb, cc, dd, ck, tz (not initial, only after vowels)
my @single_consonants = (); # b, c, d, sch, ch (do we need this? same as line below)
my @onset_coda_ambisyllabic = (); # bl, schl, st, pfl, pf 
my @not_coda = (); # fr, spr, chr, schm, schn, str 
my @not_onset = (); # rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, cht 

open(DATA, "<$file") or die "Couldn't open file!";

while(<DATA>) {
    $_ =~ s/\n//;
    if (exists $all{$_}){
    	print "duplicate: $_\n";
        next;
    }	
    $all{$_} = 1;
    if (/^(a|e|i|o|u|ä|ö|ü)/) {
	push(@vowels, $_);
    }
    elsif (/.+r\z/ or /sch(m|n)/) {
	push(@not_coda, $_);
    }  
    elsif (/([a-z])\1/ or /(ck|tz)/ or /.+(st|.t|m|l|n)\z/) {
	push(@not_onset, $_);
    }  
    else {#(/.+(l|t|f)\z/) {
	push(@onset_coda_ambisyllabic, $_);
    }  
}

close(DATA) or die "Could not close file properly!";

#print "Vowels:\n@vowels\n";
#print "Double consonants and other noninital consonant clusters:\n@not_onset\n";
#print "Clusters at the start, the end, or the middle of a word, sometimes belong to two successive syllables :\n@onset_coda_ambisyllabic\n";
#print "Clusters that need a vowel as successor :\n@not_coda\n";
##print "noninitial clusters ending with z or k :\n@cluster_notinitial\n";

# Counts the occurences of all letters of a word
# Returns a hash of the form letter: occurences
sub letter_count {
    #print "input = @_\n";
    my $w = shift;
    #print "w in letter_count: $w\n";
    my @letters = split(//, $w);
    my %letter_count;
    for(@letters){
        if (exists $letter_count{$_}) {
       	    $letter_count{$_} += 1;
        }
        else {
	    $letter_count{$_} = 1;
        }
    }
    return %letter_count;
}

# Takes references of a list of letter clusters and a hash of letter occurences as parameters
# Counts how many instances of each cluster can be generated with the given number of letters
# Returns a hash containing the cluster: instances pairs
sub cluster_count{
    my ($clusters_ref, $count_ref) = @_;
    my @clusters = @{$clusters_ref};
    my %count = %{$count_ref};
    #my $length = scalar(@_);
    #print "length of \@_ = $length\n";
    #print "\@_ in cluster_count = @_\n";
    #print "clusters : @clusters\n";
    #print "count in cluster_count:\n";
    #print " $_ : $count{$_} \n" for keys(%count);
    my %item_count;
    my $min = 0;
    #for(my $i=0; $i < scalar(@clusters); $i++){
    foreach my $c (@clusters) {
        #my $c = $clusters[$i];
        #print "c in cluster_count = $c\n";
	    my %item_letter_count = letter_count($c);
        #print "$_ : $item_letter_count{$_} \n" for keys(%item_letter_count);
	    my $min = 100;
	    foreach my $letter (keys %item_letter_count){
            #print "letter: $letter\n";
	        if (not exists($count{$letter})) {
		        $min = 0;
	            last;
	        }else {
	        	if ( int($count{$letter}/$item_letter_count{$letter}) < $min) {
		        $min = int($count{$letter}/$item_letter_count{$letter});
		        }
            }
        }
	    if ($min == 0 or $min == 100) {
	        next;
	    } else {
            #$item_count{$clusters[$i]} = $min;
            $item_count{$c} = $min;
            #print "$clusters[$i] : $item_count{$clusters[$i]}\n";
        }
    }
    return %item_count;
}

# Takes a word and counts the occurences of vowels, consonants and the letter y
# Returns the maximum number of syllables the anagram may have
sub calc_syllables {
    #print "\$_ = $_\n";
    my $w = shift;   
    my @letters = split(//, $w);
    #print "w in calc_syllables: $w\n";
    my $single_vowels = 0;
    my $single_consonants = 0;
    my $y_count = 0;
    for(@letters) {
        if (/a|e|i|o|u|ä|ö|ü/) {
            $single_vowels += 1;
        } elsif (/y/) {
            $y_count += 1;
        } else {
            $single_consonants += 1;
        }
    }
    #print "number of single vowels = $single_vowels\n";
    #print "number of single_consonants = $single_consonants\n";
    #print "number of letter y = $y_count\n";
    #    if ($single_vowels <= $single_consonants) {
    #$syllables = $single_vowels + $y_count;
    #}
    #else {
    my $syllable = $single_vowels + $y_count;
    return $syllable;
}

# Takes a cluster of letters and hash of letter: occurrences pairs as parameters
# Subtracts 1 from each letter that is used by the cluster
# Returns the changed hash
sub countdown_letters {
    my ($cluster, $letter_instances_ref) = @_;
    #my $cluster = ${$cluster_ref};
    my %letter_instances = %{$letter_instances_ref};
    my @letters = split(//, $cluster);
    for(@letters) {
        if ($letter_instances{$_} == 0) {
            %letter_instances = ();
            last;
        } else {
            $letter_instances{$_} -= 1;
        }
    }
    return %letter_instances;
}


my %occurrences = letter_count($word);
print "occurrences: ";
print "$_: $occurrences{$_} \t" for keys(%occurrences);
print "\n";

my %syllable_count = ();
my $syllables = calc_syllables($word);
print "*************************************************\n";
print "Maximum number of syllables = $syllables\n";
$syllable_count{"|"} = $syllables;
print "$_: $syllable_count{$_}\t" for keys(%syllable_count);
print "\n";

my %vowel_count = cluster_count(\@vowels, \%occurrences);
print "*************************************************\n";
print "Vowels and vowel clusters in input word :\n";
print "$_: $vowel_count{$_}\t" for keys(%vowel_count);
print "\n";

my %not_coda_count = cluster_count(\@not_coda, \%occurrences);
print "*************************************************\n";
print "Not coda clusters in input word :\n";
print "$_: $not_coda_count{$_}\t" for keys(%not_coda_count);
print "\n";

my %not_onset_count = cluster_count(\@not_onset, \%occurrences);
print "*************************************************\n";
print "Not onset clusters in input word :\n";
print "$_: $not_onset_count{$_}\t" for keys(%not_onset_count);
print "\n";

my %onset_coda_ambisyllabic_count = cluster_count(\@onset_coda_ambisyllabic, \%occurrences);
print "*************************************************\n";
print "Onset coda and ambisyllabic clusters in input word :\n";
print "$_: $onset_coda_ambisyllabic_count{$_}\t" for keys(%onset_coda_ambisyllabic_count);
print "\n";

my @vertices = (\%syllable_count, \%vowel_count, \%not_coda_count, \%onset_coda_ambisyllabic_count, \%not_onset_count);
print "vertices = @vertices\n";
print "vertices[0] = $vertices[0]\n";
#print "\@vertices = syllables, vowels, not_coda, onset_coda_ambisyllabic, not_onset\n";
my %adjacency_lists = (0 => [1,2,3], 1 => [0,2,3,4], 2 => [1], 3 => [0,1], 4 => [0,1]);
#print "adjacency lists:\n";
#print "$_: @{$adjacency_lists{$_}}\t" for keys(%adjacency_lists);
#print "\n";

my @adjacency_matrix = qw/0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0/;
my $len = scalar(@adjacency_matrix);
#print "Length of adjacency_matrix = $len\n";

#my $test = "nnn";
#my %test_count = countdown_letters($test, \%occurrences);
#print "$_ : $test_count{$_}\n" for keys(%test_count);

my @anagrams = ();

sub concatenate {
    my ($word_length, $anagram_length, $vertex, $anagram_ref, $letter_count_ref) = @_;
    my @anagram = @{$anagram_ref};
    my %letter_count = %{$letter_count_ref};
    if ($anagram_length == $word_length) {
        my $anagram = join('-', @anagram);
        push(@anagrams, $anagram);
        print "$anagram\n";
        return;
    }
    my $row = $vertex * 5;
    print "row = $row\n";
    for(my $i=0; $i<5; $i++) {
        print "i = $i\n";
        if ($adjacency_matrix[$row + $i] == 1) {
            my %vertex = %{$vertices[$i]};
            if (%vertex) {
                foreach my $key (keys %vertex) {
                    my %downcount = countdown_letters($key, \%letter_count);
                    if (%downcount) {
                        push(@anagram, $key);
                        if ($key != '|') {
                            $anagram_length += length($key);
                        }
                        concatenate($word_length, $anagram_length, $i, \@anagram, \%letter_count);
                    } else {
                        print "Not enough letters for cluster $key!\n";
                    }
                }
            } else {
                print "No clusters in vertex $vertex\n";
            }
        }
    }
    return;
}

my @anagram = ();

concatenate($length, 0, 0, \@anagram, \%occurrences);
print "Anagrams: @anagrams\n";
