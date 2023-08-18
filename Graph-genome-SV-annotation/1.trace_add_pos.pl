#!/usr/bin/env perl
#===============================================================================
#
#         FILE: trace_add_pos.pl
#
#        USAGE: ./trace_add_pos.pl  
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
#      CREATED: 03/19/2022 07:33:11 PM
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
use List::Util qw/max min sum maxstr minstr shuffle/;

my ($gfa_file, $trace_file, $out_file) = @ARGV;

# output is 0-based [a,b]

my $thin_gfa = 1;
#my $thin_gfa = 0;



my $gfa = &read_gfa($gfa_file);

my $I = open_in_fh($trace_file);
my $O = open_out_fh($out_file);
my %printed_svids;
while(<$I>) {
    #                          reflen altlen
    # biallelic 1_100070 AltIns  125   135  s1,s2,s3  Ref,DYYS  s1,s2190687,s3  IndPLM
    #     0       1       2       3     4     5        6              7          8
    chomp;
    s/ //g;
    my @F = split(/\t/);
    my $svid = $F[1];
    next if exists $printed_svids{$svid};
    my $type = $F[2];
    my $altlen = $F[4];
    my @ref_nodes = split(/,/, $F[5]);
    my ($chr, $start, $end) = &get_min_max_pos(\@ref_nodes);
    $printed_svids{$svid}++;
    say $O join "\t", $svid, $type, $chr, $start, $end, $altlen;
}

exit;

sub get_min_max_pos {
    my ($nodes) = @_; # $gfa
    #say join ' ', @$nodes;
    my $start_node = shift @$nodes // die;
    my $end_node = pop @$nodes // die;
    my $chr = $$gfa{$start_node}[0] // die "no chr for $start_node";
    die if $chr ne $$gfa{$end_node}[0] // die;
    my @poss = ( $$gfa{$start_node}[2], $$gfa{$end_node}[1] );
    for my $node (@$nodes) {
        my ($chr_now, $start, $end, $SR) = $$gfa{$node}->@*;
        die unless defined $SR;
        die "$chr_now, $start, $end, $SR @$nodes" if $SR != 0;
        die if $chr_now ne $chr;
        push @poss, $start;
        push @poss, $end;
    }
    #say join ' ', @poss;
    my $min = min(@poss);
    my $max = max(@poss);
    return ($chr, $min, $max);
}

sub read_gfa {
    my $gfa_file = shift;
    my %gfa_hash;
    my $I = open_in_fh($gfa_file);
    while(<$I>) {
        chomp;
        my @F = split(/\t/);
        if ($F[0] eq 'S') {
            # S  s12  CTGTCTCC  LN:i:8  SN:Z:1  SO:i:115492  SR:i:0
            # 0   1     2         3       4         5          6
            my $node = $F[1];
            $F[6-$thin_gfa] =~ /^SR:i:(\d+)$/ or die $_;
            my $SR = $1;
            $F[3-$thin_gfa] =~ /^LN:i:(\d+)$/ or die $_;
            my $LN = $1;
            $F[4-$thin_gfa] =~ /^SN:Z:(.+)$/ or die $_;
            my $chr = $1;
            $F[5-$thin_gfa] =~ /^SO:i:(\d+)$/ or die $_; # 0-based
            my $pos_start =  $1;
            my $pos_end = $pos_start + $LN - 1;
            $gfa_hash{$node} = [$chr, $pos_start, $pos_end, $SR];
            #die Dumper \%gfa_hash if $node eq 's1';
        }
    }
    return(\%gfa_hash);
}
