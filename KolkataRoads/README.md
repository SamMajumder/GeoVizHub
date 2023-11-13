# Streets and Waterways of Kolkata Visualization
This project generates a detailed visualization of the streets and waterways in and around Kolkata, India, using data from OpenStreetMap. The map differentiates between main streets, small streets, and water bodies, using a color-coded scheme for easy distinction.

## Libraries Used
`osmdata`
`sf`
`terra`
`tidyverse`

## Workflow Description

### 1) City Boundaries:

Retrieves the boundaries of Kolkata from OpenStreetMap.
Filters out the state polygon to focus on the city level.

### 2) Defining Areas for the Map:

Narrows down to specific areas within and around Kolkata for detailed visualization.

### 3) Main Streets Extraction:

Extracts major streets such as motorways, primary, secondary, and tertiary roads.

### 4) Small Streets Extraction:

Gathers data on smaller streets including residential, living streets, service roads, and footways.

### 5) Water Bodies Extraction:

Collects data on natural water bodies within the specified boundaries.

### 6) Visualization Preparation:

Creates a ggplot object and layers the spatial data with appropriate aesthetic mappings.
Applies manual color scales to differentiate between street types and water bodies.
Adjusts the theme for a visually appealing dark background and white text.

### 7) Title and Citation:

Adds a title to the visualization indicating the focus on Kolkata's streets and waterways.
Includes a caption to cite OpenStreetMap as the data source.

### 8) Saving the Plot:

Saves the visualization as a high-resolution PNG file with custom dimensions and background settings. 

### Final map 

![Kolkata Roads](https://github.com/SamMajumder/GeoVizHub/blob/main/KolkataRoads/Kolkata_Roads.png)

## Data Sources
OpenStreetMap data for Kolkata's boundaries, streets, and waterways.

## Citation
Map data © OpenStreetMap contributors. The visualization is created by processing OpenStreetMap data, which is made available under the Open Data Commons Open Database License (ODbL).
