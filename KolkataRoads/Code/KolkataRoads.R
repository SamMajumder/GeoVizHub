
library(osmdata)
library(sf)
library(terra)
library(tidyverse)

##### City boundaries ####

Kolkata_boundaries <- osmdata::getbb("Kolkata India") %>%
                           osmdata::opq() %>%
                           add_osm_feature(key = 'boundary',
                                           value = c('administrative')) %>%
                           osmdata::osmdata_sf() %>%
                           .$osm_multipolygons %>%
                      #### eliminate the state polygons ###
                           dplyr::filter(osm_id != 1960177)
                         
     
#### Defining the areas we want to show for our map ###

Kolkata_and_adjoining_areas <- Kolkata_boundaries %>%
                                dplyr::filter(name %in% c('Kolkata District',
                                                          'Serampur Uttarpara',
                                                          'Uluberia - I',
                                                          'Sankrail',
                                                          'Sonarpur',
                                                          'Thakurpukur Maheshtala',
                                                          'Budge Budge - I',
                                                          'Budge Budge - II',
                                                          'Bidhannagar',
                                                          'Barasat - I',
                                                          'Barasat - II',
                                                          'Baruipur',
                                                          'Barrackpore',
                                                          'Haora'))

                      
                           
### Main streets 

Streets_kolkata <- osmdata::getbb("Kolkata India") %>%
                                             opq() %>%
                              add_osm_feature(key ='highway',
                                              value = c('motorway','primary',
                                                        'secondary','tertiary')) %>%
                                                osmdata::osmdata_sf() %>% .$osm_lines
                                  
### Small streets 

Small_streets_kolkata <- osmdata::getbb("Kolkata India") %>%
                                                       opq() %>%
                            add_osm_feature(key ='highway',
                                            value = c('residential', 'living_street',
                                                      'service', 'footway')) %>%
                            osmdata::osmdata_sf() %>% .$osm_lines

#### Water 

water <- osmdata::getbb('Kolkata India') %>%
                      opq() %>%
                      add_osm_feature(key = 'natural',
                                      value=c('water')) %>%
         osmdata::osmdata_sf() %>% .$osm_polygons
  




p <- Kolkata_and_adjoining_areas %>%
  ggplot() +
  geom_sf(fill = "white") +
  geom_sf(data = Small_streets_kolkata,
          aes(color = 'Small Streets')) +
  geom_sf(data = Streets_kolkata,
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
          size = 8, color = "grey60",
          hjust = 0.1, vjust = 10
        ),
        legend.background = element_rect(fill = "black"),
        legend.text = element_text(color = "white",
                                   size = 12),
        legend.title = element_text(color = "white",
                                    size = 12),
        plot.title = element_text(hjust = 0.5, vjust = 1, size = 25, color = "white")) +
  labs(title = "Streets and waterways of Kolkata and adjoining areas",
       caption = "Data Source: ")


ggsave(p,filename = "Kolkata_Roads.png",width = 22, height = 10, dpi = 600,
       bg = "white", device = "png")
