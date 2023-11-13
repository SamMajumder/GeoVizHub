# Ecoregion Mapping in North America

## Introduction
This project aims to create a detailed map of ecoregions in North America. It utilizes various R packages to handle spatial data, manipulate raster and vector data, and produce high-quality visualizations.

## Packages Used
The project utilizes the following R packages:
- ncdf4
- here
- tidyverse
- terra
- sf
- RColorBrewer
- rayshader
- elevatr
- raster

## Workflow

### 1. Setup
- Required packages are loaded.
- Necessary directories are created for data storage.

### 2. Data Acquisition
- Ecoregion shapefile is downloaded from the specified URL.
- The downloaded file is then unzipped into the `Datasets` directory.

### 3. Data Preparation
- The Ecoregion shapefile is imported and processed.
- The shape of North America is extracted by aggregating polygons and transforming them into a single polygon.
- Elevation data for North America is retrieved and visualized.
- The ecoregion shapefile is converted to a raster format, and a color map is applied to represent different ecoregions.

### 4. Raster Manipulation
- Ecoregion and elevation rasters are transformed into `terra` raster objects.
- Elevation raster is resampled to match the extent of the ecoregion raster.

### 5. Image Processing and 3D Visualization
- A custom 3D visualization is created using the rayshader package.
- Camera angles and lighting are adjusted to render a high-quality image.

### 6. Legend Creation
- A strip legend is created for the ecoregions using ggplot2.
- The legend is saved as a PNG file.

### 7. Final Map Composition
- The final ecoregion map and the legend are combined using the magick package.
- The composed image is saved as the final output.

## Output
The output of the project is a detailed and visually appealing map of North American ecoregions, presented in a 3D perspective, along with a corresponding legend. 

## Final Ecoregion Map
![North American Ecoregion Map](https://github.com/SamMajumder/GeoVizHub/raw/main/TopoEcoMap/final-ecoregion-map.png)


