## ----setup, include=FALSE------------------------
library(tidyverse)
library(ggridges)
library(RColorBrewer)
library(knitr)
knitr::opts_chunk$set(
  echo = TRUE,
  fig.path = "./figures/"
  )


## ----message = FALSE-----------------------------
members = readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-09-22/members.csv')


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- Q1_frequency_framing, fig.align = "center", fig.height = 4, fig.width = 7, message=FALSE----
# Determine proportion of successful expeditions based on season
pr_success_df = members %>%
  filter(season != 'Unknown') %>%
  distinct(expedition_id, .keep_all = T) %>%
  group_by(season) %>%
  summarise(pr_success = mean(success, na.rm = T), season) %>%
  distinct(pr_success) %>% 
  arrange(pr_success)

# Save probabilities as vector
pr_success_ls = pr_success_df$pr_success

# This function is used to create a df representing a sampling grid with overall
# probabilities defined by `pr_success_ls`
# written by Kris Sankaran:
# https://krisrs1128.github.io/stat679_notes/2022/06/02/week13-1.html
sample_grid = function(p = 0.5) {
  expand.grid(seq_len(25), seq_len(25)) %>%
  mutate(response = sample(0:1, n(), replace = TRUE, prob = c(1 - p, p)))
}

# Lines 64-66 also written by Kris Sankaran :
# https://krisrs1128.github.io/stat679_notes/2022/06/02/week13-1.html
success_grid = map(pr_success_ls, ~ sample_grid(.)) %>%
  bind_rows(.id = "p") %>%
  mutate(pr_success_ls = pr_success_ls[as.integer(p)]) 

# Loop creates labels that will be used in frequency framing plot
for (i in 1:4) {
  # Label: {season} (XX.X%)
  pct_label = paste0(
    pr_success_df$season[i], 
    ' (', 
    round(pr_success_df$pr_success[i]*100, 1), 
    '%)'
    )
  success_grid$pr_success_ls = gsub(
    pr_success_df$pr_success[i], 
    pct_label, 
    success_grid$pr_success_ls
    )
}

# Plot frequency framing grid
success_grid %>%
  ggplot() +
  geom_tile(
    aes(Var1, Var2, fill = as.factor(response)), 
    col = "white", 
    linewidth = 0.5
    ) +
  facet_grid(~pr_success_ls) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_continuous(expand = c(0, 0)) +
  coord_fixed() +
  labs(
    fill = '', 
    col = '', 
    title = 'Proportion of Successful Expeditions Across Seasons'
    ) +
  scale_fill_manual(
    values = c("light grey", "black"),
    labels = c('Unsuccessful', 'Successful')
    ) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    plot.title = element_text(hjust = 0.5)
  )



## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- Q2_2D_density, fig.align = "center", fig.height = 4.5, fig.width = 5, message=FALSE, warning=FALSE----
members %>%
  select(age, highpoint_metres) %>%
  ggplot(aes(age, highpoint_metres)) +
  geom_density_2d_filled(alpha = 0.8) +
  labs(
    x = 'Age (years)', 
    y = 'Elevation highpoint (m)', 
    title = 'Effect of Age on a Climber\'s Elevation Highpoint'
    ) +
  scale_fill_manual(
    values = colorRampPalette(brewer.pal(9, 'Blues'))(14)
    ) +
  scale_x_continuous(limits = c(15, 65)) +
  scale_y_continuous(limits = c(5000, 9000)) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = 'none'
    )


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')

