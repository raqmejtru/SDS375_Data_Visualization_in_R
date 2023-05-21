## ----setup, include=FALSE------------------------
library(tidyverse)
library(broom)
library(cowplot)
knitr::opts_chunk$set(
  echo = TRUE,
  fig.path = "./figures/"
  )


## ---- message=FALSE------------------------------
rents = readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-07-05/rent.csv')


## ------------------------------------------------
rents_clean = rents %>%
  filter(room_in_apt == 0) %>%
  drop_na(price, beds, baths, sqft)


## ---- fig_1--------------------------------------
n_listings = nrow(rents_clean)
title = paste0('Complete observations across years', ' (n=', n_listings, ')')

rents_clean %>%
  ggplot() +
  geom_bar(aes(x = year)) +
  labs(title = title, subtitle = 'Figure 1') +
  theme_minimal()


## ------------------------------------------------
rents_subset = rents_clean %>%
  filter(year >= 2011) %>%
  select(year, price, beds, baths, sqft)


## ------------------------------------------------
# Perform PCA, save model.
rents_pc_fit = rents_subset %>%
  select(where(is.numeric)) %>% # select numeric columns
  scale() %>%                   # scale to mean=0, var=1
  prcomp()                      # perform PCA


## ---- fig_2--------------------------------------
# Arrow styling code from Dr. Wilke's dimension-reduction-1 slides:
arrow_style = arrow(
  angle = 20, length = grid::unit(8, 'pt'),
  ends = 'first', type = 'closed'
)

# Plot rotation of PC1 and PC2
plot_rotation = rents_pc_fit %>%
  tidy(matrix = 'rotation') %>%
  pivot_wider(
    names_from = 'PC',
    values_from = 'value',
    names_prefix = 'PC'
  ) %>%
  ggplot(aes(PC1, PC2)) +
  geom_segment(
    xend = 0,
    yend = 0,
    arrow = arrow_style,
    col = 'dark grey'
    ) +
  geom_text(
    aes(label = column),
    hjust = 0.5
    ) +
  xlim(-0.6, 0.2) +
  coord_fixed() +
  theme_minimal() +
  labs(subtitle = 'Contributions to PC1 and PC2')

# Plot % variance explained by PCs
plot_var = rents_pc_fit %>%
  tidy(matrix = 'eigenvalues') %>%
  ggplot(aes(PC, percent)) +
  geom_col() +
  scale_x_continuous(breaks = 1:4) +
  scale_y_continuous(
    name = 'variance explained',
    label = scales::label_percent(accuracy = 1)
  ) +
  theme_minimal() +
  labs(subtitle = 'Variance Explained by PCs') +
  theme(plot.title = element_text(hjust = 0.5))

# Combined plot
combined_plots = plot_grid(plot_rotation, plot_var)
combined_title = ggdraw() +
  draw_label(
    'Inspecting PCA Results',
    fontface = 'bold',
    x = 0,
    y = 1,
    hjust = 0
    ) +
  draw_label(
    'Figure 2',
    fontface = 'plain',
    size = 10,
    x = 0,
    y = 0.5,
    hjust = 0
    ) +
  theme(plot.margin = margin(0, 0, 0, 50))

plot_grid(
  combined_title,
  combined_plots,
  ncol = 1,
  rel_heights = c(0.1, 1)
  ) +
  theme(plot.margin = margin(6, 0, 0, 0))



## ---- fig_3, fig.height=9, fig.width=8-----------
# will be used to append original data to PCs
rents_w_name = rents_clean %>% filter(year >= 2011)

# number of neighborhoods
# (used to generate palette at from http://medialab.github.io/iwanthue/)
num_nhoods = rents_w_name %>% distinct(nhood) %>% nrow()
nhood_palette = read.csv('palette_i_want_hue.csv', header = F)

# % variance explained labels
pct_var = rents_pc_fit %>%
  tidy(matrix = 'eigenvalues') %>%
  filter(PC == 1 | PC == 2) %>%
  select(percent) %>%
  mutate(percent = percent*100) %>%
  round(digits = 1) %>%
  as.list() %>%
  unlist()

# PC1 & PC2 faceted by county, colored by neighborhood.
rents_pc_fit %>%
  augment(rents_w_name) %>%
  drop_na(county) %>%
  ggplot(aes(.fittedPC1, .fittedPC2)) +
  geom_point(
    aes(col = nhood),
    alpha = 0.2
    ) +
  labs(
    x = paste0('PC1', ' (', pct_var[1], '%)'),
    y = paste0('PC2', ' (', pct_var[2], '%)'),
    title = 'Effects of PC1 and PC2 on Housing Listings in the California Bay Area',
    subtitle = 'Figure 3\nColors correspond to neighborhood (144 total)'
    ) +
  scale_color_manual(values = nhood_palette$V1) +
  facet_wrap(
    ~county,
    nrow = 5
    ) +
  coord_fixed() +
  theme_minimal() +
  theme(legend.position = 'none')

