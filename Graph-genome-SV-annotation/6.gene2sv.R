library(readr)
library(multidplyr)
library(dplyr, warn.conflicts = FALSE)
library(tidyverse)
library(intervals)
library(magrittr)

zzcallen = function(starts, ends) {
  unions = data.frame(start=starts, end=ends) %>% Intervals() %>%
    interval_union()
  ret_len = 0
  for (i in seq( dim(unions)[1] )) {
    ret_len = ret_len + unions[i,2] - unions[i,1]
  }
  return(ret_len)
}

svs = '1.trace_add_pos.pl.out' %>%
  read_delim( "\t", escape_double = FALSE, col_names = FALSE, 
             trim_ws = TRUE)
names(svs) = c('svid','type', 'chr', 'svstart', 'svend', 'svaltlen')

svs = svs %>% mutate(svreflen = svend-svstart)

svs$maxlen = svs %>% select(svreflen, svaltlen) %>% apply(1, max) %>% unlist()

need_svids = svs %>% filter(maxlen>=50) %$% svid



dat <- read_delim("3.bed.gff4", 
                          "\t", escape_double = FALSE, col_names = FALSE, 
                          trim_ws = TRUE)

names(dat)

names(dat) = c( 'chr', 'start', 'end', 'svid', 'type', 'svstart', 'svend', 'svaltlen', 'gffchr', 'gffsource', 'gfftype', 'gffstart', 'gffend', 'gffphase', 'gffstrand', 'gffxx','zzgene' )



cluster <- new_cluster(24)
cluster_library(cluster, c("dplyr",'intervals'))
cluster_copy(cluster, "zzcallen")

datlen = dat %>%
  filter(svid %in% need_svids) %>% ############## sel sv only
  select(zzgene, gfftype, type, start, end) %>%
  #head(1000) %>%
  group_by(zzgene, gfftype) %>%
  partition(cluster) %>%
  summarise(len=zzcallen(start, end-1) ) %>%
  collect() %>%
  ungroup()

sv_intro = datlen %>% spread(gfftype, len) %>%
    replace_na(list(mRNA=0, CDS=0)) %>%
    mutate(intro=mRNA-CDS) %>% select(zzgene, intro)

datlen2 = sv_intro %>% mutate(gfftype = 'intro') %>% rename('len'='intro') %>% 
    select(zzgene, gfftype, len) %>% rbind(datlen)


genelist = read_delim("Ref.gff.gene.gz.stat", "\t", escape_double = FALSE, col_names = FALSE,  trim_ws = TRUE)
names(genelist) = c('zzgene', 'gfftype', 'gfftypelen')

gene_intro = genelist %>% spread(gfftype, gfftypelen) %>% mutate(intro=mRNA-CDS) %>% select(zzgene, intro)

genelist = gene_intro %>% mutate(gfftype = 'intro') %>% rename('gfftypelen'='intro') %>%
    select(zzgene, gfftype, gfftypelen) %>%
    rbind(genelist)


datleng = datlen2 %>% merge(genelist, by=c('zzgene', 'gfftype'), all=T) %>%
  replace_na(list(len=0)) %>%
  mutate(zzgene = gsub('^GENE=','',zzgene)) %>%
  rename('sv_covered'='len', 'totallen'='gfftypelen') %>%
  filter(totallen>0) %>% ############################# overlap percentage!!!!!!!!!!!
  mutate(sv_percent = sv_covered/totallen )



datleng %>% write.table(file='6.R.tsv', sep="\t", quote=F, row.names=F)

datleng %>% filter(sv_percent>0) %$% table(gfftype) %>% as.data.frame() %>%
    write.table(file='6.R.tsv.stat', sep="\t", quote=F, row.names=F)











