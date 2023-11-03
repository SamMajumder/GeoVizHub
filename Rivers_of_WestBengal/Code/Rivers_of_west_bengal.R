

packages <- list("here","tidyverse","raster","ggplot2","sf")

lapply(packages, require,character.only = T)




############# 
### loading the WestBengal shapefile ##
####### 

West_Bengal <- sf::st_read(here("Datasets","nyu_2451_42212",
                           "india-village-census-2001-WB.shp")) %>%
                            dplyr::select(geometry)


#### Transforming it first ### 

West_Bengal <- West_Bengal %>%
                  sf::st_transform(4326)


##################### 
#### Loading the river dataset # 
########## 

Rivers <- sf::st_read(here("Datasets","Asian_rivers",
                                 "HydroRIVERS_v10_as_shp",
                                 "HydroRIVERS_v10_as.shp")) %>% 
                                           dplyr::select(ORD_FLOW,
                                                         geometry)

### Only selecting the rivers which we require ###

sf::sf_use_s2(F)

Rivers <- sf::st_intersection(Rivers, West_Bengal)


### rescaling the ord flow values ###
### so that we can prorperly plot the river width of each

Rivers <- Rivers %>%
             dplyr::mutate(width = as.numeric(ORD_FLOW),
                           width = dplyr::case_when(
                             width == 2 ~ 0.8,
                             width == 4 ~ 0.6,
                             width == 5 ~ 0.5,
                             width == 6 ~ 0.4,
                             width == 7 ~ 0.3)) %>%
             dplyr::mutate(ORD_FLOW = factor(ORD_FLOW, levels = c("2", "4", "5", 
                                                                  "6", "7"))) %>%
             sf::st_as_sf()


p <- ggplot() +
           geom_sf(data = Rivers,
    aes(
      color = factor(
        ORD_FLOW
      ),
      size = width,
      alpha = width
    )
  ) +
  scale_color_manual(
    name = "",
    values = hcl.colors(
      5, "Dark 3",
      alpha = 1
    )
  ) +
  scale_size(
    range = c(.1, .7)
  ) +
  scale_alpha(
    range = c(.01, 1)
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.caption = element_text(
      size = 8, color = "grey60",
      hjust = 0.1, vjust = 10
    ),
    plot.margin = unit(
      c(
        t = 0, r = 0,
        b = 0, l = 0
      ),
      "lines"
    ),
    plot.background = element_rect(
      fill = "black",
      color = NA
    ),
    panel.background = element_rect(
      fill = "black",
      color = NA
    )
  ) +
  labs(caption = "Data Source: Lehner, B., & Grill, G. (2013). [Map of Global River Hydrography].\nHydrological Processes, 27(15): 2171–2186. https://doi.org/10.1002/hyp.9740") +
  labs(title = "Rivers of West Bengal") +
  theme(
    plot.title = element_text(hjust = 0.5, vjust = 1, size = 30,
                              color = "white")
  )
  

p
             
ggsave(p,filename = "WestBengal_Rivers.png",width = 7, height = 7.75, dpi = 600,
       bg = "white", device = "png")







