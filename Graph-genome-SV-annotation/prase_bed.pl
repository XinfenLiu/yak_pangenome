use warnings;
use strict;
use v5.24;
use zzIO;

my ($inbed_allsv, $inbed_union, $out) = @ARGV;


my $unions = &read_bed_union($inbed_union);
my $svs = &read_bed_svs($inbed_allsv);

my $O = open_out_fh($out);
say $O join "\t", qw/chr start end reflen replen rep_percent/;
foreach my $chr (sort keys %$svs) {
    foreach my $id (sort keys $$svs{$chr}->%*) {
        my $svlen = $$svs{$chr}{$id};
        $id=~/^(\d+):(\d+)$/ or die;
        my $start = $1;
        my $end = $2;
        my $union = $$unions{$chr}{$id} // 0;
        my $len = $end-$start;
        my $repeat_percent = $union/$len;
        say $O join "\t", $chr, $start, $end, $len, $union, $repeat_percent;
    }
}

exit;

sub read_bed_svs() {
    my ($in) = @_;
    my $I = open_in_fh($in);
    my %ret;
    while(<$I>) {
        # 2       7155406 7156724
        # 0          1    2
        chomp;
        next unless $_;
        my ($chr, $start, $end, $svid) = split(/\t/, $_);
        my $svlen = $end-$start;
        my $id = "$start:$end";
        $ret{$chr}{$id} = $svlen;
    }
    return \%ret;
}



sub read_bed_union() {
    my ($in) = @_;
    my $I = open_in_fh($in);
    my %ret;
    while(<$I>) {
        # 2       7155406 7156724 SVID 2       7144723 8164169 1318
        # 0          1    2        3  4        5     6          7
        chomp;
        next unless $_;
        my ($chr, $start, $end, $svid, undef, undef, undef, $union) = split(/\t/, $_);
        my $id = "$start:$end";
        $ret{$chr}{$id} += $union;
    }
    return \%ret;
}
