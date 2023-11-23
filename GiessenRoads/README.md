# Mapping Streets and Waterways of Giessen, Germany

## Introduction
This project is focused on visualizing the streets and waterways in Giessen, Germany using R. It demonstrates the use of spatial data to create a detailed map, highlighting different types of streets and water bodies. The map aims to provide a clear and informative view of the city's infrastructure.

## Requirements
To run this project, the following R libraries are needed:
- `osmdata` - For querying and retrieving spatial data from OpenStreetMap
- `sf` - For handling and manipulating spatial data
- `terra` - For spatial data analysis and modeling
- `tidyverse` - For data manipulation and visualization

## Project Structure

### Retrieving City Boundaries
- The city boundaries of Giessen, Germany are fetched using the `getbb` function from `osmdata` and filtered for administrative boundaries.

### Mapping Main Streets
- Main streets including motorways, primary, secondary, and tertiary roads are extracted and processed.

### Mapping Small Streets
- Small streets such as residential, living streets, service, and footways are also identified and processed.

### Water Bodies Mapping
- Water bodies within the city limits are retrieved and added to the map.

## Visualization
- A map is created using `ggplot`:
  - Different layers are added for small streets, main streets, and water bodies.
  - Custom color schemes are applied for visual distinction.
  - Aesthetic enhancements are made for readability and appeal.

## Saving the Final Output
- The final map is saved as a high-resolution PNG file, ensuring that all details are visible and clear.

![map](https://github.com/SamMajumder/GeoVizHub/blob/main/GiessenRoads/Code/Giessen_Roads.png)

## Usage
To run this project, simply load the R script and execute. Ensure all required libraries are installed.

## Output
The output of this project is a detailed map titled "Streets and waterways of Giessen", visualizing the city's layout in terms of its roads and water bodies.
