

options(scipen=999)

packages <- list("ncdf4","here","tidyverse","terra","sf")

lapply(packages, require,character.only = T) 

source(here("Code","Functions.R"))

# Check if "Datasets" and "Figures" folder exists, if not, create it

# List of directories to create
dirs_to_create <- c("RawDatasets","ProcessedDatasets1960",
                    "ProcessedDatasets2022")

# Loop through the directories and create them if they don't exist
for (dir_name in dirs_to_create) {
  dir_path <- here(dir_name)
  
  if (!dir.exists(dir_path)) {
    dir.create(dir_path)
  }
}   

### Creating an additional folder within RawDatasets ###

# List of directories to create
dirs_to_create <- c("USCountyCentroid")

# Loop through the directories and create them if they don't exist
for (dir_name in dirs_to_create) {
  dir_path <- here("RawDatasets",
                   dir_name)
  
  if (!dir.exists(dir_path)) {
    dir.create(dir_path)
  }
}  



################## 

###################################
##### Download data ###
######## 


#### setting a high timeout limit ## setting it to 10 minutes 

options(timeout=600)

######### downloading the average temperature netcdf
# Define the URL
url <- "https://www.ncei.noaa.gov/data/nclimgrid-monthly/access/nclimgrid_tavg.nc"


# Define the destination file path using here()
dest_file <- here("RawDatasets", 
                  "nclimgrid_tavg.nc")


# Download the file
download.file(url, dest_file, mode = "wb")

##########
## download the US county centroid shapefile ##
######## 

# Define the URL
url <- "https://www.weather.gov/source/gis/Shapefiles/County/c_08mr23.zip"


# Define the destination file path using here()
dest_file <- here("RawDatasets", 
                  "c_08mr23.zip")


# Download the file
download.file(url, dest_file, mode = "wb")


# Define the path to the zip file
centroid_shapefile_zip <- here("RawDatasets", "c_08mr23.zip")

# Define the directory where the unzipped files should be stored
centroid_shapefile_unzipped <- here("RawDatasets", "USCountyCentroid")

# Unzip the file
unzip(zipfile = centroid_shapefile_zip, exdir = centroid_shapefile_unzipped)


############
#### export the layers 
##########

tavg <- terra::rast(here("RawDatasets","nclimgrid_tavg.nc"))

output_dir <- here("ProcessedDatasets1960")
output_dir_2 <- here("ProcessedDatasets2022")

### exporting layers from 1960
export_layers(tavg,781:792,output_dir)


#### exporting layers from 2022
export_layers(tavg,1525:1536,output_dir_2)

#########
## now read in the county centroid shapefile #
########### 

US_county_centroid <- sf::st_read(here("RawDatasets",
                                       "USCountyCentroid",
                                       "c_08mr23.shp"))


Coordinates <- US_county_centroid %>% 
                            dplyr::select(STATE,COUNTYNAME,
                                          LON,LAT) %>%
                            sf::st_drop_geometry()


########## 
### Extracting values at points for 1960 
#######

## listing all tmax files 

rasters_1960 <- list.files(path = here("ProcessedDatasets1960"),
                           pattern = ".*\\.tif$",full.names = TRUE)

Tavg_1960_list <- geoRflow_raster_pipeline_point(rasters_1960,
                                                Coordinates,
                                                lat_col = "LAT",
                                                lon_col = "LON",
                                                method = "terra",
                                                crs = "EPSG:4326")


################ 
#### Extracting the list that contains the dataframes with values ###

# Define the new column names
new_column_names <- c("STATE", "COUNTYNAME", "LON", "LAT", 
                      "Jan_tavg", "Feb_tavg", "Mar_tavg", "Apr_tavg", 
                      "May_tavg", "June_tavg", "July_tavg", "August_tavg", 
                      "Sept_tavg", "Oct_tavg", "Nov_tavg", "Dec_tavg")


Avg_temp_1960_monthly <- process_dataframes(Tavg_1960_list,
                               "dataframes_with_values",
                               new_col_names = new_column_names,
                               extract_index = 1) %>% 
                                      tidyr::drop_na()



Avg_temp_1960 <- Avg_temp_1960_monthly %>% 
                                tidyr::drop_na() %>% 
                                dplyr::rowwise() %>%
                                dplyr::summarise(Tavg_1960 = mean(Jan_tavg:Dec_tavg)) %>%
                                dplyr::mutate(STATE = Avg_temp_1960_monthly$STATE,
                                              COUNTYNAME =Avg_temp_1960_monthly$COUNTYNAME,
                                              LON = Avg_temp_1960_monthly$LON,
                                              LAT = Avg_temp_1960_monthly$LAT)
                            




########## 
### Extracting values at points for 1960 
#######

## listing all tmax files 

rasters_2022 <- list.files(path = here("ProcessedDatasets2022"),
                           pattern = ".*\\.tif$",full.names = TRUE)

Tavg_2022_list <- geoRflow_raster_pipeline_point(rasters_2022,
                                                 Coordinates,
                                                 lat_col = "LAT",
                                                 lon_col = "LON",
                                                 method = "terra",
                                                 crs = "EPSG:4326")


################ 
#### Extracting the list that contains the dataframes with values ###

# Define the new column names
new_column_names <- c("STATE", "COUNTYNAME", "LON", "LAT", 
                      "Jan_tavg", "Feb_tavg", "Mar_tavg", "Apr_tavg", 
                      "May_tavg", "June_tavg", "July_tavg", "August_tavg", 
                      "Sept_tavg", "Oct_tavg", "Nov_tavg", "Dec_tavg")


Avg_temp_2022_monthly <- process_dataframes(Tavg_2022_list,
                                    "dataframes_with_values",
                                    new_col_names = new_column_names,
                                    extract_index = 1) %>% 
                                         tidyr::drop_na()



Avg_temp_2022 <- Avg_temp_2022_monthly %>% 
                                tidyr::drop_na() %>% 
                                dplyr::rowwise() %>%
                                dplyr::summarise(Tavg_2022 = mean(Jan_tavg:Dec_tavg)) %>%
                                dplyr::mutate(STATE = Avg_temp_2022_monthly$STATE,
                                              COUNTYNAME =Avg_temp_1960_monthly$COUNTYNAME,
                                              LON = Avg_temp_1960_monthly$LON,
                                              LAT = Avg_temp_1960_monthly$LAT)




##### Joining the two datasets ####
## and joining the county centroids data 


Avg_temp_change <- Avg_temp_2022 %>%
                        dplyr::inner_join(Avg_temp_1960) %>% 
                        dplyr::mutate(Temp_change = Tavg_2022 - Tavg_1960) %>%
                        dplyr::inner_join(US_county_centroid) %>%
                        sf::st_as_sf()


### Now adding a column to the this dataset to categorize the type of temp change

Avg_temp_change <- Avg_temp_change %>%
  dplyr::mutate(Temp_change_category = case_when(
    Temp_change >= 0 & Temp_change <= 1 ~ "more than 0 degree increase",
    Temp_change > 1 & Temp_change <= 2 ~ "more than 1 degree increase",
    Temp_change > 2 & Temp_change <= 3 ~ "more than 2 degree increase",
    Temp_change > 3 & Temp_change <= 4 ~ "more than 3 degree increase",
    Temp_change > 4 & Temp_change <= 5 ~ "more than 4 degree increase",
    Temp_change > 5 ~ "more than 5 degree increase",
    Temp_change >= -1 & Temp_change < 0 ~ "under 1 degree decrease",
    Temp_change >= -2 & Temp_change < -1 ~ "more than -1 degree decrease",
    Temp_change >= -3 & Temp_change < -2 ~ "more than -2 degree decrease",
    Temp_change < -3 ~ "more than -3 degree decrease",
    TRUE ~ "Other" # Default case
  )) %>%
  dplyr::mutate(Temp_change_category = factor(as.factor(Temp_change_category), 
                                              levels = c("more than 5 degree increase",
                                                         "more than 4 degree increase",
                                                         "more than 3 degree increase",
                                                         "more than 2 degree increase",
                                                         "more than 1 degree increase",
                                                         "more than 0 degree increase",
                                                         "under 1 degree decrease",
                                                         "more than -1 degree decrease",
                                                         "more than -2 degree decrease",
                                                         "more than -3 degree decrease",
                                                         "Other")))


p <- ggplot(data = Avg_temp_change) +
  geom_sf(aes(fill = Temp_change_category), color = NA) +
  scale_fill_viridis_d(option = "D") +  # Use a discrete color scale
  theme_void() +  # Use a minimal theme
  labs(fill = "Temperature change relative to 1960",
       caption = "Source: NOAA Monthly U.S. Climate Gridded Dataset") +
  coord_sf(crs = 4326) +
  theme(panel.background = element_rect(fill = "white",
                                        color = NA),
        plot.background = element_rect(fill = "white",
                                       color = NA),
        legend.title = element_text(face ="bold",
                                    size = 15),
        legend.text = element_text(size = 15),
        legend.position = "right",
        plot.caption = element_text(size = 12))


ggsave("Temperature.png", p, 
       width = 22, height = 10)
















