# Sundarban Shifts

## Project Overview
Sundarban Shifts is a remarkable endeavor to monitor the vegetation changes in the Sundarbans Mangroves, a unique ecosystem straddling Bangladesh and India. This project utilizes the MODIS MOD13A2 dataset to analyze the Normalized Difference Vegetation Index (NDVI) as a measure of vegetation health, shedding light on the ecological dynamics amidst climate change, sea-level rise, and human activities. By employing Python libraries for data visualization, this project presents an interactive geographical depiction of NDVI variations over time, encapsulating the essence of the Sundarbans' vegetation and underlining the importance of informed conservation strategies.

## Data Sources
- Vegetation Data: MODIS/006/MOD13A2 - Kamel Didan - University of Arizona, Alfredo Huete - University of Technology Sydney and MODAPS SIPS - NASA. (2015). [MOD13A2 MODIS/Terra Vegetation Indices 16-Day L3 Global 1km SIN Grid](http://doi.org/10.5067/MODIS/MOD13A2.006).

## Dependencies
- Python Libraries: `ee`, `numpy`, `pandas`, `matplotlib`, `PIL`, `imageio`, `os`, `IPython`, `osgeo`, `gdal`, `rasterio`
- Environment: [Google Earth Engine](https://earthengine.google.com/)

## Workflow
1. **Library Loading**: Installation of `rasterio` and importing required libraries for the script execution.
2. **Earth Engine Authentication**: Authentication and initialization of Google Earth Engine to access geospatial datasets.
3. **Yearly NDVI Calculation**: Definition of the region of interest (Sundarbans Mangroves) and fetching MODIS NDVI data for a specific year, iterating through the years to calculate the mean NDVI for each year, exporting the results to TIFF images.
4. **Plot Display**: Visualization of a subset of the generated NDVI images for selected years using Matplotlib.
5. **GIF Creation**: Reading the NDVI images, normalize and apply a custom colormap, and add a year label to each image, creating a GIF from the sequence of images to visualize the time-lapse of NDVI values.
6. **GIF Labeling**: Similar to the GIF creation, but adding a year label to each image in the GIF to visualize the time-lapse of NDVI values.

![Sundarban shifts](https://github.com/SamMajumder/GeoVizHub/blob/main/SundarbanShifts/SundarbanShifts.gif)

## Contributing
We welcome contributions to Sundarban Shifts! Please see our [Contributing Guide](CONTRIBUTING.md) for more details.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
