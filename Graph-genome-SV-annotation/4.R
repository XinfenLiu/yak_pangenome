# cal: sv in genes


library(readr)
library(multidplyr)
library(dplyr, warn.conflicts = FALSE)
library(tidyverse)
library(intervals)

zzcallen = function(starts, ends) {
  unions = data.frame(start=starts, end=ends) %>% Intervals() %>%
    interval_union()
  ret_len = 0
  for (i in seq( dim(unions)[1] )) {
    ret_len = ret_len + unions[i,2] - unions[i,1]
  }
  return(ret_len)
}



dat <- read_delim("3.bed.gff4", 
                          "\t", escape_double = FALSE, col_names = FALSE, 
                          trim_ws = TRUE)

names(dat)

names(dat) = c( 'chr', 'start', 'end', 'svid', 'type', 'svstart', 'svend', 'svaltlen', 'gffchr', 'gffsource', 'gfftype', 'gffstart', 'gffend', 'gffphase', 'gffstrand', 'gffxx','gffname' )



cluster <- new_cluster(24)
cluster_library(cluster, c("dplyr",'intervals'))
cluster_copy(cluster, "zzcallen")

datlen = dat %>%
  select(svid, gfftype, type, start, end) %>%
  #head(1000) %>%
  group_by(svid, gfftype, type) %>%
  partition(cluster) %>%
  summarise(len=zzcallen(start, end-1) ) %>%
  collect()

datleng = datlen %>% spread(key = 'gfftype', value = 'len')

svs = '1.trace_add_pos.pl.out' %>%
  read_delim( "\t", escape_double = FALSE, col_names = FALSE, 
             trim_ws = TRUE)
names(svs) = c('svid','type', 'chr', 'svstart', 'svend', 'svaltlen')

svs = svs %>% mutate(svlen = svend-svstart)

datleng = datleng %>% merge(svs, by=c('svid', 'type'), all=T) %>%
  replace_na(list(CDS=0, gene=0, mRNA=0)) %>%
  mutate(intergenetic = svlen-gene)

datleng %>% write.table(file='4.R.tsv', sep="\t", quote=F, row.names=F)






