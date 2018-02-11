################################################################################
# This script creates the file plot4.png, which is a required part of the      #
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

# Create an index of Source Classification Codes for coal combustion-related sources.
index <- scc %>% filter(grepl("Coal", Short.Name)) %>% select(SCC)

# Subset the data.
nei <- nei %>% filter(SCC %in% index[[1]] & year %in% c(1999, 2008))

# Calculate the total emissions from all sources by year.
totalByYear <- nei %>% group_by(year) %>% summarize(total = sum(Emissions))

# Transform the year column into factor.
totalByYear$year <- as.factor(totalByYear$year)



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
png(file = "plot4.png", antialias = "none")
ggplot(data = totalByYear, aes(x = year, y = total)) +
  geom_bar(stat = "identity") +
  labs(title = "Total PM2.5 emissions from coal combustion-related sources in the US", x = "year", y = "total PM2.5 emissions, in tons") +
  scale_y_continuous(labels = comma)
dev.off()

# Print a message to the console.
print(paste("This script has now created a file called 'plot4.png'. Look for it in ", getwd(), "."))
