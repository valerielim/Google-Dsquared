# Task: Extract Reddit data from single keyword to all child comments

# 1. Construct URL params for API query
# 2. Call API for json data
# 3. Convert json data to csv file
# 4. Clean csv file to get list of post IDs
# 5. Extract comments and details for each post ID
# 6. Store comment data as csv file. 

# ---------------------------------------------------------------------------- #
# 1. Construct URL params for API query

import os

# Set up workspace
path = 'C:\\Users\\valeriehy.lim\\Documents\\PythonDocs'
os.chdir(path)
print "#1. Set directory to", path

# Search keywords
print
print "# ------------------------------------------------ #"
print "#2. REDDIT QUERY DIMENSIONS"
keyword_input = ['jaguar']
keyword_list = "+".join(keyword_input)
print "Keyword is:", keyword_list

# Subreddit input
subreddits_label = "subreddit:"
subreddits_input = ['Jaguar', 'Jaguars', 'cars', 'jaguarcars', 'carporn', 
                'cars', 'autos', 'spotted', 'formula1', 'classiccars',
                'Shitty_Car_Mods'] # Not case sensitive
subreddits_list = "+".join(subreddits_input)
print "Subreddits are:", subreddits_input

# T (time) options: //hour, day, week, month, year, all//
time_label = "&t="
time_input = "all"
print "Time frame is:", time_input

# SORT options: //relevance, hot, top, new, comments//
sort_label = "&sort="
sort_input = "new"
print "Sort frame is:", sort_input

# LIMIT options: must be digits, keep enclosed within " "
limit_label = "&limit="
limit_input = "9999999" # default: max
print "Limit range is:", limit_input

# Frame (don't edit this)
start = 'http://www.reddit.com/r/'
middle = '/search.json?q='
end = '&restrict_sr=TRUE' # search only this subreddit(s)

# Assemble it
full_link = "%s%s%s%s%s%s%s%s%s%s%s" % (start,
 subreddits_list, middle, keyword_list, time_label, time_input,
 sort_label, sort_input, limit_label, limit_input, end)
print
print "The query is:", full_link
print "# ------------------------------------------------ #"
print

# ---------------------------------------------------------------------------- #
# 2. Call API for json data

import urllib2
import json
import yaml
import fileinput

print "#3. Calling API for above query..."
print 
response = urllib2.urlopen(full_link)
print "Call successful."
print "Loading response into local environment..."
print 
data = json.load(response)
clean_data = json.dumps(data)
cleaner_data = yaml.safe_load(clean_data) # a long dict, only 4 global env
print "Response data load completed."
print 

# Save file
print "#4. Saving response as JSON file..."
txt_file_name = 'uglyjson.txt'
myfile = open(txt_file_name, 'w' )
myfile.write(clean_data)
myfile.close()
print "Complete."
print 
print "File saved as", txt_file_name, "in location", path
print "# ------------------------------------------------ #"
print

# ---------------------------------------------------------------------------- #
# 3. Convert json data to csv file

# pip install selenium first
# install chromedriver.exe too

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait 
from selenium.webdriver.support import expected_conditions as EC

print "#5. Loading selenium with chrome driver for conversion..."
print
chrome = webdriver.Chrome()
chrome.get('https://json-csv.com/')
load_data = chrome.find_element_by_id('fileupload')

print "Uploading JSON file for conversion..."
print
# file_location = "%s\\%s" % (path, txt_file_name)
load_data.send_keys('C:\\Users\\valeriehy.lim\\Documents\\PythonDocs\\uglyjson.txt')

# Download converted csv
print "Waiting for file conversion to be complete..."
print 
wait = WebDriverWait(chrome, 10)
import sys 
for i in xrange(10,0,-1): # Prints countdown from 10 9 8 ...
    time.sleep(1)
    sys.stdout.write(str(i)+' ')
    sys.stdout.flush()
wait.until(EC.element_to_be_clickable((By.ID, 'convert-another')))
chrome.find_element_by_css_selector("a#download-link.btn-lg.btn-success").click()
time.sleep(10) # To allow time to finish downloading
chrome.quit()
print 
print "Csv file downloaded, location at DOWNLOADS folder."
print "# ------------------------------------------------ #"
print

# ---------------------------------------------------------------------------- #
# 4. Clean csv file to get list of post IDs

import pandas as pd
import os
import glob

downloads_folder = 'C:\\Users\\valeriehy.lim\\Downloads'
file_type = '*.csv'
files_to_sort = glob.glob('%s\\%s' % (downloads_folder, file_type) )

latest_file = max(files_to_sort, key=os.path.getctime)
file_name = str(latest_file[33:])
print "#6. Reading csv file with reddit posts from:", file_name
print 

data = pd.read_csv(latest_file)
ID_list = data['data__children__data__id'].tolist()
ID_list = [x for x in ID_list if str(x) != 'nan']
num_IDs = len(ID_list)
print "#Extracting list of relevant reddit post IDs:"
print ID_list
print
print "There were", num_IDs, "valid posts in this query."
print 

# ---------------------------------------------------------------------------- #
# 5. Extract comments and details for each post ID

import praw
import requests
import requests.auth
import pandas as pd
from praw.models import MoreComments

from tqdm import * 
import pprint
pp = pprint.PrettyPrinter(indent=2)

# Passwords
Username = 'lonely_dingleberry'
Password = 'Passw0rd!1'
Client_ID = 'cOuv_433uGowhg'
Client_secret = 'Lck5D8FGEiDyrngC6_mgODA5yXU'

# Auth
print "Preparing reddit authentication to extract comment details per post..."
reddit = praw.Reddit(user_agent='Testing stuff for school project (by /u/lonely_dingleberry)',
                     client_id=Client_ID, client_secret=Client_secret,
                     username=Username, password=Password)
print "Done."
print

# Date
import datetime
def get_date(submission):
    time = submission.created
    return datetime.datetime.fromtimestamp(time)
    # Source: https://www.reddit.com/r/learnprogramming/comments/37kr5n/praw_is_it_possible_to_get_post_time_and_date/

# Extraction function
def get_comments(ID_list):
    
    # Empty df to store comments as returned in loop below
    holder = pd.DataFrame()
    # Extract comment, author and date for each post
    for post_ID in tqdm(ID_list):
        # Source: https://praw.readthedocs.io/en/v5.2.0/tutorials/comments.html#extracting-comments-with-praw
        print "Reading post", post_ID 
        submission = reddit.submission(id=post_ID)
        submission.comments.replace_more(limit=0) # get ALL child comments
        c_comments = []
        c_authors = []
        c_date = []
        
        for comment in submission.comments.list():
            print "Extracting data for comment:", comment
            c_comments.append(comment.body)
            c_authors.append(comment.author)
            c_date.append(str(get_date(comment)))

        # Bind data to table
        c_headers = [["Comment", "Author", "Date"]]
        for C, A, D in zip(c_comments, c_authors, c_date):
            c_headers.append([C, A, D])

        # Add labels to identify which comments belong to which post
        c_table = pd.DataFrame(c_headers, columns=['Comment', 'Author', 'Date']).set_index('Date')
        post_title = submission.title
        c_table['Post_ID'] = post_ID
        c_table['Post_title'] = post_title
        holder = holder.append(c_table)
        
    return holder

# Get IDs of all relevant posts from CSV file
print "Extracting child comments from parent post list. This will take awhile..."
print 
child_comments = get_comments(ID_list)
pp.pprint(child_comments)
