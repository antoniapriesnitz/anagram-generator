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
    #my $cl = $_;
    #print "word in letter_count: $word\n";
    my @letters = split(//, $word);
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
    #print "length of input array = $length\n";
    #print "input array = @_\n";
    #print "clusters : @clusters\n";
    #print "count in cluster_count:\n";
    #print " $_ : $count{$_} \n" for keys(%count);
    my %item_count;
    my $min = 0;
    for(my $i=0; $i < scalar(@clusters); $i++){
        $word = $clusters[$i];
        #print "word = $word\n";
	    my %item_letter_count = letter_count();
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
	    if ($min == 0) {
	        next;
	    } else {
            $item_count{$clusters[$i]} = $min;
            #print "$clusters[$i] : $item_count{$clusters[$i]}\n";
        }
    }
    return %item_count;
}

# Takes a word and counts the occurences of vowels, consonants and the letter y
# Returns the maximum number of syllables the anagram may have
sub calc_syllables {
    #print "\$_ = $_\n";
    my @letters = split(//, $word);
    print "word in calc_syllables: $word\n";
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
    print "number of single vowels = $single_vowels\n";
    print "number of single_consonants = $single_consonants\n";
    print "number of letter y = $y_count\n";
    #    if ($single_vowels <= $single_consonants) {
    #$syllables = $single_vowels + $y_count;
    #}
    #else {
    my $syllable = $single_vowels + $y_count;
    return $syllable;
}

# Takes a cluster of letters and hash of letter: occurences pairs as parameters
# Subtracts 1 from each letter that is used by the cluster
# Returns the changed hash
sub countdown_letters {
    my ($cluster, $occurrences_ref) = @_;
    #my $cluster = ${$cluster_ref};
    my %occurences = %{$occurrences_ref};
    my @letters = split(//, $cluster);
    for(@letters) {
        if ($occurences{$_} == 0) {
            %occurences = ();
            last;
        } else {
            $occurences{$_} -= 1;
        }
    }
    return %occurences;
}


my %l_count = letter_count();#($word);
print "l_count outside of subroutine: \n";
print "$_ : $l_count{$_} \n" for keys(%l_count);

my %syllable_count = ();
my $syllables = calc_syllables(\%l_count);
print "*************************************************\n";
print "Maximum number of syllables = $syllables\n";
$syllable_count{"|"} = $syllables;
print "$_ : $syllable_count{$_}\n" for keys(%syllable_count);

my %vowel_count = cluster_count(\@vowels, \%l_count);
print "*************************************************\n";
print "Vowels and vowel clusters in input word :\n";
print "$_ : $vowel_count{$_} \n" for keys(%vowel_count);

my %not_coda_count = cluster_count(\@not_coda, \%l_count);
print "*************************************************\n";
print "Not coda clusters in input word :\n";
print "$_ : $not_coda_count{$_} \n" for keys(%not_coda_count);

my %not_onset_count = cluster_count(\@not_onset, \%l_count);
print "*************************************************\n";
print "Not onset clusters in input word :\n";
print "$_ : $not_onset_count{$_} \n" for keys(%not_onset_count);

my %onset_coda_ambisyllabic_count = cluster_count(\@onset_coda_ambisyllabic, \%l_count);
print "*************************************************\n";
print "Onset coda and ambisyllabic clusters in input word :\n";
print "$_ : $onset_coda_ambisyllabic_count{$_} \n" for keys(%onset_coda_ambisyllabic_count);

my @dicts = [\%syllable_count, \%vowel_count, \%not_coda_count, \%onset_coda_ambisyllabic_count, \%not_onset_count];
print "\@dicts = syllables, vowels, not_coda, onset_coda_ambisyllabic, not_onset\n";
my %successors = (0 => [1,2,3], 1 => [0,2,3,4], 2 => [1], 3 => [0,1], 4 => [0,1]);
print "successors:\n";
print "$_ : @{$successors{$_}}\n" for keys(%successors);


my $test = "nnn";
my %test_count = countdown_letters($test, \%l_count);
print "$_ : $test_count{$_}\n" for keys(%test_count);
