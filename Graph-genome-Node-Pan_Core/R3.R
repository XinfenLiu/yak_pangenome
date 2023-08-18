library(readr)
library(tidyverse)
library(magrittr)

core_percent = 1
soft_core_percent = 0.6

zzread = function(file) {
  zzsumarise = function(dat) {
    ret = dat %>% 
      group_by(idcount, ids) %>% summarise(nodes = sum(nodes), nodelens = sum(nodelens)) %>%
      group_by(idcount) %>% summarise(nodes = mean(nodes), nodelens = mean(nodelens))
    return(ret)
  }
  #file =  './list/yak.list.out'
  dat <- file %>%
    read_delim("\t", escape_double = FALSE, trim_ws = TRUE) %>%
    filter(i>0) %>%
    #filter(isRef==0) %>%
    mutate(percent = i/idcount) %>%
    mutate(is_core = if_else(percent >= core_percent, 1, 0)) %>%
    mutate(is_softcore = if_else(percent < core_percent & percent >= soft_core_percent, 1, 0)) %>%
    mutate(is_private = if_else(i==1 & idcount>1, 1, 0))
  core = dat %>%
    filter(is_core==1) %>%
    zzsumarise()
  pan = dat %>%
    #filter(is_core==1) %>%
    zzsumarise()
  private = dat %>%
    filter(is_private==1) %>%
    zzsumarise()
  return( list(pan, core, private) )
}

t = './2.YAK.list.out' %>% zzread()
yak_pan = t[[1]]
yak_core = t[[2]]
yak_private = t[[3]]


t = './3.YAK_cattle.list.out' %>% zzread()
tau_pan = t[[1]]
tau_core = t[[2]]
tau_private = t[[3]]

t = './4.YAK_cattle_BWG.list.out' %>% zzread()
append_pan = t[[1]]
append_core = t[[2]]
append_private = t[[3]]

merged_pan = rbind(yak_pan, tau_pan, append_pan)
merged_core = rbind(yak_core, tau_core, append_core)


# sum
pdf(file = 'R.R.pdf', width = 5, height = 3)
ggplot() +
  geom_bar(stat = 'identity', data=merged_pan, aes(x=idcount, y=nodelens), fill='#7AD3D1') +
  geom_bar(stat = 'identity', data=merged_core, aes(x=idcount, y=nodelens), fill='#E96A64') +
  #geom_hline(yintercept = 2748879150, linetype=2, size=0.5, color='gray40', alpha=0.9) +
  geom_vline(xintercept = 22.48, linetype=1, size=0.5, color='gray40', alpha=0.9) +
  geom_vline(xintercept = 44.48, linetype=1, size=0.5, color='gray40', alpha=0.9) +
  coord_cartesian(ylim = c(1.3e9,3.35e9), xlim = c(2,47)) +
  #scale_x_continuous(breaks = c(1,10,20,30)) +
  scale_y_continuous(breaks = seq(1.3e9, 3.4e9, 0.5e9), 
                     labels = seq(1.3, 3.4, 0.5), 
  ) +
  scale_x_continuous(breaks = c(1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 48),
                     labels = c(1, '', 10, '',20, '', 30, '', 40, '', 48 ),
                     ) +
  xlab(NULL) +
  ylab('Cumulative size(Gb)') +
  theme_classic() +
  theme(axis.text.x = element_text(color='black')) +
  theme(axis.text.y = element_text(color='black'))
dev.off()




