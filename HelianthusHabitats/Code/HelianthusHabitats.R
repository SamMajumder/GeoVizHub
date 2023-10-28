library(rgbif)
library(here)
library(tidyverse)
library(sf)
library(stars)
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
                               "Sunflower_occurrence_north_america.rds")) 

######### 
## converting this dataframe into an sf object ####

Sunflower_data_sf <- sf::st_as_sf(Sunflower_data,
                                  coords = c("Longitude", 
                                             "Latitude"),
                                  crs = 4326,  # Assign a crs
                                  remove = FALSE)  ### keep the Longitude and Latitude
                                  



########### importing the Ecoregion shapefile ##

Ecoregion_shape <- sf::st_read(here("Datasets","na_cec_eco_l1",
                                    "NA_CEC_Eco_Level1.shp"))


# Transform Sunflower_sf to match the CRS of Ecoregion_shape
Sunflower_data_sf <- st_transform(Sunflower_data_sf, 
                                  st_crs(Ecoregion_shape))


##### 
### Spatial join with the ecoregion shape file ###
#### 

Distribution <- Ecoregion_shape %>% 
                          sf::st_join(Sunflower_data_sf,
                                      join = st_intersects,
                                      left = FALSE) %>% 
                                       tidyr::drop_na() %>% 
                          ###### Selecting the columns that we want 
                          dplyr::select(Species,NA_L1NAME,Latitude,Longitude,
                                        geometry) %>% 
                          ###### rename the NA_L2NAME column to Ecoregion ##
                          dplyr::rename(Ecoregion = NA_L1NAME)







ggplot() +
  geom_sf(data = Distribution) +
  geom_sf(data = Sunflower_data_sf) +
  coord_sf(datum = st_crs(Sunflower_data_sf))





