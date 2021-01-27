# Data Cleaning Project
This repository is the final project for the [Coursera *Getting and Cleaning Data* course](https://www.coursera.org/learn/data-cleaning). This README is supposed to “explain the analysis files \[and be\] clear and understandable”. I'm not sure how that differs from the codebook. In any case…<p>

## The data
The dataset is a [zip file](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) downloaded from the [University of California at Irvine](https://www.uci.edu). It extracts to a directory named `UCI HAR Dataset`. Below is its directory structure:
```
-rw-r--r-- 1 daniel daniel     80 Oct 10  2012 activity_labels.txt
-rw-r--r-- 1 daniel daniel   2809 Oct 15  2012 features_info.txt
-rw-r--r-- 1 daniel daniel  15785 Oct 11  2012 features.txt
-rw-r--r-- 1 daniel daniel 635204 Jan 25 10:37 README.html
-rw-r--r-- 1 daniel daniel   4582 Jan 25 10:37 README.md
-rw-r--r-- 1 daniel daniel   4453 Dec 10  2012 README.txt
drwx------ 3 daniel daniel   4096 Nov 29  2012 test
drwx------ 3 daniel daniel   4096 Nov 29  2012 train
```
1. The file `activity__labels.txt`, as the name implies, is the file of labels of the activities, i.e.:
```
$ cat activity_labels.txt
1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING
```
<ol start="2">
  <li>The file `features_info.txt` describes the entries in `features.txt` and how they were derived. Large parts of it are highly technical and mainly of academic interest.</li>
  <li>The file `features.txt`, as the name implies, contains the features of interest. The entries therein will, after some manipulations through `mutate()`, become the column names for the required `tidy_summary.txt`.</li>
</ol>
Below are the first 15 entries:

```
   V1                V2
1   1 tBodyAcc-mean()-X
2   2 tBodyAcc-mean()-Y
3   3 tBodyAcc-mean()-Z
4   4  tBodyAcc-std()-X
5   5  tBodyAcc-std()-Y
6   6  tBodyAcc-std()-Z
7   7  tBodyAcc-mad()-X
8   8  tBodyAcc-mad()-Y
9   9  tBodyAcc-mad()-Z
10 10  tBodyAcc-max()-X
11 11  tBodyAcc-max()-Y
12 12  tBodyAcc-max()-Z
13 13  tBodyAcc-min()-X
14 14  tBodyAcc-min()-Y
15 15  tBodyAcc-min()-Z
```
+ Further down are features that begin with `f`. As explained in`features_info`, the `t` and `f` prefixes refer to time and frequency domains, respectively.
+ Note that the first three contain the string “mean”, the next three “std”. Those signify that those features will produce the means and standard deviations, respectively, of the measurements.
+ Finally, the dataset consists of text files, which means that we have to use `tibble::as_tibble(read.table())` and provide column names. `tibble::as_tibble(read.table())` will turn the file into a data frame.<p>
# Massaging the data files

## Transforming the`features` file
Examining the `features` file reveals some work to be done:<p>

1. determining the `features` that represent means and standard deviations.
1. replacing the prefixes `t` and `f` with more descriptive `Time` and `Frequency`, respectively
1. replacing “angle” with “Angle” for consistency in capitalization
1. replacing double occurrences of “Body” — i.e., “BodyBody” — with “Body”
1. separating “Acc”, “Gyro”, “Jerk”, and “Mag” from the rest of the feature with dots — i.e., “.Acc”, “.Gyro”, “.Jerk”, and “.Mag”
1. replacing double occurrences of the dot (“..”) with a single dot
1. removing a dot at the end of the feature.

The long function chain starting at line 58 in `run_analysis.R` accomplishes this.

## Loading the activities
This is a simple matter of invoking `tibble::as_tibble(read.table())` on `activity_labels.txt`, and assigning column names.<p>
## Loading the training dataset
This consists of four steps:
1. setting `train` column names to the rows of `features` dataset
1. adding subject data and activity data to the training dataset
1. renaming the V1 columns to `Subject.Id` in `subject_training.txt` and to `Activity.Id` in y_training.txt
1. combining the two txt files above with `cbind()`<p>

## Loading the test dataset
Activity here is the same as in the previous section, applied to the test dataset.<p>

## Merge the training and test datasets
This consists of the following steps:
1. adding descriptive activity names from activities
1. selecting the mean and std deviation features only.
1. grouping by subject and activity.
1. merging the training and test datasets using rbind() into a `merged` dataset

## Creating the tidy summary
The `summary()` function, applied to the `merged` training and test databases from the previous section, will create the required `tidy_summary` file.

## Writing the tidy summary to a file
A simple `write.table()` applied to `tidy_summary` wraps up the project.

# How to run the script.
1. At line 13 of `run_analysis.R` is a line to set the current directory. You may edit it to your own preference.
2. Run the script.

