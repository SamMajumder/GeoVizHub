# Bilingual and Trilingual Mapping in India

## Introduction
This project focuses on creating detailed maps showcasing the proportion of bilingual and trilingual populations in each state of India. It leverages various R packages for spatial data handling, data manipulation, and visualization, aiming to provide insightful geospatial representations of language diversity across the country.

## Packages Used
The project relies on the following R packages for its execution:
- `here`
- `tidyverse`
- `terra`
- `sf`
- `RColorBrewer`
- `readxl`
- `viridis`
- `gridExtra`

## Workflow

### 1. Setup
- Necessary R packages are loaded.
- Directories are set up for organized data storage.

### 2. Data Import
- State shapefiles are imported and processed with necessary renaming and mutation for uniformity.

### 3. Data Manipulation
- States of Telangana and Andhra Pradesh are merged for updated geographical representation.
- Population data is loaded and processed, including the merging of certain states for consistency.

### 4. Bilingual and Trilingual Data Processing
- Data regarding bilingual and trilingual populations are imported and processed.
- Proportions of bilingual and trilingual populations are calculated relative to the total population of each state.

### 5. Geospatial Visualization
- Maps are created to visualize the proportion of bilingual and trilingual populations in each state.
- Insets for smaller regions like Lakshadweep and Andaman & Nicobar are created for detailed representation.
- Custom color palettes are applied for better visual distinction.

### 6. Final Output
- The final maps are saved as high-resolution PNG files.
- Insets are carefully placed to ensure visibility of smaller regions.

## Output
The project yields two detailed maps:
- A map visualizing the percentage of the bilingual population in India.
- A map showing the percentage of the trilingual population in India.

Each map includes insets for smaller regions and is colored based on the proportion of the population speaking two or three languages.

### Final Maps
- Bilingual Population Map: `India_bilingual.png`
- Trilingual Population Map: `India_trilingual.png`

## Data Sources
1) **India State Boundaries shapefile** = Parliamentary Constituencies Maps are provided by Data{Meet} Community Maps Project. Its made available under the Creative Commons Attribution 2.5 India. (http://projects.datameet.org/maps/)
2) **Population and Language Census data** = Office of Registrar General & Census Commissioner, India, Ministry of Home Affairs, Government of India (https://censusindia.gov.in/census.website/data/census-tables)
