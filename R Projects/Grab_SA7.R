# Date: 27 Sep 2017, Wed, 3pm
# Title: Complete up to Naive Bayes. 
# Reference: https://github.com/abromberg/sentiment_analysis/blob/master/sentiment_analysis.R
# Reference 2: http://rpubs.com/chengjun/sentiment
# Comparison of lists: https://www.kaggle.com/apasupat/sentiment-analysis-3-different-methods/code
# Graphs for bubble plot: http://t-redactyl.io/blog/2016/02/creating-plots-in-r-using-ggplot2-part-6-weighted-scatterplots.html
# Graphs for sentiment: https://medium.com/@actsusanli/text-mining-is-fun-with-r-35e537b12002



# ---------------------------------------------------------------------------- #
# [prep dataset]

setwd("C:/Users/valeriehy.lim/Documents")

# Load data -- read the uber_comments_clean.csv file
uber <- read.csv(file.choose(), header=T, na.strings=c("", " ","NA")); View(uber)
grab <- read.csv(file.choose(), header=T, na.strings=c("", " ","NA")); View(grab)
options(stringsAsFactors = FALSE)

# Rename columns
names(uber) <- c("creation_time", "post_username", "post_ID", 
                 "post_comment", "message_ID", "sentiment")

names(grab) <- c("creation_time", "post_username", "post_ID", 
                 "post_comment", "message_ID", "sentiment")

# Format data types
grab <- transform(grab, creation_time = as.character(creation_time), 
                  post_username = as.character(post_username),
                  post_ID = as.factor(post_ID), 
                  post_comment = as.character(post_comment),
                  message_ID = as.factor(message_ID),
                  sentiment = as.factor(sentiment)); str(grab)

uber <- transform(uber, creation_time = as.character(creation_time), 
                  post_username = as.character(post_username),
                  post_ID = as.factor(post_ID), 
                  post_comment = as.character(post_comment),
                  message_ID = as.factor(message_ID),
                  sentiment = as.factor(sentiment)); str(uber)

# ---------------------------------------------------------------------------- #
# Clean up time format, build feature for number of words per comment

library(stringr)
library(dplyr)
library(lubridate)
library(ggplot2)

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
grab <- format_FBtime(grab); str(grab)
uber <- format_FBtime(uber); str(uber)

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

# Plot number of posts
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

# Plot timeseries of number of posts by day
ggplot(timeseries, aes(as.Date(DateSG))) + 
    geom_line(aes(y = Uber, color="Uber"), size= 0.5, colour="black") + 
    geom_line(aes(y = Grab, color="Grab"), size= 0.5, colour="forest green") + 
    labs(colour="Company", x="Month", y="Number of Comments") +
    scale_x_date(date_breaks = "1 month", date_labels = "%b") + 
    theme(legend.position = "bottom")

# ---------------------------------------------------------------------------- #

# Plot number of posts over time, by day
colnames(grab1)[2] = "Num_comments"; colnames(uber1)[2] = "Num_comments"
uber1 <- mutate(uber1, Company='Uber')
grab1 <- mutate(grab1, Company='Grab', Num_comments=Num_comments*-1)
timeseries2 <- rbind(uber1, grab1) %>%
    transform(DateSG = as.Date(DateSG)) 

# Uber (right side)
plot_uber <- ggplot(timeseries2, aes(x=DateSG)) + 
    geom_bar(data = subset(timeseries2, Company == 'Uber'),
             aes(y=Num_comments, fill = Num_comments), colour="black", stat = "identity") +
    scale_x_date(date_breaks = "1 month", date_labels = "%b"); plot_uber

# Grab (left)
print(plot_uber + 
    geom_bar(data = subset(timeseries2, Company == 'Grab'), 
             aes(y= Num_comments, fill = Num_comments), colour="dark green", stat = 'identity') +
    scale_y_continuous(breaks= seq(-75, 75, 25), limits = c(-75, 75), 
                       position = "right", name = "Grab  - - -  Uber") + xlab("") + 
    scale_fill_gradient2(low ="forest green", mid = "white", high = "black", 
                         midpoint = 0, space = "rgb")+
        theme(legend.position = "none") + coord_flip())

# ---------------------------------------------------------------------------- #

# Format data for MONTH clusters
timeseries3 <- mutate(timeseries2, Month=month(DateSG)) %>%
    group_by(Month, Company) %>%
    summarise(Num_comments = sum(Num_comments))
Labels <- data.frame(num = c(3:9), Date = c("Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep"))
timeseries3 <- left_join(timeseries3, Labels, by=c("Month" = "num"))    

# Uber (right side)
plot_uber <- ggplot(timeseries3, aes(reorder(Date, Month))) + 
    geom_bar(data = subset(timeseries3, Company == 'Uber'),
             aes(y=Num_comments, fill = Num_comments), stat = "identity") + 
    scale_x_discrete(name = "Month", labels=abbreviate); plot_uber
         
# Grab (left)
print(plot_uber + 
          geom_bar(data = subset(timeseries3, Company == 'Grab'), 
                   aes(y= Num_comments, fill = Num_comments), stat = 'identity') +
          scale_y_continuous(breaks = seq(-600,600, 200), limits = c(-750, 750), 
                             position = "right", name = "Grab   - - -   Uber") +
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

# ---------------------------------------------------------------------------- #
# Load and edit AFINN dictionary

library(plyr)
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
afinn_list$score[afinn_list$word %in% c("best", "nice", "appreciation")] <- 4
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
neg1 <- data.frame(word = c("silly", "dafaq", "dafuq", "cringe", "picky"), score = -1)
neg2 <- data.frame(word = c("jialat", "waited", "waiting", "rubbish", "lousy", "siao", "??", "-_-", "-.-", 
                            "lying", "lies", "wtf", "wts", "sicko", "slap", "slapped"), score = -2)
neg4 <- data.frame(word = c("freaking", "knn", "ccb", "fk", "fking", "moronic"), score = -4)

# Merge changes with main AFINN list
afinn_list <- rbind(afinn_list, pos4, pos2, pos1, neg1, neg2, neg4)

# ---------------------------------------------------------------------------- #
# Calculate AFINN scores for each comment

# Prep: Subset 
grab_words <- subset(grab, select = c(post_comment, message_ID))
uber_words <- subset(uber, select = c(post_comment, message_ID))

# Split comments to single words per cell
grab_indv <- strsplit(grab_words$post_comment, split = " ") 
uber_indv <- strsplit(uber_words$post_comment, split = " ") 

# Relink single words to parent comment, "message_ID"
uber_words <- data.frame(message_ID = rep(uber_words$message_ID, sapply(uber_indv, length)), 
                         words = unlist(uber_indv)) # n=94,856
grab_words <- data.frame(message_ID = rep(grab_words$message_ID, sapply(grab_indv, length)), 
                         words = unlist(grab_indv)) # n=80,334

# To lower
grab_words$words <- tolower(grab_words$words); uber_words$words <- tolower(uber_words$words)

# Customise stopwords
library(tm)
stop_words <- as.data.frame(stopwords("en"))
more_stopwords <- as.data.frame(c("uber", "grab", "will", "can", "get", 'u')) # add more if you want
names(stop_words)[1] <- "words"; names(more_stopwords)[1] <- "words"
stop_words <- rbind(stop_words, more_stopwords)
detach("package:tm", unload=TRUE)

# Remove stopwords
uber_words <- uber_words[!(uber_words$words %in% stop_words$words),] # n= 52632
grab_words <- grab_words[!(grab_words$words %in% stop_words$words),] # n= 44908

# Remove punctuation, empty rows
grab_words <- transform(grab_words, words = (sub("^([[:alpha:]]*).*", "\\1", grab_words$words)))
uber_words <- transform(uber_words, words = (sub("^([[:alpha:]]*).*", "\\1", uber_words$words)))
grab_words <- grab_words[(!grab_words$words==""),] # n= 39826
uber_words <- uber_words[(!uber_words$words==""),] # n= 47411

# Remove stopwords again
grab_words <- grab_words[!(grab_words$words %in% stop_words$words),] # n= 38,398
uber_words <- uber_words[!(uber_words$words %in% stop_words$words),] # n= 45,552

# Remove NA rows
grab_words <- grab_words[!is.na(grab_words$words),] # n= 38,132
uber_words <- uber_words[!is.na(uber_words$words),] # n= 45,392

# ---------------------------------------------------------------------------- #

# Group by most common words
uber_w <- uber_words %>% 
    dplyr::group_by(words) %>% 
    dplyr::summarise(n = n()) %>%
    arrange(desc(n))
    
grab_w <- grab_words %>% 
    dplyr::group_by(words) %>% 
    dplyr::summarise(n = n()) %>%
    arrange(desc(n))

 # Plot top words per brand
uber_tw <- uber_w[1:9,]
grab_tw <- grab_w[1:9,]
ggplot(uber_tw, aes(x=reorder(words, n), y=n, fill=factor(n))) + geom_bar(stat="identity") +
    ylab("Popularity of words, Uber") + xlab("Words") + 
    theme(legend.position = "none") + coord_flip() + 
    scale_fill_brewer(palette="Greys")
ggplot(grab_tw, aes(x=reorder(words, n), y=n, fill=factor(n))) + geom_bar(stat="identity") +
    ylab("Popularity of words, Grab") + xlab("Words") + 
    theme(legend.position = "none") + coord_flip() + 
    scale_fill_brewer(palette="Greens")

# ---------------------------------------------------------------------------- #

# Match words with AFINN score
grab_words <- left_join(grab_words, afinn_list, by= c("words" = "word")) # n=38,182
uber_words <- left_join(uber_words, afinn_list, by= c("words" = "word")) # n=45,392

# Calculate mean of each comments' word scores
uber_afinn <- uber_words %>%
    dplyr::group_by(message_ID) %>%
    dplyr::summarise(mean = mean(score, na.rm=TRUE)) # 2950
grab_afinn <- grab_words %>%
    dplyr::group_by(message_ID) %>%
    dplyr::summarise(mean = mean(score, na.rm=TRUE)) # 2899

# Convert NAN to 0
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))
uber_afinn[is.nan(uber_afinn)] <- 0 # 2950
grab_afinn[is.nan(grab_afinn)] <- 0 # 2899

# Independent samples two-tailed t-test
t.test(uber_afinn$mean, grab_afinn$mean)

# With original dictionary and score=0 only: p-value = 1.8e-14

# Join data back to frame
grab <- dplyr::left_join(grab, grab_afinn, by = "message_ID") 
uber <- dplyr::left_join(uber, uber_afinn, by = "message_ID")
grab[is.na(grab)] <- 0
uber[is.na(uber)] <- 0

# Plot bar charts
grab_boxplot <- grab %>%
    mutate(Month_num = month(DatetimeSG)) %>%
    subset(select=c(Month_num, mean)) %>%
    mutate(Company = "Grab")
uber_boxplot <- uber %>%
    mutate(Month_num = month(DatetimeSG)) %>%
    subset(select=c(Month_num, mean)) %>%
    mutate(Company = "Uber")

# Format decimal places, remove NAs
boxplots <- rbind(grab_boxplot, uber_boxplot)
boxplots$mean <- round(boxplots$mean, digits=2)
boxplots[is.na(boxplots)] <- 0

# Label month names
# Labels <- data.frame(num = c(3:9), Date = c("Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep"))
boxplots <- left_join(boxplots, Labels, by=c("Month_num" = "num")) 

# Boxplot per month by score
ggplot(data = boxplots, aes(x=reorder(factor(Date), Month_num), y=mean)) + 
    geom_boxplot(aes(fill=Company)) + 
    xlab("Month") +
    scale_y_continuous(name = "Rude   - - -   Polite",
                       breaks = seq(-5, 5, 1.0),
                       limits=c(-5, 5)) + 
    scale_fill_brewer(palette = "Accent") +
    theme(legend.position = "bottom") 

# ---------------------------------------------------------------------------- #
# Make smaller categories of terms

vNegTerms <- c(afinn_list$word[afinn_list$score==-5 | afinn_list$score==-4])
negTerms <- c(afinn_list$word[afinn_list$score==-3 | afinn_list$score==-2 |  afinn_list$score==-1])
posTerms <- c(afinn_list$word[afinn_list$score==3 | afinn_list$score==2 | afinn_list$score==1])
vPosTerms <- c(afinn_list$word[afinn_list$score==5 | afinn_list$score==4])

# Function to calculate number of words in each category within a sentence
library(plyr)
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
detach("package:plyr", unload=TRUE)

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
colnames(grab)[13:16] <- c("vNegTerms", "negTerms", "posTerms", "vPosTerms") 
colnames(uber)[13:16] <- c("vNegTerms", "negTerms", "posTerms", "vPosTerms") 

# Save data
write.csv(uber, file="uber_features.csv")
write.csv(grab, file="grab_features.csv")

# ---------------------------------------------------------------------------- #
# NB model

library(e1071)

# Pos Neg feature
uber$direction <- uber$vNegTerms*-5 + uber$negTerms*-2 + uber$posTerms*2 + uber$vPosTerms*5
grab$direction <- grab$vNegTerms*-5 + grab$negTerms*-2 + grab$posTerms*2 + grab$vPosTerms*5

# EXtract posts with labels
uber_lab <- uber[!is.na(uber$sentiment), ] #n=1,391
grab_lab <- grab[!is.na(grab$sentiment), ] #n=1,237

# Build naive bayes model -- note that it tests and trains on labelled data
classifier_g <- naiveBayes(grab_lab[,c(11:17)], grab_lab[,5])
classifier_u <- naiveBayes(uber_lab[,c(11:17)], uber_lab[,5])

# Predict & print results
predicted_g <- predict(classifier_g, grab_lab)
predicted_u <- predict(classifier_u, uber_lab)

results_g <- table(predicted_g, grab_lab[,5], dnn=list('predicted','actual'))
results_u <- table(predicted_u, uber_lab[,5], dnn=list('predicted','actual'))

# Binomial test for confidence intervals
binom.test(results_g[1,1] + results_g[2,2]+ results_g[3,3], nrow(grab_lab), p=0.5)
binom.test(results_u[1,1] + results_u[2,2]+ results_u[3,3], nrow(uber_lab), p=0.5)

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
#               results - uber, mean score incl
#           actual
# predicted  negative neutral positive
# negative      131      29       11
# neutral       238     749      140
# positive        7      16       70
#
# 95 percent confidence interval: 0.6577817 0.7073668
# sample estimates:
#     probability of success 
# 0.6829619 
##################################
#               results - grab, mean score incl
#           actual
# predicted  negative neutral positive
# negative       33       6       13
# neutral       162     698      222
# positive       12      12       79
#
# 95 percent confidence interval: 0.6275680 0.6813139
# sample estimates:
#     probability of success 
# 0.65481
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
