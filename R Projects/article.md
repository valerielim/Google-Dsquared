# Locals more polite towards Grab than Uber

### Introduction

I'm currently enrolled in 
[Google's Squared Data & Analytics program](https://sites.google.com/site/squareddataandanalytics/ "Squared Data Program")
where I've become very interested in analysing human behavior through machine learning. 
Coming from a background in Psychology, I've spent 1.5 years [working](http://blog.nus.edu.sg/psychology/ "Psychology Department Blog") 
in [behavioral research labs](http://www.fas.nus.edu.sg/psy/current/grad_research/research.html "Areas of Research in Psychology, NUS") 
around the National University of Singapore, 
but never had the means to explore with more powerful tools. This program trained me with 
skills on Python and R programming that let me test and scale my analysis more rigorously 
on larger, more varied datasets to perhaps uncover more interesting things. I was giddy with
new-found power, I mean, excitement.

An opportunity came to apply my skills under my industrial attachment to 
[MindShare](http://www.wpp.com/wpp/companies/mindshare/ "Mindshare"), 
a global media agency within the large GroupM/WPP family. The company had acquired exclusive rights 
to use [Facebook's (beta) API](https://developers.facebook.com/docs/graph-api/ "Facebook API Documentation") 
in Singapore, bringing in near unlimited access to volumes of public data for social listening projects. 
However, while they had ETL processes built in for other mature sources, no one had created any for Facebook 
yet as it was pretty new. I spoke to my director and volunteered to work on the data.

A few days later,  my colleagues and I had a debate over lunch on which ride-hailing company was 
more popular - Uber or Grab. Thanks to [Travis' smooth moves](https://www.wired.com/story/timeline-uber-crises/ "Timeline of Uber Crises"), 
Uber has a more negative company image in recent months. But has this really affected Singaporeans' attitude towards Uber/Grab? 
Or are we just an apathetic, price conscious lot? I realised there was now a great way to find out. 
I decided on a project that would consolidate my learning so far in all these areas: R, statistics, 
sentiment analysis and data mining, and classification algorithms. 

### Quick Summary 

**Here was my (very) basic approach:**

* Mine data from Grab & Uber through Facebook API (SG only)
* Build training set, `n=400` (10%) out of 4000+ lines
* Train and test classification algorithms based on the data
* Based on sentiment, plot which company is more popular

My initial attempt at sentiment analysis using raw text alone failed miserably. NLP is a notoriously 
difficult area due to [double-negative syntax](https://en.wikipedia.org/wiki/Double_negative, "Double Negatives"), 
[detecting sarcasm](https://stackoverflow.com/questions/14097388/can-an-algorithm-detect-sarcasm "Sarcasm Detection"),
and [inconsistencies](http://sentic.net/singlish-sentic-patterns.pdf, "NLP For Singlish") 
with the lexicon of local lingua. On my first attempt, my naive bayes machine scored only `27.5%` 
accuracy at two-factor classification (avg: 50%). It was so pathetic it was kind of funny. 

However, my mentor back at Google encouraged me to continue working. He gave me feedback on my 
ideas, and challenged me to take up Kaggle competitions to improve my experience in machine learning. 
Through self-learning, I came across [several excellent papers](www.google.com "placeholder") 
on feature engineering in improving classification algorithms, which inspired me to try engineering 
some of my own, and ultimately re-attempt the problem.

This second* attempt was more successful, with my improved classifiers scored `~70%` accuracy on trinary 
classifications (avg: 33%), and `~90%` on binary classifications. I also found out some funny things 
about Grab and Uber's customers. 

**Here is my (still very) basic approach:**

* Mine data from Grab & Uber through Facebook API (SG only)
* Enlarge training set, `n=1200` (30%) out of 4000+ lines 
* Engineer numerical features for valences in sentiment
* Engineer other features for datetime, length
* Adapt `AFINN` dictionary to include local lexicon
* Train and test classification algorithms based on the data
* Based on sentiment, plot which company is more popular

> This post will be peppered with R code for this project. For brevity's sake, I only include code 
analysing Grab but I've ran the exact same functions on the Uber dataset. To view the code 
for both sets, and to view it all at once, check it out on Github. To skip to the conclusion, click here. 

### Methodology

Load up data into your workspace, drop unnecessary columns and give the rest consistent names.

```R
# Load data 
grab <- read.csv(file.choose())
options(stringsAsFactors = FALSE)

# Keep only relevant cols, rename them
grab <- subset(grab, select = c(1,2,3,4,5,6))
names(grab) <- c("creation_time", "post_username", "post_ID", "post_comment", "message_ID", "sentiment")
```

Build feature for number of words as `wordcount`. Remove non-ASCII characters from strings.

```R
library(stringr)
# Count number of words per comment
grab$wordcount <- str_count(grab$post_comment, '\\s+')+1

# Remove non-ASCII characters in comments, usernames
grab$post_comment <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", "", grab$post_comment)
grab$post_username <- gsub("[^0-9A-Za-z\\\',!?:;.-_@#$%^&*()\" ]", "", grab$post_username)
```

Build feature for sentiment score. 

To build scores, I've chosen the `AFINN` dictionary, which has a list of emotive words 
and their scores corresponding to how positive `+5` or negative `-5` they are. 
For instance, `bullshit` is rated `-4` while `terrific` is rated `4`. 

I've modified it very slightly for this data set (e.g, `charged` was initially `-2` but I've reset 
it to `0` as many riders talk about being charged for rides in a neutral sense), 
and added some swear words.

```R
# Load word files 
afinn_list <- read.delim(file='AFINN-111.txt', header=FALSE, stringsAsFactors=FALSE);afinn_list
names(afinn_list) <- c('word', 'score')
afinn_list$word <- tolower(afinn_list$word)

# Check if word exists & return score: (reuse this!) If word exists in list, modify score, else add word to list. 
afinn_list$score[afinn_list$word=="YOURWORDHERE"]

# Modify scores (for words already in AFINN)
afinn_list$score[afinn_list$word %in% c("love", "best", "nice")] <- 4
afinn_list$score[afinn_list$word %in% c("charges", "charged", "joke", "improvement")] <- 0
afinn_list$score[afinn_list$word %in% c("irresponsible")] <- -1
afinn_list$score[afinn_list$word %in% c("cheat", "cheated", "frustrated", "scam", "pathetic",
                                        "useless", "dishonest", "tricked", "hopeless",
                                        "waste", "gimmick", "liar", "lied")] <- -4

# Add scores (for words not in AFINN)
pos4 <- data.frame(word = c("bagus", "yay", ":)", "kindly", "^^", "yay", "swee", "awesome", "steadi"), score = 4)
pos2 <- data.frame(word = c("jiayou", "lol", "haha", "assist", "thnks", "thnk", "thx", "bro", "pls",
                            "amin", "amen", "free", "supper", "dating", "arigato"), score = 2)
neg1 <- data.frame(word = c(":(", "silly", "cringe", "zzz", "picky"), score = -1)
neg2 <- data.frame(word = c("jialat", "waited", "waiting", "rubbish", "lousy", "siao", "??", "-_-", "-.-", 
                            "lying", "lies", "wtf", "wts", "sicko", "slap", "slapped"), score = -2)
neg4 <- data.frame(word = c("freaking", "!!!", "knn", "ccb", "?!", "!?", "fk", "fking", "moronic"), score = -4)

# Merge changes with main AFINN list
afinn_list <- rbind(afinn_list, pos4, pos2, neg1, neg2, neg4)
```

Next, I matched word scores with words, and calculate average score per comment. For this, 
I verified that each `message_ID` is the unique key of each comment, while `post_ID` 
is the key of the parent comment in that thread. To keep the post short, I only present code for
analysing Grab, and repeat the same functions for Uber. To view the full set of both, please 
refer to the Github doc.

```R
library(tidytext)

# Prep for transformation: adjust data types and create new dataframe
grab_words <- subset(grab, select = c(post_comment, message_ID))
grab_words <- transform(grab_words, message_ID = as.factor(message_ID),  post_comment = as.character(post_comment))

# Split comments to single words per cell
grab_indv <- strsplit(grab_words$post_comment, split = " ") 

# Relink single words back to main comment, "message_ID"
grab_words <- data.frame(message_ID = rep(grab_words$message_ID, sapply(grab_indv, length)), words = unlist(grab_indv)) 
grab_words$words <- tolower(grab_words$words)

# Customise then remove all stopwords
library(tm)
stop_words <- as.data.frame(stopwords("en"))
more_stopwords <- as.data.frame(c("uber", "grab")) # add more if you want
names(stop_words)[1] <- "words"
names(more_stopwords)[1] <- "words"
stop_words <- rbind(stop_words, more_stopwords)
grab_words <- grab_words[!(grab_words$words %in% stop_words$words),]
detach("package:tm", unload=TRUE)

# Remove punctuation, empty rows
grab_words <- transform(grab_words, words = (sub("^([[:alpha:]]*).*", "\\1", grab_words$words)))
grab_words <- grab_words[(!grab_words$words==""),]

# Match words with AFINN score
library(dplyr)
grab_words <- left_join(grab_words, afinn_list, by= c("words" = "word"))

# Calculate mean of each comments' scores
grab_afinn <- grab_words %>%
    group_by(message_ID) %>%
    summarise(mean = mean(score.y, na.rm=TRUE)) 

# Convert NAN to 0 
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))
grab_afinn[is.nan(grab_afinn)] <- 0

# Independent samples two-tailed t-test
t.test(uber_afinn$mean, grab_afinn$mean)

# Merge back with dataframe, keep comment values
grab <- left_join(grab, grab_afinn, by = "message_ID")

detach("package:tidytext", unload=TRUE)
detach("package:dplyr", unload=TRUE)
```

> Print output of T-test, put t-test graph here!

Since we're at it, I decided to cluster and count the number of positive and negative words 
in each comment. Following a cool post by Andy Bromberg, the function looks like this:

```R
library(plyr)

vNegTerms <- c(afinn_list$word[afinn_list$score==-5 | afinn_list$score==-4])
negTerms <- c(afinn_list$word[afinn_list$score==-3 | afinn_list$score==-2 |  afinn_list$score==-1])
posTerms <- c(afinn_list$word[afinn_list$score==3 | afinn_list$score==2 | afinn_list$score==1])
vPosTerms <- c(afinn_list$word[afinn_list$score==5 | afinn_list$score==4])
              
# Function to calculate number of words in each category within a sentence
sentimentScore <- function(sentences, vNegTerms, negTerms, posTerms, vPosTerms){
    final_scores <- matrix('', 0, 5)
    scores <- plyr::laply(sentences, function(sentence, vNegTerms, negTerms, posTerms, vPosTerms){
        initial_sentence <- sentence
        sentence <- gsub('[[:punct:]]', '', sentence)
        sentence <- gsub('[[:cntrl:]]', '', sentence)
        sentence <- gsub('\\d+', '', sentence)
        sentence <- tolower(sentence)
        wordList <- str_split(sentence, '\\s+')
        words <- unlist(wordList)
        vPosMatches <- match(words, vPosTerms)
        posMatches <- match(words, posTerms)
        vNegMatches <- match(words, vNegTerms)
        negMatches <- match(words, negTerms)
        vPosMatches <- sum(!is.na(vPosMatches))
        posMatches <- sum(!is.na(posMatches))
        vNegMatches <- sum(!is.na(vNegMatches))
        negMatches <- sum(!is.na(negMatches))
        score <- c(vNegMatches, negMatches, posMatches, vPosMatches)
        newrow <- c(initial_sentence, score)
        final_scores <- rbind(final_scores, newrow)
        return(final_scores)
    }, vNegTerms, negTerms, posTerms, vPosTerms)
    return(scores)
}

# Convert and apply function
grab_vec <- as.vector(grab$post_comment)
grab_scores <- as.data.frame(sentimentScore(grab_vec, vNegTerms, negTerms, posTerms, vPosTerms))
colnames(grab_scores) <- c('post_comment', 'vNegTerms', 'negTerms', 'posTerms', 'vPosTerms')
grab_scores <- transform(grab_scores, 
                         vNegTerms = as.numeric(vNegTerms),
                         negTerms = as.numeric(negTerms),
                         posTerms = as.numeric(posTerms),
                         vPosTerms = as.numeric(vPosTerms))

# Recombine with main data set
grab <- cbind(grab, grab_scores$vNegTerms, grab_scores$negTerms, 
               grab_scores$posTerms, grab_scores$vPosTerms)

```
Phew. I am finally ready to throw it into the machine. 

> Print tibble of what data should look like

### Results

For results, I split them into two classifiers: `naive bayes` and `maxent`. 

```R
library(e1071)

# Build naive bayes model -- note that it tests and trains on ALL data
classifier_nb <- naiveBayes(labelled_data[,c(2:5, 8, 10)], labelled_data[,9])

# Predict & print results
predicted_nb <- predict(classifier_nb, labelled_data)
results_nb <- table(predicted_nb, labelled_data[,9], dnn=list('predicted','actual')); results_nb

# Binomial test for confidence intervals
binom.test(results_nb[1,1] + results_nb[2,2]+ results_nb[3,3], nrow(labelled_data), p=0.5)
```

### Discussion





### A note on Feature Engineering

First, through reading [this journal](http://sentic.net/singlish-sentic-patterns.pdf) which found a unigram 
splitting + SVM machine approach worked best for Singlish classification, and [this paper] which reported poor performance on 
bigram splitting, I found that attempting POS tagging for Singlish syntax does not appear to be as effecitve 
and did not attempt it for this paper. Also, I'm not sure how to do it. 

Second, although I have engineered features for `day of week` and `time of comment`, these datetime features 
did not significantly improve the accuracy of my classifier model (measured by stepwise regression) and hence 
I left them out in the discussion. Functions for building these features from data from the Facebook API are 
still available for use in my full code found on Github. 

Third, I chose to use `Naive Bayes` and `Max Entropy` classifiers as they performed best on this dataset. This is 
surprising considering others have found better performance on `SVM` machines. However, this is a blog post, not 
an academic paper, so I won't really go investigate why. If you have thoughts on this, please share them and I'd be 
happy to discuss. I'm still learning and appreciate helpful guidance :-)

