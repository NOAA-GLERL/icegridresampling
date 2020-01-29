## Temporal interpolation for ice cover data using linear interpolatin with categorization
## Reference: ...
## Input: 1. GLERL Resampled 1024x1024 Grid [Winter 1973-2007]: 
##		     - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical
##			 - National Snow and Ice Data Center
## 		  2. GLERL 1024x1024 Grid [Winter 2008-Present]: 
##		     - NOAA GLERL: https://www.glerl.noaa.gov/data/ice/#historical
##			 - National Snow and Ice Data Center
##		  3. Projection information of Grid-510 and Grid-1024:
##			 - See reference 	
## Output: 1. The ascii files of psudo-daily 1024x1024 grid
##		   2. The ice cover plots of temporal-interpolated 1024x1024 grid
##		   3. Time and flag [whether the data is temporal interpolated: 1-measurement, 2-Interpolated]

## Scripts can run under RStudio version 1.1.463
## Time_Interp.R Apr 2019 @ NOAA GLERL yang.3328@osu.edu/james.kessler@noaa.gov

rm(list=ls())

Packages <- c("raster", "ggplot2", "timeDate", "arules", "fields", "gdata")
lapply(Packages, library, character.only = TRUE)

# Set the file dir
setwd('THE FOLDER DIR OF TIME_INTERP.R SCRIPT')
File_Dir <- 'THE FOLDER DIR OF 1024x1024 GRID DATA'

## Set global variables
year_str <- 1973
year_end <- 2010
Level_IC_1 <- c(-99, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100)
Level_IC_2 <- c(-99, 0, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 100)
break_1 <- c(-99, 0, 2.5, 7.5, 12.5, 17.5, 22.5, 27.5, 32.5, 37.5, 42.5, 47.5, 52.5, 57.5, 62.5, 67.5, 72.5, 77.5, 82.5, 87.5, 92.5, 97.5, 100)
break_2 <- c(-99, 0, 2.5, 7.5, 15, 25, 35, 45, 55, 65, 75, 85, 92.5, 97.5, 100)
CRS_1024 <- "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=-24 +datum=WGS84 +units=m +no_defs"
r <- raster(nrows=1024, ncols=1024, crs = CRS_1024,
            xmn=-10288021.9553, xmx=-8444821.9553, ymn=4675974.1583, ymx=6519174.1583) 
values(r) <- NA
t_Julian <- c()
Flag_TI <- c()
# Create output folder
dir.create("TXT_Raster_TimeInt")
dir.create("Fig_Raster_TimeInt")

for (year in year_str:year_end){
  dir.create(paste("TXT_Raster_TimeInt/",year, sep = ''))
  dir.create(paste("Fig_Raster_TimeInt/", year, sep = ""))
  
  ## List the file
  List_CT <- list.files(path = paste(File_Dir, year, sep = ''))
  # Recoring Time
  temp_t <- as.numeric(julian(timeDate(substr(List_CT[1], 2, 9), format='%Y%m%d')))
  y_J_ori <- y_J_int <- c(temp_t)
  t_Julian <- c(t_Julian, temp_t)
  # Recoring data
  Data_Ori <- Data_Interp <- stack(r)
  temp_data <- Data_Ori[[1]] <- Data_Interp[[1]] <- raster(matrix(scan(file=paste(File_Dir, year, '/',List_CT[1], sep=''),skip=6),
                                                                  1024, 1024, byrow=TRUE), crs = CRS_1024,
                                                           xmn=-10288021.9553, xmx=-8444821.9553, ymn=4675974.1583, ymx=6519174.1583)
  # Flag for whether the data is interpolated: 1-measurement, 2-Interpolation
  Flag_TI <- c(Flag_TI, 1)

  for (k in 1:(length(List_CT)-1)) {
    # Convert calender time to julian date
    time_str <- temp_t
    time_end <- temp_t <- as.numeric(julian(timeDate(substr(List_CT[k+1], 2, 9), format='%Y%m%d')))
    
	# If time_end is the next day of time_str -> no need to interpolate 
    if ((time_end-time_str) == 1) {
      next
    }
	
    # Assign the categorized levels based on observed time whether before winter 1983
    if (as.numeric(substr(List_CT[k], 2, 9))<19820800) {
      Level_IC <- Level_IC_1
      break_level <- break_1
    } else {
      Level_IC <- Level_IC_2
      break_level <- break_2
    }
    
    # Record the time
    t_Julian <- c(t_Julian, ((time_str+1):time_end))
    y_J_int <- c(y_J_int, ((time_str+1):time_end))
    y_J_ori <- c(y_J_ori, time_end)
    
    # Read ice cover data
    x <- sapply(1:(time_str-time_end+1), function(...) r)
    x[[1]] <- temp_data
    x[[length(x)]] <- temp_data <- raster(matrix(scan(file=paste(File_Dir, year, '/', List_CT[k+1], sep=''),skip=6), 1024, 1024, byrow=TRUE),
                                          crs = CRS_1024,xmn=-10288021.9553, xmx=-8444821.9553, ymn=4675974.1583, ymx=6519174.1583)
    # Flag
    Flag_TI <- c(Flag_TI, c(rep(2, times=(time_end-time_str-1)),1))
    
    # Convert raster layer to stack for linear interpolation between layers
    s <- stack(x)
    z <- approxNA(s)
    
    # Output the interpolation results to txt file and plot the figure
    for (i in 2:(nlayers(z)-1)) {
      temp1 <- as.matrix(z[[i]])
      dim(temp1) <- c(1,1024*1024)
      # Set land area (=-1) to NA
      temp1[temp1==-1] <- NA
      
      # Convert the interpolated values to 13th level of ice cover value
      temp2 <- as.numeric(discretize(temp1, method = "fixed", breaks = break_level))
      temp1 <- Level_IC[temp2]
      temp1[is.na(temp1)] <- -1
      dim(temp1) <- c(1024,1024)
      
      # Output the txt and plot
      file_name <- format(as.Date(time_str+i-1, origin=as.Date("1970-01-01")), "%Y%m%d")
      cat("#ncols         1024\n#nrows         1024\n#xllcorner     -10288021.9553\n#yllcorner     4675974.1583\n#cellsize      1800\n#NODATA_value  -99\n",
          file=paste("TXT_Raster_TimeInt/", year, '/',file_name,"_TI.ct",sep=""))
      write.fwf(temp1, file = paste("TXT_Raster_TimeInt/", year, '/',file_name,'_TI.ct', sep=""), 
                width = c(3), sep = " ", quote=FALSE, colnames = FALSE, rownames=FALSE, append=TRUE)
      # Plot the figure
      temp1 <- raster(temp1, crs = CRS_1024,
                      xmn=-10288021.9553, xmx=-8444821.9553, ymn=4675974.1583, ymx=6519174.1583)
      png(paste("Fig_Raster_TimeInt/", year, '/',file_name,'_TI.jpg',sep=""),width=850,height=850)
      plot(temp1, col=tim.colors(), legend=FALSE, axes=FALSE, zlim=c(0,100), xlab="", ylab="")
      plot(temp1,zlim=c(0,100), col=tim.colors(),legend.only=TRUE,horizontal=TRUE,
           smallplot=c(0.25,0.75,0.17,0.19), 
           legend.args=list(text='Ice Coverage [%]', side=3, cex=1.4),
           axis.args=list(at=seq(0,100,20),cex.axis=1.3,tck=0.4,mgp = c(3, 0.6, 0)))
      dev.off()
      
      Data_Interp <- addLayer(Data_Interp, temp1)
      rm(temp1, temp2)
    }
    Data_Ori <- addLayer(Data_Ori, temp_data)
    Data_Interp <- addLayer(Data_Interp, temp_data)
    rm(x,s,z)
  }
}
# Output Time/Flag
t_Calender <- as.Date(t_Julian, origin=as.Date("1970-01-01"))
Output_T_Flag <- data.frame(Date = t_Calender, Flag = Flag_TI)
write.table(Output_T_Flag, file = "Output_T_Flag.csv", sep = ",", quote = FALSE, row.names=FALSE, col.name=TRUE)
