#Read GLERL ice cover 1024x1024 grid data
#
#Input: 
#    GLERL 1024x1024 grid 
#       - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical      
#       - National Snow and Ice Data Center: https://doi.org/10.7265/krkb-f591
#Output:
#	1. ncols: number of columns
#	2. nrows: number of rows
#	3. xllcorner: X coordinate of the lower-left corner of the grid (unit: m)
#	4. yllcorner: Y coordinate of the lower-left corner of the grid (unit: m)
#	5. cellsize: cell size in meters
#	6. NODATA_value: the code for no data (-99)
#	7. ice_cover: ice cover 1024x1024 grid (unit: %)
#	8. lat: WGS84 latitude coordinate of each pixel (unit: degree)
#	9. lon: WGS84 longitude coordinate of each pixel (unit: degree) 
#
#
# Read_IceCover.R: Jun 2020 @ NOAA GLERL yang.3328@osu.edu/james.kessler@noaa.gov

file_name='g20190309.ct'

# read in header and parse variable/value pairs
hdr <- read.table(file_name,nrows=6,row.names=1)
for (i in 1:6){ assign(row.names(hdr)[i], hdr[i,]) }

# read in ice_cover and coordinates
ice_cover <- matrix(scan(file_name, skip=7), nrows, ncols)
lat <- matrix(scan('1024_latgrid.txt'), nrows, ncols)
lon <- matrix(scan('1024_longrid.txt'), nrows,ncols)


