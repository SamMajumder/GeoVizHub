

library(rgbif)
library(here)
library(tidyverse)
library(sf)
library(stars)
library(rayshader)


##### load the functions ####

source("0_Functions.R")




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
                    


class(Sunflower_data)
######

Sunflower_data <- readRDS("Sunflower_occurrence_north_america.rds") 

######### 
## converting this dataframe into an sf object ####

Sunflower_data_sf <- sf::st_as_sf(Sunflower_data,
                                  coords = c("Longitude", 
                                             "Latitude"),
                                  crs = 4326,  # Assuming original data is in WGS 84
                                  remove = FALSE) %>% 
                     dplyr::rename(Geometry_point = geometry)



########### importing the Ecoregion shapefile ##

Ecoregion_shape <- sf::st_read(here("Datasets","NA_CEC_Eco_Level3",
                                    "NA_CEC_Eco_Level3.shp"))




# Transform Ecoregion_shape to match the CRS of Ecoregion_shape
Sunflower_data_sf <- st_transform(Sunflower_data_sf, 
                                  st_crs(Ecoregion_shape))


##### 
### Spatial join with the ecoregion shape file ###
#### 

Distribution <- Sunflower_data_sf %>% 
                     sf::st_join(Ecoregion_shape,
                                 join = st_intersects,
                                 left = TRUE) %>% 
                                 tidyr::drop_na()



#### Now calculating the multipoint ###

Centroids <- Distribution %>% 
                 dplyr::group_by(Species,NA_L2NAME) %>%
                 dplyr::summarise(Total = n()) %>%
                 sf::st_centroid(Geometry_point) %>%
                 dplyr::arrange(desc(Total)) %>%
                 ungroup() %>%
                 dplyr::rename(Centroid_geometry = Geometry_point) %>%
                 dplyr::mutate(Longitude = sf::st_coordinates(Centroid_geometry)[, 1],
                               Latitude = sf::st_coordinates(Centroid_geometry)[, 2]) %>%
                 dplyr::rename(Ecoregion = NA_L2NAME)



#########################
#### performing another spatial join to bring the sunflower centroid points into the ecoregion polygons
########### 

Distribution_final <- Ecoregion_shape %>% 
                           dplyr::select(NA_L2NAME,geometry) %>%
                           dplyr::rename(Ecoregion = NA_L2NAME) %>%
                           sf::st_join(Centroids,
                           join = st_intersects,
                           left = FALSE) %>% 
                           tidyr::drop_na()


##### Now we will create point geometries from our centroids ###

Centroids <- data.frame(Longitude = Distribution_final$Longitude,
                        Latitude = Distribution_final$Latitude)


Centroids <- sf::st_as_sf(Centroids,
                          coords = c("Longitude", 
                                     "Latitude"),
                          crs = st_crs(Distribution_final))



#### Now adding this to the our Distribution_final dataframe ###

Distribution_final <- Distribution_final %>%
                           dplyr::mutate(Point_geometry = Centroids$geometry) %>%
                           dplyr::select(-c(Ecoregion.y)) %>%
                           dplyr::rename(Ecoregion = Ecoregion.x) 
                           




  

##############
##### Now preparing the data for spike plots ###
###########

### for this part of the code, credit goes to Milos ##
#### his github:https://github.com/milos-agathon/making-crisp-spike-maps-with-r/blob/main/R/create-spike-map-in-r.r
####

bb <- sf::st_bbox(Distribution_final)

get_raster_size <- function() {
  height <- sf::st_distance(
    sf::st_point(c(bb[["xmin"]], bb[["ymin"]])),
    sf::st_point(c(bb[["xmin"]], bb[["ymax"]]))
  )
  width <- sf::st_distance(
    sf::st_point(c(bb[["xmin"]], bb[["ymin"]])),
    sf::st_point(c(bb[["xmax"]], bb[["ymin"]]))
  )
  
  if (height > width) {
    height_ratio <- 1
    width_ratio <- width / height
  } else {
    width_ratio <- 1
    height_ratio <- height / width
  }
  
  return(list(width_ratio, height_ratio))
}

width_ratio <- get_raster_size()[[1]]
height_ratio <- get_raster_size()[[2]]

size <- 1000
width <- round((size * width_ratio), 0)
height <- round((size * height_ratio), 0)

get_raster <- function() {
  rast <- stars::st_rasterize(
    Distribution_final %>%
      dplyr::select(Total, Point_geometry),
    nx = width, ny = height
  )
  
  return(rast)
}

Distribution_raster <- get_raster()


plot(Distribution_raster)


# Convert the raster data to a matrix for rayshader
Distribution_matrix <- Distribution_raster %>%
  as("Raster") %>%
  rayshader::raster_to_matrix()


# Define a color palette
# Define a color palette
cols <- rev(c(
  "#0b1354", "#283680",
  "#6853a9", "#c863b3"
))

texture <- grDevices::colorRampPalette(cols)(256)


# Create the initial 3D object
Distribution_matrix %>%
  rayshader::height_shade(texture = texture) %>%
  rayshader::plot_3d(
    heightmap = Distribution_matrix,
    solid = F,
    soliddepth = 0,
    zscale = 15,
    shadowdepth = 0,
    shadow_darkness = .95,
    windowsize = c(800, 800),
    phi = 65,
    zoom = .65,
    theta = -30,
    background = "white"
  )





gg



gg %>%
  plot_gg(width = 5, height = 5, multicore = TRUE, scale = 300)


  













