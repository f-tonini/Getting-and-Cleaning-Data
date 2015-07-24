# Getting-and-Cleaning-Data
This repo contains the Rscript used for the final project of the "Getting and Cleaning Data" course, Data Science Signature Track (Coursera). The zipped folder contains the datasets necessary for the analysis.

## Description of the script:

First of all we use the `unzip()` function to unzip our large data folder into our working directory. It is preferrable to do this instead of keeping the unzipped data on github, given the large size of the files.

The script is divided into 5 main tasks:

1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement. 
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive variable names. 
5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

##1. Merge the training and the test sets to create one data set.

First we need to find and read the files associated to our data, including the subject IDs, activity codes, and variable measurements. The script reads these files separately within the **TRAIN** and **TEST** folders. Because the files have only lists of values without any labels or structured form, we can use the `scan()` function. After reading the necessary files, we notice that both the _subject.txt_ and _y.txt_ files have the same length. Based on that, we combine the subject IDs with activity codes next to each other. Moreover, we add an extra column with no data in it to be replaced later on with actual measurements (_this last step is not mandatory but helps speeding up with efficient memory allocation_). After repeating the same steps for both the TRAIN and TEST folders, we accomplish *task 1* by merging the training and test data sets into a single one.

##2. Extract only the measurements on the mean and standard deviation for each measurement.

In order to extract only the measurements on the mean and standard deviation we need to follow two steps:
+ add a column with the feature names so we can subset on it
+ grab only the feature names that contain the words _mean_ or _std_ in it

First we need to read the _feature.txt_ file to store all 561 feature names. After replicating the vector of feature names to match the size of our main data set, we transform our dataset matrix into a `data.frame` object and create a feature names variable in it. At this point, we start using the `dplyr` package to make efficient manipulations on our data frame object. We use the `grep()` function to extract the words _mean_ and _std_ from all the feature names in the dataset, and subset (filter) our dataset based on that. 

##3. Use descriptive activity names to name the activities in the data set.

In order to replace all the activity codes with the correspondent activity labels, we first read in the *activity\_labels.txt* file. Then we use the `rename()` function of the `dplyr` package to rename our _y_ activity code variable to something more descriptive and use `mutate()` to override it with the corresponding activity label. This task is accomplished by using the `sapply()` function.

##4.Appropriately label the data set with descriptive variable names. 

We rename all remaining variables in the dataset with more descriptive names using the `rename()` function again.

##5.From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

To accomplish this task, we will first group our observations by activity, subject, and variable name using the `group_by()` function of the `dplyr` package. Then, we will take the mean of each feature using the `summarize()` function by using the aforementioned grouping. The final dataset now contains the mean of each feature by activity type and subject ID.

**The final step in the script writes our final summarized data set in a .txt file.**


