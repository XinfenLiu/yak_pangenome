# Prepare Files
```shell
# After perfomed bovine-graphs
cd analysis/bubble
```

# Statistic of Core/Pan/Private Nodes
```shell
    ln -s ../*_coverage.tsv ./bov_coverage.tsv
    Rscript R.R
    cat *.csv
```

# Plot Core/Pan/Private Nodes for each samples
## Generate ids.spe.list:
    Two colume with no header: ID SPE
## Compute
```shell
    Rscript R2.R
```

# Plot Core/Pan Nodes lengh and count
## Generate id2spe.csv:
    3 colume with no header: SID SID1 spe
## Compute
```shell
cat id2spe.csv | perl -alne '$s=$F[-1]; $s="YAK" if $s ~~ [qw/D W/]; $s="cattle" if $s~~[qw/T Z/]; $s="BWG" if $s~~[qw/Gaur Bison Wisent/]; print join "\t", @F, $s;' | grep -v SID | sort -k4,4 > id2spe.csv2

cat id2spe.csv2 | grep YAK | cut -f1 > 2.YAK.list

cat id2spe.csv2 | perl -alne 'if($F[3] eq "YAK") {print join "\t", $F[0],1}; if($F[3] eq "cattle"){print join "\t", $F[0], 0}' > 3.YAK_cattle.list

cat id2spe.csv2 | perl -alne 'if($F[3] eq "YAK") {print join "\t", $F[0],1}; if($F[3] eq "cattle"){print join "\t", $F[0], 1}; if($F[3] eq "BWG"){print join "\t", $F[0], 0}' > 4.YAK_cattle_BWG.list


for i in 2.YAK.list 3.YAK_cattle.list 4.YAK_cattle_BWG.list  ; do i=$(pwd)/$i;  echo "python3 /data/01/user101/project/bov/01.build_pan/remap/list/tsv2pan_core.py -i /data/01/user101/project/bov/xx4.addbov48/remap/Bov_Pan_coverage.tsv -t 50 --ids_list_file $i -o $i.out --max_rep_count 500 > $i.out.log 2>&1 "; done > x1.sh

sh x1.sh
```
