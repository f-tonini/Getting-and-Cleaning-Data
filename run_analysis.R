#You should create one R script called run_analysis.R that does the following. 
#1) Merges the training and the test sets to create one data set.
#2) Extracts only the measurements on the mean and standard deviation for each measurement. 
#3) Uses descriptive activity names to name the activities in the data set
#4) Appropriately labels the data set with descriptive variable names. 
#5) From the data set in step 4, creates a second, independent tidy data set with the average 
#   of each variable for each activity and each subject.

#let's unzip the dataset folder inside the working directory
unzip("getdata-projectfiles-UCI HAR Dataset.zip")

##let's start by reading in the separate files we need to combine within the TRAIN and TEST folders:
subject.train <- scan("./UCI HAR Dataset/Train/subject_train.txt")
#length(subject.train)
#7352 items
system.time(X.train <- scan("./UCI HAR Dataset/Train/X_train.txt"))
#  user  system elapsed 
#8.555   0.068   8.648
y.train <- scan("./UCI HAR Dataset/Train/y_train.txt")
#7352 items

#SAME THING FOR THE TEST DATA SET:
subject.test <- scan("./UCI HAR Dataset/Test/subject_test.txt")
X.test <- scan("./UCI HAR Dataset/Test/X_test.txt")
y.test <- scan("./UCI HAR Dataset/Test/y_test.txt")

#subjects and y files have the same length, thus can be combined next to each other
#to have a list of subject IDs (1-30) along with their activity code (1-6).
#Let's also initialize an empty column next to both variables where to store our measurements within with X file
mat.train <- cbind(subject.train, y.train, rep(NA, length(y.train))) 
mat.test <- cbind(subject.test, y.test, rep(NA, length(y.test)))

#because the X files stores all repeated measurements after each other, we need to replicate
#our matrix of subject IDs and activity codes by the number of feature variables measured (listed in 'features.txt')
#We have 561 different feature variables, thus we replicate the matrix 561 times.
mat.train.long <- mat.train[rep(seq_len(nrow(mat.train)), each=561), ]
mat.test.long <- mat.test[rep(seq_len(nrow(mat.test)), each=561), ]
#nrow(mat.train.long)
#4124472 now it matches X.train!

#Now we are ready to replace our empty column with actual values from the X file
mat.train.long[,3] <- X.train
mat.test.long[,3] <- X.test

##1. Merge the training and the test sets to create one data set:
#let's combine (stack) them:
mat.long <- rbind(mat.train.long, mat.test.long)
nrow(mat.long)
#5777739 final length of our combined dataset

#2) Extracts only the measurements on the mean and standard deviation for each measurement:

#In order to extract only the measurements on the mean and standard deviation we need to follow two steps:
#(a) add a column with the feature names so we can subset on it
#(b) grab only the feature names that contain the words "mean" or "std" in it

##read feature names file:
f.df <- read.table("./UCI HAR Dataset/features.txt", sep=" ", stringsAsFactors = F)
f.names <- f.df[ ,2] #let's store the feature names in a vector

#our 561 feature names need to be replicated in order to match the number of rows in our dataset matrix
feature <- rep(f.names, nrow(mat.long)/561)

#let's transform our dataset matrix into a dataframe 
df.long <- as.data.frame(mat.long)
#add feature names to it
df.long$feature <- f.names

#Let's use the dplyr package to make efficient manipulations on our dataset
library(dplyr)

df.long <- df.long %>%
  filter(feature %in% grep(paste(c("mean", "std"), collapse="|"), df.long$feature, value=T))

head(df.long) #check if it subset the correct variables

##3. Uses descriptive activity names to name the activities in the data set:
## let's rename the activity categories with the appropriate labels
l.df <- read.table("./UCI HAR Dataset/activity_labels.txt", sep=" ", stringsAsFactors = F) 

#we will use sapply() to associate each activity code with its label
df.long <- df.long %>%
  rename(activity=y.train) %>%
  mutate(activity=sapply(activity, FUN=function(x) l.df[x,2]))

##4. Appropriately labels the data set with descriptive variable names:
df.long <- df.long %>%
  rename(subject_ID=subject.train, value=V3)

names(df.long) #now our dataset has more informative names

##5. From the data set in step 4, creates a second, independent tidy data set with the average 
## of each variable for each activity and each subject:

#in order to accomplish this task we will first group our observations by activity, subject, and variable name
#then take the mean of each feature by activity and subject ID:
df.long_summary <- df.long %>%
                group_by(activity, subject_ID, feature) %>%
                summarize(value_avg = mean(value, na.rm=TRUE))

##save new tidy dataset to external txt file:
write.table(df.long_summary, file="summary.txt", row.names=FALSE)


