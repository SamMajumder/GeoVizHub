library(rgbif)
library(here)
library(tidyverse)
library(sf)
library(RColorBrewer)
library(cowplot)
library(gridExtra)
library(grid)
library(ggspatial)
library(rayshader)


name_backbone("Helianthus")$usageKey

Sunflower <- occ_search(scientificName = "Helianthus L.", 
                        continent = "north_america",
                        basisOfRecord = "PRESERVED_SPECIMEN",
                        hasGeospatialIssue = FALSE,
                        return = 'data',
                        limit = 34232)




Sunflower_data <- Sunflower$data




unique(Sunflower_data$species)




##########

species_names <- c("agrestis","angustifolius","annuus",
                   "atrorubens","carnosus","debili_ssp_tardiflorus",
                   "floridanus","heterophyllus","longifolius",
                   "microcephalus","porteri","P_tenuifolius","radula",                       
                   "silphioides","niveu_ssp_tephrodes","verticillatus",
                   "argophyllus","cusickii","divaricatus","giganteus",                    
                   "grosseserratus","maximiliani","mollis","neglectus",                   
                   "occidentali_ssp_occidentalis","petiolari_ssp_petiolaris",
                   "praeco_ssp_runyonii","salicifolius")


species_names_string <- paste(species_names, collapse = "|")


Sunflower_data <- Sunflower_data %>% 
  ## filtering out all other species which are outside the backbone of the 28 species 
  dplyr::filter(str_detect(species, species_names_string)) %>% 
  ##### selecting specific columns ## the ones we need
  dplyr::select(species,decimalLatitude,decimalLongitude) %>% 
  #### removing Helianthus annuus × debilis ### 
  dplyr::filter(species != "Helianthus annuus × debilis") %>% 
  ### pruning the names to only contain the species names ## 
  dplyr::mutate(species = str_remove_all(species,
                                         "Helianthus ")) %>% 
  ### change the names to be like uppercase first letter (title) 
  dplyr::mutate(species = str_to_title(species)) %>% 
  ## dropping the na values ##### 
tidyr::drop_na() %>% 
  ## changing the latitude and longitude column names ###
  dplyr::rename(Species = species,
                Latitude = decimalLatitude,
                Longitude = decimalLongitude)



######

Sunflower_data <- readRDS(here("Code",
                               "Sunflower_occurrence_north_america.rds")) %>%
                               dplyr::mutate(Species = factor(Species))

######### 
## converting this dataframe into an sf object ####

Sunflower_data_sf <- sf::st_as_sf(Sunflower_data,
                                  coords = c("Longitude", 
                                             "Latitude"),
                                  crs = 4326,  # Assign a crs
                                  remove = FALSE)  ### keep the Longitude and Latitude
                                  


########### importing the Ecoregion shapefile ##

Ecoregion_shape <- sf::st_read(here("Datasets","NA_CEC_Eco_Level3",
                                    "NA_CEC_Eco_Level3.shp"))



# Transform Sunflower_sf to match the CRS of Ecoregion_shape
Sunflower_data_sf <- st_transform(Sunflower_data_sf, 
                                  st_crs(Ecoregion_shape))


##### 
### Spatial join with the ecoregion shape file ###
#### 

Distribution <- Sunflower_data_sf %>% 
                          sf::st_join(Ecoregion_shape,
                                      join = st_intersects,
                                      left = FALSE) %>% 
                                       tidyr::drop_na() %>% 
                          ###### Selecting the columns that we want 
                          dplyr::select(Species,NA_L1NAME,Latitude,Longitude,
                                        geometry) %>% 
                          ###### rename the NA_L2NAME column to Ecoregion ##
                          dplyr::rename(Ecoregion = NA_L1NAME)



##### Now let's calculate the Centroids of each species ##

Centroids <- Distribution %>%
                 dplyr::group_by(Species,Ecoregion) %>%
                 dplyr::summarise(Total = n()) %>%
                 sf::st_centroid(geometry) %>%
                 dplyr::arrange(desc(Total)) %>%
                 ungroup() %>%
                 dplyr::rename(Centroid_geometry = geometry) %>%
                 dplyr::mutate(Longitude = sf::st_coordinates(Centroid_geometry)[, 1],
                               Latitude = sf::st_coordinates(Centroid_geometry)[, 2]) %>%
                 dplyr::filter(Ecoregion != "WATER")
                 





### Now filter the original Ecoregion file to only contain the ecoregions we require
  

#### Let's filter the Ecoregion shape file to only contain the Ecoregions we want ##

Ecoregions <- unique(Centroids$Ecoregion)

Ecoregion_shape <- Ecoregion_shape %>%
                              dplyr::filter(NA_L1NAME %in% 
                                              Ecoregions) %>% 
                              dplyr::rename(Ecoregion = NA_L1NAME)


##############
##### Defining the colors for the legends ####
############## 

colors_ecoregion <- c("GREAT PLAINS" = "#addd8e", 
                      "EASTERN TEMPERATE FORESTS" = "#31a354", 
                      "NORTH AMERICAN DESERTS" = "#e7ba52", 
                      "MEDITERRANEAN CALIFORNIA" = "#e34a33", 
                      "TEMPERATE SIERRAS" = "#756bb1",
                      "NORTHWESTERN FORESTED MOUNTAINS" = "#006d2c", 
                      "NORTHERN FORESTS" = "#2ca25f", 
                      "SOUTHERN SEMIARID HIGHLANDS" = "#e7cb94", 
                      "TROPICAL DRY FORESTS" = "#fd8d3c", 
                      "TROPICAL WET FORESTS" = "#41ab5d", 
                      "MARINE WEST COAST FOREST" = "#238b45", 
                      "TAIGA" = "#3690c0", 
                      "HUDSON PLAIN" = "#74c476")



#################
####
############ 

species_shapes <- c(1:19, 21:23) 

main_plot <- ggplot() +
  geom_sf(data = Ecoregion_shape, aes(fill = Ecoregion)) +
  geom_sf(data = Centroids, aes(shape = Species, fill = Species), size = 3, color = "black", stroke = 1) + 
  scale_fill_manual(values = c(colors_ecoregion, colors_species)) +
  scale_shape_manual(values = species_shapes) +
  coord_sf(datum = st_crs(Sunflower_data_sf)) + 
  annotation_north_arrow(location = "bl", which_north = "true", 
                         pad_x = unit(0.0, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering) +
  annotation_scale(location = "bl", width_hint = 0.5) +
  theme_minimal() +
  theme(
    legend.position = "none", 
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.background = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, size = 1)
  )

######################## 

df_ecoregion <- data.frame(Ecoregion = names(colors_ecoregion))

legend_ecoregion_strip <- ggplot(df_ecoregion, aes(x = Ecoregion, y = 1, 
                                                   fill = Ecoregion)) +
  geom_bar(stat = "identity", width = 1) +
  coord_fixed(ratio = 0.2) +
  scale_fill_manual(values = colors_ecoregion) +
  theme_void() +
  theme(legend.position="none",
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1,
                                   size = 8)) 

####################

legend_species_plot <- ggplot(data = data.frame(Species = names(colors_species)), 
                              aes(x = 1, y = Species, fill = Species, shape = Species)) +
  geom_point(size = 5, color = "black") + # increased point size and added black outline
  scale_fill_manual(values = colors_species) +
  scale_shape_manual(values = species_shapes) +
  theme_void() +
  theme(legend.position = c(-0.7, 0.2), 
        legend.key = element_blank(),
        legend.text = element_text(size = 12),
        legend.title = element_text(face = "bold", 
                                    size = 12),
        plot.margin = margin(t = 0, r = 0, b = 0, l = -20))

legend_species <- cowplot::get_legend(legend_species_plot) 

########## Combining Everything

final_plot <- grid.arrange(
  arrangeGrob(main_plot, 
              legend_species, 
              ncol = 2, widths = c(4, 1)),
  legend_ecoregion_strip,
  ncol = 1, nrow = 2, heights = c(4, 1),
  top = textGrob("Distribution of a few wild sunflower species in North America", 
                 gp = gpar(fontface = "bold", fontsize = 20),
                 just = 0.75)
)


ggsave("sunflower_distribution.png", final_plot, width = 22, height = 10)







