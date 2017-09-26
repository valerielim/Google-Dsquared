# Date: 12 Sep 2017
# Title: Grab_Uber
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
    
    #5. Keep Singapore Date as 'Date'
    
    # Use this to manually update any other timezone inaccuracies 
    df$DatetimeSG <- df$DatetimeSG + hours(3)
    df <- mutate(df, DateSG = paste(year(df$DatetimeSG), 
                                  month(df$DatetimeSG), 
                                  day(df$DatetimeSG), 
                                  sep="-"))
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

# Plot number of posts over time
grab1 <- grab %>% 
    group_by(DateSG) %>% 
    summarise(n = n()) 
uber1 <- uber %>% 
    group_by(DateSG) %>% 
    summarise(n = n()) 
colnames(grab1)[2] = "Grab"; colnames(uber1)[2] = "Uber"

# Merge
timeseries <- left_join(grab1, uber1, by=c("DateSG"="DateSG"))
timeseries[is.na(timeseries)] <- 0

# Format
timeseries <- transform(timeseries, 
                        Date = as.POSIXct(strptime(timeseries$DateSG, "%Y-%m-%d", tz="Singapore")),
                        Grab = as.numeric(Grab), Uber = as.numeric(Uber))

# Plot timeseries
ggplot(timeseries, aes(as.Date(DateSG))) + 
    geom_line(aes(y = Uber, color="Uber"), size=1) + 
    geom_line(aes(y = Grab, color="Grab"), size=1) + 
    labs(colour="Company", x="Date", y="num_posts") +
    scale_x_date(date_breaks = "1 month", date_labels = "%b")

# Plot back to back histogram 
uber1 <- mutate(uber1, Company='Uber')
grab1 <- mutate(grab1, Company='Grab', Num_comments=Num_comments*-1)
colnames(grab1)[2] = "Num_comments"; colnames(uber1)[2] = "Num_comments"
timeseries3 <- rbind(uber1, grab1) %>%
    transform(DateSG = as.Date(DateSG)) 

# Uber (right side)
plot_uber <- ggplot(timeseries3, aes(x=DateSG)) + 
    geom_bar(data = subset(timeseries3, Company == 'Uber'),
             aes(y=Num_comments, fill = Num_comments), stat = "identity") +
    scale_x_date(date_breaks = "1 month", date_labels = "%b"); plot_uber

# Grab (left)
print(plot_uber + 
    geom_bar(data = subset(timeseries3, Company == 'Grab'), 
             aes(y= Num_comments, fill = Num_comments), stat = 'identity') +
    scale_y_continuous(labels = NULL, limits = c(-50, 50)) + xlab("") + 
    ylab("Grab  -  Uber") + 
    scale_fill_gradient2(low ="forest green", mid = "white", high = "black", 
                         midpoint = 0, space = "rgb")+ coord_flip())

# Format data for MONTH clusters
timeseries4 <- mutate(timeseries3, Month=month(DateSG)) %>%
    group_by(Month, Company) %>%
    summarise(Num_comments = sum(Num_comments))

Labels <- data.frame(num = c(3:9), 
                     Date = c("Mar", "4"="Apr", "5"="May", '6'="Jun",
                                   "7"="Jul", "8"="Aug", "9"="Sep"))
timeseries5 <- left_join(timeseries4, Labels, by=c("Month" = "num"))    

# Uber (right side)
plot_uber <- ggplot(timeseries5, aes(reorder(Date, Month))) + 
    geom_bar(data = subset(timeseries5, Company == 'Uber'),
             aes(y=Num_comments, fill = Num_comments), stat = "identity") + 
    scale_x_discrete("Date", labels=abbreviate); plot_uber
         
# Grab (left)
print(plot_uber + 
          geom_bar(data = subset(timeseries5, Company == 'Grab'), 
                   aes(y= Num_comments, fill = Num_comments), stat = 'identity') +
          scale_y_continuous(breaks = c(-200,-400,-600,0,200,400,600), limits = c(-750, 750), position = "right") +
          ylab("Grab  -  Uber") + 
          scale_fill_gradient2(low ="forest green", mid = "white", high = "black", 
                               midpoint = 0, space = "rgb") + 
          theme(legend.position = "none") + coord_flip())

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
detach("package:ggplot2", unload=TRUE)
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
afinn_list$score[afinn_list$word %in% c("love", "best", "nice", "appreciation")] <- 4
afinn_list$score[afinn_list$word %in% c("charges", "charged", "pay", "like", "joke", "improvement")] <- 0
afinn_list$score[afinn_list$word %in% c("irresponsible", "whatever")] <- -1
afinn_list$score[afinn_list$word %in% c("cheat", "cheated", "frustrated", "scam", "pathetic",
                                        "useless", "dishonest", "tricked", "hopeless",
                                        "waste", "gimmick", "liar", "lied")] <- -4

# Add scores (for words not in AFINN)
pos4 <- data.frame(word = c("bagus", "yay", ":)", "kindly", "^^", "yay", "swee", "awesome", "polite", 
                            "professional", "thnks", "thnk", "thx", "thankyou","tq", "ty", "pls"), score = 4)
pos2 <- data.frame(word = c("jiayou", "assist", "amin", "amen", "supper", "dating", "arigato", "well", "bro"), score = 2)
pos1 <- data.frame(word = c("hi", "dear", "hello"), score = 1)
neg1 <- data.frame(word = c("silly", "dafaq", "dafuq", "cringe", "zzz", "picky"), score = -1)
neg2 <- data.frame(word = c("jialat", "waited", "waiting", "rubbish", "lousy", "siao", "??", "-_-", "-.-", 
                            "lying", "lies", "wtf", "wts", "sicko", "slap", "slapped"), score = -2)
neg4 <- data.frame(word = c("freaking", "!!!", "knn", "ccb", "?!", "!?", "fk", "fking", "moronic"), score = -4)

# Merge changes with main AFINN list
afinn_list <- rbind(afinn_list, pos4, pos2, pos1, neg1, neg2, neg4)

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
                         words = unlist(uber_indv)) # n=94,696
grab_words <- data.frame(message_ID = rep(grab_words$message_ID, sapply(grab_indv, length)), 
                         words = unlist(grab_indv)) # n=80,068
grab_words$words <- tolower(grab_words$words); uber_words$words <- tolower(uber_words$words)

# Customise stopwords
library(tm)
stop_words <- as.data.frame(stopwords("en"))
more_stopwords <- as.data.frame(c("uber", "grab")) # add more if you want
names(stop_words)[1] <- "words"; names(more_stopwords)[1] <- "words"
stop_words <- rbind(stop_words, more_stopwords)
detach("package:tm", unload=TRUE)

# Remove stopwords
uber_words <- uber_words[!(uber_words$words %in% stop_words$words),]
grab_words <- grab_words[!(grab_words$words %in% stop_words$words),]

# Remove punctuation, empty rows
grab_words <- transform(grab_words, words = (sub("^([[:alpha:]]*).*", "\\1", grab_words$words)))
uber_words <- transform(uber_words, words = (sub("^([[:alpha:]]*).*", "\\1", uber_words$words)))
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

boxplot(uber_afinn$mean, grab_afinn$mean)


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
grab <- subset(grab, select=-c(Date, grab_scores.vNegTerms, 
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
classifier_g <- naiveBayes(grab[,c(9:14)], grab[,5])
classifier_u <- naiveBayes(uber[,c(3, 9:14)], uber[,5])

# Predict & print results
predicted_g <- predict(classifier_g, grab)
predicted_u <- predict(classifier_u, uber)

results_g <- table(predicted_g, grab[,5], dnn=list('predicted','actual'))
results_u <- table(predicted_u, uber[,9], dnn=list('predicted','actual'))

# Binomial test for confidence intervals
binom.test(results_g[1,1] + results_g[2,2]+ results_g[3,3], nrow(grab), p=0.5)
binom.test(results_u[1,1] + results_u[2,2]+ results_u[3,3], nrow(uber), p=0.5)

##################################
#               results - with relabelling; uber
#            actual
# predicted  negative neutral positive
# negative      174      34       16
# neutral       219     807      165
# positive       13      12       79
# 
# 95 percent confidence interval: 0.6740394 0.7208483
# Final probability of success 
# 0.6978275 
##################################
#               results - grab
#           actual
# predicted  positive negative neutral
# positive      175       18      44
# negative       29      137      33
# neutral       179      113     740
# 
# 95 percent confidence interval: 0.6928107 0.7395618
# sample estimates:
#     probability of success 
# 0.7166213 
##################################

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

# ---------------------------------------------------------------------------- #
# Tag topics in csv file

# Add/delete columns
unlabelled_data <- subset(unlabelled_data, select = -c(sentiment))


library(dplyr)

Flagkeyword <- function(df, keyword, title){
    
    # Requires
    # 1. column to be searched should be named "post_comment"
    # 2. keyword should be placed in inverted commas (ie. "staycation")    
    
    # Returns
    # 1. column named "title"
    # 2. rows with strings matching keywords will be flagged 1, the rest, 0
    
    df$Flags <- 0
    df[grepl(keyword, df$message, ignore.case=TRUE), ]$Flags <- 1
    colnames(df)[colnames(df)=="Flags"] <- title
    return(df)
}

# Brands
output <- Flagkeyword(output, "UBER", title = "Uber")
output <- Flagkeyword(output, "GRAB", title = "Grab")
output <- Flagkeyword(output, "cdg|taxi|cab|comfort", "Comfort_Taxi")

# Services
output <- Flagkeyword(output, "pool", title = "Uberpool")
output <- Flagkeyword(output, "uberx", title = "UberX")
output <- Flagkeyword(output, "grabshare", title = "Grabshare")

# Promos
output <- Flagkeyword(output, "promo",
                      title = "Promo_General")
output <- Flagkeyword(output, paste("can't|\bcant\b|\bcouldnt\b|\bcouldn't\b",
                                    "|cannot|\bfully\b).*([redeem]|\bapply\b)",
                                    "|(limit|\bcode\b).*(redemption|exceed|",
                                    "promotion)|(promo|code).*",
                                    "(redemption exceeds|not valid)"),
                      title = "Redeem_probs")
output <- Flagkeyword(output, paste0("(never|not).*(receive|receiving)",
                                     ".*(promo|code|email)|(email code)"), 
                      title = "Never_Receive")

# Customer Service
output <- Flagkeyword(output, paste0("customer service|service|support team|",
                                     "communication agent"), 
                      title = "Customer_Service")
output <- Flagkeyword(output, paste0("(\bnever\b|\bno\b|(not gotten a)|",
                                     "\bplease\b|(not received any)|kindly|",
                                     "(nobody).*(reply|\bpm\b))"), 
                      title = "CS_No_Reply")
output <- Flagkeyword(output, paste0("(cut and paste|copy and paste|standard|",
                                     "low quality|no quality|\bsop\b).*",
                                     "(repl|answer)|(not responding)"), 
                      title = "Reply_Quality")

# Payments
output <- Flagkeyword(output, "(over|double|anyhow).*(charge)", 
                      title = "Over_Charge")
output <- Flagkeyword(output, "(payment|deduct).*(error)", 
                      title = "Payment_System")
output <- Flagkeyword(output, "surge", 
                      title = "Surge")

# General topics
output <- Flagkeyword(output, paste0("scam|con|criminal|offence|fake|cheat",
                                     "|suspect|misleading|dupe|duped|trap"), 
                      title = "Cheat")
output <- Flagkeyword(output, paste0("(!{2,})|god damn|useless|fuck|idiot|",
                                     "nonsense|shit|uninstall|delete"),
                      title = "Churn")
output <- Flagkeyword(output, "(\bchild\b|car|infant).*(seat|safety|restraint)", 
                      title = "Child_seat")


# Common complaints
output <- Flagkeyword(output, "waiting time|wait", title = "Waiting_Time")
output <- Flagkeyword(output, "cancel", # includes cancellation fee
                      title = "Cancellations")
output <- Flagkeyword(output, "cancel.*(\bfee\b)", # includes cancellation fee
                      title = "Cancellation_fee")

# Driver related
output <- Flagkeyword(output, "driver", title = "Driver_General")
output <- Flagkeyword(output, "sleep", title = "Sleepy_Driver")
output <- Flagkeyword(output, "rude driver", title = "Rude_Driver")
output <- Flagkeyword(output, "molest|sex|\btouch\b|pervert", 
                      title = "Pervert_Drivers")

# Comparisons
output <- Flagkeyword(output, "breakdown", title = "SMRT_Breakdown")
output <- Flagkeyword(output, "SMRT|SBS|\btrain\b|\bbus\b|public transport", 
                      title = "Public_transport")

# Save output to CSV file
write.csv(output, file="uber_topics.csv")

# ---------------------------------------------------------------------------- #
# word cloud functions

library(SnowballC)
library(NLP)
library(tm)

# Read text into new variable called comment1
driversonly <- dplyr::filter(output, Driver_General==1)
comment1 <- driversonly$message

# Preview first 6 messages
head(comment1)

# Create corpous for processing by TS package
corpus1 <- VCorpus(VectorSource(comment1))

# Make lowercase
corpus1 <- tm_map(corpus1, content_transformer(tolower))

# Build stopwords list
myStopwords <- c(stopwords("english"), "the", "and", "lah", "uber", "car", 
                 "will", "can", "use", "singapore", "back", "get", "driver")

# Remove stopwords
corpus1 <- tm_map(corpus1, removeWords, myStopwords)

# Word stemming
corpus1 <- tm_map(corpus1, stemDocument)

# Remove punctuation,  numbers, white space
corpus1 <- tm_map(corpus1, removePunctuation)
corpus1 <- tm_map(corpus1, removeNumbers)
corpus1 <- tm_map(corpus1, stripWhitespace)

# ------------------------------- DTM ------------------------------- #

# Generate DTM (Frequency Count)
# doc <- corpus1
dtm <- DocumentTermMatrix(corpus1)
# m1 <- as.matrix(dtm)

# 2. Generate ddtm (Tf-Idf)
dtm2 <- DocumentTermMatrix(corpus1, control=list(weighting=function(x) weightTfIdf(x, 
                                                                                   normalize=FALSE)))
# m2 <- as.matrix(dtm2)

# Generate dtm (binary)
dtm3 <- DocumentTermMatrix(corpus1, control=list(weighting=weightBin))
# m3 <- as.matrix(dtm3)

# Count frequency of each concept
freq <- colSums(as.matrix(dtm))

# Compute concepts
length(freq)

# Sort frequency of concepts in decreasing order; display top topics
sor <- sort(freq, decreasing=TRUE)
head(sor)

# save dtm to excel
# m <- as.matrix(dtm)
# dim(m)
# write.csv(m, file="dtml1.csv")

# subset & sort in decreasing order
subfreq <- subset(freq, freq>20)
subfreq <- sort(subfreq, decreasing = TRUE)

# make to dataframe
dffreq <- data.frame(term=names(subfreq), fre=subfreq)


# ------------------------------- GRAPHICS ------------------------------- #

library(ggplot2)
library(RColorBrewer)
library(wordcloud)

ggplot(dffreq, aes(x=dffreq$term, y=dffreq$fre))+geom_bar(stat="identity")+coord_flip()

fancythemename <- brewer.pal(6, "Paired") # colour
wordcloud(names(freq), freq, min.freq=50)
wordcloud(names(freq), freq, max.words = 100, rot.per=0.6, colors=fancythemename)


# Pick colour palette / Display all colours
?brewer.pal
display.brewer.all(n=NULL, type="all", select=NULL)


# View first 6 objects
for(i in 1:6){
    print(corpus1[[i]][1])
}

# ------------------------------- GRAPHICS ------------------------------- #
# Count number of comments per parent post

library(dplyr)

# Print number of child comments per post_ID, in descending order
childcomments <- as.data.frame(table(tester$post_ID))
childcomments <- childcomments[order(-childcomments$Freq),]; childcomments

# Print summary of number of comments
child_summary <- childcomments %>%
    group_by(Freq) %>%
    tally() %>%
    as.data.frame() %>%
    arrange(desc(n))

# Rename
names(child_summary)[1]<-"comments_per_post"
names(child_summary)[2]<-"num_posts"




# Split posts into individual words
# post_words <- tester %>%
#     select(post_comment, message_ID, post_ID) %>%
#     unnest_tokens(post_words, output = word, input = post_comment, token = "words") %>%
#     filter(!word %in% stop_words$word,
#            str_detect(word, "^[a-z']+$")); post_words

# sentiment_score <- post_words %>%
#     left_join(afinn_list, by = "word") %>%
#     # should be left join
#     group_by(review_id, stars) %>% # group by msg_ID
#     summarize(sentiment = mean(afinn_score)); sentiment_score

# # Introduce time periods 
# ### NOT USEFUL 
# labelled_data$timeperiod <- ""
# labelled_data <- transform(labelled_data, 
#                            timeperiod = ifelse(hour_num %in% c(7, 8, 9, 10, 11, 12), "morning", 
#                                                ifelse(hour_num %in% c(13, 14, 15, 16, 17, 18), "afternoon", 
#                                                       ifelse(hour_num %in% c(19, 20, 21, 22, 23, 0), "night", 
#                                                              ifelse(hour_num %in% c(1, 2, 3, 4, 5, 6), "redeye", "")))))
# 
