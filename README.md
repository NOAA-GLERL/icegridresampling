# icegridresampling
Scripts used to convert historical Great Lakes ice cover 510 x 516 grids to 1024 x 1024 grids.  Data can be found on the NOAA-GLERL website at https://www.glerl.noaa.gov/data/ice/#historical or downloaded from the THREDDs server at https://coastwatch.glerl.noaa.gov/thredds/Satellite/ice/ice_concentration_catalog.html.  


The spatial interpolation for converting grids from the 510 x 516 to the 1024 x 1024 grids are processed by the “Resampling_Raster.R” script.  The temporal interpolation to create a daily data product prior to 2011 was estimated by the “Time_Interp.R” script.  Both scripts utilize RStudio version 1.1.463.

More information available about the ice data set and these scripts in the manuscript below.

Yang, T.Y., J. Kessler, L. Mason, P.Y. Chu, J. Wang, (2020) A Consistent Great Lakes Ice Cover Digital Data Set for Winters 1973-2019. Scientific Data, in review.
