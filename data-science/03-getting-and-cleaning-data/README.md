# Coursera - Data Science - Course 3: Getting and Cleaning Data - Week 4 - Programming Assignment

## Assignment Brief

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Step 1: Merge the training and test sets to create one data set

According to the *Human Activity Recognition* team:

> The (...) dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.

The two sets (test and training) live in the following files:

- `train/X_train.txt`: Training set.
- `test/X_test.txt`: Test set.

We can check that the two sets (test and training) have the same number of columns:

```R
if(!file.exists("./data/dilyand")) {
  dir.create("./data/dilyand")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl, destfile = "./data/dilyand/hardata.zip") # add method = "curl" if on a Mac

unzip("./data/dilyand/hardata.zip", exdir = "./data/dilyand")

testSet <- read.table("./data/dilyand/UCI HAR Dataset/test/X_test.txt")

trainingSet <- read.table("./data/dilyand/UCI HAR Dataset/train/X_train.txt")

# This should return TRUE if the two sets have the same number of columns
ncol(testSet) = ncol(trainingSet)
```

We can also confirm that the training set has ~70% of the observations:

```R
nrow(trainingSet) / (nrow(trainingSet) + nrow(testSet)) * 100
```

Since the two datasets have the same number of columns, merging them is easy:

```R
mergedSet <- rbind(testSet, trainingSet)
```

We can verify that the merged set has the correct dimensions -- the same number of columns as the test and training sets, and a number of rows equal to the sum of the rows of the two original sets:

```R
# Both of these should return TRUE
(ncol(mergedSet) == ncol(testSet)) & (ncol(mergedSet) == ncol(trainingSet))
nrow(mergedSet) == nrow(testSet) + nrow(trainingSet)
```

## Step 2: Extract only the measurements on the mean and standard deviation for each measurement

Both the test and the training set, as well as our merged set don't have column names.

According to the *Human Activity Recognition* `README`, there is a file that contains all the column names, which are the same for both sets (test and training):

- `features.txt`: List of all features.

We can verify that `features.txt` has a name for each column in the two datasets:

```R
features <- read.table("./data/dilyand/UCI HAR Dataset/features.txt")

# This should return TRUE
(nrow(features) == ncol(testSet)) & (nrow(features) == ncol(trainingSet))
```

We only want the mean and standard deviation for each measurement. According to `features_info.txt` (which shows information about the variables used in the feature vector), the variables we are looking for are:

- mean(): Mean value
- std(): Standard deviation

The dataset has columns for these variables for each relevant feature (such as `tBodyAcc` or `tBodyAccJerk`). Some features break the signal down in three directions: X, Y and Z.

An example column name for the `mean()` variable of a feature on one axis looks like this: `fBodyAccJerk-mean()-Y`.

An example column name for the `std()` variable of a feature on one axis looks like this: `fBodyGyro-std()-Z`.

We can create an index of the relevant column names:

```R
# We need to escape the brackets to ensure they are interpreted as literals. This prevents, eg `fBodyBodyGyroJerkMag-meanFreq()` from ending up in the results.
meanColumnNamesIndex <- grep("mean\\(\\)", features$V2)
stdColumnNamesIndex <- grep("std\\(\\)", features$V2)

# Combine the two in a single, sorted numeric vector
columnNamesIndex <- sort(as.numeric(c(meanColumnNamesIndex, stdColumnNamesIndex)))
```

This index now let's us extract the desired column names from the features list:

```R
features$V2[columnNamesIndex]
```

We can now use this index to extract only the desired mean and standard deviation measurements:

```R
filteredSet <- mergedSet[ , columnNamesIndex]
```

We can verify that this filtered set has the same number of rows as the merged set, and that the number of columns in the filtered set is equal to the length of the index vector:

```R
# Both of these should return TRUE
nrow(filteredSet) == nrow(mergedSet)
ncol(filteredSet) == length(columnNamesIndex)
```

## Step 3: Use descriptive activity names to name the activities in the data set
