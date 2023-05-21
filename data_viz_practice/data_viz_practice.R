## ----setup, include=FALSE------------------------
library(tidyverse)
library(knitr)
library(ggridges)
library(cowplot)
library(colorspace)
library(ggforce)
library(naniar)
library(shinyjs)
library(broom)
library(kableExtra)

knitr::opts_chunk$set(
  echo = TRUE,
  fig.path = "./figures/"
  )


## ---- HW1_Q1-------------------------------------
ggplot(economics) +
  geom_line(aes(x = date, y = pop)) +
  labs(
    x = 'Year',
    title = 'U.S. Population Size Over Time'
    ) +
  scale_y_continuous(
    'Population (Thousands)',
    labels =  scales::comma
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


## ---- HW1_Q2-------------------------------------
ggplot(economics) +
  geom_point(
    aes(x = pop, y = unemploy, col = date)
    ) +
  scale_y_continuous(
    'Number of Unemployed (Thousands)',
    labels =  scales::comma
    ) +
  scale_x_continuous(
    'Population (Thousands)',
    labels =  scales::comma
    ) +
  labs(
    col = 'Year',
    title = 'Unemployment Ratio Over Time'
    ) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


## ---- message=FALSE------------------------------
# data prep:
txhouse = txhousing %>%
  filter(city %in% c('Austin', 'Houston', 'San Antonio', 'Dallas')) %>%
  filter(year %in% c('2000', '2005', '2010', '2015')) %>%
  group_by(city, year) %>%
  summarize(total_sales = sum(sales))


## ---- HW2_Q1-------------------------------------
ggplot(txhouse) +
  geom_col(
    aes(
      x = total_sales,
      y = fct_reorder(city, total_sales)
      )
    ) +
  facet_wrap(~year, nrow = 1) +
  labs(
    y = '',
    title = 'Texas Real Estate Sales Across the 2000s'
    ) +
  scale_x_continuous(
    name = "Number of sales",
    label = scales::unit_format(unit = "K", scale = 0.001, sep = "")
    ) +
  theme(plot.title = element_text(hjust = 0.5))


## ---- HW2_Q2-------------------------------------
ggplot(txhouse) +
  geom_col(
    aes(
      x = year,
      y = total_sales,
      fill = city
      ),
    col = "gray20"
    ) +
  labs(
    fill = 'City',
    x = 'Year',
    title = 'Texas Real Estate Sales Across the 2000s'
    ) +
  scale_y_continuous(
    name = 'Number of sales',
    label = scales::unit_format(unit = "K", scale = 0.001, sep = "")
    ) +
  scale_fill_viridis_d() +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


## ---- HW2_Q3-------------------------------------
ggplot(txhouse) +
  geom_col(
    aes(
      x = year,
      y = total_sales,
      fill = fct_reorder(city, -total_sales)
      ),
    position = "dodge",
    col = "gray20"
    ) +
  labs(
    fill = 'City',
    x = 'Year',
    title = 'Texas Real Estate Sales Across the 2000s'
    ) +
  scale_y_continuous(
    name = 'Number of sales',
    label = scales::unit_format(unit = "K", scale = 0.001, sep = "")
    ) +
  scale_fill_viridis_d() +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


## ---- HW3_Q1, fig.align="center", fig.height=3.5, fig.width=7----
ggplot(diamonds) +
  geom_bar(
    aes(x = color, fill = cut),
    alpha = 0.8
    ) +
  scale_y_continuous(
    name = 'Count',
    labels = scales::label_comma()) +
  labs(
    x = 'Color',
    title = 'Variation in Diamond Cut by Color'
    ) +
  scale_fill_brewer('Cut') +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


## ---- message=FALSE------------------------------
# data prep:
OH_pop = midwest %>%
  filter(state == "OH") %>%
  arrange(desc(poptotal)) %>%
  mutate(row = row_number()) %>%
  filter(poptotal >= 100000) %>%
  select(c(county, poptotal))


## ---- HW3_Q2, fig.align="center", fig.height=5, fig.width=7----
ggplot(OH_pop) +
  geom_point(aes(poptotal, reorder(county, poptotal))) +
  scale_x_continuous(
    breaks = seq(100000, 1400000, 200000),
    labels = scales::label_comma(scale = 0.001, suffix = 'K')
    ) +
  scale_y_discrete() +
  labs(
    x = 'Population Size',
    y = 'County',
    title = 'Population Size of Ohio Counties',
    subtitle = 'Note: data only represents counties with at least 100K inhabitants.'
  )


## ---- HW3_Q3, fig.align="center", fig.height=5, fig.width=7----
ggplot(OH_pop) +
  geom_point(aes(poptotal, reorder(county, poptotal))) +
  scale_x_log10(
    breaks = seq(100000, 1500000, 200000),
    label = scales::label_comma(scale = 0.001, suffix = 'K')
    ) +
  scale_y_discrete() +
  theme(axis.text.x = element_text(angle = 315, vjust = -0.3)) +
  labs(
    x = 'Population Size',
    y = 'County',
    title = 'Population Size of Ohio Counties',
    subtitle = 'Note: data only represents counties with at least 100K inhabitants.'
  )


## ---- HW4_Q1, fig.align = "center", fig.height = 4.5, fig.width = 7.5----
# Define base layer of plot
base_plot = mpg %>%
  ggplot(aes(x = cyl, y = hwy)) +
  labs(
    x = 'Number of Cylinders',
    y = 'Highway Miles Per Gallon'
    ) +
  theme_minimal() +
  theme(plot.subtitle = element_text(face = 'italic', hjust = 0.5)) +
  background_grid(minor = 'none')

# Plot without jitter
no_jitter = base_plot +
  geom_point(
    alpha = 0.5, shape = 16
    ) +
  labs(subtitle = 'No jitter:')

# Plot with jitter
jitter = base_plot +
  geom_point(
    alpha = 0.5, shape = 16,
    position = position_jitter(width = 0.2, height = 0)
    ) +
  labs(subtitle = 'With jitter:')

# Combine two plots onto one row
combined = plot_grid(no_jitter, jitter)

# Define a title for the combined figure
title = ggdraw() +
  draw_label(
    'Effect of Cylinders on Highway Fuel Economy',
     hjust = 0.5, fontface = 'bold'
    )

# Add title to combined figure
plot_grid(
  title,
  combined,
  ncol = 1,
  rel_heights = c(0.1, 1)
  )


## ---- HW4_Q2, fig.align = "center", fig.height = 7, fig.width = 7.5, message=FALSE----
# Clean drive train labels
mpg$drv = gsub('4$', '4WD', mpg$drv)
mpg$drv = gsub('f', 'FWD', mpg$drv)
mpg$drv = gsub('r', 'RWD', mpg$drv)

# Define base plot
base2_plot = mpg %>%
  ggplot(aes(x = cty, y = class, fill = drv)) +
  labs(
    x = 'City Miles Per Gallon',
    y = 'Class',
    fill = 'Drive Train'
    ) +
  scale_x_continuous(
    limits = c(min(mpg$cty), max(mpg$cty))
    ) +
  theme_minimal()

# Box plot
box = base2_plot +
  geom_boxplot() +
  theme(legend.position = 'none')

# Ridgeline of densities
ridge = base2_plot +
  # Color set to drive train here to remove harsh black outline
  geom_density_ridges(scale = 1, alpha = 0.8, rel_min_height = 0.01) +
  theme(legend.position = 'bottom')

# Combine two plots onto one row
combined = plot_grid(box, ridge, nrow = 2)

# Define a title for the combined figure
title = ggdraw() +
  draw_label(
    'Variation in City Fuel Economy by Car Class and Drive Train',
    hjust = 0.5, fontface = 'bold'
    )

# Add title to combined figure
plot_grid(
  title,
  combined,
  ncol = 1,
  rel_heights = c(0.1, 1)
  )


## ---- message=FALSE------------------------------
# data prep:
ufo_sightings = read_csv("https://wilkelab.org/classes/SDS348/data_sets/ufo_sightings_clean.csv") %>%
  separate(datetime, into = c("month", "day", "year"), sep = "/") %>%
  separate(year, into = c("year", "time"), sep = " ") %>%
  separate(date_posted, into = c("month_posted", "day_posted", "year_posted"), sep = "/") %>%
  select(-time, -month_posted, -day_posted) %>%
  mutate(
    year = as.numeric(year),
    state = toupper(state)
  ) %>%
  filter(!is.na(country))


## ------------------------------------------------
ufo_sightings %>%
  filter(year >= 2000) %>%
  group_by(city) %>%
  summarise(sighting_count = n()) %>%
  arrange(-sighting_count) %>%
  slice(1:10) %>%
  kable()


## ---- message=FALSE------------------------------
keep_states = c('AZ', 'IL', 'NM', 'OR', 'WA')
ufo_filtered_states = ufo_sightings %>%
  filter(year >= 1940) %>%
  filter(state %in% keep_states) %>%
  select(year, state) %>%
  group_by(year, state) %>%
  summarise(count = n()) %>%
  arrange(state)

ufo_filtered_states %>% head() %>% kable()


## ---- HW5_Q3, eval=TRUE, message=FALSE-----------
ufo_filtered_states %>%
  ggplot() +
  geom_line(
    aes(x = year, y = count, color = state),
    alpha = 0.7,
    size = 1.2
    ) +
  labs(
    x = 'Year',
    y = 'UFO Sightings (Count)',
    title = 'Increased UFO Sightings Since 1940s'
    ) +
  theme_minimal() +
  scale_color_discrete_qualitative(palette = "Dark 2") +
  scale_x_continuous(breaks = seq(1940, 2020, 10)) +
  theme(plot.title = element_text(hjust = 0.5))


## ---- message=FALSE------------------------------
# data prep:
olympics = readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-07-27/olympics.csv')
olympics_2002 <- olympics %>%
  filter(year == 2002, season == "Winter") %>%
  select(sex) %>%
  count(sex) %>%
  pivot_wider(names_from = sex, values_from = n)


## ------------------------------------------------
long = olympics_2002 %>%
  pivot_longer(1:2, names_to = 'sex', values_to = 'count')

long %>% kable()


## ------------------------------------------------
long_pct = long %>%
  mutate(percent = round(count/sum(count), 3)*100)

long_pct %>% kable()


## ------------------------------------------------
olympics_2002_clean = long_pct %>%
    mutate(sex = case_when(
      sex == 'F' ~ 'Female',
      sex == 'M' ~ 'Male'
      )
    )
olympics_2002_clean %>% kable()


## ---- HW6_Q2, fig.height=3.25--------------------
# Clean labels
female_stat = paste0(olympics_2002_clean$percent[1], '%')
male_stat = paste0(olympics_2002_clean$percent[2], '%')
total_athletes = paste0('Based on ', sum(olympics_2002_clean$count), ' total athletes')

olympics_2002_clean %>%
  ggplot(aes(x = percent, y = '', fill = sex)) +
  geom_col(alpha = 0.9) +
  scale_fill_manual(
    values = c('#D55E00', '#0072B2'),
    breaks = c('Female', 'Male')
    ) +
  coord_polar() +
  theme_void() +
  geom_text(
    aes(x = 80, y = 1, fontface = 2),
    col = 'white',
    label = female_stat
  ) +
  geom_text(
    aes(x = 30, y = 1, fontface = 2),
    col = 'white',
    label = male_stat
  ) +
  labs(
    title = 'Composition of 2002 Winter Olympic Athletes',
    subtitle = total_athletes,
    fill = 'Sex'
    ) +
  theme(plot.subtitle = element_text(face = 'italic'))


## ---- HW7_Q1-------------------------------------
my_palette = c('#A23C42', '#F2C265', '#607665', '#36364F')
swatchplot(my_palette)


## ------------------------------------------------
#data prep:
midwest2 = midwest %>%
  filter(state != "IN")


## ---- HW7_Q2, fig.width=6------------------------
midwest2 %>%
ggplot() +
  geom_point(
    aes(
      popdensity,
      percollege,
      fill = state
      ),
    shape = 21,
    size = 3,
    color = "black",
    stroke = 0.1
    ) +
  scale_x_log10() +
  scale_y_continuous() +
  scale_fill_manual(values = my_palette) +
  labs(
    x = 'Population density',
    y = 'Percent college educated',
    title = 'Effect of population density on college education'
  ) +
  theme_classic(12) +
  theme(
    axis.text = element_text(size = 12, color = 'black'),
    plot.background = element_rect(fill = '#FEF8F0', color = '#FEF8F0'),
    panel.background = element_rect(fill = '#FEF8F0'),
    legend.background = element_rect(fill = '#FEF8F0'),
    plot.title = element_text(hjust = 0.5)
  )


## ------------------------------------------------
#data prep:
oceanbuoys$year = factor(oceanbuoys$year)
oceanbuoys = na.omit(oceanbuoys)


## ---- HW7_Q3-------------------------------------
cel_to_far = function(temp_c){
  temp_f = 32 + (temp_c*1.8)
  return(temp_f)
}

oceanbuoys %>%
  mutate(
    sea_temp_f = cel_to_far(sea_temp_c),
    air_temp_f = cel_to_far(air_temp_c)
  ) %>%
  select(1, 9, 10) %>%
  group_by(year) %>%
  summarize(
    avg_sea_temp_f = round(mean(sea_temp_f, na.rm = T), 2),
    avg_air_temp_f = round(mean(air_temp_f, na.rm = T), 2)
    ) %>%
  kable()


## ---- message=FALSE------------------------------
#data prep:
BA_degrees = read_csv("https://wilkelab.org/SDS375/datasets/BA_degrees.csv")


## ---- HW8_Q1, fig.width=7, warning=FALSE---------
subset_fields = c('Business', 'Education', 'Psychology')
BA_degrees %>%
  filter(field %in% subset_fields) %>%
  group_by(field) %>%
  mutate(
    range = abs(max(perc) - min(perc))
    ) %>%
  ggplot(aes(x = year, y = perc)) +
  geom_point(col = 'dark grey') +
  geom_smooth(
    formula = y ~ x,
    method = 'lm'
    ) +
  facet_wrap(
    vars(reorder(field, -range))
    ) +
  labs(
    x = '',
    y = 'Proportion',
    title = 'Degree Popularity into the 21st century'
    ) +
  theme(
    panel.background = element_rect(fill = 'white'),
    axis.line = element_line(color = 'grey'),
    panel.grid = element_line(color = '#ececec'),
    plot.title = element_text(hjust = 0.5)
    )


## ---- HW8_Q2-------------------------------------
subset_fields = c('Business', 'Education', 'Psychology')
BA_degrees %>%
  filter(field %in% subset_fields) %>%
  nest(data = -field) %>%
  mutate(
    fit = map(data, ~lm(perc ~ year, data = .x)),
    glance_out = map(fit, glance)
    ) %>%
  select(field, glance_out) %>%
  unnest(cols = glance_out) %>%
  mutate(across(2:13, round, 4)) %>%
  kable()


## ----message = FALSE-----------------------------
heart_data = read_csv('https://wilkelab.org/SDS375/datasets/heart_disease_data.csv')


## ------------------------------------------------
# Perform PCA, save model.
heart_pc_fit = heart_data %>%
  select(where(is.numeric)) %>% # select numeric columns
  scale() %>%                   # scale to mean=0, var=1
  prcomp()                      # perform PCA

# Styling code from Dr. Wilke's dimension-reduction-1 slides:
arrow_style = arrow(
  angle = 20, length = grid::unit(8, 'pt'),
  ends = 'first', type = 'closed'
)


## ---- HW9_Q1a, fig.height=4.5--------------------
# Plot rotation of PC1 and PC2
heart_pc_fit %>%
  tidy(matrix = 'rotation') %>%  # extract rotation matrix
  pivot_wider(                   # pivot so each PC is a col
    names_from = 'PC', values_from = 'value',
    names_prefix = 'PC'
  ) %>%
  ggplot(aes(PC1, PC2)) +
  geom_segment(
    xend = 0, yend = 0,
    arrow = arrow_style,
    col = 'dark grey'
  ) +
  geom_text(
    aes(label = column),
    hjust = 0.5
    ) +
  xlim(-0.8, 0.8) +
  ylim(-.8, .5) +
  theme_minimal() +
  coord_fixed() +
  ggtitle('Effects of Variables on PC1 and PC2 of Heart Health')


## ---- HW9_Q1b, fig.height=4.5, fig.width=7-------
# Plot % variance explained by PCs
heart_pc_fit %>%
  tidy(matrix = 'eigenvalues') %>% # extract eigenvalues
  ggplot(aes(PC, percent)) +
  geom_col() +
  scale_x_continuous(
    # create one axis tick per PC
    breaks = 1:8
  ) +
  scale_y_continuous(
    name = 'variance explained',
    # format y axis ticks as percent values
    label = scales::label_percent(accuracy = 1)
  ) +
  theme_minimal() +
  ggtitle('Variance of Heart Health Explained by PCs')




## ---- HW9_Q2, fig.height=5-----------------------
pct_var = heart_pc_fit %>%
  tidy(matrix = 'eigenvalues') %>%
  filter(PC == 1 | PC == 2) %>%
  select(percent) %>%
  mutate(percent = percent*100) %>%
  round(digits = 1) %>%
  as.list() %>%
  unlist()

heart_pc_fit %>%
  augment(heart_data) %>%                # add model to data
  ggplot(aes(.fittedPC1, .fittedPC2)) +  # plot PC1, PC2
  geom_point(
    aes(color = HeartDisease),
    shape = 1, alpha = 0.5
    ) +
  labs(
    x = paste0('PC1', ' (', pct_var[1], '%)'),
    y = paste0('PC2', ' (', pct_var[2], '%)'),
    title = 'Effects of PC1 and PC2 on Heart Health'
    ) +
  theme_minimal() +
  coord_fixed()


## ------------------------------------------------
heart_pc_fit %>%
  tidy(matrix = 'rotation') %>%
  filter(PC == 1 | PC == 2) %>%
  arrange(value) %>%
  slice(1:3) %>%
  mutate(value = round(value, digits = 3)) %>%
  rename(variable = column, contribution = value) %>%
  kable()

