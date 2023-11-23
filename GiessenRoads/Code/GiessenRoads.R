library(osmdata)
library(sf)
library(terra)
library(tidyverse)

##### City boundaries ####

Giessen_boundaries <- osmdata::getbb("Giessen Germany") %>%
                                  osmdata::opq() %>%
                                  add_osm_feature(key = 'boundary',
                                                  value = c('administrative')) %>%
                      osmdata::osmdata_sf() %>%
                      .$osm_multipolygons %>%
                    ### grabbing Giessen ###
                      dplyr::filter(name == "Gießen")


### Main streets 

Streets_Giessen <- osmdata::getbb("Giessen Germany") %>%
                            opq() %>%
                    add_osm_feature(key ='highway',
                                    value = c('motorway','primary',
                                              'secondary','tertiary')) %>%
                   osmdata::osmdata_sf() %>% .$osm_lines
  

### Small streets 

Small_streets_Giessen <- osmdata::getbb("Giessen Germany") %>%
                               opq() %>%
                        add_osm_feature(key ='highway',
                                        value = c('residential', 'living_street',
                                                  'service', 'footway')) %>%
                        osmdata::osmdata_sf() %>% .$osm_lines

#### Water 

water <- osmdata::getbb('Giessen Germany') %>%
                   opq() %>%
            add_osm_feature(key = 'natural',
                  value=c('water')) %>%
            osmdata::osmdata_sf() %>% .$osm_polygons

# Define a circular window
center <- st_centroid(Giessen_boundaries) # center of the circle
radius <- 5000 # define the radius
circle_window <- st_buffer(center, dist = radius) # create the circle

# Function to clip data to a circle
clip_to_circle <- function(data) {
  st_intersection(data, circle_window)
}

# Clip each dataset
Giessen_boundaries <- clip_to_circle(Giessen_boundaries)
Streets_Giessen <- clip_to_circle(Streets_Giessen)
Small_streets_Giessen <- clip_to_circle(Small_streets_Giessen)
water <- clip_to_circle(water)

p <- Giessen_boundaries %>%
  ggplot() +
  geom_sf(fill = "white") +
  geom_sf(data = Small_streets_Giessen,
          aes(color = 'Small Streets')) +
  geom_sf(data = Streets_Giessen,
          aes(color = 'Main Streets')) +
  geom_sf(data = water,
          aes(fill = "Waterways")) +
  scale_color_manual(
    values = c('Small Streets' = '#C8A2C8', 'Main Streets' = '#FF7F50'),
    name = "Street Types",
    breaks = c('Small Streets', 'Main Streets')
  ) +
  scale_fill_manual(
    values = c('Waterways' = '#87CEEB'),
    name = "Water Bodies",
    breaks = c('Waterways')
  ) +
  theme_void() +
  theme(panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        legend.position = c(0.1, 0.9),
        plot.caption = element_text(
          size = 10, color = "white",
          hjust = 0.98, vjust = 10
        ),
        legend.background = element_rect(fill = "black"),
        legend.text = element_text(color = "white",
                                   size = 12),
        legend.title = element_text(color = "white",
                                    size = 10),
        plot.title = element_text(hjust = 0.5, vjust = 1, size = 25, color = "white")) +
  labs(title = "Streets and waterways of Giessen",
       caption = "Data Source: Map data from OpenStreetMap")


ggsave(p,filename = "Giessen_Roads.png",width = 22, height = 10, dpi = 600,
       bg = "white", device = "png")



                   