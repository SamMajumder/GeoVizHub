# US Temperature Change Analysis (1960 - 2022)

This project aims to analyze and visualize the changes in average temperatures across different counties in the US from the year 1960 to 2022. The analysis is performed using R, focusing on spatial data handling, visualization, and data processing.

## Libraries Used
- `ncdf4`: For handling netCDF data.
- `here`: For constructing file paths.
- `tidyverse`: For data wrangling and visualization.
- `terra`: For handling raster data.
- `sf`: For handling spatial data.

## Data Sources
- Average temperature data from NOAA Monthly U.S. Climate Gridded Dataset.
https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc:C00332

### Citation

Vose, Russell S., Applequist, Scott, Squires, Mike, Durre, Imke, Menne, Matthew J., Williams, Claude N. Jr., Fenimore, Chris, Gleason, Karin, and Arndt, Derek (2014): NOAA Monthly U.S. Climate Gridded Dataset (NClimGrid), Version 1. [1960 and 2022]. NOAA National Centers for Environmental Information. DOI:10.7289/V5SX6B56 [11/4/2023].

- US county centroid shapefile from the National Weather Service.
https://www.weather.gov/gis/Counties

**Citation Information:**
- **Originator:** National Weather Service
- **Publication Date:** 1995
- **Title:** Counties of U.S.
- **Geospatial Data Presentation Form:** vector digital data

**Publication Information:**
- **Publication Place:** Silver Spring, MD
- **Publisher:** National Weather Service
- **Online Linkage:** [National Weather Service Geodata](http://www.nws.noaa.gov/geodata/county/html/county.htm)

## Workflow

### Data Collection:
1. Download the average temperature netCDF file from NOAA.
2. Download the US county centroid shapefile from the National Weather Service.

### Data Processing:
1. Check and create required directories for data storage and processing.
2. Unzip the downloaded shapefile.
3. Load necessary R packages and source custom functions for data processing.

### Spatial Data Handling:
1. Extract and export specific layers from the netCDF file for the years 1960 and 2022.
2. Read in the county centroid shapefile and process it for later use.

### Data Analysis:
1. Extract temperature values for each county for the years 1960 and 2022.
2. Calculate the average temperature for each county for both years.
3. Compute the temperature change for each county over the time period.

### Visualization Preparation:
1. Categorize temperature change into various ranges for better visualization.
2. Prepare a color palette and legend for the visualization.

### Plot Assembly:
1. Create a plot showing the temperature change across US counties.
2. Customize the plot with labels, legend, and title.

### Saving the Plot:
Save the final plot to a file named `Temperature.png`.

## Output
A visualization showing the change in average temperatures across US counties from 1960 to 2022, saved as `Temperature.png`. 

![Temperature US](https://github.com/SamMajumder/GeoVizHub/blob/main/TempDiffUS/Temperature.png)

## Custom Functions
Custom functions are utilized for specific tasks such as extracting and exporting layers from the netCDF file, extracting values from raster data at specified point locations, and processing the data for visualization.

## Instructions to Run the Code
1. Ensure all required libraries are installed.
2. Place the script in a directory and set it as the working directory in R.
3. Run the script to generate the output plot showing the temperature change.
