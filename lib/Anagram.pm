package Anagram;
#erbt von Word
#zusätzliche Attribute für Tiefensuche

use 5.006;
use strict;
use warnings;
use Moose;
use Data::Dumper;

extends 'Word';
# input word "blablub"
# unique letters in order of occurrence: blau 
# quantities of unique letters: 3211
has 'target_length' => (is => 'ro', isa => 'Int');# termination condition; not correct length calculated by the Word method!
has 'current_length' => (is => 'rw', isa => 'Int');# changes during depth first search
has 'vowels' => (is => 'ro', isa => 'Hash', builder => '_select_clusters'); # a:0010, u:0001
has 'onset' => (is => 'ro', isa => 'Hash', builder => '_select_clusters');# bl:1100, b:1000, l:0100
has 'onset_coda' => (is => 'ro', isa => 'Hash', builder => '_select_clusters');# bl:1100, b:1000, l:0100 or better just an array? Not used in concatenate
has 'coda' => (is => 'ro', isa => 'Hash', builder => '_select_clusters');# b:1000, l:1000, bl:1100,bb:2000

sub _select_clusters{
}

1;
