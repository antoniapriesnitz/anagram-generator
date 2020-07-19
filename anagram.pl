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
    #else {
    #	push(@single_consonants, $_);
    #}  
}

close(DATA) or die "Could not close file properly!";

#print "Vowels:\n@vowels\n";
#print "Double consonants and other noninital consonant clusters:\n@not_onset\n";
#print "Clusters at the start, the end, or the middle of a word, sometimes belong to two successive syllables :\n@onset_coda_ambisyllabic\n";
#print "Clusters that need a vowel as successor :\n@not_coda\n";
##print "noninitial clusters ending with z or k :\n@cluster_notinitial\n";
##print "Single consonants :\n@single_consonants\n";


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


sub cluster_count{
    my ($clusters_ref, $count_ref) = @_;
    my @clusters = @{$clusters_ref};
    my %count = %{$count_ref};
    my $length = scalar(@_);
    #print "length of input array = $length\n";
    #print "input array = @_\n";
    print "clusters : @clusters\n";
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


my %l_count = letter_count();#($word);
print "l_count outside of subroutine: \n";
print "$_ : $l_count{$_} \n" for keys(%l_count);

my %vowel_count = cluster_count(\@vowels, \%l_count);
print "Vowels and vowel clusters in input word :\n";
print "$_ : $vowel_count{$_} \n" for keys(%vowel_count);

my %not_coda_count = cluster_count(\@not_coda, \%l_count);
print "Not coda clusters in input word :\n";
print "$_ : $not_coda_count{$_} \n" for keys(%not_coda_count);

my %not_onset_count = cluster_count(\@not_onset, \%l_count);
print "Not onset clusters in input word :\n";
print "$_ : $not_onset_count{$_} \n" for keys(%not_onset_count);

my %onset_coda_ambisyllabic_count = cluster_count(\@onset_coda_ambisyllabic, \%l_count);
print "Onset coda and ambisyllabic clusters in input word :\n";
print "$_ : $onset_coda_ambisyllabic_count{$_} \n" for keys(%onset_coda_ambisyllabic_count);
