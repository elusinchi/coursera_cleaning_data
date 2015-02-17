library("dplyr")
library("plyr")
library("gdata")

#setwd("d:/_Coursera/home/cleaning.data.3/project")

if (!file.exists("./data")) {dir.create("./data")}

use_smaller_data_set <- FALSE

test_rows <- 29 # 2947
train_rows <- 73 # 7352

if (!use_smaller_data_set) {

  set_test <- read.csv("./test/X_test.txt", header=FALSE,sep ="")
  set_train <- read.csv("./train/X_train.txt", header=FALSE,sep ="")
  
  test_rows <- nrow(set_test)
  train_rows <- nrow(set_train)
  
}


data_names <- read.csv("./features.txt", header=FALSE,sep ="")

set_test <- read.csv("./test/X_test.txt", header=FALSE,sep ="", nrows=test_rows, col.names=data_names[,2], check.names=TRUE, colClasses="numeric")
set_train <- read.csv("./train/X_train.txt", header=FALSE,sep ="", nrows=train_rows, col.names=data_names[,2], check.names=TRUE, colClasses="numeric")

activity_label <- read.csv("./activity_labels.txt", header=FALSE,sep ="", stringsAsFactors=FALSE)
labels_test <- read.csv("./test/Y_test.txt", header=FALSE,sep ="", nrows=test_rows, col.names=c("activity_name"))
labels_train <- read.csv("./train/Y_train.txt", header=FALSE,sep ="", nrows=train_rows, col.names=c("activity_name"))

labels_test$activity_name <- mapvalues(labels_test[,1], activity_label[,1], activity_label[,2])
labels_train$activity_name <- mapvalues(labels_train[,1], activity_label[,1], activity_label[,2])

subject_test <- read.csv("./test/subject_test.txt", header=FALSE,sep ="", nrows=test_rows, col.names=c("subject"))
subject_train <- read.csv("./train/subject_train.txt", header=FALSE,sep ="", nrows=train_rows, col.names=c("subject"))


start_train <- 1+test_rows
end_train <- test_rows+train_rows
df_set_test <- join(data.frame(id=1:test_rows, subject_test), join(data.frame(id=1:test_rows, labels_test), data.frame(id=1:test_rows, set_test)))
df_set_train <- join(data.frame(id=start_train:end_train, subject_train), join(data.frame(id=start_train:end_train, labels_train), data.frame(id=start_train:end_train, set_train)))


df_bind <- rbind(df_set_test,df_set_train)

kept_cols <-  c("id","activity_name","subject",c(matchcols(df_bind, "mean"),matchcols(df_bind, "std")))
df_small <- df_bind[,kept_cols]                                            

write.csv(df_small, "./data/run_analysis.csv")

by_activity <- group_by(df_small, activity_name)
by_activity_and_subject <- group_by(by_activity, subject, add = TRUE)
d_summ <- summarise_each(by_activity_and_subject, funs(mean), -c(1,2))

write.table(d_summ, "./data/summary.txt", row.name=FALSE)

verify_my_table <- read.table("./data/summary.txt", header=TRUE)