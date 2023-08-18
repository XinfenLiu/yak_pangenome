#!/usr/bin/env perl
#===============================================================================
#
#         FILE: prase_gff.stat.pl
#
#        USAGE: ./prase_gff.stat.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Zeyu Zheng (LZU), zhengzy2014@lzu.edu.cn
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 05/10/2022 11:18:01 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
no warnings qw( experimental::smartmatch );
use v5.24;
use Carp qw/confess carp/; # carp=warn;confess=die
use zzIO;
use Data::Dumper;

my ($in, $out) = @ARGV;

$in //= 'Ref.gff.gene.gz';
$out //= 'Ref.gff.gene.gz.stat';

my $I = open_in_fh($in);
my $O = open_out_fh($out);

my %hash;
while(<$I>){
    chomp;
    next if /^#/;
    my @F = split /\t/;
    my $type = $F[2];
    my $gene = $F[8];
    my $len = $F[4] - $F[3];
    $hash{$gene}{$type} += $len;
}

foreach my $gene (sort keys %hash){
    foreach my $type (sort keys %{$hash{$gene}}){
        say $O join("\t", $gene, $type, $hash{$gene}{$type});
    }
}
