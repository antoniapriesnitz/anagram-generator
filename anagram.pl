#!/usr/bin/perl

use strict;
use warnings;

#my @single_vowels = (); # a, e, i, o, u, ä
#my @vowel_clusters = (); # aa, ai, ah, äh, au
#my @cluster_notinitial = (); # tz, ck
my @vowels = ();
my @double_consonants = (); # bb, cc, dd, ck, tz
my @single_consonants = (); # b, c, d, sch, ch 
my @cluster_ltf = (); # bl, schl, st, pfl, pf
my @cluster_rmn = (); # fr, spr, chr, schm, schn, str

open(DATA, "<$ARGV[0]") or die "Couldn't open file!";

while(<DATA>) {
    $_ =~ s/\n//;
    if (/^(a|e|i|o|u|ä|ö|ü)/) {
	push(@vowels, $_);
    }
    elsif (/([a-z])\1/ or /(ck|tz)/) {
	push(@double_consonants, $_);
    }  
    elsif (/.+(l|t|f)\z/) {
	push(@cluster_ltf, $_);
    }  
    elsif (/.+(r|m|n)\z/) {
	push(@cluster_rmn, $_);
    }  
    #elsif (/.+(z|k)\z/) {
    #	push(@cluster_notinitial, $_);
    #}  
    else {
	push(@single_consonants, $_);
    }  
}

print "vowels : @vowels\n";
print "double consonants and noninital consonant clusters: @double_consonants\n";
print "clusters ending with l, t, or f : @cluster_ltf\n";
print "clusters ending with r, m, or n : @cluster_rmn\n";
#print "noninitial clusters ending with z or k : @cluster_notinitial\n";
print "single consonants : @single_consonants\n";
close(DATA) or die "Could not close file properly!";
