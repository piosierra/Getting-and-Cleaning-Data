
## Course project for Getting and Cleaning Data
## Author: Pio Sierra
## 
## This script creates a tidy data set according to the project requirements.
## Use the README.md file to see the full details.

## Loading needed libraries

library(dplyr)
library(reshape2)

## Unpacking the data if it is still not unpacked

if(file.exists("./getdata_projectfiles_UCI HAR Dataset.zip"))
  {
  unzip("./getdata_projectfiles_UCI HAR Dataset.zip")
  }

## Step 1: Merges the training and the test sets to create one data set.
## First we bind the columns of each data set, and then we bind the rows of the two sets.

## Binding test data
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
all_test <- cbind(subject_test, y_test,X_test)

## Binding train data
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
all_train <- cbind(subject_train, y_train,X_train)

## Binding both sets together
all_data <- rbind(all_test, all_train)


## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement. 

## Read the features table and keep only the measurements related to mean and std
features <- read.table("UCI HAR Dataset/features.txt")    
features_mean_std <- dplyr::filter(features, grepl('[Mm]ean|std', V2))

## Offset the value of the column by 2 (to account for the 2 columns for Subject and Activity)
## and select only those columns
features_mean_std$V3 = features_mean_std$V1+2
data_mean_std <- all_data[,c(1,2,features_mean_std$V3)]


## Step 3: Uses descriptive activity names to name the activities in the data set

## Change the activity numbers by the corresponding label
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
data_mean_std[,2]<- activities[data_mean_std[,2],2]


## Step 4: Appropriately labels the data set with descriptive variable names. 

## Takes "Subject and "Activity" as names for the data originaly in "subject_test" and "y_test", 
## and the name of the feature for the rest.
colnames(data_mean_std) = c("Subject", "Activity", as.character(features_mean_std[,2]))


## Step 5: From the data set in step 4, creates a second, independent tidy data set with the 
## average of each variable for each activity and each subject.

## Melts data into the long form. Uses "Measurement" as name for the variable column, and keeps 
## the default name "value" for the value column.
data_with_activity <- melt(data_mean_std, id=c("Subject", "Activity"), 
                           measure.vars=c(colnames(data_mean_std[3:88])), variable.name="Measurement")

## Groups the data by Subject, Activity and Measurement
data_with_activity_grouped <- dplyr::group_by(data_with_activity,Subject,Activity,Measurement)

## Summarises the data by the mean of the values.
tidy_data <- dplyr::summarise(data_with_activity_grouped,mean=mean(value))

## Writes the final tidy data set to a table without rownames.
write.table(tidy_data,"getdata-013-CP-tidy_data.txt", row.name=FALSE)

