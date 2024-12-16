# icegridresampling
Scripts used to convert historical Great Lakes ice cover 510 x 516 grids to 1024 x 1024 grids.  Data can be found on the NOAA-GLERL website at https://www.glerl.noaa.gov/data/ice/#historical or downloaded from the THREDDs server at https://coastwatch.glerl.noaa.gov/thredds/Satellite/ice/ice_concentration_catalog.html.  


The spatial interpolation for converting grids from the 510 x 516 to the 1024 x 1024 grids are processed by the “Resampling_Raster.R” script.  The temporal interpolation to create a daily data product prior to 2011 was estimated by the “Time_Interp.R” script.  Both scripts utilize RStudio version 1.1.463.

Sample code for reading in the ice data (from ".ct" ASCII files) is available in Python, Matlab and R.

More information available about the ice data set can be found at: 
Yang, T.-Y., Kessler, J., Mason, L., Chu, P. Y., & Wang, J. (2020). A consistent Great Lakes ice cover digital data set for winters 1973–2019. Scientific Data, 7(1). https://doi.org/10.1038/s41597-020-00603-1



_This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project code is
provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of
Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed
by all applicable Federal law. Any reference to specific commercial products, processes, or services by service
mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or
favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a
DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by
DOC or the United States Government._
