# Made by: Valerie Lim
# Date: ??
# Title: Analytics Applications with R, using Campaign data as testset


# ---------------------------- Media Metrics ---------------------------- #

install.packages('dplyr')
install.packages('googleVis')
install.packages('lubridate')
library(dplyr)

data <- read.csv("Campaign.csv")
options(stringsAsFactors = FALSE)
str(data)

# Separate Month from datetime var
library(lubridate)
month(data$Date)
data <- mutate(data, month_clean = month(data$Date))

# Group by Month, calculate CPC
total_cost_date <- dplyr::summarize(group_by(data, month_clean), 
                        total_cost = sum(data$Cost, na.rm=TRUE),
                        total_clicks = sum(data$No.of.clicks, na.rm=TRUE),
                        CPC = total_cost/total_clicks)

# Merge files
test1 <- read.csv("2016-01-01.csv")
test2 <- read.csv("2016-01-02.csv")
combi <- rbind(test1, test2)

# Merge 365 files
myMergedData <- do.call(rbind, lapply(list.files
                (path = "/Users/valerielim/Documents/Rfiles/Day 2 Exercise 1"), 
                read.csv))
View(myMergedData)
options(stringsAsFactors = FALSE)

# -------------------------------- Exercise 1 -------------------------------- #

# Q1: Create a KPI table comparing the month-over-month (M-o-M) % changes from 
# May to June, across all countries and campaigns, for the following KPIs: 
# CPC cost per click
# CTR click through rate 
# CPM cost per thousand
# CPVP cost per viewed product 
# CPBP cost per bought product
# VTB view-to-buy rate


# Make month as new column, month_clean
data <- mutate(myMergedData, month_clean = month(myMergedData$Date))
View(data)

# Group by Month, CPC
CPC_full <- dplyr::summarize(group_by(data, month_clean), 
                                total_cost = sum(Cost, na.rm=TRUE),
                                total_clicks = sum(No.of.clicks, na.rm=TRUE),
                                CPC = total_cost/total_clicks)
CPC_value <- dplyr::summarize(group_by(data, month_clean), 
                      			CPC = sum(Cost, na.rm=TRUE)/sum(No.of.clicks, 
                                                            na.rm=TRUE))
CPC_value

# Group by Month, CTR
CTR_full <- dplyr::summarize(group_by(data, month_clean), 
                        total_cost = sum(Cost, na.rm=TRUE),
                        total_impressions = sum(Served.Impressions, na.rm=TRUE),
                        CTR = total_cost/total_impressions)

CTR_value <- dplyr::summarize(group_by(data, month_clean), 
                              CTR = sum(Cost, na.rm=TRUE)/sum(Served.Impressions, 
                                                              na.rm=TRUE))
CTR_value

# Group by Month, CPVP
CPVP_full <- dplyr::summarize(group_by(data, month_clean), 
                              total_cost = sum(Cost, na.rm=TRUE),
                              total_viewedprods = sum(No.of.products.viewed, 
                                                      na.rm=TRUE),
                              CPVP = total_cost/total_viewedprods)

CPVP_value <- dplyr::summarize(group_by(data, month_clean), 
								CPVP = sum(Cost, na.rm=TRUE)
								/sum(No.of.products.viewed, na.rm=TRUE))
CPVP_value

# Group by Month, CPBP
CPBP_full <- dplyr::summarize(group_by(data, month_clean), 
                               total_cost = sum(Cost, na.rm=TRUE),
                               total_boughtprods = sum(No.of.product.bought, 
                                                       na.rm=TRUE),
                               CPBP = total_cost/total_boughtprods)

CPBP_value <- dplyr::summarize(group_by(data, month_clean), 
                              CPBP = sum(Cost, na.rm=TRUE)
                              /sum(No.of.product.bought, na.rm=TRUE))
CPBP_value

# Group by Month, VTB
VTB_full <- dplyr::summarize(group_by(data, month_clean), 
                               total_viewedprods = sum(No.of.products.viewed, 
                                                       na.rm=TRUE),
                               total_boughtprods = sum(No.of.product.bought, 
                                                       na.rm=TRUE),
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
finaldata <- mutate(finaldata, working=((finaldata[,2]-finaldata[,1])
                                        /finaldata[,1])*100)
View(finaldata)


# Export csv data to Google Sheets

library(googlesheets)

# Copy the key from desired Gsheets URL
gkey <- "18OE1ra2jAPqR-3jAquUUT0ZWoDp7HORf4Ve84WGvcAQ" 
gs_auth() 

# Pass to function
raw_data_sheet <- gs_key(gkey)

# Rmb to edit file name, sheet name, input name. 
gs_edit_cells(raw_data_sheet, ws = "Sheet1", input = finaldata, 
				anchor = "A1", byrow = FALSE,
              	col_names = NULL, trim = FALSE, verbose = TRUE)

# -------------------------------- Exercise 2 -------------------------------- #


# Q: What is the difference in Cost Per Viewed Product (CPVP) in the month 
# of MAY on Desktop device, between SALES and non-SALES campaigns? 

# Group by Month, CPVP, Country, Device
CPVP_sg_desktop <- filter(data, month_clean == 5, Device == "desktop")

# Make new column stating category
CPVP_sg_desktop$category <- ifelse(grepl("sales", ignore.case=TRUE, 
                                         CPVP_sg_desktop$Campaign), 
                                   "Sales", "Non-sales")

CPVP_sg_desktop <- summarise(group_by(CPVP_sg_desktop, category),
                           CPVP = sum(Cost)/sum(No.of.products.viewed))

View(CPVP_sg_desktop)

# -------------------------------- Exercise 3 -------------------------------- #

# Q: What is the most effective channel in driving view-to-buy rate 
# of product in May filtered for Malaysia market? (Which channel has the 
# highest view-to-buy rate in Malaysia in May?)

VTB_msia_mobile <- filter(data, month_clean == 5, Country == "malaysia")

VTB_msia_mobile <- summarise(group_by(VTB_msia_mobile, Channel),
                             VTB = sum(No.of.product.bought, na.rm=TRUE)/
                               sum(No.of.products.viewed, na.rm=TRUE))

View(VTB_msia_mobile)

# -------------------------------- Exercise 4 -------------------------------- #

# Q: For each campaign, which countries have the highest number of unique 
# placements for the "Display" channel? Note: exclude duplicate dates. 

Disp_place <- filter(data, Channel == 'display')

# Remove all duplicates of country, campaign, placement combinations
Disp_place <- Disp_place[!duplicated(Disp_place[c("Country", "Campaign", 
                                                  "Placement")]),]

# Sort to group by campaign & country, count number
Disp_place <- summarise(group_by(Disp_place, Campaign, Country),
                        placementCount = n())


View(Disp_place)
