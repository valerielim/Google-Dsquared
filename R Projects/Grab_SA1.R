# Date created: 12 Sep 2017
# Title: Grab_SA1.R (SA = sentiment analysis)

# Reference: https://github.com/abromberg/sentiment_analysis/blob/master/sentiment_analysis.R
# Reference 2: http://rpubs.com/chengjun/sentiment

# ---------------------------------------------------------------------------- #
# prep dataset

setwd("C:/Users/valeriehy.lim/Documents")

# Load data -- read the uber_comments_clean.csv file
data <- read.csv(file.choose())
options(stringsAsFactors = FALSE)

# Make spare copies
output <- data
tester <- data

# ---------------------------------------------------------------------------- #
# Build features - day of week, time of post, number of comments

library(stringr)
library(dplyr)
library(lubridate)

# Clean date function
timeSG <- function(df){
    
    # Requires:
    # 1. Target datetime column titled "creation_time"
    
    # Returns: 
    # 1. new column "Date" in format YYYY-MM-DD
    # 2. new column "Time" in format HH:MM:SS
    # 3. cleaned version of original datetime as YYYY-MM-DD HH:MM:SS (UTC -8:00)
    # 4. new version in SG timezone as YYYY-MM-DD HH:MM:SS (SGT +8:00) 
    
    # 1. Date YYYY-MM-DD
    df <- mutate(df, Date = paste(year(df$creation_time), 
                                  month(df$creation_time), 
                                  day(df$creation_time), 
                                  sep="-"))
    
    # 2. Time HH:MM:SS
    df <- mutate(df, Time=substr(as.character(df$creation_time),12, 19))
    
    # 3. Original time as 'DatetimeRAW'
    df <- mutate(df, DatetimeRAW = paste(df$Date, df$Time))
    df$DatetimeRAW <- as.POSIXct(strptime(df$DatetimeRAW, 
                                          "%Y-%m-%d %H:%M:%S", 
                                          tz="Pacific/Easter"))
    
    # 4. Singapore time as 'DatetimeSG'
    df <- mutate(df, DatetimeSG = with_tz(df$DatetimeRAW, "Singapore"))

    # Use this to manually update any other timezone inaccuracies 
    df$DatetimeSG <- df$DatetimeSG + hours(3)
    
    return(df)
}

# Apply cleantimezoneSG function
names(tester)[1]<-"creation_time" # Rename date column bef applying function
tester <- timeSG(tester)

# Extract hour as feature
tester$Time <- hour(tester$DatetimeSG)

# Extract dayofweek as feature
tester$Dayofweek <- as.POSIXlt(tester$DatetimeSG)$wday

# Count num_words per comment as feature
tester$wordcount <- str_count(tester$message, '\\s+')+1

# Detach conflicting packages before importing others in next section
detach("package:dplyr", unload=TRUE)
detach("package:lubridate", unload=TRUE)

# ---------------------------------------------------------------------------- #
# Clean and format data set

# Keep only necessary columns
tester <- subset(tester, select = c(1,2,4,6,9,11,12,13))

# Rename to format
names(tester)[1]<-"creation_time" # for ref
names(tester)[2]<-"post_username"
names(tester)[3]<-"post_comment"
names(tester)[4]<-"sentiment"
names(tester)[5]<-"hour_num"
names(tester)[6]<-"timesg_num"
names(tester)[7]<-"weekday_num"
names(tester)[8]<-"wordcount"

# Remove strange characters in body
tester$post_comment <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", 
                            "", tester$post_comment)

# ---------------------------------------------------------------------------- #
# Build features for sentiment wordscore: import tools

library(plyr)
library(stringr)
library(e1071)

# SetWD to documents folder; stored files MUST be in [SENTIMENT ANALYSIS] folder
setwd("~/sentiment_analysis")

# Load word files 
afinn_list <- read.delim(file='AFINN-111.txt', 
                         header=FALSE, stringsAsFactors=FALSE);afinn_list
names(afinn_list) <- c('word', 'score')
afinn_list$word <- tolower(afinn_list$word)

# Import 4 lists of words
# Note: Edit word list where appropriate. Use regexp format.
vNegTerms <- c(afinn_list$word[afinn_list$score==-5 | afinn_list$score==-4], 
                "disappointed", "disappointing", "no point", "upset", "scam", 
               "waste", "bad", "knn", ":(", "refuse", "lost", "demand",
               "cheat", "cheated", "conned", "hopeless", "pathetic", "rubbish",
               "ccb", "wtf", "bullshit", "hell", "what a joke", "fk", "unfair",
               "unequal", "difficult", "nonsense", "inferior", "upset", "hate",
               "overcharge", "disappoint", "dissappoint", "disapoint", 
               # include common spelling errors 
               "(\\?{1,})(\\!{1,})|(\\!{1,})(\\?{1,})|(\\!{2,})|(\\?{2,})") 
               # for angry punctuation like ??+ !?+ !?+ !!+ 

negTerms <- c(afinn_list$word[afinn_list$score==-3 | afinn_list$score==-2 | 
                afinn_list$score==-1], "dangerous", "unauthorized", "rude",
              "failed", "sick", "cheapo", "regret", "poo", "argh", "lousy",
              "second-rate", "moronic", "demand", "slapped", "inconvenient",
              "confused", "disappointing", "bloody", "silly", "tired", "cringe",
              "predictable", "stupid", "siao", "picky", "waste", "zzz",
              "inflated", "unethical", "confusing", "irresponsible", "fake",
              "expensive", "unsuccessful", "getting on my nerves", 
              "-.-", "-_-", "too long")

posTerms <- c(afinn_list$word[afinn_list$score==3 | afinn_list$score==2 | 
                afinn_list$score==1], "pleasant", "great", "appreciate",
              "surprising", "thnks", "amen", "amin", "bro", "supper", "dating", 
              "well done", "fuss free")

vPosTerms <- c(afinn_list$word[afinn_list$score==5 | afinn_list$score==4], 
               "uproarious", "riveting", "fascinating", "dazzling", "legendary", 
               "win", "wow", "haha", "lol", "yummylicious", "whizz", "nice",
               "swee", "awesome", "arigato", "yay", "love") 

# Function to calculate number of words in each category within a sentence
sentimentScore <- function(sentences, vNegTerms, negTerms, posTerms, vPosTerms){
    final_scores <- matrix('', 0, 5)
    scores <- laply(sentences, function(sentence, vNegTerms, negTerms, 
                                        posTerms, vPosTerms){
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
# Build features for sentiment wordscore: Apply tools to create wordscore

# Create separate tables for each sentiment
tagged_positive <- dplyr::filter(tester, sentiment=="positive")
tagged_negative <- dplyr::filter(tester, sentiment=="negative") 
tagged_neutral <- dplyr::filter(tester, sentiment=="neutral") 

# Convert to char vectors
tagged_pos <- as.vector(tagged_positive$post_comment) 
tagged_neg <- as.vector(tagged_negative$post_comment) 
tagged_neu <- as.vector(tagged_neutral$post_comment) 

# Pass vectors through SENTIMENTSCORE function to build tables
posResult <- as.data.frame(sentimentScore(tagged_pos, vNegTerms, negTerms, 
                                          posTerms, vPosTerms))
negResult <- as.data.frame(sentimentScore(tagged_neg, vNegTerms, negTerms, 
                                          posTerms, vPosTerms))
neuResult <- as.data.frame(sentimentScore(tagged_neu, vNegTerms, negTerms, 
                                          posTerms, vPosTerms))

# Recombine with original features from prev section
posResult <- cbind(posResult, 
                   tagged_positive$hour_num,
                   tagged_positive$weekday_num,
                   tagged_positive$wordcount)
negResult <- cbind(negResult, 
                   tagged_negative$hour_num,
                   tagged_negative$weekday_num,
                   tagged_negative$wordcount)
neuResult <- cbind(neuResult, 
                   tagged_neutral$hour_num,
                   tagged_neutral$weekday_num,
                   tagged_neutral$wordcount)

# Reattach label with original sentiments
posResult <- cbind(posResult, 'positive')
negResult <- cbind(negResult, 'negative')
neuResult <- cbind(neuResult, 'neutral')

# Rename columns 
colnames(posResult) <- c('sentence', 'vNeg', 'neg', 'pos', 'vPos', 
                         'hour_num', 'weekday_num', 'wordcount', 'sentiment')
colnames(negResult) <- c('sentence', 'vNeg', 'neg', 'pos', 'vPos', 
                         'hour_num', 'weekday_num', 'wordcount', 'sentiment')
colnames(neuResult) <- c('sentence', 'vNeg', 'neg', 'pos', 'vPos', 
                         'hour_num', 'weekday_num', 'wordcount', 'sentiment')

# Combine the positive and negative tables
labelled_data <- rbind(posResult, negResult, neuResult)
labelled_binary <- rbind(posResult, negResult) # pos and neg only

# Format data types before modelling
labelled_data <- transform(labelled_data, 
                           sentence = as.character(sentence),
                           vNeg = as.numeric(vNeg),
                           neg = as.numeric(neg),
                           pos = as.numeric(pos),
                           vPos = as.numeric(vPos),
                           hour_num = as.factor(hour_num),
                           weekday_num = as.factor(weekday_num),
                           wordcount = as.numeric(wordcount),
                           sentiment = as.factor(sentiment)); str(labelled_data)

labelled_binary <- transform(labelled_binary, 
                           sentence = as.character(sentence),
                           vNeg = as.numeric(vNeg),
                           neg = as.numeric(neg),
                           pos = as.numeric(pos),
                           vPos = as.numeric(vPos),
                           hour_num = as.factor(hour_num),
                           weekday_num = as.factor(weekday_num),
                           wordcount = as.numeric(wordcount),
                           sentiment = as.factor(sentiment)); str(labelled_binary)

# ---------------------------------------------------------------------------- #
# Extra features: Overall wordscore, and Timeperiods

# Build overall wordscore; negative score means more neg words.
labelled_data$net_score <- (labelled_data$vNeg*-5) + (labelled_data$neg*-2) + 
    (labelled_data$pos*2) + (labelled_data$vPos*5)

labelled_binary$net_score <- (labelled_binary$vNeg*-5) + (labelled_binary$neg*-2) + 
    (labelled_binary$pos*2) + (labelled_binary$vPos*5)

# Introduce time periods 
### NOTE: Found NOT USEFUL in improving accuracy
labelled_data$timeperiod <- ""
labelled_data <- transform(labelled_data, 
    timeperiod = ifelse(hour_num %in% c(7, 8, 9, 10, 11, 12), "morning", 
                ifelse(hour_num %in% c(13, 14, 15, 16, 17, 18), "afternoon", 
                ifelse(hour_num %in% c(19, 20, 21, 22, 23, 0), "night", 
                ifelse(hour_num %in% c(1, 2, 3, 4, 5, 6), "redeye", "")))))

# ---------------------------------------------------------------------------- #
# Pass data through Naive Bayes classifier

# Trinary dataset performance

# Build naive bayes model
# Note: due to small sample data set, tests and trains on ALL data
classifier_nb <- naiveBayes(labelled_data[,c(2:5, 8, 10)], labelled_data[,9])

# Predict & print results
predicted_nb <- predict(classifier_nb, labelled_data)
results_nb <- table(predicted_nb, labelled_data[,9], 
                    dnn=list('predicted','actual')); results_nb

# Binomial test for confidence intervals
binom.test(results_nb[1,1] + results_nb[2,2] + results_nb[3,3], 
           nrow(labelled_data), p=0.5)

# Binary dataset performance

# Build naive bayes model
# Note: due to small sample data set, tests and trains on ALL data
classifier_nb <- naiveBayes(labelled_binary[,c(2:5, 8, 10)], labelled_binary[,9])

# Predict & print results
predicted_nb <- predict(classifier_nb, labelled_binary)
results_nb <- table(predicted_nb, labelled_binary[,9], 
                    dnn=list('predicted','actual')); results_nb

# Binomial test for confidence intervals
binom.test(results_nb[1,1] + results_nb[2,2], nrow(labelled_binary), p=0.5)

# PS: See results doc for answers
# ---------------------------------------------------------------------------- #
# Pass data through other classifiers

library(RTextTools)

# Shuffle order of rows to distribute pos, neg posts equally throughout set
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
# Use classifier to predict labels for remaining unlabelled posts

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

# End
# ---------------------------------------------------------------------------- #
