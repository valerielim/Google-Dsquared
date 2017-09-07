# Title: Day 2 Exercise 2
# Date: 8 Aug 2017 
# Made by: Valerie Lim

# ----------------------- Exercise 2: Solving BI Qns ------------------------- #

# Q: What are the top 3 channels by lowest CPC for the Singapore market 
# on mobile device?

# filter for country, device type
sgdata <- filter(campaignData, Country == 'singapore')
sgdata <- filter(sgdata, Device == 'mobile')

# summarise by channel
sgdata_channel <- summarize(group_by(sgdata, Channel),
                            CPC = sum(Cost)/sum(No.of.clicks))

# Top 3
sgdata_channel <- arrange(sgdata_channel, desc(CPC))

# Q: What is the difference in Cost Per Viewed Product (CPVP) in the month 
# of MAY on Desktop device, between SALES and non-SALES campaigns? 

# Group by Month, CPVP, Country, Device
CPVP_sg_desktop <- filter(data, month_clean == 5, Device == "desktop")

# Make new column stating category
CPVP_sg_desktop$category <- ifelse(grepl("sales", ignore.case=TRUE, CPVP_sg_desktop$Campaign), 
                                   "Sales", "Non-sales")

CPVP_sg_desktop <- summarise(group_by(CPVP_sg_desktop, category),
                             CPVP = sum(Cost)/sum(No.of.products.viewed))

View(CPVP_sg_desktop)

# Q: What is the most effective channel in driving view-to-buy rate 
# of product in May filtered for Malaysia market? (Which channel has the 
# highest view-to-buy rate in Malaysia in May?)

VTB_msia_mobile <- filter(data, month_clean == 5, Country == "malaysia")

VTB_msia_mobile <- summarise(group_by(VTB_msia_mobile, Channel),
                             VTB = sum(No.of.product.bought, na.rm=TRUE)/
                                 sum(No.of.products.viewed, na.rm=TRUE))

View(VTB_msia_mobile)

# Q: For each campaign, which countries have the highest number of unique 
# placements for the "Display" channel? Note: exclude duplicate dates. 

Disp_place <- filter(data, Channel == 'display')

# Remove all duplicates of country, campaign, placement combinations
Disp_place <- Disp_place[!duplicated(Disp_place[c("Country", "Campaign", "Placement")]),]

# Sort to group by campaign & country, count number
Disp_place <- summarise(group_by(Disp_place, Campaign, Country),
                        placementCount = n())


View(Disp_place)

# ------------------------- EXPORT TO GOOGLE SHEETS -------------------------- #

# Export results to Google sheets

library(googlesheets)

gkey <- "18OE1ra2jAPqR-3jAquUUT0ZWoDp7HORf4Ve84WGvcAQ" 
# Copy this from desired Gsheets URL tail
gs_auth() 
raw_data_sheet <- gs_key(gkey)

# Rmb to edit file name, sheet name, input name. 
gs_edit_cells(raw_data_sheet, ws = "Sheet1", input = finaldata, anchor = "A1", 
              byrow = FALSE, col_names = NULL, trim = FALSE, verbose = TRUE)


########################################################################

# Extras - Unnecessary reconfig exercise for DATES
# WHAT A BITCH
# Lubridate can't recognise actual date-month-year columns 
# so I manually relabelled them
revenue <- mutate(revenue, Month = month(revenue$Date), 
                  Year = year(revenue$Date),
                  Day = day(revenue$Date))

# Add 20-16 in front of year
revenue$Year <- sub("^", "20", revenue$Year)
revenue$Year <- sub("^", "0", revenue$Month)
revenue <- mutate(revenue, Date_clean = paste(revenue$Year, revenue$Month, revenue$Day, sep="-"))

########################################################################

# Load revenue file 
revenue <- read.csv("Revenue.csv")

# Check revenue file, numbers should be integers
options(stringsAsFactors = FALSE)
View(revenue)
str(revenue)

# Join files as 'revdata'
revdata <- left_join(data, revenue, by = c("Date", "Campaign"))
str(revdata)
View(revdata)

# Group revenue by Campaign
revdata <- summarize(group_by(revdata, Campaign, Date), 
                     totalCost = sum(Cost),
                     totalImpressions = sum(Impressions),
                     totalRevenue)

geom_point(data = iris, na.rm = TRUE, show.legend = NA,
           inherit.aes = TRUE)
