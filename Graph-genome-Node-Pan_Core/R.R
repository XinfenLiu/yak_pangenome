library(tidyverse)
library(readr)
library(magrittr)

dat <- read_table2("bov_coverage.tsv")
head(dat)

fin = dat %>% filter(rrank!=0) %>%
  select(-start_chromo, -start_pos, -rrank, -nodeid) %>% 
  #head(10) %>% 
  gather(key = 'sid', value = 'cov', -nodelen) %>%
  #mutate(cov=if_else(cov>0, 1, 0)) %>%
  filter(cov>0) %>%
  group_by(sid) %>%
  summarise(sumlen = sum(nodelen), sumcount=n()) %>%
  ungroup()

write.csv(x = fin, file = '2.fin.csv')

fin %>% filter(! grepl('Bub', x = sid)) %$% sumcount %>% mean()



# shared by all samples
idhas = dat %>% #filter(rrank!=0) %>%
  select(-start_chromo, -start_pos, -rrank, -nodeid) %>% 
  select(-starts_with('Bub')) %>%
  #head(10) %>%
  select(-nodelen) %>% apply(1, function(d) {sum(d>0)}) %>% unlist()
  
ids_total = max(idhas)

dat2 = dat %>% select(nodelen, rrank) %>%
  mutate(idhas=idhas)


dat2[, 'type'] = 'dispensable'
dat2[which(dat2$idhas==1), 'type'] = 'pravate'
dat2[which(dat2$idhas> 0.9*ids_total), 'type'] = 'softcore'
dat2[which(dat2$idhas==ids_total), 'type'] = 'core'


fin2 = dat2 %>% group_by(type) %>%
  summarise(sumlen = sum(nodelen), sumcount=n()) %>%
  ungroup()  
write.csv(x = fin2, file = '2.fin2.csv')


fin2$sumlen %>% sum()

fin2 %>% mutate(sumlen = sumlen/sum(sumlen),
                sumcount = sumcount / sum(sumcount) ) %>%
  write.csv(file = '2.fin2.2.csv')

