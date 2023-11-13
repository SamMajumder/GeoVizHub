

packages <- list("ncdf4","here","tidyverse","terra","sf",
                 "RColorBrewer","rayshader","elevatr","raster")

lapply(packages, require,character.only = T) 


############## 
### Create the directories ### 

options(scipen=999)

# Check if "Datasets" and "Figures" folder exists, if not, create it

# List of directories to create
dirs_to_create <- c("Datasets")

# Loop through the directories and create them if they don't exist
for (dir_name in dirs_to_create) {
  dir_path <- here(dir_name)
  
  if (!dir.exists(dir_path)) {
    dir.create(dir_path)
  }
}   


###############  Download the ecoregion shapefile ##

#### setting a high timeout limit ## setting it to 10 minutes 

options(timeout=600)

######### downloading the average temperature netcdf
# Define the URL
url <- "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/cec_na/na_cec_eco_l1.zip"


# Define the destination file path using here()
dest_file <- here("Datasets", 
                  "na_cec_eco_l1.zip")


# Download the file
download.file(url, dest_file, mode = "wb")

##### Unzipping the datasets #####

unzip(dest_file,exdir = here("Datasets"))

########### importing the Ecoregion shapefile ##

Ecoregion_shape <- sf::st_read(here("Datasets","NA_CEC_Eco_Level1.shp")) 



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

# Assume a resolution of 1 
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

#### also converting the elevation raster to a rast object 

elevation_NA <- terra::rast(elevation_NA)


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

##### Substituting or assigning new colors to the raster values ##

ecoregion_raster <- terra::subst(ecoregion_raster,
                                  from,
                                  to,
                                  names = custom_palette)


#### making sure that the elevation raster is the same extent as the elevation

elevation_NA <- terra::resample(elevation_NA,ecoregion_raster,
                                method = "near")


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
      brightness = 90,
      contrast = 80,
    ), max_darken = .1
  ) %>%
  rayshader::plot_3d(
    elevation_NA_matrix,
    zscale = 800,
    solid = F,
    shadow = T,
    shadow_darkness = 1,
    background = "black",
    windowsize = c(
      1000 , 1000
    )) 



rayshader::render_camera(theta = 1,phi = 30,zoom = 0.6)

### render the image ####
rayshader::render_highquality(
    filename = "Ecoregion_NorthAmerica.png",
    width = 1000,
    height = 1000,
    samples = 200,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c("#F5F5DC", "white"),
    interactive = F
  )
  


################ 
# 8. MAKE STRIP LEGEND 

color_palette <- c(
  WATER = "blue",
  ARCTIC_CORDILLERA = "darkblue",
  NORTH_AMERICAN_DESERTS = "sandybrown",
  MEDITERRANEAN_CALIFORNIA = "darkred",
  SOUTHERN_SEMIARID_HIGHLANDS = "sienna",
  TEMPERATE_SIERRAS = "green",
  TROPICAL_DRY_FORESTS = "olivedrab",
  TROPICAL_WET_FORESTS = "darkgreen",
  TUNDRA = "lightblue",
  TAIGA = "darkcyan",
  HUDSON_PLAIN = "gray",
  NORTHERN_FORESTS = "forestgreen",
  NORTHWESTERN_FORESTED_MOUNTAINS = "lightgreen",
  MARINE_WEST_COAST_FOREST = "darkolivegreen",
  EASTERN_TEMPERATE_FORESTS = "mediumseagreen",
  GREAT_PLAINS = "wheat"
)


# Assuming Ecoregion_shape$NA_L1NAME is defined and contains unique ecoregion names
Ecoregions <- unique(Ecoregion_shape$NA_L1NAME)

# Creating a data frame for the ecoregions
df_ecoregion <- data.frame(Ecoregion = names(color_palette))

# Creating the legend strip plot
legend_ecoregion_strip <- ggplot(df_ecoregion, aes(x = Ecoregion, y = 1, fill = Ecoregion)) +
  geom_bar(stat = "identity", width = 1) +
  coord_fixed(ratio = 0.2) +
  scale_fill_manual(values = color_palette) +
  theme_void() +
  theme(legend.position="none",
        axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1, size = 16)) 

# Saving the legend as a PNG file
ggsave("legend_ecoregion_strip.png", plot = legend_ecoregion_strip, width = 47, 
       height = 10, dpi = 300, bg = "white")




# 9. FINAL MAP
#-------------

# Read the ecoregion map and the legend
ecoregion_img <- magick::image_read("Ecoregion_NorthAmerica.png")
my_legend <- magick::image_read("legend_ecoregion_strip.png")

# Scale and prepare the legend (adjust the size according to your needs)
my_legend_scaled <- magick::image_scale(my_legend, "1000x") |>
  magick::image_background("none") |>
  magick::image_transparent("white")

# Composite the images (adjust the offset for proper positioning)
p <- magick::image_composite(ecoregion_img, my_legend_scaled, 
                             offset = "+0+")

# Save the final image
magick::image_write(p, "final-ecoregion-map.png")



