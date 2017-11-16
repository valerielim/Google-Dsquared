# Date: 16 Nov 2017
# Title: Reformatting
# Description: Reformat telephone directory data prior to BQ port

setwd("C:/Users/valeriehy.lim/Documents/TrainingTracker")

file <- read.csv("RANKS.csv")
names(file) <- c("Name", "Position_Title")

# Delete strings between brackets 
Position_Title <- gsub("\\s*\\([^\\)]+\\)","",as.character(file$Position_Title))
file <- as.data.frame(cbind(Name = file[,1], Position_Title))

# Split by multiple delimiters
library(dplyr)
file <- file %>% 
    separate(Position_Title, into = c("a", "b"), sep = '[-]') %>%
    separate(a, into = c("c", "d"), sep = '[â€“]') %>%
    separate(c, into = c("e", "f"), sep = '[,]')

# Merge columns back together    
file <- with(file, data.frame(Name=Name, Position_Title=e, Rank=ifelse(
                                    is.na(ifelse(is.na(b), d, b)),
                                    f, 
                                    (ifelse(is.na(b), d, b)))))

# trim leading and trailing whitespace
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

file$Name <- trim(file$Name)
file$Position_Title <- trim(file$Position_Title)
file$Rank <- trim(file$Rank)

# Save as csv
write.csv(file, "RANKS_clean.csv")
