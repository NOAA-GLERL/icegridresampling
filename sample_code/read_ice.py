"""
Read GLERL ice cover 1024x1024 grid data

Input: GRERL 1024x1024 grid
       - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical      
       - National Snow and Ice Data Center: https://doi.org/10.7265/krkb-f591
Output: 1. ncols: number of columns
		2. nrows: number of rows
		3. xllcorner: X coordinate of the lower-left corner of the grid (unit: m)
		4. yllcorner: Y coordinate of the lower-left corner of the grid (unit: m)
		5. cellsize: cell size in meters
		6. NODATA_value: the code for no data (-99)
		7. ice_cover: ice cover 1024x1024 grid (unit: %)
		8. lat: WGS84 latitude coordinate of each pixel (unit: degree)
		9. lon: WGS84 longitude coordinate of each pixel (unit: degree) 

Scripts can run under Python version 3.7
Read_IceCover.py: Jun 2020 @ NOAA GLERL yang.3328@osu.edu/james.kessler@noaa.gov
"""




import numpy as np
from linecache import getline as gl

file_name = "file name"

# Read header
hdr = [gl(file_name, i) for i in range(1,7)]
values = [float(h.split(" ")[-1].strip()) for h in hdr]
ncols, nrows, xllcorner, yllcorner, cellsize, NODATA_value = values
del hdr, values

# Read ice cover data
ice_cover  = np.loadtxt(file_name, skiprows=7)

# Read ltitude/longitude data
lat = np.loadtxt("1024_latgrid.txt")
lon = np.loadtxt("1024_longrid.txt")

