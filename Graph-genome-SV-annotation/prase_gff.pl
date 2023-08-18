#!/usr/bin/env perl
#===============================================================================
#
#         FILE: prase_gff.pl
#
#        USAGE: ./prase_gff.pl  
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
#      CREATED: 05/10/2022 11:03:21 AM
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

$in //= 'Ref.gff.gz';
$out //= 'Ref.gff.gene.gz';


my $I = open_in_fh($in);
my $O = open_out_fh($out);

my $gene_now = "";
while(<$I>){
    chomp;
    next if /^#/;
    my @F = split /\t/;
    if ($F[2] eq 'gene'){
        $F[8] =~ /ID=([^;]+)(;|$)/ or die;
        my $gene_id = $1;
        #my $gene_name = $F[8] =~ /Name=([^;]+)/;
        $gene_now = $gene_id;
        $F[8] = "GENE=$gene_id";
    } else {
        die unless defined $gene_now;
        $F[8] = "GENE=$gene_now";
    }
    print $O join("\t", @F), "\n";
}


