#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max);

my ($file, $word) = @ARGV;
my $length = length($word);
print "Input word: $word, length = $length\n";

my %all = ();
my @vowel_clusters = (); # single or clusters
my @onset_coda_ambisyllabic_clusters = (); # bl, schl, st, pfl, pf 
my @not_coda_clusters = (); # fr, spr, chr, schm, schn, str 
my @not_onset_clusters = (); # rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, cht 

open(DATA, "<$file") or die "Couldn't open file!";

while(<DATA>) {
    $_ =~ s/\n//;
    if (exists $all{$_}){
    	print "duplicate: $_\n";
        next;
    }	
    $all{$_} = 1;
    if (/^(a|e|i|o|u|ä|ö|ü)/) {
	push(@vowel_clusters, $_);
    }
    elsif (/.+r\z/ or /sch(m|n)/) {
	push(@not_coda_clusters, $_);
    }  
    elsif (/([a-z])\1/ or /(ck|tz)/ or /.+(st|.t|m|l|n)\z/) {
	push(@not_onset_clusters, $_);
    }  
    else {#(/.+(l|t|f)\z/) {
	push(@onset_coda_ambisyllabic_clusters, $_);
    }  
}

close(DATA) or die "Could not close file properly!";

#print "Vowels:\n@vowel_clusters\n";
#print "Double consonants and other noninital consonant clusters:\n@not_onset_clusters\n";
#print "Clusters at the start, the end, or the middle of a word, sometimes belong to two successive syllables :\n@onset_coda_ambisyllabic_clusters\n";
#print "Clusters that need a vowel as successor :\n@not_coda_clusters\n";
##print "noninitial clusters ending with z or k :\n@cluster_notinitial\n";

# Counts the occurences of all letters of a word
# Returns a hash of the form letter: occurences
sub letter_count {
    my $w = shift;
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
    #my %item_count;
    my @item_count;
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
            #$item_count{$c} = $min;
            push(@item_count, $c);
            #print "$clusters[$i] : $item_count{$clusters[$i]}\n";
        }
    }
    #return %item_count;
    return @item_count;
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
    my $syllables = $single_vowels + $y_count;
    if ($syllables > 0) {
        $syllables += 1; # first and last element in generated anagram will be syllable start marker "|"
    }
    return $syllables;
}

# Takes a cluster of letters and hash of letter: occurrences pairs as parameters
# Subtracts 1 from each letter that is used by the cluster
# Returns the changed hash
sub countdown_letters {
    my ($cluster, $l_instances_ref) = @_;
    my %l_instances = %{$l_instances_ref};
    #print "cluster in countdown_letters:\t $cluster\n";
    #print "l_instances in countdown_letters:\t";
    #print "$_: $l_instances{$_}\t" for keys(%l_instances);
    #print "\n";
    my %l_instances_modified = %l_instances;
    my @letters = split(//, $cluster);
    my $bool = 1;
    for(@letters) {
        if ((not exists $l_instances{$_}) or ($l_instances_modified{$_} == 0)) {
            $bool = 0;
            last;
        } else {
            $l_instances_modified{$_} -= 1;
        }
    }
    if ($bool == 0) {
        #print "bool in countdown_letters = $bool\n";
        return ($bool, \%l_instances);
    } else {
        #print "l_instances_modified in countdown_letters:\t";
        #print "$_: $l_instances_modified{$_}\t" for keys(%l_instances_modified);
        #print "\n";
        return ($bool, \%l_instances_modified);
    }
}


my %occurrences = letter_count($word);
#print "occurrences: ";
#print "$_: $occurrences{$_} \t" for keys(%occurrences);
#print "\n";

my @syllable_markers = ();
my $syllables = calc_syllables($word);
print "*************************************************\n";
print "Maximum number of syllables = $syllables\n";
push(@syllable_markers, "|");
print "syllable symbols = @syllable_markers";
print "\n";

$occurrences{"|"} = $syllables;
print "occurrences: ";
print "$_: $occurrences{$_} \t" for keys(%occurrences);
print "\n";

my @vowels = cluster_count(\@vowel_clusters, \%occurrences);
print "*************************************************\n";
print "Vowels and vowel clusters in input word :\n";
print "@vowels\n\n";

my @not_coda = cluster_count(\@not_coda_clusters, \%occurrences);
print "*************************************************\n";
print "Not coda clusters in input word :\n";
print "@not_coda\n\n";

my @not_onset = cluster_count(\@not_onset_clusters, \%occurrences);
print "*************************************************\n";
print "Not onset clusters in input word :\n";
print "@not_onset\n\n";

my @onset_coda_ambisyllabic = cluster_count(\@onset_coda_ambisyllabic_clusters, \%occurrences);
print "*************************************************\n";
print "Onset coda and ambisyllabic clusters in input word :\n";
print "@onset_coda_ambisyllabic\n\n";

my @vertices = (\@syllable_markers, \@vowels, \@not_coda, \@onset_coda_ambisyllabic, \@not_onset);
#print "\@vertices = syllables, vowels, not_coda, onset_coda_ambisyllabic, not_onset\n";
#my %adjacency_lists = (0 => [1,2,3], 1 => [0,2,3,4], 2 => [1], 3 => [0,1], 4 => [0,1]);
#print "adjacency lists:\n";
#print "$_: @{$adjacency_lists{$_}}\t" for keys(%adjacency_lists);
#print "\n";

my @adjacency_matrix = qw/0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0/; # 5 rows of size 5

my @anagrams = ();

sub concatenate {
    my ($word_length, $anagram_length, $vertex, $anagram_ref, $letter_count_ref) = @_;
    my @anagram = @{$anagram_ref};
    if ($anagram_length >= $word_length) {
        my $anagram = join('.', @anagram);
        push(@anagrams, $anagram);
        return;
    }
    my %letter_count = %{$letter_count_ref};
    my $row_start = $vertex * 5;
    for(my $i=0; $i<5; $i++) {
        if ($adjacency_matrix[$row_start + $i] == 1) {
            my @next_vertex = @{$vertices[$i]};
            for(@next_vertex) {
                if (($vertex == 0) and (scalar(@anagram) >= 2)) { # last item in anagram is syllable gap
                    if ($anagram[-2] =~ /[a|e|i|o|u|ä|ö|ü]/) { # second last item is vowel
                        if ($i == 1) { # current cluster is vowel
                            #print "vowel | vowel at end of anagram\n";
                            #print "@anagram\t\t$_\n";
                            next;
                        }
                    } else { # second last item in anagram must be consonant (cannot be syllable gap)
                        if ($i != 1) { # current cluster is consonant
                            if (scalar(@anagram) == 2) {
                                #print "cons | cons at start of anagram:\n";
                                #print "@anagram\t\t$_\n";
                                next;
                            }
                        }
                    }
                }   
                my ($bool, $downcount_ref) = countdown_letters($_, \%letter_count);
                my %downcount = %{$downcount_ref};
                if ($bool) {
                    push(@anagram, $_);
                    if ($_ =~ /[a-z]|ä|ö|ü/)  {
                        $anagram_length += length($_);
                    }
                    concatenate($word_length, $anagram_length, $i, \@anagram, \%downcount);
                    pop(@anagram);
                    $anagram_length -= length($_);
                }
            }
        }
    }
    return;
}

my @anagram = ();

#print "length of input word = $length\n";
concatenate($length, 0, 0, \@anagram, \%occurrences);
print "Anagrams: \n";
for(@anagrams){
    print "$_\n";
}
my @readable_anagrams = ();
for(@anagrams) {
    $_ =~ tr/|.//d;
    push(@readable_anagrams, $_);
}
print "readable anagrams:\n @readable_anagrams\n";
