# North American Sunflower Species Distribution

This project aims to analyze and visualize the distribution of certain wild sunflower species (Genus Helianthus) across different ecoregions in North America. The analysis is carried out using R, with a focus on spatial data handling and visualization.

## Libraries Used

- `rgbif`: For accessing species occurrence data from the Global Biodiversity Information Facility (GBIF).
- `here`: For constructing file paths.
- `tidyverse`: For data wrangling and visualization.
- `sf`: For handling spatial data.
- `RColorBrewer`: For color palettes.
- `cowplot`, `gridExtra`, `grid`, `ggspatial`, `rayshader`: For advanced plotting and visualization.

## Data Sources

1. Species occurrence data from GBIF (Global Biodiversity Information Facility)
2. Ecoregion shapefile representing different level I ecoregions in North America. (https://www.epa.gov/eco-research/ecoregions-north-america)

## Workflow

1. **Data Collection**:
   - Fetch a list of sunflower species and their occurrence data in North America from GBIF.

2. **Data Processing**:
   - Filter and modify the retrieved data to isolate specific species and variables of interest.

3. **Spatial Data Handling**:
   - Convert the data frame to a spatial object and perform coordinate transformations.

4. **Spatial Join**:
   - Match sunflower data with the corresponding ecoregion based on geographical coordinates.

5. **Centroid Calculation**:
   - Calculate the centroid of each group of species occurrences within an ecoregion.

6. **Visualization Preparation**:
   - Define custom color and shape mappings for the visualization.

7. **Plot Assembly**:
   - Combine the main plot, legend plots, and title into a final plot layout.

8. **Saving the Plot**:
   - Save the final plot to a file.

## Output

A visualization showing the distribution of selected sunflower species across North American ecoregions, saved as `sunflower_distribution.png`.

```
