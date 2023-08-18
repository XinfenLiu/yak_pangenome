# Prepare files
```shell
# After perfomed bovine-graphs
cd analysis/bubble
mkdir zz
ln -s ../../../graph/*_graph.gfa ./bov_graph.gfa
ln -s XX/DIR/Ref.gff.gz ./Ref.gff.gz
ln -s ../*_path_trace.tsv bov_path_trace.tsv.ori
ln -s XX/DIR/Repeat.bed ./rep.bed
```

# Pre-process files
```shell
cat bov_path_trace.tsv.ori  | perl -alne '$F[2]="$F[2]_$F[0]"; print join "\t", @F' > bov_path_trace.tsv

cat bov_graph.gfa | grep '^S' | perl -alne 'splice @F,2,1; print join "\t", @F' > thin.gfa

perl prase_gff.pl Ref.gff.gz Ref.gff.gene.gz

perl prase_gff.stat.pl Ref.gff.gene.gz Ref.gff.gene.gz.stat
```

# Compute SV location (exon / intron / intergenetic)
```shell
perl 1.trace_add_pos.pl thin.gfa  bov_path_trace.tsv 1.trace_add_pos.pl.out

cat 1.trace_add_pos.pl.out | perl -alne 'BEGIN{print join "\t", qw/svid type chr start end altlen reflen maxlen/} $reflen = $F[4]-$F[3]; $maxlen=$reflen>$F[5] ? $reflen : $F[5]; print join "\t", @F, $reflen, $maxlen' > 1.trace_add_pos.pl.out.stat

cat 1.trace_add_pos.pl.out.stat | perl -alne 'print if $.==1 or $F[-1]>50'  > 1.trace_add_pos.pl.out.stat.svonly

cat 1.trace_add_pos.pl.out | perl -alne 'print join "\t", @F[2,3], $F[4]+1, $F[0], $F[1], @F[3,4,5]' > 2.bed

#bedtools intersect -a 2.bed -b Ref.gff.gz -wb  > 3.bed.gff4
bedtools intersect -a 2.bed -b Ref.gff.gene.gz -wb  > 3.bed.gff4

Rscript 4.R
```
# Compute SV location (5k flank region)
```shell
bedtools intersect -a 2.bed -b Ref.gff.gz.5kbflk/3.5kbflk.bed -wb > 5.5kbflk.bed

cat 5.5kbflk.bed.R.tsv2 | perl -alne 'print and next if $.==1; $lref = $F[4]-$F[3]; $l=$lref>$F[5]?$lref:$F[5]; print if $l>50;' > 5.5kbflk.bed.R.tsv2.svonly

Rscript 6.gene2sv.R
```

# Compute SV location (repeat region)
```shell
cat 1.trace_add_pos.pl.out.stat.svonly | perl -alne 'next if $.==1; print join "\t", $F[2], $F[3], $F[4], $F[0]' > 2.svpos.bed

bedtools intersect -a 2.svpos.bed -b rep.bed -wo | sort | uniq > 3.union.bed

perl prase_bed.pl 2.svpos.bed   3.union.bed 4.merged.bed
```

