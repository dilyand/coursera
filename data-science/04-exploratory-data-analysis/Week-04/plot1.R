################################################################################
# This script creates the file plot1.png, which is a required part of the      #
# submission for the Week 4 project of the Exploratory Data Analysis course.   #
#                                                                              #
# By default, the script assumes you already have two files -- called          #
# 'summarySCC_PM25.rds' and 'Source_Classification_Code.rds'                   #
# in the current working directory.                                            #
################################################################################



################################################################################
#
#        READING IN THE DATA


# Load the `dplyr` package.
if(!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}

# Read in the data.
nei <- tbl_df(readRDS("summarySCC_PM25.rds"))
scc <- tbl_df(readRDS("Source_Classification_Code.rds"))



################################################################################
#
#        DATA TRANSFORMATIONS


# Calculate the total emissions from all sources by year of data release.
totalByYear <- nei %>% group_by(year) %>% summarize(total = sum(Emissions))

# Transform the year column into factor.
totalByYear$year <- as.factor(totalByYear$year)


################################################################################
#
#        CREATING THE PLOT


# Plot the data and save it to a 480x480 .png file in the current working directory.
png(file = "plot1.png", antialias = "none")
with(totalByYear, plot(total / 1000000, pch = 19, type = "b", axes = FALSE, main = "Total PM2.5 emissions in the US", sub = "by year of data release", xlab = "", ylab = "total PM2.5 emissions from all sources, in tons"))
axis(side = 1, at = totalByYear$year, labels = totalByYear$year)
pts <- pretty(totalByYear$total / 1000000)
axis(side = 2, at = pts, labels = paste(pts, "m", sep = ""))
box()
dev.off()

# Print a message to the console.
print(paste("This script has now created a file called 'plot1.png'. Look for it in ", getwd(), "."))
