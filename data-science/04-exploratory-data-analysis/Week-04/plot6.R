################################################################################
# This script creates the file plot6.png, which is a required part of the      #
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


# Convert SCC column to character.
scc$SCC <- as.character(scc$SCC)

# Create an index of Source Classification Codes for highway vehicles.
# This excludes recreational equipment and off-road vehicles.
index <- scc %>% filter(grepl("Highway Vehicles", SCC.Level.Two)) %>% select(SCC)

# Subset the data.
nei <- nei %>% filter(SCC %in% index[[1]] & fips %in% c("24510", "06037"))

# Calculate the total emissions from all sources by year.
totalByCountyAndYear <- nei %>% group_by(fips, year) %>% summarize(total = sum(Emissions))

# Transform the fips and year columns into factors.
totalByCountyAndYear$fips <- as.factor(totalByCountyAndYear$fips)
totalByCountyAndYear$year <- as.factor(totalByCountyAndYear$year)

# Rename the fips column.
names(totalByCountyAndYear)[1] <- "county"

# Rename the levels of the county factor.
levels(totalByCountyAndYear$county) <- c("Los Angeles County, CA", "Baltimore City, MD")



################################################################################
#
#        CREATING THE PLOT


# Load required libraries.
if(!require("ggplot2")) {
  install.packages("ggplot2")
  library(ggplot2)
}

if(!require("scales")) {
  install.packages("scales")
  library(scales)
}

# Plot the data and save it to a 480x480 .png file in the current working directory.
png(file = "plot6.png", antialias = "none")
ggplot(totalByCountyAndYear, aes(x = year, y = total, colour = county, group = county)) +
  geom_line() +
  labs(title = "Total PM2.5 emissions from motor vehicles", x = "year of release", y = "total PM2.5 emissions, in tons") +
  scale_y_continuous(labels = comma)
dev.off()

# Print a message to the console.
print(paste("This script has now created a file called 'plot6.png'. Look for it in ", getwd(), "."))
