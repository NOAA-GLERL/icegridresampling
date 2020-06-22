%% Read GLERL ice cover 1024x1024 grid data
%  Input: GRERL 1024x1024 grid
%         - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical      
%         - National Snow and Ice Data Center: https://doi.org/10.7265/krkb-f591
%  Output: 1. ncols: number of columns
%		   2. nrows: number of rows
%		   3. xllcorner: X coordinate of the lower-left corner of the grid (unit: m)
%		   4. yllcorner: Y coordinate of the lower-left corner of the grid (unit: m)
%		   5. cellsize: cell size in meters
%		   6. NODATA_value: the code for no data (-99)
%		   7. IC: ice cover 1024x1024 grid (unit: %)
%		   8. Lat: WGS84 latitude coordinate of each pixel (unit: degree)
%		   9. Lon: WGS84 longitude coordinate of each pixel (unit: degree) 
%  Scripts can run under Matlab version R2019b
%  Read_IceCover.m: Jun 2020 @ NOAA GLERL yang.3328@osu.edu/james.kessler@noaa.gov
clc; clear all; close all;

%% Read data
%  Unit: %, "-1": land, "-99": missing data
file_name = 'file name';
fid = fopen(file_name);
temp = [];
% Read header
for i = 1:6
    s = fgets(fid);
    temp = [temp; str2num(s(15:end))];
end
temp = num2cell(temp);
[ncols, nrows, xllcorner, yllcorner, cellsize, NODATA_value] = temp{:};
fclose(fid); 
clear temp s i;

% Read ice cover data
fid = fopen(file_name);
dat = textscan(fid,repmat('%d',1,1024),'Headerlines',7);
IC = double(cell2mat(dat)); 
fclose(fid);
clear dat fid;

% Read latitude data
fid = fopen('1024_latgrid.txt');
dat = textscan(fid,repmat('%.5f',1,1024));
Lat = cell2mat(dat);
fclose(fid);
clear dat fid;

% Read longitude data
fid = fopen('1024_longrid.txt');
dat = textscan(fid,repmat('%.5f',1,1024));
Lon = cell2mat(dat);
fclose(fid);
clear dat fid;