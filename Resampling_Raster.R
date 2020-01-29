## Resampling the GLERL 510x516 (Grid-510) to 1024x1024 (Grid-1024) using projection with Nearest Neighbor Search method
## Reference: ...
## Input: 1. GLERL 510x516 grid: 
##		     - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical
##			 - National Snow and Ice Data Center
## 		  2. CoastWatch Water/land mask: 
##			 - CoastWatch Land Mask: https://coastwatch.glerl.noaa.gov/ftp/masks/
##		  3. Projection information of Grid-510 and Grid-1024:
##			 - See reference 	
## Output: 1. The ascii files of Resamped 1024x1024 grid
##		   2. The ice cover plots of original 510x516 and resampled 1024x1024 grid

## Scripts can run under RStudio version 1.1.463
## Resampling_Raster.R July 2018 @ NOAA GLERL yang.3328@osu.edu/james.kessler@noaa.gov

rm(list=ls())

library(raster)
library(fields)
library(gdata)

# Set the file dir
setwd('THE FOLDER DIR OF RESAMPLING_RASTER SCRIPT')
File_Dir <- 'THE FOLDER DIR OF 510X516 GRID DATA'


# Randomly choose g20180521.ct as 1024 referenced grid
r_1024 <- raster(matrix(scan(file=paste(File_Dir,'2018/', 'g20180521.ct',sep=""),skip=6),1024,1024, byrow=TRUE),
                 crs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=-24 +datum=WGS84 +units=m +no_defs",
                 xmn=-10288021.9553, xmx=-8444821.9553, ymn=4675974.1583, ymx=6519174.1583)
mask_1024 <- matrix(scan('THE FILE DIR OF 1024 LAND/WATER MASK'),1024,1024,byrow=TRUE)

# Set Parameters
year_str <- 1973
year_end <- 2007
dir.create("TXT_Raster")
dir.create("Fig_Raster")

for (year in year_str:year_end){
  print(year)
  File_Path = paste(File_Dir, year, '/', sep = '')
  dir.create(paste("TXT_Raster/", year, sep = ''))
  dir.create(paste("Fig_Raster/", year, sep = ''))
  List_CT <- list.files(path = File_Path)
  List_CT <- sub('.ct', '', List_CT)
  for (k in 1:(length(List_CT))) {
    file_name <- List_CT[k]
    # Read 510x516 grid and rasterize
    ori_data<-matrix(scan(file=paste(File_Path, file_name,'.ct', sep=""),skip=6),510,516, byrow=TRUE)
    r_data <- raster(ori_data, crs="+proj=merc +lon_0=-84.14 +lat_ts=45.04 +x_0=0 +y_0=0 +ellps=clrk66 +units=m +no_defs",
                     xmn=-649446.25, xmx=666353.75, ymn=3306260, ymx=4606760)
    # Project 510 grid to 1024 grid using nearest nighbor, which is used to compute values for the new rasterLayer
    r_project <- projectRaster(r_data, r_1024, method="ngb")
    # Get the re-sampling value for filling process
    temp <- matrix(getValues(r_project),1024,1024,byrow=TRUE)
    # Check the boundary with 1024 mask:
    # If [mask1024 = land or re-sample1024 = land] <- NA, the later criteria is for preventing "-1" influence filling process
    temp[mask_1024==0 | temp==-1] <- NA
    # Finding the pixels which are mask1024=water, but resample1024 = land -> which have to be filled in values
    NA_lo <- which(mask_1024!=0 & is.na(temp), arr.ind = TRUE)
    # Using searching window to search most common values around the pixels. It will enlarge the window size until all of the pixels find the value
    win_size <- 1
    while (nrow(NA_lo)!=0){
      val_fil <- matrix(NA, nrow(NA_lo),(win_size*2+1)^2)
      for (i in 1:nrow(NA_lo)){
        if ((NA_lo[i,2][[1]]+win_size)>1024){ # For the right part of Lake Ontario
          up_bd <- 1024
          size_ext <- (win_size*2+1) * ((win_size*2+1)-(NA_lo[i,2][[1]]+win_size)+1024)
        } else{
          up_bd <- (NA_lo[i,2][[1]]+win_size)
          size_ext <- (win_size*2+1)^2 
        }
        # For every pixel, find the values within the window
        val_fil[i,1:size_ext] <- matrix(temp[(NA_lo[i,1][[1]]-win_size):(NA_lo[i,1][[1]]+win_size), (NA_lo[i,2][[1]]-win_size):up_bd],1,size_ext)
      }
      # Find the most common value
      val_fil_com <- matrix(NA, nrow(val_fil),1)
      for (q in 1:nrow(val_fil)){
        if (sum(is.na(val_fil[q, ]))==ncol(val_fil)){
          next
        }
        temp99 <- as.data.frame(table(val_fil[q,]))
        val_fil_com[q] <- as.numeric(as.character(temp99[which.max(temp99$Freq),1]))
      }
      temp[mask_1024!=0 & is.na(temp)] <- val_fil_com
      
      NA_lo <- which(mask_1024!=0 & is.na(temp), arr.ind = TRUE)
      win_size <- win_size + 1
    }
    # Assign "-1" to land
    temp[is.na(temp)] <- -1
    values(r_project) <- matrix(t(temp),1,1024*1024)
    
    # Output the files
    cat("#ncols         1024\n#nrows         1024\n#xllcorner     -10288021.9553\n#yllcorner     4675974.1583\n#cellsize      1800\n#NODATA_value  -99\n",
        file=paste("TXT_Raster/", year, '/',file_name,'.ct', sep=""))
    write.fwf(temp, file = paste("TXT_Raster/", year, '/',file_name,'.ct', sep=""), 
              width = c(3), sep = " ", quote=FALSE, colnames = FALSE, rownames=FALSE, append=TRUE)
    # Plot
    png(paste("Fig_Raster/", year, '/',file_name,'_Ori.jpg',sep=""),width=850,height=850)
    plot(r_data, col=tim.colors(), legend=FALSE, axes=FALSE, zlim=c(0,100), xlab="", ylab="")
    plot(r_data,zlim=c(0,100), col=tim.colors(),legend.only=TRUE,horizontal=TRUE,
               smallplot=c(0.25,0.75,0.17,0.19), 
               legend.args=list(text='Ice Coverage [%]', side=3, cex=1.4),
               axis.args=list(at=seq(0,100,20),cex.axis=1.3,tck=0.4,mgp = c(3, 0.6, 0)))
    dev.off()
    png(paste("Fig_Raster/", year, '/',file_name,'_RS.jpg',sep=""),width=850,height=850)
    plot(r_project, col=tim.colors(), legend=FALSE, axes=FALSE, zlim=c(0,100), xlab="", ylab="")
    plot(r_project,zlim=c(0,100), col=tim.colors(),legend.only=TRUE,horizontal=TRUE,
               smallplot=c(0.25,0.75,0.17,0.19), 
               legend.args=list(text='Ice Coverage [%]', side=3, cex=1.4),
               axis.args=list(at=seq(0,100,20),cex.axis=1.3,tck=0.4,mgp = c(3, 0.6, 0)))
    dev.off()
  }
}

        