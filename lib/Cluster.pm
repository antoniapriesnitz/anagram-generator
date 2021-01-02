package Cluster;# Do I need this?

use 5.006;
use strict;
use warnings;
use Data::Dumper;
use Moose;

extends 'Word';

has 'category' => (is = 'ro', isa => 'Str');# values: vowel, onset, onset-coda, coda
# vowels:  a, e, i, o, u, ä, ö, ü, y
# onset: fr, spr, chr, schm, schn, str... 
# onset_coda: bl, schl, st, pfl, pf... 
# coda: bb, ll, rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, cht... 

#in: line of language file (i.e. cluster string space number string, e.g. "cht 3"
#split into cluster string and number string: 0 for vowel, 1 for onset, 2 for onset-coda, 3 for coda
#out: new cluster object
#might be better to separate parsing from creating a new object
sub new {
        $_ =~ s/\n//;
        if (exists $all{$_}){
    	    print "duplicate: $_\n";
            next;
        }	
        $all{$_} = 1;
        if (/[^ ]+ 0/){
            $_ =~ s/ [0-9]//;
	        push(@vowel_clusters, $_);
        }
        elsif (/[^ ]+ 1/){
            $_ =~ s/ [0-9]//;
	        push(@onset_clusters, $_);
        }  
        elsif (/[^ ]+ 2/){
            $_ =~ s/ [0-9]//;
	        push(@onset_coda_clusters, $_);
        }  
        elsif (/[^ ]+ 3/){
            $_ =~ s/ [0-9]//;
	        push(@coda_clusters, $_);
        }  
        else {
            print "not matched: $_\n";
        }
    }
    
    close(DATA) or die "Could not close file properly!";

    return (\@vowel_clusters, \@onset_clusters, \@onset_coda_clusters, \@coda_clusters);
}
#
#sub partition(cluster)
#gives back a hash, keys=start of partitions, values=end of partitions
#partition pair = two clusters, which concatenated form the input cluster
#the first of the pair must be coda oder onset-coda, the second onset oder onset-coda
#e.g. "r" and "st" concatenated form "rst"
1;
