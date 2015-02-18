#########################################################################################
#
# This script will read "raw" data from the Samsung wearable database in the working directory and
# 1- Merges the training and the test sets to create one data set.
# 2- Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3- Uses descriptive activity names to name the activities in the data set
# 4- Appropriately labels the data set with descriptive variable names. 
# 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#
#########################################################################################
#
#
# For convenience, have a way to run the analysis on fewer sample - easier to develop and debug considering how slow it can be to treat the whole data set
use_smaller_data_set <- FALSE
#use_smaller_data_set <- TRUE

# -----------------------------------------------------------------
# Filenames information
#
# Note that those are all stored in a flat directory structure, unlike the nested directories (./test, ./train...) inside the Samsung ZIP archive.
# While I would prefer retaining the original data structure and use sub-directory, the expected behavior "seems" to be that
# of a flat structure. Proper information on the expected data and its location are given in the codebook.
filename_set_test          <- "./X_test.txt"
filename_activity_test     <- "./y_test.txt"
filename_subjectid_test    <- "./subject_test.txt"
filename_set_train         <- "./X_train.txt"
filename_activity_train    <- "./y_train.txt"
filename_subjectid_train   <- "./subject_train.txt"
filename_datafield_names   <- "./features.txt"
filename_activity_names    <- "./activity_labels.txt"

# define the names of the output files
filename_output_tidyset             <- "./output_tidyset.csv"
filename_output_tidyset_names       <- "./output_tidyset_names.csv"
filename_output_tidyset_summary     <- "./output_tidysummary.txt"


#
#
##########################################################################################
#
# Script proper. After those definitions, let's start doing things!
#
#########################################################################################
#
#

# -----------------------------------------------------------------
# Install the missing packages if necessary and load the library
# This makes the script more "fire and forget" in the sense that the user
# doesn't have to mess with loading missing packages
#
list.of.packages <- c("plyr", "dplyr", "gdata")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library("plyr")
library("dplyr")
library("gdata")

# -----------------------------------------------------------------
# Let's read all the "raw" data
#
# Let's set the working directory to where the run_analysis.R script is
# This makes the script more "fire and forget" in the sense that the user
# doesn't have to mess with setting the working directory "just right"
old_wd <- getwd()
#
#setwd(dirname(sys.frame(1)$ofile))
# NOTE: WHILE THIS IS A COOL TRICK, I'm removing it to be compliant 
# with the requirement "The code should have a file run_analysis.R in the main directory 
# that can be run ***as long as the Samsung data is in your working directory*** "

# -----------------------------------------------------------------
# Define the number of rows in the test and train sets. 
# This is needed because of the "use_smaller_data_set" option we give the 
# user when testing or debugging
test_rows  <- 29 # smaller than the full test  set (2947)
train_rows <- 73 # smaller than the full train set (7352)
if (!use_smaller_data_set) {

  # we need to find the number of rows in test and train sets. Because that's the only info we are interested in, we
  # don't really care about other parameters
  set_test  <- read.csv(filename_set_test, header=FALSE,sep ="")
  set_train <- read.csv(filename_set_train, header=FALSE,sep ="")
  
  test_rows  <- nrow(set_test)
  train_rows <- nrow(set_train)
}

# The "raw" data are csv files without header. 
# For measurement data, it is useful to force the datatype to numeric to properly ready the exponential notation values
# Note: We use a slightly  unconventional "aligned" format in the code below to better show similarities and differences in the options for the read.csv of all the data
data_names         <- read.csv(filename_datafield_names, header=FALSE,sep ="")
activity_label     <- read.csv(filename_activity_names , header=FALSE,sep ="", stringsAsFactors=FALSE)

# Clean up the data names a bit by 
# We store the cleaned up names in a new column so that it's easy to see the before and after by
# just viewing data_names
data_names[,3] <- data_names[,2]
#
# Replace abreviations with human readable names
data_names[,3] <- gsub( "Acc" , " Acceleration " , data_names[,3])
data_names[,3] <- gsub( "Freq" , " Frequency " , data_names[,3])
data_names[,3] <- gsub( "Gyro" , " Gyroscope " , data_names[,3])
data_names[,3] <- gsub( "Jerk" , " Jerk Signal " , data_names[,3])
data_names[,3] <- gsub( "sma", " interquartile range ", data_names[,3])
data_names[,3] <- gsub( "iqr", " signal magnitude area ", data_names[,3])
data_names[,3] <- gsub( "mad", " median absolute deviation ", data_names[,3])
data_names[,3] <- gsub( "Mag", " Magnitude ", data_names[,3])
data_names[,3] <- gsub( "arCoeff", " autorregresion coefficients ", data_names[,3])
data_names[,3] <- gsub( "maxInds", " index of largest magnitude frequency component ", data_names[,3])
data_names[,3] <- gsub( "std", " standard deviation ", data_names[,3])

#
data_names[,3] <- gsub( "angle", "ANGLE between ", data_names[,3])
data_names[,3] <- gsub( "^t" , "TIME DOMAIN MEASURE of " , data_names[,3])
data_names[,3] <- gsub( "^f" , "FAST FOURIER TRANSFORM of " , data_names[,3])

# fix a few oddity
data_names[,3] <- gsub( "[gG]ravity", " Gravity ", data_names[,3])
data_names[,3] <- gsub( "BodyBody" , " Body" , data_names[,3])



# - replace punctuations:     "[(),-]" -> " " 
# - remove redundant spaces:  "[ ]+"   -> " "
# - remove trailing spaces:   "[ ]+$"  -> ""
data_names[,3] <- gsub("[ ]+"," ", gsub("[ ]+$", "", gsub( "[(),-]" , " " , data_names[,3])))


#
set_test           <- read.csv(filename_set_test       , header=FALSE,sep ="", nrows=test_rows,  col.names=data_names[,3], check.names=TRUE, colClasses="numeric")
set_train          <- read.csv(filename_set_train      , header=FALSE,sep ="", nrows=train_rows, col.names=data_names[,3], check.names=TRUE, colClasses="numeric")

# Note that we use the (cleaned up) data field names to appropriately labels the data sets with relatively descriptive variable names
#
labels_test        <- read.csv(filename_activity_test  , header=FALSE,sep ="", nrows=test_rows,  col.names=c("activity_name"))
labels_train       <- read.csv(filename_activity_train , header=FALSE,sep ="", nrows=train_rows, col.names=c("activity_name"))

subject_test       <- read.csv(filename_subjectid_test , header=FALSE,sep ="", nrows=test_rows,  col.names=c("subject"))
subject_train      <- read.csv(filename_subjectid_train, header=FALSE,sep ="", nrows=train_rows, col.names=c("subject"))


# -----------------------------------------------------------------
# Let's start tidying up the data
#
# Having Read the activity names as strings instead of as a factor makes it easier to replace the numeric values of activity by a human-readable descriptive text
# This is done to appropriately label the data set with descriptive variable names. 
labels_test$activity_name  <- mapvalues(labels_test[,1], activity_label[,1], activity_label[,2])
labels_train$activity_name <- mapvalues(labels_train[,1], activity_label[,1], activity_label[,2])

# join data belonging to the same measures. We identify each measure with a unique index in a new column named "id"
# we choose test data to have indexes 1 to test_rows (i.e. 2947 in the data set)
# and train data to have indexes test_rows+1 (2948) to test_row+train_rows (i.e. 2947+7352)
indexes_test  <- 1:test_rows
indexes_train <- (1+test_rows):(test_rows+train_rows)
df_set_test   <- join(data.frame(id=indexes_test,subject_test), join(data.frame(id=indexes_test, labels_test), data.frame(id=indexes_test, set_test)))
df_set_train  <- join(data.frame(id=indexes_train, subject_train), join(data.frame(id=indexes_train, labels_train), data.frame(id=indexes_train, set_train)))

# Merge the training and the test sets to create one data set
df_bind <- rbind(df_set_test,df_set_train)

# Extract only the measurements on the mean and standard deviation for each measurement. 
# We use gdata::matchcols to easily find column with mean and standard in their name.
# We sort the mean and std columns by name to better group related std and mean data.
# A side effect is that the order of the column will be different from the order in the "raw" data.
kept_cols <-  c("id","activity_name","subject",sort(c(matchcols(df_bind, "mean"),matchcols(df_bind, "standard"))))
df_small <- df_bind[,kept_cols]                                            

# -----------------------------------------------------------------
# OUTPUT!
#

# We write out this "smaller" data set. This isn't required but it seems useful to preserve that data
write.csv(df_small, filename_output_tidyset)

# We also write out "just the names" of that tidy data in case we want to manually clean it up, include it in the codebook, etc.
write.csv(names(df_small), filename_output_tidyset_names)



# -----------------------------------------------------------------
# Let's create the "second" tidy data set
#

# From the data set, we create a second, independent tidy data set with the average of each variable for each activity and each subject.
# first group by activity name
by_activity <- group_by(df_small, activity_name)

# then group the previously grouped data by suject. We use the parameter add=TRUE to group by both criteria.
by_activity_and_subject <- group_by(by_activity, subject, add = TRUE)

# and create the summary data. Note that we don't want to take the mean of the "id" or "subject" field ; ) so we exclude those columns
d_summ <- summarise_each(by_activity_and_subject, funs(mean), -c(1,2))



# -----------------------------------------------------------------
# OUTPUT!
#
# write as a space separated text file. This is a bit messy to read for a human but is very standard as it can be read by a simple read.table command.
write.table(d_summ, filename_output_tidyset_summary, row.name=FALSE)

# and just to make sure, re-read the table we have just written. This also gives a good idea to people reading this code on how to read the generated data 
# in their own code.
verify_my_table <- read.table(filename_output_tidyset_summary, header=TRUE)

# ------------------------------------------------------------------
# Cleaning up after ourselves
#
# We restore the working directory as it was before running this script
setwd(old_wd)

# That's it!
#
##########################################################################################