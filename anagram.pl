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

print "Vowels:\n@vowels\n";
print "Double consonants and other noninital consonant clusters:\n@not_onset\n";
print "Clusters at the start, the end, or the middle of a word, sometimes belong to two successive syllables :\n@onset_coda_ambisyllabic\n";
print "Clusters that need a vowel as successor :\n@not_coda\n";
#print "noninitial clusters ending with z or k :\n@cluster_notinitial\n";
#print "Single consonants :\n@single_consonants\n";
close(DATA) or die "Could not close file properly!";


sub letter_count {
    #my $cl = $_;
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
    my (@cluster_array, %letter_dict) = @_;
    my %item_count;
    foreach my $cluster (@cluster_array){
        local $word = \$cluster;
	    my %item_letter_count = letter_count;
	    my $min = 100;
	    foreach my $letter (keys %item_letter_count){
	        if ($letter_dict{$letter} == 0) {
		        $min = 0;
	            last;
	        }else {
	        	if ($letter_dict{$letter} < $min) {
		        $min = $letter_dict{$letter};
		        }
	        }
	    }
	if ($min == 0) {
	    next;
	} else {
            $item_count{$cluster} = $min;
	}
        print "$cluster : $item_count{$cluster}\n";
    }
    return %item_count;
}


my %count = letter_count;
print "$_ : $count{$_} \n" for keys(%count);
cluster_count(@vowels, %count);
