## ----setup, include=FALSE------------------------
library(tidyverse)
library(ggridges)
library(knitr)
knitr::opts_chunk$set(
  echo = TRUE,
  fig.path = "./figures/"
  )


## ---- data_preparation, message = FALSE----------
olympics = readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-27/olympics.csv')

olympics_alpine = olympics %>% 
  filter(!is.na(weight)) %>%             # only keep athletes with known weight
  filter(sport == "Alpine Skiing") %>%   # keep only alpine skiers
  mutate(
    medalist = case_when(                # add column describing whether athlete medaled at event 
      is.na(medal) ~ 'Did not medal',    # NA values go to 'Did not medal'
      !is.na(medal) ~ 'Medalist'         # non-NA values (Gold, Silver, Bronze) go to 'Medalist'
    )
  ) %>%
  mutate(
    event_class = case_when(             # add column with event class 
      sex == 'M' ~ 'Men\'s',             # M events are labeled Men's
      sex == 'F' ~ 'Women\'s',           # F events are labeled Women's
    )
  ) %>%
  mutate(
    sex = case_when(                     # re-label sex for nicer legends
      sex == 'F' ~ 'Female',
      sex == 'M' ~ 'Male'
    )
  ) 

# For Q2: 
# Remove redundant Alpine Skiing <Women's/Men's> in event labels
olympics_alpine$event = gsub('Alp.+en\'s', '', olympics_alpine$event)

# For Q3: 
# Re-order years so time increases as you move down y-axis
years_sorted = olympics_alpine %>% select(year) %>% arrange(-year) %>% distinct() 
olympics_alpine$year = factor(olympics_alpine$year, levels = years_sorted$year)

# Athletes from 1936 plotted as points, not densities
data_1936 = olympics_alpine %>% filter(year == '1936') 

# Remaining distinct athletes per year plotted as densities
data_remaining = olympics_alpine %>% distinct(year, id, .keep_all = T)


## ---- data_summaries, include=TRUE, eval=TRUE----
# Total events
olympics_alpine %>% nrow()

# Total athletes
olympics_alpine %>% distinct(id) %>% nrow()

# Distinct events
olympics_alpine %>% distinct(event) 


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- Q1_violin, fig.align = "center", fig.height = 4, fig.width = 5----
ggplot(olympics_alpine) +
  geom_violin(
    aes(
      x = sex, 
      y = weight, 
      fill = medalist
      ), 
    color = 'white'
    ) +
  labs(
    x = '', 
    y = 'Weight (kg)', 
    fill = '',
    title = 'Weight Distribution of Female and Male Olympic Skiers'
    ) +
  scale_fill_manual(values = c('#D55E00', '#009E73')) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = 'top'
    )


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- Q2_ridgeline, fig.align = "center", fig.height = 4, fig.width = 7, message=FALSE----
ggplot(olympics_alpine) +
  geom_density_ridges(
    aes(x = weight, y = event, fill = event_class),
    color = 'white', 
    scale = 1.8, alpha = 0.8, 
    rel_min_height = 0.01
    ) +
  labs(
    x = 'Weight (kg)', 
    y = '', 
    fill = 'Event Class:',
    title = 'Distribution of Weights in Olympic Alpine Skiing Events'
    ) +
  scale_fill_manual(
    values = c('#CC79A7', '#0072B2'), 
    breaks = c('Women\'s', 'Men\'s')
    ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = 'top'
    )


## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')


## ---- Q3_ridgeline, fig.align = "center", fig.height = 4.5, fig.width = 6, message=FALSE----
ggplot() + 
  # Weights of athletes from 1948-2014
  geom_density_ridges(
    aes(
      x = data_remaining$weight, 
      y = data_remaining$year, 
      fill = data_remaining$sex
      ),
    col = 'white', 
    scale = 1.8, 
    alpha = 0.8, 
    rel_min_height = 0.01
    ) +
  # Weights of 1936 athletes
  geom_point(
    aes(
      x = data_1936$weight, 
      y = data_1936$year, 
      col = data_1936$sex)
    ) +
  xlim(
    min(data_remaining$weight), 
    max(data_remaining$weight)
    ) +
  labs(
    x = 'Weight (kg)', 
    y = '', 
    fill = '', 
    color = '',
    title = 'Alpine Skier Weights Across Winter Olympics Years'
    ) +
  scale_fill_manual(values = c('#CC79A7', '#0072B2')) +
  scale_color_manual(values = c('#CC79A7', '#0072B2')) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = 'top'
    )



## ---- results='asis', eval=(opts_knit$get('rmarkdown.pandoc.to') == 'latex'), echo = FALSE----
cat('\\pagebreak')

