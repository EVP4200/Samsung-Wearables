# Create data directory if it doesn't exist
if(!dir.exists("data")) {
  dir.create("data")
}

# File URL
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download if not already present
zipFile <- "data/UCI_HAR_Dataset.zip"

if(!file.exists(zipFile)) {
  download.file(fileUrl, zipFile)
}

# Unzip
unzip(zipFile, exdir = "data")
