library(tidyverse)
library(magrittr)

library(readr)

library(readr)
i2spe <- read_delim("ids.spe.list", delim = "\t", 
                      escape_double = FALSE, col_names = FALSE, 
                      trim_ws = TRUE)

head(i2spe)
names(i2spe) = c("SID",'spe')

sids = dat$SID %>% unique() %>%
  gsub(pattern = '^ChrA', replacement = '') %>%
  gsub(pattern = '^fixA', replacement = '')  %>%
  gsub(pattern = '^ChrA', replacement = '') 


i2spe2 = i2spe %>%
  filter(! grepl('^Bub', SID)) %>%
  mutate(SID=gsub('_cds$','',SID)) %>%
  mutate(SID=gsub('_','A',SID)) %>%
  mutate(SID=gsub('ChrAARS-.*', 'ARS', SID)) %>%
  mutate(SID=gsub('^ChrA', '', SID)) %>%
  mutate(SID=gsub('^(.+)0(\\d)$', '\\1\\2', SID)) %>%
  mutate(SID=gsub('1', 'A', SID)) %>%
  mutate(SID=gsub('2', 'B', SID)) %>%
  mutate(SID=gsub('3', 'C', SID)) %>%
  mutate(SID=gsub('4', 'D', SID))# %>% #dim()
  #filter(! SID %in% sids) %>%
  as.data.frame() %$% sids %>% unique() %>% length()
  
#data.frame(SID=sids) %>%
dat %>%
  mutate(SID = gsub(pattern = '^ChrA', replacement = '', SID)) %>%
  mutate(SID = gsub(pattern = '^fixA', replacement = '', SID)) %>%
  mutate(SID = gsub(pattern = '^ChrA', replacement = '', SID)) %>%
  #filter( SID %in% i2spe2$SID)
  merge(by=c('SID'), i2spe2, all = T) %>% view()
  as.data.frame() %$% SID %>% unique() %>% length()
  as.data.frame()
  
  
  
dat <- read_delim("bov_coverage_by_samples.tsv", 
                                      delim = "\t", escape_double = FALSE, 
                                      trim_ws = TRUE)
head(dat)

dat$svtype %>% table

dat %>% 
  mutate(svtype = factor(x=svtype, levels=c('private','shared','softcore','core'),
                         labels = c('private','variable','softcore','core'))) %>%
  ggplot(aes(x=SID, y=sumlen,fill=svtype)) +
  geom_bar(stat='identity') +
  scale_y_continuous(breaks = c(0,0.7e9, 1.4e9, 2.1e9, 2.8e9),
                     labels = c(0, 0.7, 1.4, 2.1, 2.8)) +
  scale_fill_manual(values = c('#a1e8e4','#eccdb3','#59d4ee','#f9909c')) +
  theme_classic() +
  labs(fill=NULL) +
  ylab('Cumulative size (Gb)')


library(readr)
ids2spe <- read_delim("/data/01/user101/project/bov/xx4.addbov48/id2spe.csv", 
                      delim = "\t", escape_double = FALSE, 
                      col_names = T, trim_ws = TRUE)
head(ids2spe)

dat2 = dat %>% 
  merge(ids2spe, by=c('SID'), all.x = T)
  
  
library(ggthemes)

dat2 %>% 
  mutate(svtype = factor(x=svtype, levels=c('private','shared','softcore','core'),
                         labels = c('private','variable','softcore','core'))) %>%
  mutate(spe = factor(spe, levels = c('Ref', 'D', 'W', 'T', 'Z', 'Bison', 'Wisent', 'Gaur'))) %>%
  mutate(SID = factor(SID)) %>%
  ggplot(aes(x=fct_reorder(SID, spe, .fun = unique), y=sumlen,fill=svtype)) +
  geom_bar(stat='identity') +
  geom_point(aes(y = 0.9, color=spe)) +
  coord_cartesian(ylim = c(0, 2.8e9)) +
  scale_y_continuous(breaks = c(0,0.7e9, 1.4e9, 2.1e9, 2.8e9),
                     labels = c(0, 0.7, 1.4, 2.1, 2.8)) +
  scale_fill_manual(values = c('#a1e8e4','#eccdb3','#59d4ee','#f9909c')) +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0.5)) +
  #theme(axis.line = element_blank() ) +
  #theme_tufte() +
  #theme(axis.ticks.length = unit(4, "pt")) +
  labs(fill=NULL) +
  xlab(NULL) +
  ylab('Cumulative size (Gb)')





