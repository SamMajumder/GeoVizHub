# West Bengal Vegetation Analysis

## Overview
This script is designed for analyzing and visualizing vegetation in West Bengal, India. It uses various R packages to process geographical data, create NDVI (Normalized Difference Vegetation Index) visualizations, and generate 3D overlays to represent the region's topography and vegetation.

## Dependencies
To run this script, the following R packages are required:
- here
- tidyverse
- raster
- ggplot2
- sf
- elevatr
- terra
- RColorBrewer
- rayshader
- png
- magick

These can be installed using `install.packages("package_name")`.

## Functionality
1. **Data Loading and Transformation:** The script starts by loading a shapefile of West Bengal and transforming its coordinates.
2. **Elevation Data Processing:** It retrieves elevation data for the region using the `elevatr` package.
3. **NDVI Raster Processing:** It loads an NDVI raster file and crops it to the West Bengal region.
4. **Visualization Enhancements:** A custom color palette is applied to the NDVI raster for better visualization.
5. **3D Visualization:** The script generates a 3D representation of the elevation data overlaid with the NDVI data.
6. **Image Processing and Composition:** Finally, it saves the 3D visualization as an image and combines it with a blank ggplot title plot using the `magick` package.

## Output
The script produces the following files:
- `West_Bengal_NDVI.png`: An image of the reclassified NDVI raster.
- `WestBengal.png`: A 3D rendered image of West Bengal's topography and NDVI.
- `Plot_title.png`: A blank ggplot title plot.
- `WestBengal_final.png`: The final composite image including the 3D render and title plot.

![map](https://github.com/SamMajumder/GeoVizHub/blob/main/WestBengalEcology/WestBengal_final.png)

