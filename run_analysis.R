# ---
#      title: "run_analysis"
# author: "Daniel Escasa"
# date: "January 25, 2021"
# output: 
#      html_document:
#      number_sections: true
# ---
     
#      ```{r setup, include=TRUE}
# knitr::opts_chunk$set(echo = TRUE)
# ```
# Introduction {-}
#The run_analysis.R script downloads the Human Activity Recognition dataset, tidies it up, and performs various required data manipulations and summaries.<p>
     
     # Boring admin stuff
     ## Install dplyr if necessary
 #    ```{r, load dplyr}
if (!require("dplyr")) {
     message("Installing dplyr")
     install.packages("dplyr")
}
#```
## Make sure I'm in the right directory
#```{r}
setwd("/home/daniel/Documents/Coursera/DataCleaning.JH/")
utils::sessionInfo()[2]
#```
## Download Human Activity Report dataset if necessary
#```{r, dl HAR dataset}
if (!file.exists("./UCI_HAR_Dataset.zip")) {
     message("Downloading dataset")
     download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                   destfile = "./UCI_HAR_Dataset.zip",  
                   method = "internal", 
                   mode = "wb")
}
#```
## Extract Human Activity Report dataset if necessary
#I've decided to extract it to my DataCleaning.JH directory instead of a DATA directory.
#```{r, extract HAR dataset}
if (!file.exists("./UCI HAR Dataset")) {
message("Extracting dataset")
unzip("./UCI_HAR_Dataset.zip", 
overwrite = FALSE)
}
#```
# Load the features
#First line (`tibble:as_tibbl()`) reads in `features.txt` and coerces it as a data frame.<p>
## Search for the mean and standard deviations
# The first two calls to `mutate()` do this.<p>
## Create syntactically valid names in a new features column named `Features`
## Fix variable names from the features data frame
# Succeeding `mutate()` function invocations do this. One aim is enhanced readability, e.g., `Time.BodyGyro-arCoeff()-X,2` instead of `tBodyGyro-arCoeff()-X,2`. More precisely:<p>
# 1. Features starting with a lowercase t are converted to `Time.`, e.g., `tBodyGyro-arCoeff()-X,2` becomes Time.BodyGyro-arCoeff()-X,2.<p>
# 1. Occurrences of `.t` anywhere in a feature$Features string are transformed to `.Time`.<p>
# 1. Same with features that begin with f, converted to `Frequency.`, e.g., `fBodyAcc-bandsEnergy()-1,24` becomes `Frequency.BodyAcc-bandsEnergy()-1,24`.<p>
# 1. Occurrences of `.f` anywhere in a feature$Features string are transformed to `.Frequency`.<p>
# 1. Features that begin with `angle.` start with `Angle.` after the `mutate()`.<p>
# 1. Double occurrences of `Body` — i.e., `BodyBody` become `Body`<p>
# 1. Occurrences of `Acc`, `Gyro`, `Jerk`, and `Mag` are transformed to `.Acc`, `.Gyro`, `.Jerk`, and `.Mag`, respectively.<p>
# 1. Occurrences of a multiple dots `..` are transformed to a single dot `.`. It may take two calls to `gsub()` to do this.<p>
# 1. Features with a trailing period `.` lose that period.<p>
# 1. Lastly, characters that cannot be part of an R identifier are removed. These include the open and close parentheses and square brackets.<p>
# Strangely, this may not be necessary since R accepted `train[, "tBodyAcc-mean()-X"]`. Nevertheless… Maybe for backward compatibility?<p>
# 
# ```{r load features}
features <- tibble::as_tibble(read.table("./UCI HAR Dataset/features.txt", 
col.names = c("Id", "Feature")))

features <- features %>% 
mutate(Is.Mean          = grepl("mean\\(\\)", features$Feature)) %>%
mutate(Is.Std           = grepl("std\\(\\)", features$Feature)) %>%
mutate(Feature.Variable = make.names(features$Feature, unique = TRUE)) %>%
mutate(Feature.Variable = gsub("^t", "Time.", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("\\.t", ".Time.", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("^f", "Frequency.", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("\\.f", ".Frequency.", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("^angle\\.", "Angle.", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("BodyBody", "Body", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("Acc", ".Acc", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("Gyro", ".Gyro", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("Jerk", ".Jerk", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("Mag", ".Mag", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("\\.\\.", ".", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("\\.\\.", ".", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("\\.$", "", Feature.Variable)) %>%
mutate(Feature.Variable = gsub("(^|[\\.])([[:alpha:]])", "\\1\\U\\2", 
Feature.Variable, perl=TRUE))
#```
## mutate() rocks! {-}

# Load activities
# As in the previous chunk, `tibble:as_tibbl()` reads in `labels.txt` and coerces it as a data frame. The data frame gets assigned column names "Id" and "Activity"
# ```{r load activities}
activities <- tibble::as_tibble(read.table("./UCI HAR Dataset/activity_labels.txt", 
col.names = c("Id", "Activity")))
# ```
# Load the training dataset
# Again, coerce `X_train.txt` as a data frame.<p>
## Assign `features` dataset to `train` column names 
## Add subject data and activity data to the training dataset
# ```{r load training dataset}
train <- tibble::as_tibble(read.table("./UCI HAR Dataset/train/X_train.txt"))
colnames(train) <- features$Feature.Variable
train <- cbind(
rename(tibble::as_tibble(read.table("./UCI HAR Dataset/train/subject_train.txt")), 
Subject.Id = V1),
rename(tibble::as_tibble(read.table("./UCI HAR Dataset/train/y_train.txt")),
Activity.Id = V1),
Dataset.Partition = c("Training"),
train)
# ```
# Load the test dataset
## Assign `features` dataset to `test` column names 
## Add subject data, and activity data to the test dataset<p>
# Mostly the same as the previous chunk, applied to the `test` dataset
# ```{r load test dataset}
test <- tibble::as_tibble(read.table("./UCI HAR Dataset/test/X_test.txt"))
colnames(test) <- features$Feature.Variable
test <- cbind(
rename(tibble::as_tibble(read.table("./UCI HAR Dataset/test/subject_test.txt")), 
Subject.Id = V1),
rename(tibble::as_tibble(read.table("./UCI HAR Dataset/test/y_test.txt")),
Activity.Id = V1),
Dataset.Partition = c("Test"),
test)
# ```
# Merge the training and test datasets.
## Add descriptive activity names from activities.
## Select the mean and std deviation features only.
##  Group by subject and activity.
# ```{r merge training and test}
merged <- rbind(train, test) %>%
left_join(activities, by = c("Activity.Id" = "Id")) %>%
select(Subject.Id, Activity,   
one_of(
filter(features, Is.Mean == TRUE | Is.Std == TRUE) %>%
select(Feature.Variable) %>% .[["Feature.Variable"]])) %>%
group_by(Subject.Id, Activity)
# ```
# Create a tidy summary of feature means grouped by subject and activity.
# ```{r create tidy summary}
tidy_summary <- summarise_each(merged, funs(mean))
# ```
# Write tidy summary to file.
# ```{r write tidy summary}
write.table(tidy_summary, "tidy_summary.txt", row.names = FALSE)
# ```
