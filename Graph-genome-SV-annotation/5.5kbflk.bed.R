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


datori <- read_delim("2.bed",
                          "\t", escape_double = FALSE, col_names = FALSE,
                          trim_ws = TRUE)
names(datori) = c( 'chr', 'svstartbed', 'svstartbed', 'svid', 'type', 'svstart', 'svend', 'svaltlen')
datori = datori %>% select(-svstartbed, -svstartbed)

dat <- read_delim("5.5kbflk.bed",
                          "\t", escape_double = FALSE, col_names = FALSE,
                          trim_ws = TRUE)

names(dat)

names(dat) = c( 'chr', 'start', 'end', 'svid', 'type', 'svstart', 'svend', 'svaltlen', 'bed1', 'bed2', 'bed3' )



cluster <- new_cluster(24)
cluster_library(cluster, c("dplyr",'intervals'))
cluster_copy(cluster, "zzcallen")

datlen = dat %>%
  select(svid, type, start, end) %>%
  #head(1000) %>%
  group_by(svid, type) %>%
  partition(cluster) %>%
  summarise(flank=zzcallen(start, end-1) ) %>%
  collect()


svs = '4.R.tsv' %>%
  read_delim( "\t", escape_double = FALSE, col_names = T,
             trim_ws = TRUE)

  
datleng = datori %>%
  merge(svs, by=c('chr', 'svid', 'type', 'svstart', 'svend', 'svaltlen'), all=T) %>%
  merge(datlen, 
          by=c('svid', 'type'), all=T) %>%
  replace_na(list(CDS=0, gene=0, mRNA=0, flank=0))

datleng %>% write.table(file='5.5kbflk.bed.R.tsv', sep="\t", quote=F, row.names=F)


datleng %>% filter(mRNA != gene) # should be none


zzf2 = function(dat) {
  zzrownames = c('CDS', 'intro', 'intergenetic', 'flank')
  max_len_item_i = which.max(dat)
  #max_len = dat[max_len_item_i]
  max_len_item = zzrownames[max_len_item_i]
  return(max_len_item)
}


### test
dat2 = datleng %>%
  #head(2) %>% 
  mutate(intergenetic = intergenetic - flank) %>%
  mutate(intro = gene - CDS) %>%
  select(svid, type, chr, svstart, svend, svaltlen, svlen, 
          CDS, intro, intergenetic, flank) %>%
  mutate(func_type = select(., CDS, intro, intergenetic, flank) %>%
                    apply(1, zzf2) )
  
dat2 %>% write.table(file='5.5kbflk.bed.R.tsv2', sep="\t", quote=F, row.names=F)
