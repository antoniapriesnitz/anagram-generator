#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max);

if (scalar(@ARGV) < 3) {
    push(@ARGV, 0);
}
my ($file, $word, $info) = @ARGV;
my $length = length($word);

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
    my @item_count;
    my $min = 0;
    foreach my $c (@clusters) {
	    my %item_letter_count = letter_count($c);
	    my $min = 100;
	    foreach my $letter (keys %item_letter_count){
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
            push(@item_count, $c);
        }
    }
    return @item_count;
}

# Takes a word and counts the occurences of vowels, consonants and the letter y
# Returns the maximum number of syllables the anagram may have
sub calc_syllables {
    my $w = shift;   
    my @letters = split(//, $w);
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
        return ($bool, \%l_instances);
    } else {
        return ($bool, \%l_instances_modified);
    }
}


my %occurrences = letter_count($word);
my $syllables = calc_syllables($word);
$occurrences{"|"} = $syllables;

my @syllable_markers = ();
push(@syllable_markers, "|");
my @vowels = cluster_count(\@vowel_clusters, \%occurrences);
my @not_coda = cluster_count(\@not_coda_clusters, \%occurrences);
my @onset_coda_ambisyllabic = cluster_count(\@onset_coda_ambisyllabic_clusters, \%occurrences);
my @not_onset = cluster_count(\@not_onset_clusters, \%occurrences);

if ($info) {
    print "Vowels:\n@vowel_clusters\n";
    print "Double consonants and other noninital consonant clusters:\n@not_onset_clusters\n";
    print "Clusters at the start, the end, or the middle of a word, sometimes belong to two successive syllables:\n@onset_coda_ambisyllabic_clusters\n";
    print "Clusters that need a vowel as successor:\n@not_coda_clusters\n";
    print "**************************************************************\n";
    print "Input word: $word\n";
    print "length = $length\n";
    print "Maximum number of syllables = $syllables\n";
    print "occurrences:\t";
    print "$_: $occurrences{$_}\t" for keys(%occurrences);
    print "\n";
    print "New syllable marker:\t@syllable_markers\n";
    print "Vowels and vowel clusters in input word:\t@vowels\n";
    print "Not coda clusters in input word:\t@not_coda\n";
    print "Onset coda and ambisyllabic clusters in input word:\t@onset_coda_ambisyllabic\n";
    print "Not onset clusters in input word :\t@not_onset\n";
    print "**************************************************************\n\n";
}

for(@onset_coda_ambisyllabic) {
    push(@not_onset, $_);
    push(@not_coda, $_);
}
#my %adjacency_lists = (0 => [1,2,3], 1 => [0,2,3,4], 2 => [1], 3 => [0,1], 4 => [0,1]);

my @vertices = (\@syllable_markers, \@vowels, \@not_coda, \@onset_coda_ambisyllabic, \@not_onset);
#my @adjacency_matrix = qw/0 1 1 1 0 1 0 1 1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0/; # 5 rows of size 5
my @adjacency_matrix = qw/0 1 1 0 0 1 0 1 0 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0/; # 5 rows of size 5
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
                    if (($anagram[-2] =~ /^([^aeiouäöü])/) and ($i != 1)) {# 2nd last and current are consonants
                        if ((scalar(@anagram) == 2) or $anagram_length == $word_length-1) { 
                        # syllable gap before first vowel or between consonants after last vowel
                        print "@anagram\t$_\n";
                            next;
                        }
                        elsif (scalar(@anagram) >= 4) {
                            if (($anagram[-4] =~ /^([^aeiouäöü])/) and $anagram[-3] =~ /\|/) {
                                print "@anagram\t\t$_\n"; # Syllables without vowels
                                next;
                            }
                        }
                    }
                    if (scalar(@anagram) >= 4) {
                        if (($anagram[-2] =~ /[a|e|i|o|u|ä|ö|ü]/) and ($i == 1)) {# 2nd last item and current are vowels
                            if (($anagram[-4] =~ /[a|e|i|o|u|ä|ö|ü]/)  and ($anagram[-3] =~ /\|/)) { #prevent circle of vowels
                                #print "@anagram\t$_\n";
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

concatenate($length, 0, 0, \@anagram, \%occurrences);
#print "Anagrams: \n";
#for(@anagrams){
#print "$_\n";
#}

my @readable_anagrams = ();
for(@anagrams) {
    $_ =~ tr/.//d;
    push(@readable_anagrams, $_);
}
my $number = scalar(@anagrams);
print "$number anagrams:\n";
for(@readable_anagrams) {
    print "$_\n";
}
