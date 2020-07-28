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
my @onset_coda_clusters = (); # bl, schl, st, pfl, pf 
my @onset_clusters = (); # fr, spr, chr, schm, schn, str 
my @coda_clusters = (); # rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, cht 

open(DATA, "<$file") or die "Couldn't open file!";

while(<DATA>) {
    $_ =~ s/\n//;
    if (exists $all{$_}){
    	print "duplicate: $_\n";
        next;
    }	
    $all{$_} = 1;
    if (/^[aeiouäöüy]/) {
	push(@vowel_clusters, $_);
    }
    elsif (/.+r\z/ or /j|sch(m|n|w)/) {
	push(@onset_clusters, $_);
    }  
    elsif (/^.\z/ or /^[^lm]l\z/ or /^pf[^t]*|^(sch(l)?|(c|p)h|s(p|c))\z|qu/) {
	push(@onset_coda_clusters, $_);
    }  
    elsif (/([a-z])\1/ or /(ck|tz|(rz|cht|m)l)/ or /.+(st|.*t|m|n|g|k|ch|z|s|f|d|b)\z/) {
	push(@coda_clusters, $_);
    }  
    else {
        push(@vowel_clusters, $_);
        print "not matched: $_\n";
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

# Takes a word and counts the occurences of vowels
# Returns the maximum number of syllables the anagram may have
sub calc_syllables {
    my $w = shift;   
    my @letters = split(//, $w);
    my $vowels = 0;
    for(@letters) {
        if (/a|e|i|o|u|ä|ö|ü|y/) {
            $vowels += 1;
        }
    }
    if ($vowels > 0) {
        $vowels += 1; # first and last element in generated anagram will be syllable start marker "|"
    }
    return $vowels;
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
my @onset = cluster_count(\@onset_clusters, \%occurrences);
my @onset_coda = cluster_count(\@onset_coda_clusters, \%occurrences);
my @coda = cluster_count(\@coda_clusters, \%occurrences);

my %onset = ();
for(@onset) {
    $onset{$_} = 1;
}

my %coda = ();
for(@coda) {
    $coda{$_} = 1;
}
my %onset_coda = ();
for(@onset_coda) {
    push(@coda, $_);
    push(@onset, $_);
    $onset_coda{$_} = 1;
    $onset{$_} = 1;
    $coda{$_} = 1;
}

if ($info) {
    print "Vowels:\n@vowel_clusters\n";
    print "Clusters that need a vowel as successor:\n@onset_clusters\n";
    print "Double consonants and other noninital consonant clusters:\n@coda_clusters\n";
    print "Clusters at the start or the end of a word:\n@onset_coda_clusters\n";
    print "**************************************************************\n";
    print "Input word: $word\n";
    print "length = $length\n";
    print "Maximum number of syllables = $syllables\n";
    print "occurrences:\t";
    print "$_: $occurrences{$_}\t" for keys(%occurrences);
    print "\n";
    print "New syllable marker:\t@syllable_markers\n";
    print "Vowels and vowel clusters in input word:\t@vowels\n";
    print "Onset clusters in input word:\t@onset\n";
    print "Coda clusters in input word :\t@coda\n";
    print "Onset and coda clusters in input word:\t@onset_coda\n";
    print "**************************************************************\n\n";
}

#my %adjacency_lists = (0 => [1,2], 1 => [0,3], 2 => [1], 3 => [0]) ;

my @vertices = (\@syllable_markers, \@vowels, \@onset, \@coda);
my @adjacency_matrix = qw/0 1 1 0 1 0 0 1 0 1 0 0 1 0 0 0 /; # 4 rows of size 4
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
    my $row_start = $vertex * 4;
    for(my $i=0; $i<4; $i++) {
        if ($adjacency_matrix[$row_start + $i] == 1) {
            my @next_vertex = @{$vertices[$i]};
            for(@next_vertex) {
                if (length($_) + $anagram_length > $word_length) {
                    my $l = length($_);
                    next;
                }
                if ($vertex == 0) { # last item in anagram is syllable gap
                    if ($i != 1) { # current is consonant
                        if (length($_)+ $anagram_length == $word_length) { 
                        # current is last cluster in anagram -> new syllable without vowel
                        #if (length($_) == 1) {
                        #print "new syllable without vowel: @anagram\t$_\n";
                        #last;
                        #}
                            next;
                        }
                        if (scalar(@anagram) >= 2 and ($anagram[-2] =~ /^([^aeiouäöüy])/)) {# 2nd last is consonant
                            my $ambisyllabic = join('', $anagram[-2],$_);
                            if (exists $onset_coda{$ambisyllabic} or exists $coda{$ambisyllabic}) {# to avoid duplicates
                                #print "possible duplicate cc and c|c: @anagram\t$_\n";
                                next;
                            }
                            if ((scalar(@anagram) == 2) or $anagram_length == $word_length-1) { 
                                # syllable gap before first vowel or between consonants after last vowel
                                    next;
                            }
                        }
                    }
                    else { # current is vowel
                        if (scalar(@anagram) >= 2 and exists $onset{$anagram[-2]}) {
                            print "possible duplicate cv and c|v: @anagram\t$_\n";
                            next;
                        }
                    }
                }   
                my ($bool, $downcount_ref) = countdown_letters($_, \%letter_count);
                my %downcount = %{$downcount_ref};
                if ($bool) {
                    push(@anagram, $_);
                    if ($_ =~ /[a-zäöüß]/)  {
                        $anagram_length += length($_);
                    }
                    concatenate($word_length, $anagram_length, $i, \@anagram, \%downcount);
                    pop(@anagram);
                    if ($_ =~ /[a-zäöüß]/)  {
                        $anagram_length -= length($_);
                    }
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
my %duplicates = ();
for(@anagrams) {
    $_ =~ tr/.|//d;
    push(@readable_anagrams, $_);
    if (exists($duplicates{$_})) {
        $duplicates{$_} += 1;
    } else {
        $duplicates{$_} = 1;
    }
}
my $number = scalar(@anagrams);
print "$number anagrams:\n";
#for(@readable_anagrams) {
#print "$_\n";
#}

print "\nduplicates:\n";
print "$_: $duplicates{$_}\n" for keys(%duplicates);
