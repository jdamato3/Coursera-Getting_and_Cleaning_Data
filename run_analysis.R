# James D'Amato
# Coursera: Getting and Cleaning Data - Project
# Due Date: August 23, 2015

###################################################################################################

library(reshape2)

filename = "project_dataset.zip"

# Download the dataset
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, filename, method="curl")

# Unzip the dataset
unzip(filename)

# Load activity labels
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
# Ensure 2nd column is character vector
activityLabels[,2] <- as.character(activityLabels[,2])

# Load features
features <- read.table("UCI HAR Dataset/features.txt")
# Ensure 2nd column is character vector
features[,2] <- as.character(features[,2])

# Grep the features that only contain the mean and standard deviation
featuresSel <- grep(".*mean.*|.*std.*", features[,2])
# Set the names to the selected features
featuresSel.names <- features[featuresSel,2]
# Replace hypenated suffixes with only characters
featuresSel.names = gsub('-mean', 'Mean', featuresSel.names)
featuresSel.names = gsub('-std', 'Std', featuresSel.names)
# Remove empty suffixes
featuresSel.names <- gsub('[-()]', '', featuresSel.names)

# Load the training dataset
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresSel]
# Load the training results
trainRes <- read.table("UCI HAR Dataset/train/Y_train.txt")
# Load the training subjects
trainSubs <- read.table("UCI HAR Dataset/train/subject_train.txt")
# Merge to create a complete training dataset
trainData <- cbind(trainSubs, trainRes, trainData)

# Load the test dataset
testData <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresSel]
# Load the test results
testRes <- read.table("UCI HAR Dataset/test/Y_test.txt")
# Load the test subjects
testSubs <- read.table("UCI HAR Dataset/test/subject_test.txt")
# Merge to create a complete test dataset
testData <- cbind(testSubs, testRes, testData)

# Merge training and test sets to generate a complete dataset
cmpltData <- rbind(trainData, testData)
# Set the applicable column names
colnames(cmpltData) <- c("subject", "activity", featuresSel.names)

# Ensure activities within complete dataset are factors
cmpltData$activity <- factor(cmpltData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
# Ensure subjects within complete dataset are subjects
cmpltData$subject <- as.factor(cmpltData$subject)

# Stack into single column
cmpltData.melted <- melt(cmpltData, id = c("subject", "activity"))
# Set ID variables 
cmpltData.mean <- dcast(cmpltData.melted, subject + activity ~ variable, mean)

# Per instructions, write output to text file
write.table(cmpltData.mean, "~/Documents/tidyData.txt", row.names = FALSE, quote = FALSE)
