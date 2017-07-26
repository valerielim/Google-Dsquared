# Made by: Valerie
# Date: 25/07/2017
# Title: Text Cleaning & Preparation to Word Cloud

install.packages("NLP")
install.packages("tm")
install.packages("SnowballC")

library(SnowballC)
library(NLP)
library(tm)

# Load data (Here: Use Music Play.csv)
data_music <- read.csv(file.choose())
View(data_music)

# Read text column to new variable called comment1
comment1 <- data_music$Q2..What.do.you.like.least.about.this.portable.music.player.

# Preview first 6 comments
head(comment1)

# Create corpus, which can be processed by TM package.
# 1. Pass object to VectorSource to create a temporary source
# 2. Pass source through VCorpus to create corpus
vector1 <- VectorSource(comment1)
corpus1 <- VCorpus(vector1)

# Convert to LOWER before parsing stopwords
corpus1 <- tm_map(corpus1, content_transformer(tolower))

# Deal with stopwords
stopwords('english')  # View stopwords
myStopwords <- c(stopwords('english'), 'the', 'and', "hello", "world")  # Add SW
corpus1 <- tm_map(corpus1, removeWords, myStopwords)  # Remove SW

# Clean up the rest: Make lowercase, stem
corpus1 <- tm_map(corpus1, removePunctuation)
corpus1 <- tm_map(corpus1, removeNumbers)
corpus1 <- tm_map(corpus1, stemDocument)
corpus1 <- tm_map(corpus1, stripWhitespace)

# ----------------------------------- DTM ----------------------------------- #

# Generate Frequency Count matrix
doc <- corpus1
dtm <- DocumentTermMatrix(doc)
m1 <- as.matrix(dtm)

?DocumentTermMatrix
# 2. Generate Tf-Idf matrix
dtm2 <- DocumentTermMatrix(doc, control=list(weighting=function(x) 
    weightTfIdf(x, normalize=FALSE)))
m2 <- as.matrix(dtm2)

# 3. Generate dtm Binary
dtm3 <- DocumentTermMatrix(doc, control=list(weighting=weightBin))
m3 <- as.matrix(dtm3)

# 4. Count frequency of each column 
freq <- colSums(as.matrix(dtm))

# 5. Count length of columns
length(freq)

# 6. Sort frequency in decreasing order; longest columns first
sor <- sort(freq, decreasing=TRUE)
head(sor)  # print top 6 most frequent words

# Optional: save output to excel
m <- as.matrix(dtm)
dim(m)
write.csv(m, file="dtml1.csv")

# Optional: subset & sort in decreasing order
# Note: Subset selects all words that appear more than 20 times
subfreq <- subset(freq, freq>20)
subfreq <- sort(subfreq, decreasing = TRUE)

# Make to dataframe for word cloud
dffreq <- data.frame(term=names(subfreq), fre=subfreq)
View(dffreq)

?data.frame

# --------------------------------- GRAPHICS --------------------------------- #

# install.packages("RColorBrewer")
# install.packages("wordcloud")

library(RColorBrewer)
library(wordcloud)
library(ggplot2)

ggplot(dffreq, 
       aes(x=dffreq$term, 
           y=dffreq$fre))+geom_bar(stat="identity")+coord_flip()


whatisaid <- brewer.pal(6, "Paired")  # colour-group name
wordcloud(names(freq), freq, min.freq=10)
wordcloud(names(freq), freq, max.words = 100, rot.per=0.6, colors=whatisaid)


# To display all colours in Brewer palette
?brewer.pal
display.brewer.all(n=NULL, type="all", select=NULL)


# View first 6 objects
for(i in 1:6){
  print(corpus1[[i]][1])
}


