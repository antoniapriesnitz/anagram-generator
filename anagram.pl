#!/usr/bin/perl

use strict;
use warnings;

#my @single_vowels = (); # a, e, i, o, u, ä
#my @vowel_clusters = (); # aa, ai, ah, äh, au
my %all = ();
my @vowels = (); # solitary or clusters
my @double_consonants = (); # bb, cc, dd, ck, tz (not initial, only after vowels)
my @single_consonants = (); # b, c, d, sch, ch (do we need this? same as line below)
my @onset_coda_ambisyllabic = (); # bl, schl, st, pfl, pf 
my @not_coda = (); # fr, spr, chr, schm, schn, str 
my @not_onset = (); # rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, 

open(DATA, "<$ARGV[0]") or die "Couldn't open file!";

while(<DATA>) {
    next if (exists $all{$_});
    $_ =~ s/\n//;
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
    elsif (/.+(l|t|f)\z/) {
	push(@onset_coda_ambisyllabic, $_);
    }  
    else {
	push(@single_consonants, $_);
    }  
}

print "Vowels : @vowels\n";
print "Double consonants and other noninital consonant clusters: @not_onset\n";
print "Clusters that can be found everywhere, sometimes belong to two successive syllables : @onset_coda_ambisyllabic\n";
print "Clusters that need a vowel as successor : @not_coda\n";
#print "noninitial clusters ending with z or k : @cluster_notinitial\n";
print "Single consonants : @single_consonants\n";
close(DATA) or die "Could not close file properly!";
