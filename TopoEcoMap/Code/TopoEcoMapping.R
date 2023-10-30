

library(here)
library(tidyverse)
library(sf)
library(RColorBrewer)
library(rayshader)
library(terra)
library(elevatr)
library(raster)
library(terra)

############## 

########### importing the Ecoregion shapefile ##

Ecoregion_shape <- sf::st_read(here("Datasets","na_cec_eco_l1",
                                    "NA_CEC_Eco_Level1.shp")) 



############# Extracting the shape of North America ##

# Aggregate all polygons into a single polygon
Outline_NA <- Ecoregion_shape %>%
                        sf::st_union() %>%
                        sf::st_boundary() %>%
                        sf::st_sf() %>%
                        sf::st_polygonize() %>% 
                        sf::st_collection_extract("POLYGON") %>%
                        sf::st_transform(4326)
                 
                                  

elevation_NA <- elevatr::get_elev_raster(locations = Outline_NA, z = 5, 
                                         clip = "locations")
#############
## 

plot(elevation_NA)

#### Now let us convert the ecoregion shape file to 4326 

Ecoregion_shape <- Ecoregion_shape %>% 
                           sf::st_transform(4326)



# Convert the ecoregion shapefile to a raster, 
### with values representing different ecoregions.

## extract the ecoregion code from the main Ecoregion shapefile
## first converting the code column to numric
Ecoregion_shape$NA_L1CODE <- as.numeric(as.character(Ecoregion_shape$NA_L1CODE))



# Rasterize the ecoregion shapefile based on the elevation raster's resolution and extent

# Assume a resolution of 1 for this example; adjust as needed
empty_raster <- raster::raster(
  extent(Ecoregion_shape),
  resolution = 1
)

ecoregion_raster <- raster::rasterize(
  Ecoregion_shape,
  empty_raster,
  field = "NA_L1CODE"
)  

plot(ecoregion_raster)

###  now convert the raster to a Spat Raster object

ecoregion_raster <- terra::rast(ecoregion_raster)

#############
## Now let's create a color map and apply it to our ecoregion raster ###


# Define a custom color palette
custom_palette <- c(
  "blue",         # WATER
  "darkblue",     # ARCTIC CORDILLERA
  "sandybrown",   # NORTH AMERICAN DESERTS
  "darkred",      # MEDITERRANEAN CALIFORNIA
  "sienna",       # SOUTHERN SEMIARID HIGHLANDS
  "green",        # TEMPERATE SIERRAS
  "olivedrab",    # TROPICAL DRY FORESTS
  "darkgreen",    # TROPICAL WET FORESTS
  "lightblue",    # TUNDRA
  "darkcyan",     # TAIGA
  "gray",         # HUDSON PLAIN
  "forestgreen",  # NORTHERN FORESTS
  "lightgreen",   # NORTHWESTERN FORESTED MOUNTAINS
  "darkolivegreen", # MARINE WEST COAST FOREST
  "mediumseagreen", # EASTERN TEMPERATE FORESTS
  "wheat"         # GREAT PLAINS
)


from <- c(0:15)
to <- t(col2rgb(custom_palette)) 

##### reclassiffying or assigning new colors to the raster values ##

ecoregion_raster <- terra::subst(ecoregion_raster,
                                  from,
                                  to,
                                  names = custom_palette)


#### saving it as an image file ###

img_file <- "na_ecoregion_image.png"

terra::writeRaster(
  ecoregion_raster,
  img_file,
  overwrite = T,
  NAflag = 255
)


############
## now loading this image back in  for creating the 3D overlays##
############ 

img <- png::readPNG(img_file)

elevation_NA_matrix <- rayshader::raster_to_matrix(elevation_NA)

## create the scene ##

h <- nrow(elevation_NA)
w <- ncol(elevation_NA)

elevation_NA_matrix %>%
   rayshader::height_shade(
    texture = colorRampPalette(
      "white"
    )(512)
  ) %>%
  rayshader::add_overlay(
    img,
    alphalayer = .9,
    alphacolor = "white"
  ) %>%
  rayshader::add_shadow(
    rayshader::lamb_shade(
      elevation_NA_matrix,
      zscale = 50,
      sunaltitude = 90,
      sunangle = 315,
    ), max_darken = .25
  ) %>%
  rayshader::add_shadow(
    rayshader::texture_shade(
      elevation_NA_matrix,
      detail = .95,
      brightness = 90, #warn
      contrast = 80,
    ), max_darken = .1
  ) %>%
  rayshader::plot_3d(
    elevation_NA_matrix,
    zscale = 5,
    solid = F,
    shadow = T,
    shadow_darkness = 1,
    background = "white",
    windowsize = c(
      w / 5, h / 5
    ),
    zoom = .5,
    phi = 45,
    theta = 0 
  )










