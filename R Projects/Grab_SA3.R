# Date: 12 Sep 2017
# Title: Grab_SA3.R
# Reference: https://github.com/abromberg/sentiment_analysis/blob/master/sentiment_analysis.R
# Reference 2: http://rpubs.com/chengjun/sentiment

# ---------------------------------------------------------------------------- #
# [prep dataset]

setwd("C:/Users/valeriehy.lim/Documents")

# Load data -- read the uber_comments_clean.csv file
uber <- read.csv(file.choose())
grab <- read.csv(file.choose())
options(stringsAsFactors = FALSE)

# Rename columns
names(uber) <- c("creation_time", "post_username", "post_ID", 
                 "post_comment", "message_ID", "sentiment")

names(grab) <- c("creation_time", "post_username", "post_ID", 
                 "post_comment", "message_ID", "sentiment")

# ---------------------------------------------------------------------------- #
# Clean up time format, build feature for number of words per comment

library(stringr) 
library(dplyr)
library(lubridate)

# Clean date // outputs many columns // keep only the ones you want
format_FBtime <- function(df){ 
    
    # What this function needs:
    # 1. Datetime column titled "creation_time"
    
    # What this function returns: 
    # 1. "DatetimeSF" in format (UTC -8:00) as YYYY-MM-DD HH:MM:SS 
    # 2. "DatetimeSG" in format (SGT +8:00) as YYYY-MM-DD HH:MM:SS 
    # 3. Drops unformatted column "creation_time"
    
    # 1. Date YYYY-MM-DD
    df <- mutate(df, Date = paste(year(df$creation_time), 
                                  month(df$creation_time), 
                                  day(df$creation_time), 
                                  sep="-"))
    
    # 2. Time HH:MM:SS
    df <- mutate(df, Time=substr(as.character(df$creation_time),12, 19))
    
    # 3. Original time as 'DatetimeSF'
    df <- mutate(df, DatetimeSF = paste(df$Date, df$Time))
    df$DatetimeSF <- as.POSIXct(strptime(df$DatetimeSF, 
                                         "%Y-%m-%d %H:%M:%S", 
                                         tz="Pacific/Easter"))
    
    # 4. Singapore time as 'DatetimeSG'
    df <- mutate(df, DatetimeSG = with_tz(df$DatetimeSF, "Singapore"))
    
    # Use this to manually update any other timezone inaccuracies 
    df$DatetimeSG <- df$DatetimeSG + hours(3)
    
    # Remove unwanted columns
    df <- subset(df, select = -c(Date, Time, creation_time))
    return(df)
}

# Apply format_FBtime function
uber <- format_FBtime(uber)
grab <- format_FBtime(grab)

# Select only data from March to Aug
grab <- grab[grab$DatetimeSG >= as.Date("010317", "%d%m%y") &
                 grab$DatetimeSG < as.Date("010917", "%d%m%y"), ] # n=3182
uber <- uber[uber$DatetimeSG >= as.Date("010317", "%d%m%y") &
                  uber$DatetimeSG < as.Date("010917", "%d%m%y"), ] # n=3159

# Extract hour, day of week --- not very useful
grab$Hour <- hour(grab$DatetimeSG)
grab$Dayofweek <- as.POSIXlt(grab$DatetimeSG)$wday
uber$Hour <- hour(uber$DatetimeSG)
uber$Dayofweek <- as.POSIXlt(uber$DatetimeSG)$wday

# ---------------------------------------------------------------------------- #

# Print date only
grab <- mutate(grab, Date = paste(year(grab$DatetimeSG), month(grab$DatetimeSG), 
                                  day(grab$DatetimeSG), sep="-"))
uber <- mutate(uber, Date = paste(year(uber$DatetimeSG), month(uber$DatetimeSG), 
                                  day(uber$DatetimeSG), sep="-"))

# Plot number of posts over time
grab1 <- grab %>% 
    group_by(Date) %>% 
    summarise(n = n()) 
uber1 <- uber %>% 
    group_by(Date) %>% 
    summarise(n = n()) 
colnames(grab1)[2] = "Grab"; colnames(uber1)[2] = "Uber"

# Merge
timeseries <- left_join(grab1, uber1, by=c("Date"="Date"))
timeseries[is.na(timeseries)] <- 0

# Format
timeseries <- transform(timeseries, 
                        Date = as.POSIXct(strptime(timeseries$Date, "%Y-%m-%d", tz="Singapore")),
                        Grab = as.numeric(Grab), Uber = as.numeric(Uber))

# Plot timeseries
ggplot(timeseries, aes(as.Date(Date))) + 
    geom_line(aes(y = Uber, color="Uber"), size=1) + 
    geom_line(aes(y = Grab, color="Grab"), size=1) + 
    labs(colour="Company", x="Date", y="num_posts") +
    scale_x_date(date_breaks = "1 month", date_labels = "%b")

# Back to back histogram - !!
timeseries2 <- mutate(timeseries, Month=month(Date)) %>%
    group_by(Month) %>%
    summarise(Grab = sum(Grab)*-1, Uber = sum(Uber))

g = ggplot(timeseries, aes(Month)) + 
    geom_bar(aes(x = "Uber"), fill="black") + 
    geom_bar(aes(x = "Grab"), fill= "green")
print(g + coord_flip())

# ---------------------------------------------------------------------------- #

# Count number of words per comment
uber$wordcount <- str_count(uber$post_comment, '\\s+')+1
grab$wordcount <- str_count(grab$post_comment, '\\s+')+1

# Remove non-ASCII characters in comments, usernames
uber$post_comment <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", 
                          "", uber$post_comment)
uber$post_username <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", 
                           "", uber$post_username)
grab$post_comment <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", 
                          "", grab$post_comment)
grab$post_username <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", 
                           "", grab$post_username)

# Detach conflicting packages before importing others in next section
detach("package:dplyr", unload=TRUE)
detach("package:lubridate", unload=TRUE)

# ---------------------------------------------------------------------------- #
# Load and edit AFINN dictionary

library(plyr)
library(stringr)
library(tidytext)

# SetWD to documents folder; stored files MUST be in [SENTIMENT ANALYSIS] folder
setwd("~/sentiment_analysis")

# Load word files 
afinn_list <- read.delim(file='AFINN-111.txt', 
                         header=FALSE, stringsAsFactors=FALSE)
names(afinn_list) <- c('word', 'score')
afinn_list$word <- tolower(afinn_list$word)

# Check if word exists & return score: (reuse this)
afinn_list$score[afinn_list$word=="YOURWORDHERE"]

# Modify scores (for words already in AFINN)
afinn_list$score[afinn_list$word %in% c("love", "best", "nice")] <- 4
afinn_list$score[afinn_list$word %in% c("charges", "charged", "pay", "like", "joke", "improvement")] <- 0
afinn_list$score[afinn_list$word %in% c("irresponsible", "whatever")] <- -1
afinn_list$score[afinn_list$word %in% c("cheat", "cheated", "frustrated", "scam", "pathetic",
                                        "useless", "dishonest", "tricked", "hopeless",
                                        "waste", "gimmick", "liar", "lied")] <- -4

# Add scores (for words not in AFINN)
pos4 <- data.frame(word = c("bagus", "yay", ":)", "kindly", "^^", "yay", "swee", "awesome", "steadi"), score = 4)
pos2 <- data.frame(word = c("jiayou", "lol", "haha", "assist", "thnks", "thnk", "thx", "thankyou", "bro", "pls",
                            "amin", "amen", "free", "supper", "dating", "arigato", "well"), score = 2)
pos1 <- data.frame(word = c("hi", "dear"), score = 1)
neg1 <- data.frame(word = c(":(", "silly", "cringe", "zzz", "picky"), score = -1)
neg2 <- data.frame(word = c("jialat", "waited", "waiting", "rubbish", "lousy", "siao", "??", "-_-", "-.-", 
                            "lying", "lies", "wtf", "wts", "sicko", "slap", "slapped"), score = -2)
neg4 <- data.frame(word = c("freaking", "!!!", "knn", "ccb", "?!", "!?", "fk", "fking", "moronic"), score = -4)

# Merge changes with main AFINN list
afinn_list <- rbind(afinn_list, pos4, pos2, neg1, neg2, neg4)

# ---------------------------------------------------------------------------- #
# Calculate AFINN scores for each comment

# Prep for transformation; adjust data types and create new dataframe
grab_words <- subset(grab, select = c(post_comment, message_ID))
grab_words <- transform(grab_words, message_ID = as.factor(message_ID),
                        post_comment = as.character(post_comment))

uber_words <- subset(uber, select = c(post_comment, message_ID))
uber_words <- transform(uber_words, message_ID = as.factor(message_ID),
                        post_comment = as.character(post_comment))

# Split comments to single words per cell
grab_indv <- strsplit(grab_words$post_comment, split = " ") 
uber_indv <- strsplit(uber_words$post_comment, split = " ") 

# Relink single words to parent comment, "message_ID"
uber_words <- data.frame(message_ID = rep(uber_words$message_ID, sapply(uber_indv, length)), 
                         words = unlist(uber_indv)) 
grab_words <- data.frame(message_ID = rep(grab_words$message_ID, sapply(grab_indv, length)), 
                         words = unlist(grab_indv)) # n=80,068

# Make lower
grab_words$words <- tolower(grab_words$words)
uber_words$words <- tolower(uber_words$words)

# Customise stopwords
library(tm)
stop_words <- as.data.frame(stopwords("en"))
more_stopwords <- as.data.frame(c("uber", "grab")) # add more if you want
names(stop_words)[1] <- "words"
names(more_stopwords)[1] <- "words"
stop_words <- rbind(stop_words, more_stopwords)

# Remove stopwords
uber_words <- uber_words[!(uber_words$words %in% stop_words$words),]
grab_words <- grab_words[!(grab_words$words %in% stop_words$words),]
detach("package:tm", unload=TRUE)

# Remove punctuation
grab_words <- transform(grab_words, words = (sub("^([[:alpha:]]*).*", "\\1", grab_words$words)))
uber_words <- transform(uber_words, words = (sub("^([[:alpha:]]*).*", "\\1", uber_words$words)))

# Remove empty rows
grab_words <- grab_words[(!grab_words$words==""),]
uber_words <- uber_words[(!uber_words$words==""),]

# Match words with AFINN score
library(dplyr)
grab_words <- left_join(grab_words, afinn_list, by= c("words" = "word"))
uber_words <- left_join(uber_words, afinn_list, by= c("words" = "word"))

# Calculate mean of each comments' word scores
uber_afinn <- uber_words %>%
    group_by(message_ID) %>%
    summarise(mean = mean(score, na.rm=TRUE)) 
grab_afinn <- grab_words %>%
    group_by(message_ID) %>%
    summarise(mean = mean(score, na.rm=TRUE)) 

# Convert NAN to 0
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))
uber_afinn[is.nan(uber_afinn)] <- 0
grab_afinn[is.nan(grab_afinn)] <- 0

# Independent samples two-tailed t-test
t.test(uber_afinn$mean, grab_afinn$mean)

# Merge back with dataframe, keep comment values
grab <- left_join(grab, grab_afinn, by = "message_ID")
uber <- left_join(uber, uber_afinn, by = "message_ID")
grab[is.na(grab)] <- 0

detach("package:tidytext", unload=TRUE)

# Plot bar charts




# ---------------------------------------------------------------------------- #
# Make smaller categories of terms

vNegTerms <- c(afinn_list$word[afinn_list$score==-5 | afinn_list$score==-4])
negTerms <- c(afinn_list$word[afinn_list$score==-3 | afinn_list$score==-2 |  afinn_list$score==-1])
posTerms <- c(afinn_list$word[afinn_list$score==3 | afinn_list$score==2 | afinn_list$score==1])
vPosTerms <- c(afinn_list$word[afinn_list$score==5 | afinn_list$score==4])

# Function to calculate number of words in each category within a sentence
sentimentScore <- function(sentences, vNegTerms, negTerms, posTerms, vPosTerms){
    final_scores <- matrix('', 0, 5)
    scores <- plyr::laply(sentences, function(sentence, vNegTerms, negTerms, posTerms, vPosTerms){
        initial_sentence <- sentence
        
        #remove unnecessary characters and split up by word 
        sentence <- gsub('[[:punct:]]', '', sentence)
        sentence <- gsub('[[:cntrl:]]', '', sentence)
        sentence <- gsub('\\d+', '', sentence)
        sentence <- tolower(sentence)
        wordList <- str_split(sentence, '\\s+')
        words <- unlist(wordList)
        
        #build vector with matches between sentence and each category
        vPosMatches <- match(words, vPosTerms)
        posMatches <- match(words, posTerms)
        vNegMatches <- match(words, vNegTerms)
        negMatches <- match(words, negTerms)
        
        #sum up number of words in each category
        vPosMatches <- sum(!is.na(vPosMatches))
        posMatches <- sum(!is.na(posMatches))
        vNegMatches <- sum(!is.na(vNegMatches))
        negMatches <- sum(!is.na(negMatches))
        score <- c(vNegMatches, negMatches, posMatches, vPosMatches)
        
        #add row to scores table
        newrow <- c(initial_sentence, score)
        final_scores <- rbind(final_scores, newrow)
        
        return(final_scores)
    }, vNegTerms, negTerms, posTerms, vPosTerms)
    
    return(scores)
}

# ---------------------------------------------------------------------------- #
# Apply score counting function

# Convert and apply function
grab_vec <- as.vector(grab$post_comment)
grab_scores <- as.data.frame(sentimentScore(grab_vec, vNegTerms, negTerms, posTerms, vPosTerms))

uber_vec <- as.vector(uber$post_comment)
uber_scores <- as.data.frame(sentimentScore(uber_vec, vNegTerms, negTerms, posTerms, vPosTerms))

# Rename
colnames(grab_scores) <- c('post_comment', 'vNegTerms', 'negTerms', 'posTerms', 'vPosTerms')
colnames(uber_scores) <- c('post_comment', 'vNegTerms', 'negTerms', 'posTerms', 'vPosTerms')

# Transform to suitable data type
grab_scores <- transform(grab_scores, 
                         vNegTerms = as.numeric(vNegTerms),
                         negTerms = as.numeric(negTerms),
                         posTerms = as.numeric(posTerms),
                         vPosTerms = as.numeric(vPosTerms)); str(grab_scores)
uber_scores <- transform(uber_scores, 
                         vNegTerms = as.numeric(vNegTerms),
                         negTerms = as.numeric(negTerms),
                         posTerms = as.numeric(posTerms),
                         vPosTerms = as.numeric(vPosTerms)); str(uber_scores)

# Recombine
grab <- cbind(grab, grab_scores$vNegTerms, grab_scores$negTerms, 
              grab_scores$posTerms, grab_scores$vPosTerms)
uber <- cbind(uber, uber_scores$vNegTerms, uber_scores$negTerms, 
              uber_scores$posTerms, uber_scores$vPosTerms)

# Format again
grab <- transform(grab, post_username = as.character(post_username),
                   post_ID = as.numeric(post_ID),
                   post_comment = as.character(post_comment),
                   message_ID = as.numeric(message_ID),
                   sentiment = as.factor(sentiment),
                   vNegTerms = as.numeric(grab_scores$vNegTerms),
                   negTerms = as.numeric(grab_scores$negTerms),
                   posTerms = as.numeric(grab_scores$posTerms),
                   vPosTerms = as.numeric(grab_scores$vPosTerms))
grab <- subset(grab, select=-c(DatetimeSF, Date, grab_scores.vNegTerms, 
     grab_scores.negTerms, grab_scores.posTerms, grab_scores.vPosTerms))
grab[is.na(grab)] <- 0

uber <- transform(uber, post_username = as.character(post_username),
                  post_ID = as.numeric(post_ID),
                  post_comment = as.character(post_comment),
                  message_ID = as.numeric(message_ID),
                  sentiment = as.factor(sentiment),
                  vNegTerms = as.numeric(uber_scores$vNegTerms),
                  negTerms = as.numeric(uber_scores$negTerms),
                  posTerms = as.numeric(uber_scores$posTerms),
                  vPosTerms = as.numeric(uber_scores$vPosTerms))
uber <- subset(uber, select=-c(DatetimeSF, Date, uber_scores.vNegTerms, 
       uber_scores.negTerms, uber_scores.posTerms, uber_scores.vPosTerms))
uber[is.na(uber)] <- 0

# Save data
write.csv(uber, file="uber_features.csv")
write.csv(grab, file="grab_features.csv")

# ---------------------------------------------------------------------------- #
# NB model

library(e1071)

# Build naive bayes model -- note that it tests and trains on ALL data
classifier_g <- naiveBayes(grab[,c(3, 9:14)], grab[,5])
classifier_u <- naiveBayes(uber[,c(3, 9:14)], uber[,5])

# Predict & print results
predicted_g <- predict(classifier_g, grab)
predicted_u <- predict(classifier_u, uber)

results_g <- table(predicted_g, grab[,9], 
                    dnn=list('predicted','actual'))
results_u <- table(predicted_u, uber[,9], 
                    dnn=list('predicted','actual'))

# Binomial test for confidence intervals
binom.test(results_g[1,1] + results_g[2,2]+ results_g[3,3], nrow(grab), p=0.5)
binom.test(results_u[1,1] + results_u[2,2]+ results_u[3,3], nrow(uber), p=0.5)

# ---------------------------------------------------------------------------- #

library(RTextTools)

# Shuffle order of rows to distribute positive, negative posts thru dataset
labelled_data <- labelled_data[sample(nrow(labelled_data)),]

# New dataframe of columns to be used
labelled_data1 <- subset(labelled_data, select = c(1:5, 8, 10))
View(labelled_data1)

# Build DTM for other models
matrix_uber <- create_matrix(labelled_data1[,1:7], language="english",
                             removeStopwords = FALSE, removeNumbers = TRUE,
                             stemWords = FALSE)
mat_uber <- as.matrix(matrix_uber)

# Build container to specify response input var, test set & training set
container_uber <- create_container(matrix_uber, 
                                   as.numeric(as.factor(labelled_data[,9])),
                                   trainSize=1:1000, testSize=1001:1519, # 75%
                                   virgin=FALSE)
                                   
# Train model with multiple ML Algos
models_all <- train_models(container_uber, 
                           algorithms=c("MAXENT" , "SVM", "RF", "BAGGING", "TREE"))

# Classify training set
results_all <- classify_models(container_uber, models_all)

# accuracy table
table(as.numeric(labelled_data[1001:1519, 9]), results_all[,"FORESTS_LABEL"])
table(as.numeric(as.factor(labelled_data[1001:1519, 9])), results_all[,"MAXENTROPY_LABEL"])

# recall accuracy
recall_accuracy(as.numeric(as.factor(labelled_data[1:666, 9])), results_all[,"FORESTS_LABEL"])
recall_accuracy(as.numeric(as.factor(labelled_data[1:666, 9])), results_all[,"MAXENTROPY_LABEL"])
recall_accuracy(as.numeric(as.factor(labelled_data[1:666, 9])), results_all[,"TREE_LABEL"])
recall_accuracy(as.numeric(as.factor(labelled_data[1:666, 9])), results_all[,"BAGGING_LABEL"])
recall_accuracy(as.numeric(as.factor(labelled_data[1:666, 9])), results_all[,"SVM_LABEL"])

# To summarize the results (especially the validity) in a formal way:
analytics <- create_analytics(container_uber, results_all)
summary(analytics)
head(analytics@document_summary)
analytics@ensemble_summary

# Cross validate with out of sample estimates of k-folds
N=5
set.seed(2014)
cross_validate(container_uber,N,"MAXENT")
cross_validate(container_uber,N,"TREE")
cross_validate(container_uber,N,"SVM")
cross_validate(container_uber,N,"RF")

# ---------------------------------------------------------------------------- #

# Load unlabelled data 
unlabelled_data <- dplyr::filter(tester, is.na(sentiment)) # n=2755

# Convert to character vector for passing thru function
unlabelled_data <- as.vector(unlabelled_data$post_comment) 

# Build tables with word-scores with SENTIMENTSCORE function
unlabelled_data <- as.data.frame(sentimentScore(unlabelled_data, 
                                                vNegTerms, negTerms, posTerms, vPosTerms))

# Bind with labels
colnames(unlabelled_data) <- c('sentence', 'vNeg', 'neg', 'pos', 'vPos')
View(unlabelled_data)

# Make sure all columns except post_comments are FACTORS
unlabelled_data <- transform(unlabelled_data,
                             vNeg = as.numeric(levels(vNeg))[vNeg],
                             neg = as.numeric(levels(neg))[neg],
                             pos = as.numeric(levels(pos))[pos],
                             vPos = as.numeric(levels(vPos))[vPos]); str(unlabelled_data)

# Shuffle order of rows to distribute positive, negative posts thru dataset
unlabelled_data <- unlabelled_data[sample(nrow(unlabelled_data)),]

# Predict sentiments using nb model 
predict_unlab <- predict(classifier_nb, unlabelled_data)
predict_unlab

# Merge prediction sentiments into one table
unlabelled_data1 <- cbind(unlabelled_data, as.data.frame(predict_unlab))
View(unlabelled_data1)

# Check distribution
nrow(subset(unlabelled_data, predict_unlab=="negative"))
