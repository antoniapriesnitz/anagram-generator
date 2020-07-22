#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max);

my ($file, $word) = @ARGV;
my $length = length($word);
print "Input word: $word, length = $length\n";

my %all = ();
my @vowel_clusters = (); # solitary or clusters
my @single_consonants = (); # b, c, d, sch, ch (do we need this? same as line below)
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
    my $syllable = $single_vowels + $y_count;
    if ($syllable > 0) {
        $syllable += 1; # first and last element in generated anagram will be syllable start marker "|"
    }
    return $syllable;
}

# Takes a cluster of letters and hash of letter: occurrences pairs as parameters
# Subtracts 1 from each letter that is used by the cluster
# Returns the changed hash
sub countdown_letters {
    #my ($cluster, $l_instances_ref, $c_instances_ref) = @_;
    my ($cluster, $l_instances_ref) = @_;
    my %l_instances = %{$l_instances_ref};
    #my %c_instances = %{$c_instances_ref};
    my %l_instances_modified = %l_instances;
    #my %c_instances_modified = %c_instances;
    my @letters = split(//, $cluster);
    my $bool = 1;
    for(@letters) {
        if ((not exists $l_instances{$_}) or ($l_instances{$_} == 0)) {
            #$c_instances_modified{$cluster} = 0;
            $bool = 0;
            last;
        } else {
            $l_instances_modified{$_} -= 1;
        }
    }
    #if (%c_instances_modified{$cluster} == 0) {
    if ($bool == 0) {
        #return (\%c_instances_modified, \%l_instances);
        return ($bool, \%l_instances);
    } else {
        #$c_instances{$cluster} -= 1;
        #return (\%c_instances, \%l_instances_modified);
        return ($bool, \%l_instances_modified);
    }
}


my %occurrences = letter_count($word);
print "occurrences: ";
print "$_: $occurrences{$_} \t" for keys(%occurrences);
print "\n";

#my %syllable_count = ();
my @syllable_markers = ();
my $syllables = calc_syllables($word);
print "*************************************************\n";
print "Maximum number of syllables = $syllables\n";
#$syllable_count{"|"} = $syllables;
push(@syllable_markers, "|");
#print "$_: $syllable_count{$_}\t" for keys(%syllable_count);
print "syllable symbols = @syllable_markers";
print "\n";

$occurrences{"|"} = $syllables;
print "occurrences: ";
print "$_: $occurrences{$_} \t" for keys(%occurrences);
print "\n";

#my %vowel_count = cluster_count(\@vowel_clusters, \%occurrences);
my @vowels = cluster_count(\@vowel_clusters, \%occurrences);
print "*************************************************\n";
print "Vowels and vowel clusters in input word :\n";
#print "$_: $vowel_count{$_}\t" for keys(%vowel_count);
print "@vowels\n";
print "\n";

#my %not_coda_count = cluster_count(\@not_coda_clusters, \%occurrences);
my @not_coda = cluster_count(\@not_coda_clusters, \%occurrences);
print "*************************************************\n";
print "Not coda clusters in input word :\n";
#print "$_: $not_coda_count{$_}\t" for keys(%not_coda_count);
print "\n";

#my %not_onset_count = cluster_count(\@not_onset, \%occurrences);
my @not_onset = cluster_count(\@not_onset_clusters, \%occurrences);
print "*************************************************\n";
print "Not onset clusters in input word :\n";
#print "$_: $not_onset_count{$_}\t" for keys(%not_onset_count);
print "@not_onset\n"; 
print "\n";

#my %onset_coda_ambisyllabic_count = cluster_count(\@onset_coda_ambisyllabic, \%occurrences);
my @onset_coda_ambisyllabic = cluster_count(\@onset_coda_ambisyllabic_clusters, \%occurrences);
print "*************************************************\n";
print "Onset coda and ambisyllabic clusters in input word :\n";
#print "$_: $onset_coda_ambisyllabic{$_}\t" for keys(%onset_coda_ambisyllabic_count);
print "@onset_coda_ambisyllabic\n"; 
print "\n";

#my @vertices = (\%syllable_count, \%vowel_count, \%not_coda_count, \%onset_coda_ambisyllabic_count, \%not_onset_count);
my @vertices = (\@syllable_markers, \@vowels, \@not_coda, \@onset_coda_ambisyllabic, \@not_onset);
#print "vertices = @vertices\n";
#print "vertices[0] = $vertices[0]\n";
print "\@vertices = syllables, vowels, not_coda, onset_coda_ambisyllabic, not_onset\n";
#my %adjacency_lists = (0 => [1,2,3], 1 => [0,2,3,4], 2 => [1], 3 => [0,1], 4 => [0,1]);
#print "adjacency lists:\n";
#print "$_: @{$adjacency_lists{$_}}\t" for keys(%adjacency_lists);
#print "\n";

my @adjacency_matrix = qw/0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0/; # 5 rows of size 5
#print "@adjacency_matrix\n";
#my $len = scalar(@adjacency_matrix);
#print "Length of adjacency_matrix = $len\n";

my @anagrams = ();

sub concatenate {
    my ($word_length, $anagram_length, $vertex, $anagram_ref, $letter_count_ref) = @_;
    my @anagram = @{$anagram_ref};
    my %letter_count = %{$letter_count_ref};
    if ($anagram_length >= $word_length) {
        my $anagram = join('.', @anagram);
        push(@anagrams, $anagram);
        print "$anagram\n";
        return;
    }
    my $row_start = $vertex * 5;
    #print "row_start = $row_start\n";
    for(my $i=0; $i<5; $i++) {
        if ($adjacency_matrix[$row_start + $i] == 1) {
            #print "i = $i\n";
            #my %vertex = %{$vertices[$i]};
            my @vertex = @{$vertices[$i]};
            #if (%vertex) {
            if (@vertex) {
                #foreach my $key (keys %vertex) {
                for(@vertex) {
                    #my ($bool, $downcount_ref) = countdown_letters($key, \%letter_count);
                    my ($bool, $downcount_ref) = countdown_letters($_, \%letter_count);
                    my %downcount = %{$downcount_ref};
                    print "$_: $downcount{$_}\t" for keys(%downcount);
                    print "\n";
                    if ($bool) {
                        #print "key = $key\n";
                        #push(@anagram, $key);
                        push(@anagram, $_);
                        #if ($key != '|') {
                        #if ($key =~ /[^\|]/)  {
                        #if ($key =~ /[a-z]|ä|ö|ü/)  {
                        if ($_ =~ /[a-z]|ä|ö|ü/)  {
                            #$anagram_length += length($key);
                            $anagram_length += length($_);
                            #print "key = $key, anagram length = $anagram_length\n";
                            print "cluster = $_, anagram length = $anagram_length\n";
                        } #else {
                        #  print "key not matched: $key\n";
                        #}
                        concatenate($word_length, $anagram_length, $i, \@anagram, \%downcount);
                    } else {
                        #print "Not enough letters for cluster $key!\n";
                        print "Not enough letters for cluster $_!\n";
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

#print "length of input word = $length\n";
concatenate($length, 0, 0, \@anagram, \%occurrences);
print "Anagrams: @anagrams\n";
