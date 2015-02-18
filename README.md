# coursera_cleaning_data
## Resources for Coursera's *Cleaning Data* project
The heart of this github repository is the **run_analysis.R** script which reads "raw" data from the "Samsung wearable"" database from the working directory and:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

This *github* repository contains:

- this file: **README.md**
- the file **codebook.md** that indicates all the variables and summaries calculated, along with units, and any other relevant information
- a single R script file: **run_analysis.R**
- the needed **Samsung data**, all present in the same directory as run_analysis.R

The **Samsung data** needed to run **run_analysis.R** is made of the following files:

- **features.txt**: List of all features.
- **activity_labels.txt**: Links the class labels with their activity name.
- **X_train.txt**: Training set.
- **y_train.txt**: Training labels.
- **X_test.txt**: Test set.
- **y_test.txt**: Test labels.
- **subject_train.txt**: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
