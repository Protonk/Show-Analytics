library(stringr)

### Scan in logs formatted as:
##
# 94.254.64.98  25/Sep/2012:10:46:05 GET /c281268.r68.cf1.rackcdn.com/The.Impromptu.E10.mp3 HTTP/1.1 206 61576365 - "CTMDEngU"
# with IP Address, timestamp, request,
# response, size and client

# Characteristics of the cleaned data go here. This speeds up import somewhat

logs.len <- as.numeric(gsub("^ +([0-9]*) .*", "\\1", system("wc -l ~/Desktop/cleaned.txt", intern = TRUE), perl = TRUE))
logs.classes <-  c(rep("character", 5), rep("numeric", 2), rep("character", 2))
logs.names <- c("Address", "Time", "Type", "Episode", "Response", "Code", "Size", "Empty", "Client")

# import file and save a copy (in case you want to munge around with the original
logs.bak <- logs.df <- read.table("~/Desktop/cleaned.txt", sep = " ", as.is = TRUE, header = FALSE, nrows = logs.len,
					 												 comment.char = "", colClasses = logs.classes, col.names = logs.names)

rm(logs.len, logs.classes, logs.names)					 												 

# Convert to Time and Date classes
logs.df[, "Time"] <- as.POSIXct(logs.df[, "Time"], format = "%d/%b/%Y:%H:%M:%S")
logs.df[, "Date"] <- as.Date(trunc(logs.df[, "Time"], "day"))


## Drop uninteresting rows

logs.df <- logs.df[!grepl("favicon|robots", logs.df[, "Episode"]), ]
logs.df <- logs.df[!logs.df[, "Code"] %in% c(304, 404), ]
logs.df <- logs.df[logs.df[, "Size"] > 500, ]
rownames(logs.df) <- as.character(1:nrow(logs.df))

## Reorganize and factor
logs.df[, "Episode"] <- gsub("%20", "\\.", logs.df[, "Episode"])
# Only the episode name and file type. Won't break when we pass 100
logs.df[, "Episode"] <- str_sub(basename(logs.df[, "Episode"]), start = 15)
# Just the episode code
logs.df[, "Episode"] <- factor(sub("([^.]*)\\..*", "\\1", logs.df[, "Episode"], perl = TRUE))

## compute max size from requests.
# useful to judge partial requests

ep.size <- by(logs.df[, "Size"], logs.df[, "Episode"], max)
size.df <- data.frame(Episode = attr(ep.size, "dimnames")[[1]], Max.size = as.numeric(ep.size))

logs.df <- merge(logs.df, size.df, by = "Episode")
rm(ep.size, size.df)

# compute size as fragment of overall

logs.df[, "Fraction"] <- logs.df[, "Size"]/logs.df[, "Max.size"]


## Reorganize columns

logs.df <- logs.df[, c("Address", "Time", "Date", "Episode", "Size", "Fraction", "Max.size", "Code", "Client")]


