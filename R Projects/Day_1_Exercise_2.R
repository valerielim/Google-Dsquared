# Made by: Valerie Lim
# Date: 17 July 2017
# Title: Working exercise R

# ---------------------------------- Start ---------------------------------- #

# Load WEB_DATA.CSV 
data <- read.csv(file.choose())
View(data)
str(data)

install.packages("googleVis")
install.packages("dplyr")
library(dplyr)
library(googleVis)

# Q1: What is the date range of this dataset?
dates <- select(data, Date)
unique(dates)
# Ans: Seems like there's only 1 unique date: 2016-06-01.

# Q2: What are the unique countries involved?
country <- select(data, Country)
unique(country)
# Ans: Sg, Malaysia, Thailand, Indonesia

# Q3: What is the total number of pageviews that the website has received?
total_pageviews <- summarize(data, Pageviews=sum(Pageviews, na.rm=TRUE))

# Q4: What is the total number of pageviews that the website has been receiving 
# per country? 
total_pageviews_Country <- summarize(group_by(data, Country), 
                                     Pageviews=sum(Pageviews, na.rm=TRUE))
total_pageviews_Country <- arrange(total_pageviews_Country, desc(Pageviews))

# Q5: Plot column
columnChart <- gvisColumnChart(total_pageviews_Country)
plot(columnChart)

# Q6: How many transactions are there on each day?
transactions <- filter(data, !is.na(TransactionID))
transactions <- select(transactions, TransactionID)
transactionData <- unique(transactions)
no_of_transactions <- count(transactionData)

# Q7: How many unique transactions per country?
transactions <- filter(data, !is.na(TransactionID))
transactions <- transactions[!duplicated(transactions$TransactionID), ]
transactions <- summarize(group_by(transactions, Country), 
                          transactionCount =n())

# Q8: How many transactions by page views? 
joined_data <- left_join(total_pageviews_Country, transactions, by="Country")
joined_data <- mutate(joined_data, 
                      transactionFactor = transactionCount/total_pageviews)

# ---------------------------------- JOINS ---------------------------------- #

# Load CRM data
crmData <-read.csv(file.choose())
names(crmData)[1] <- 'TransactionID'

# Prep transaction data by removing NA rows
transactions <- filter(data, !is.na(TransactionID))
transactions <- transactions[!duplicated(transactions$TransactionID), ]

# Join
joined_data <- left_join(transactions, crmData)

# Q10: Which gender has more transactions?
gender_analysis <- summarize(group_by(joined_gender, Gender), 
                             transactions = n())

# Visuals
pieChart <- gvisPieChart(gender_analysis, 
                         options = list(width = 400, height = 400))
plot(pieChart)

# Summarise transactions by Gender and Country
gender_analysis <- summarize(group_by(gender_analysis, Country, Gender),
                             Pageviews = sum(Pageviews, na.rm=TRUE),
                             Transactions = n())

