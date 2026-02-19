# run_analysis.R
# Getting and Cleaning Data Course Project

# Packages
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
})

# Create a data folder
if (!dir.exists("data")) dir.create("data")

# Download + unzip dataset if needed
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip_path <- file.path("data", "UCI_HAR_Dataset.zip")
unzip_dir <- "data"

if (!file.exists(zip_path)) {
  download.file(url, zip_path, mode = "wb")
}

# The unzipped folder name will be: "UCI HAR Dataset"
dataset_dir <- file.path(unzip_dir, "UCI HAR Dataset")

if (!dir.exists(dataset_dir)) {
  unzip(zip_path, exdir = unzip_dir
# Read features and activity labels
features <- read_table(file.path(dataset_dir, "features.txt"),
                       col_names = c("index", "feature"))

activity_labels <- read_table(file.path(dataset_dir, "activity_labels.txt"),
                              col_names = c("activity_id", "activity"))
                       # ---- TRAIN ----
x_train <- read_table(file.path(dataset_dir, "train", "X_train.txt"),
                      col_names = FALSE)

y_train <- read_table(file.path(dataset_dir, "train", "y_train.txt"),
                      col_names = "activity_id")

subject_train <- read_table(file.path(dataset_dir, "train", "subject_train.txt"),
                            col_names = "subject")

# ---- TEST ----
x_test <- read_table(file.path(dataset_dir, "test", "X_test.txt"),
                     col_names = FALSE)

y_test <- read_table(file.path(dataset_dir, "test", "y_test.txt"),
                     col_names = "activity_id")

subject_test <- read_table(file.path(dataset_dir, "test", "subject_test.txt"),
                           col_names = "subject")

# Apply feature names to X tables
colnames(x_train) <- features$feature
colnames(x_test)  <- features$feature

# Combine columns within train/test
train <- bind_cols(subject_train, y_train, x_train)
test  <- bind_cols(subject_test,  y_test,  x_test)

# Merge rows (train + test)
all_data <- bind_rows(train, test)      
 mean_std_cols <- grep("mean\\(\\)|std\\(\\)", names(all_data), value = TRUE)

data_mean_std <- all_data %>%
  select(subject, activity_id, all_of(mean_std_cols))
mean_std_cols <- grep("mean\\(\\)|std\\(\\)", names(all_data), value = TRUE)

data_mean_std <- all_data %>%
  select(subject, activity_id, all_of(mean_std_cols))
data_mean_std <- data_mean_std %>%
  left_join(activity_labels, by = "activity_id") %>%
  select(subject, activity, everything(), -activity_id)
clean_names <- names(data_mean_std)

clean_names <- clean_names %>%
  str_replace_all("^t", "time") %>%
  str_replace_all("^f", "frequency") %>%
  str_replace_all("Acc", "Accelerometer") %>%
  str_replace_all("Gyro", "Gyroscope") %>%
  str_replace_all("Mag", "Magnitude") %>%
  str_replace_all("BodyBody", "Body") %>%
  str_replace_all("\\(\\)", "") %>%
  str_replace_all("-", "_")

names(data_mean_std) <- clean_names
tidy_data <- data_mean_std %>%
  group_by(subject, activity) %>%
  summarise(across(where(is.numeric), mean), .groups = "drop")
  output_path <- "tidy_data.txt"
write.table(tidy_data, file = output_path, row.name = FALSE)