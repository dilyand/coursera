################################################################################
#  This script creates a file called 'tidyset.txt'. The script and the file    #
#  are required parts of the submission for the programming assignment at      #
#  the end of week 4 of the Getting and Cleaning Data course.                  #
#                                                                              #
#  This script assumes that you have downloaded the 'Human Activity            #
#  Recognition Using Smartphones Dataset' and extracted it to the current      #
#  working directory, without modifying any of the folder or file names.       #
#                                                                              #
#  The process for creating this script is described in detail in the          #
#  'README' file contained in this repo.                                       #
################################################################################



##############################
#  READING IN REQUIRED DATA  #
##############################

# Read in the test set.
testSet <- read.table("./UCI HAR Dataset/test/X_test.txt")

# Read in the training set.
trainingSet <- read.table("./UCI HAR Dataset/train/X_train.txt")

# Read in the features list.
features <- read.table("./UCI HAR Dataset/features.txt")

# Read in the label lists.
testLabels <- read.table("./UCI HAR Dataset/test/y_test.txt")
trainingLabels <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Read in the subject lists.
testSubjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainingSubjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Read in the activity names.
activityNames <- read.table("./UCI HAR Dataset/activity_labels.txt")



################################################
#  STEP 1: MERGING THE TEST AND TRAINING SETS  #
################################################

# Merge the two datasets.
mergedSet <- rbind(testSet, trainingSet)



##############################################################
#  STEP 2: EXTRACT MEAN AND STANDARD DEVIATION MEASUREMENTS  #
##############################################################

# Create an index of the relevant column names.
# Escape the brackets to ensure they are interpreted as literals.
# This prevents, eg `fBodyBodyGyroJerkMag-meanFreq()` from ending up in the results.
meanColumnNamesIndex <- grep("mean\\(\\)", features$V2)
stdColumnNamesIndex <- grep("std\\(\\)", features$V2)

# Combine the two in a single, sorted numeric vector.
columnNamesIndex <- sort(as.numeric(c(meanColumnNamesIndex, stdColumnNamesIndex)))

# Use this index to extract only the desired mean and standard deviation measurements.
filteredSet <- mergedSet[ , columnNamesIndex]



############################################
#  STEP 3: ADD DESCRIPTIVE ACTIVITY NAMES  #
############################################

# Merge the two label sets and then add the labels as a new column in the filtered merged set.

# Merge the label sets, making sure to use the same order as when merging the test and training datasets.
mergedLabels <- rbind(testLabels, trainingLabels)

# Add a label column to filteredSet.
filteredSet$activityLabels <- mergedLabels$V1

# Make the label column the first column in the table.
filteredSet <- filteredSet[ , c(ncol(filteredSet), 1:(ncol(filteredSet) - 1))]

#=================================#
#  Add a subject column as well   #
#=================================#

# Merge the subject sets, making sure to use the same order as when merging the test and training datasets.
mergedSubjects <- rbind(testSubjects, trainingSubjects)

# Add a subject column to filteredSet.
filteredSet$subject <- mergedSubjects$V1

# Make the subject column the first column in the table.
filteredSet <- filteredSet[ , c(ncol(filteredSet), 1:(ncol(filteredSet) - 1))]

#==================================#
#  Back to adding activity labels  #
#==================================#

# Match the filtered set to the activity names.
labelledFilteredSet <- merge(filteredSet, activityNames, by.x = "activityLabels", by.y = "V1")

# Replace the numeric labels with descriptive ones.
labelledFilteredSet$activityLabels <- labelledFilteredSet$V2.y

# Drop the redundant column.
labelledFilteredSet$V2.y <- NULL

# Joining the tables renamed a column (because both tables had a column called V2).
# Change the name back to the original name.
names(labelledFilteredSet)[4] <- "V2"



############################################
#  STEP 4: ADD DESCRIPTIVE VARIABLE NAMES  #
############################################

# Use the index from Step 2 to extract the desired column names from the features list
# and assign those names to the unnamed columns of the labelled filtered set.
names(labelledFilteredSet)[-c(1, 2)] <- as.vector(features$V2[columnNamesIndex])



###########################################
#  STEP 5: CREATE THE FINAL TIDY DATASET  #
###########################################

# Load the `dplyr` package.
if(!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}

# Transform the labelled filtered set into a tibble.
labelledFilteredSet <- as_tibble(labelledFilteredSet)

# Group by activity and subject.
groupedSet <- labelledFilteredSet %>% group_by(activityLabels, subject)

# By omitting the `vars` argument, I ensure it defaults to all non-grouped columns
tidySet <- groupedSet %>% summarize_all(mean, na.rm = TRUE)

# Write the tidy dataset to a file in the current working directory.
write.table(tidySet, file = "./tidyset.txt", row.names = FALSE)
