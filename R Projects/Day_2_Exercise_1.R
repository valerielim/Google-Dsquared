# Title: Day 2 Exercise 1 
# Date: 8 Aug 2017 
# Made by: Valerie Lim

# ----------------------------------- PREP ----------------------------------- #

library(dplyr)
library(lubridate)

# Import data using CAMPAIGN.CSV as tester file 
data <- read.csv("Campaign.csv")

# Clean up
options(stringsAsFactors = FALSE)
str(data)
View(data) # check if aligned
class(data) # check that it is a dataframe

# Merge 2 files
test1 <- read.csv("2016-01-01.csv")
test2 <- read.csv("2016-01-02.csv")
combi <- rbind(test1, test2)

# Merge all files
myMergedData <- do.call(rbind, lapply(list.files
    (path = "/Users/valerielim/Documents/Rfiles/Day 2 Exercise 1"), read.csv))
str(myMergedData)

# Check
View(myMergedData)
options(stringsAsFactors = FALSE)

# Separate Month
library(lubridate)
month(data$Date)

# Make month as new column, month_clean
data <- mutate(myMergedData, month_clean = month(myMergedData$Date))
str(data)

# --------------------- Exercise 1: Creating KPI Tables ---------------------- #

# Q1: Create a KPI table comparing the month-over-month (M-o-M) % changes from 
# May to June, across all countries and campaigns, for the following KPIs: 
# CPC cost per click
# CTR click through rate 
# CPM cost per thousand
# CPVP cost per viewed product 
# CPBP cost per bought product
# VTB view-to-buy rate

# Group by Month, CPC
CPC_full <- dplyr::summarize(group_by(data, month_clean), 
                                    total_cost = sum(Cost, na.rm=TRUE),
                                    total_clicks = sum(No.of.clicks, na.rm=TRUE),
                                    CPC = total_cost/total_clicks)
CPC_value <- dplyr::summarize(group_by(data, month_clean), 
                              CPC = sum(Cost, na.rm=TRUE)/sum(No.of.clicks, na.rm=TRUE))
CPC_value

# Group by Month, CTR
CTR_full <- dplyr::summarize(group_by(data, month_clean), 
                        total_cost = sum(Cost, na.rm=TRUE),
                        total_impressions = sum(Served.Impressions, na.rm=TRUE),
                        CTR = total_cost/total_impressions)

CTR_value <- dplyr::summarize(group_by(data, month_clean), 
                              CTR = sum(Cost, na.rm=TRUE)/sum(Served.Impressions, na.rm=TRUE))

CTR_value

# Group by Month, CPVP
CPVP_full <- dplyr::summarize(group_by(data, month_clean), 
                              total_cost = sum(Cost, na.rm=TRUE),
                              total_viewedprods = sum(No.of.products.viewed, na.rm=TRUE),
                              CPVP = total_cost/total_viewedprods)

CPVP_value <- dplyr::summarize(group_by(data, month_clean), 
                               CPVP = sum(Cost, na.rm=TRUE)/sum(No.of.products.viewed, na.rm=TRUE))

CPVP_value

# Group by Month, CPBP
CPBP_full <- dplyr::summarize(group_by(data, month_clean), 
                               total_cost = sum(Cost, na.rm=TRUE),
                               total_boughtprods = sum(No.of.product.bought, na.rm=TRUE),
                               CPBP = total_cost/total_boughtprods)

CPBP_value <- dplyr::summarize(group_by(data, month_clean), 
                              CPBP = sum(Cost, na.rm=TRUE)/sum(No.of.product.bought, na.rm=TRUE))
CPBP_value

# Group by Month, VTB
VTB_full <- dplyr::summarize(group_by(data, month_clean), 
                               total_viewedprods = sum(No.of.products.viewed, na.rm=TRUE),
                               total_boughtprods = sum(No.of.product.bought, na.rm=TRUE),
                               CPBP = total_viewedprods/total_boughtprods)

VTB_value <- dplyr::summarize(group_by(data, month_clean), 
                              VTB = sum(No.of.products.viewed, na.rm=TRUE)/
                                sum(No.of.product.bought, na.rm=TRUE))

VTB_value

# Merge KPIs to one table
finaldata <- left_join(CPC_value, CTR_value, by = c("month_clean"))
finaldata <- left_join(finaldata, CPVP_value, by = c("month_clean"))
finaldata <- left_join(finaldata, CPBP_value, by = c("month_clean"))
finaldata <- left_join(finaldata, VTB_value, by = c("month_clean"))
View(finaldata)

# Find % change in table 
finaldata <- t(finaldata) # transpose
finaldata <- as.data.frame(finaldata) # convert back to data frame
finaldata <- finaldata[,5:6] 
finaldata <- mutate(finaldata, working=((finaldata[,2]-finaldata[,1])/finaldata[,1])*100)
View(finaldata)

### NOTE
# Best to just get ugly data but be done with it 
# No need format until so nice 


