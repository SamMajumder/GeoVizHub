
rm(list = ls())

packages <- list("here","tidyverse","raster","ggplot2","sf","elevatr","terra",
                 "RColorBrewer","rayshader")

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

########### 

elevation_WB <- elevatr::get_elev_raster(locations = West_Bengal, z = 5, 
                                         clip = "locations")




######### Loading in the NDVI raster ### 

NDVI <- terra::rast(here("Datasets","NDVI",
                               "ndvi.tif"))

plot(NDVI)

#### Crop the raster to the shape of West Bengal ##

NDVI <- terra::mask(NDVI,West_Bengal)




custom_palette <- c("#CA8B56","#CA986A","#CBB3A8","#88C285","#74C476","#31A354",
                    "#006D2C")


from <- c(-2000:10000)
to <- t(col2rgb(custom_palette)) 

NDVI_reclassified <- terra::subst(NDVI,
                                  from,
                                  to,
                                  names = custom_palette)

plotRGB(NDVI_reclassified)


#### saving it as an image file ###

img_file <- "West_Bengal_NDVI.png"

terra::writeRaster(
  NDVI_reclassified,
  img_file,
  overwrite = T,
  NAflag = 255
)

########## 
## 

############
## now loading this image back in  for creating the 3D overlays##
############ 

img <- png::readPNG(img_file)

##### comparing the two rasters, elevation and NDVI ##
##### 

terra::ext(elevation_WB)
terra::ext(NDVI_reclassified)

####
## resampling the elevation raster to match the NDVI_reclassified raster
#### 

### First converting the elevation raster to a Terra object ###

elevation_WB_terra <- rast(elevation_WB)

### the elevation raster should match the extent of the NDVI raster

elevation_WB_resampled <- terra::resample(elevation_WB_terra,NDVI_reclassified,
                                          method = "bilinear")


elevation_WB_matrix <- rayshader::raster_to_matrix(elevation_WB_resampled)


## create the scene ##

h <- nrow(elevation_WB_resampled)
w <- ncol(elevation_WB_resampled)

elevation_WB_matrix %>%
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
      elevation_WB_matrix,
      zscale = 50,
      sunaltitude = 90,
      sunangle = 315,
    ), max_darken = .25
  ) %>%
  rayshader::add_shadow(
    rayshader::texture_shade(
      elevation_WB_matrix,
      detail = .95,
      brightness = 90, #warn
      contrast = 80,
    ), max_darken = .1
  ) %>%
  rayshader::plot_3d(
    elevation_WB_matrix,
    zscale = 100,
    solid = F,
    shadow = T,
    shadow_darkness = 1,
    background = "white",
    windowsize = c(
      1000, 1000
    ),
    zoom = 0.4,
    phi = 30,
    theta = 1
  )


rayshader::render_camera(theta = 1,phi = 30,zoom = 0.4)

### render the image ####
rayshader::render_highquality(
  filename = "WestBengal.png",
  width = 1000,
  height = 1000,
  samples = 500,
  lightdirection = 280,
  lightaltitude = c(20, 80),
  lightcolor = c("#F5F5DC", "white"),
  interactive = F
)

#############################

# Create a blank ggplot2 plot with a title
blank_plot <- ggplot() + 
  theme_void() +
  labs(title = "West Bengal Vegetation") +
  theme(plot.title = element_text(size = 20, face = "bold")) 


# Save the blank plot as a PNG file
ggsave("Plot_title.png", plot = blank_plot, width = 10, height = 8, 
       dpi = 300, bg = "white")


# Read the ecoregion map and the legend
westbengal_img <- magick::image_read("WestBengal.png")
Title <- magick::image_read("Plot_title.png")

# Scale and prepare the legend (adjust the size according to your needs)
Title_scaled <- magick::image_scale(Title, "2000x") %>%
  magick::image_background("none") %>%
  magick::image_transparent("white")

# Composite the images (adjust the offset for proper positioning)
p <- magick::image_composite(westbengal_img, Title_scaled, 
                             offset = "+5+10")

# Save the final image
magick::image_write(p, "WestBengal_final.png")














