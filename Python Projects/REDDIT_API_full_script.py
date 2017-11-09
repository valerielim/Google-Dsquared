# Task: Extract all Reddit data matching a keyword/ search parameter
# Date: ?? Nov 2017
# Creator: Valerie Lim

### Process outline 

# 1. Construct URL params for API query
# 2. Call API for json data
# 3. Convert json data to csv file
# 4. Clean csv file to get list of post IDs
# 5. Extract comments and details for each post ID
# 6. Store comment data as csv file. 

# ---------------------------------------------------------------------------- #

# Input your stuff here!!
# Don't edit the rest

### Section 1 Rules:
# > Input any amount of words
# > Names are not case sensitive
# > Separate names with ,
# > Names must be wrapped with ''

keyword_input = ['jaguar',
                 'car'] 
subreddits_input = ['Jaguar', 
                    'Jaguars',
                    'cars',
                    'jaguarcars',
                    'carporn',
                    'cars',
                    'autos',
                    'spotted',
                    'formula1',
                    'classiccars',
                    'Shitty_Car_Mods']

### Section 2 Rules:
# > Only one selection allowed
# > Selection must be wrapped with ''

time_input = 'all' # day, week, month, year, all
sort_input = 'new' # new, top, hot, rising, controversial
limit_input = '9999999' # default: maximum

# ---------------------------------------------------------------------------- #





# ---------------------------------------------------------------------------- #
# 0. Functionality testing

def test_case(query, expected_output):
    if query == expected_output:
        status = "Function works."
    else:
        status = "Function doesn't return expected output."
    return status 

# ---------------------------------------------------------------------------- #
# 1. Construct URL params for API query

import os
path = 'C:\\Users\\valeriehy.lim\\Documents\\PythonDocs'
os.chdir(path)

# Function to assemble reddit query; do not edit
def assemble_reddit_query(keyword_input, subreddits_input, time_input, 
                          sort_input, limit_input, after_input=None):

    # Join items in list up
    keyword_list = "+".join(keyword_input)
    subreddits_list = "+".join(subreddits_input)

    # Labels (don't edit this)
    time_label = "&t="
    sort_label = "&sort="
    limit_label = "&limit="
    after_label = "&after="
    
    # Frame (don't edit this)
    start = 'http://www.reddit.com/r/'
    middle = '/search.json?q='
    end = '&restrict_sr=TRUE' # search only this subreddit(s)

    if after_input is None: 
        full_link = "%s%s%s%s%s%s%s%s%s%s%s" % (start,
        subreddits_list, middle, keyword_list, time_label, time_input,
        sort_label, sort_input, limit_label, limit_input, end)
    else:
        full_link = "%s%s%s%s%s%s%s%s%s%s%s%s%s" % (start,
        subreddits_list, middle, keyword_list, time_label, time_input,
        sort_label, sort_input, limit_label, limit_input,
        after_label, after_input, end)
    return full_link

query1 = assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input)
output1 = "http://www.reddit.com/r/Jaguar+Jaguars+cars+jaguarcars+carporn+cars+autos+spotted+formula1+classiccars+Shitty_Car_Mods/search.json?q=jaguar&t=all&sort=new&limit=9999999&restrict_sr=TRUE"

query2 = assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input, after_input="t3_75ur03")
output2 = "http://www.reddit.com/r/Jaguar+Jaguars+cars+jaguarcars+carporn+cars+autos+spotted+formula1+classiccars+Shitty_Car_Mods/search.json?q=jaguar&t=all&sort=new&limit=9999999&after=t3_75ur03&restrict_sr=TRUE"

# print test_case(query1, output1)
# print test_case(query2, output2)

# ---------------------------------------------------------------------------- #
# 2. Call API for json data

import urllib2
import json
import yaml
import fileinput
import time 

def call_reddit(query):
    # Get data
    request = urllib2.Request(query)
    request.add_header('User-Agent', 'Chrome/61.0.3163.100 +http://diveintopython.org/')
    opener = urllib2.build_opener()
    print "Calling API, please wait..."
    data = opener.open(request).read()

    # Convert data
    data = json.loads(data)
    data = json.dumps(data)
    data = yaml.safe_load(data)
    print "# >>> Reddit data has been retrieved."
    return data

def save_to_text_file(variable, file_number):
    # Saves json string to .txt file inside your home directory. 
    file_name = 'uglyjson_%s.txt' % (file_number)
    myfile = open(file_name, 'w' )
    myfile.write(repr(variable))
    myfile.close()
    print "# >>> File has been saved as", file_name
    return file_name

def loop_through_all_reddit_pages(query):
    # Loops through all pages of reddit query, stores each page as new .txt json file.
    print "BEGIN RETRIEVAL PROCESS"
    print 
    file_number = 1
    print query
    data = call_reddit(query)
    file_name = save_to_text_file(variable=data, file_number=file_number)
    print
    
    # Save all text filenames for later to convert them to csv
    file_names = []
    file_names.append(file_name)
    after_key = data['data']['after']
    
    # ALL OTHER PASSES
    while len(str(after_key))>=6: # A legal post key has at least 6 char
        file_number = file_number + 1
        print "Loop number", file_number
        query = assemble_reddit_query(keyword_input, subreddits_input,
                          time_input, sort_input, limit_input, after_input=after_key)
        data = call_reddit(query)
        file_name = save_to_text_file(variable=data, file_number=file_number)
        file_names.append(file_name)
        after_key = data['data']['after']
        print 
    print "END PROCESS."
    return file_names

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
Username = x
Password = x
Client_ID = x
Client_secret = x

# Auth
print "Preparing reddit authentication to extract comment details per post..."
reddit = praw.Reddit(user_agent='x (by /u/lonely_dingleberry)',
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
print "Extracting child comments from parent post list of", num_IDs, "posts. This will take awhile..."
print 
child_comments = get_comments(ID_list)
pp.pprint(child_comments)
