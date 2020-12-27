package Read_Language_Data;
use Data::Dumper;
use Moose;

sub sort_clusters{
    my $file = shift;
    my %all = ();
    my @vowel_clusters = (); # a, e, i, o, u, ä, ö, ü, y
    my @onset_coda_clusters = (); # bl, schl, st, pfl, pf... 
    my @onset_clusters = (); # fr, spr, chr, schm, schn, str... 
    my @coda_clusters = (); # bb, ll, rbst, scht, lm, lst, fst, rfst, rsch, sst, chst, ckst, gst, tzt, schst, chst, kst, mmst, mst, nnst, nst, pst, vn,  rscht, rm, ffst, ppst, bbst, rrst, rst, rn, lln, llst, ml, rschst, rft, cht... 
    open(DATA, "<$file") or die "Could not open data file!";
    
    while(<DATA>) {
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
1;
