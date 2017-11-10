# Task: Extract all Reddit data matching a keyword/ search parameter
# Date: 10 Nov 2017
# Creator: Valerie Lim

### Process outline 

# 1. Construct URL params for API query
# 2. Call API for json data
# 3. Extract list of post IDs from data
# 5. Extract comments and details for each post from its own post ID
# 6. Store comment data as csv file

# ---------------------------------------------------------------------------- #

# EDIT THIS PART!! 
# Fill in params for your search here :-)

### Rules:
# > Input any amount of words
# > Names are not case sensitive
# > Separate names with ,
# > Names must be wrapped with ''

keyword_input = ['jaguar',
                 'car',
                 'singapore'] 

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
# Execution -- DONT TOUCH THIS PART ONWARDS

pp = pprint.PrettyPrinter(indent=1, width=80)        
query = assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input)
post_ids = loop_through_reddit_for_post_ids(query)
comments = get_comments(post_ids)
comments.to_csv("pretty_json.csv", sep=',')

# ---------------------------------------------------------------------------- #
# 0. Functionality testing

def test_case(query, expected_output):
    if query == expected_output:
        status = "Function works."
    else:
        status = "Function doesn't return expected output."
    return status 

# ---------------------------------------------------------------------------- #
# 1. Construct query

def assemble_reddit_query(keyword_input, subreddits_input, time_input, 
                          sort_input, limit_input, after_input=None):

    keyword_list = "+".join(keyword_input)
    subreddits_list = "+".join(subreddits_input)

    # Labels (don't edit this)
    time_label = "&t="
    sort_label = "&sort="
    limit_label = "&limit="
    after_label = "&after="
    start = 'http://www.reddit.com/r/'
    middle = '/search.json?q='
    end = '&restrict_sr=TRUE' # search only this subreddit(s)

    # Assemble
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

# Test cases
# query = assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input)
# output = "http://www.reddit.com/r/Jaguar+Jaguars+cars+jaguarcars+carporn+cars+autos+spotted+formula1+classiccars+Shitty_Car_Mods/search.json?q=jaguar&t=all&sort=new&limit=9999999&restrict_sr=TRUE"
# query_b = assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input, after_input="t3_75ur03")
# output_b = "http://www.reddit.com/r/Jaguar+Jaguars+cars+jaguarcars+carporn+cars+autos+spotted+formula1+classiccars+Shitty_Car_Mods/search.json?q=jaguar&t=all&sort=new&limit=9999999&after=t3_75ur03&restrict_sr=TRUE"

# print test_case(query, output)
# print test_case(query_b, output_b)

# ---------------------------------------------------------------------------- #
# 2. Call API for post_ids that match query

import urllib2
import json
import yaml
import fileinput
import time 

def call_reddit(query):
    # Get data from API
    request = urllib2.Request(query)
    request.add_header('User-Agent', 'Chrome/61.0.3163.100 +http://diveintopython.org/')
    opener = urllib2.build_opener()  
    data = opener.open(request).read()
    return data

def safe_load(data):
    # Convert raw data from API call to json, remove utf-formatting
    data = json.loads(data)
    data = json.dumps(data)
    data = yaml.safe_load(data)
    return data

def save_to_text_file(variable, file_number):
    # Save variable to text file in home directory
    file_name = 'uglyjson_%s.txt' % (file_number)
    myfile = open(file_name, 'w' )
    myfile.write(variable)
    myfile.close()
    print "File has been saved as", file_name
    return file_name

def extract_ids(data):
    num_posts = len(data['data']['children']) 
    print "Number of posts in this search:", num_posts
    post_ids = []
    for post in range(num_posts):
        post_id = data['data']['children'][post]['data']['id']
        post_ids.append(post_id)
    return post_ids

def loop_through_reddit_for_post_ids(query):

    # >> calls API for data
    # >> Extracts all post IDs
    # >> Extracts key for "next" page
    # >> loops through all subsequent "next" pages to collect post IDs
    
    file_number = 1; print "Loop number", file_number
    data = call_reddit(query)
    data = safe_load(data)

    post_ids = extract_ids(data); print "Post ID extracted successfully."
    after_key = data['data']['after']; print after_key
    print
    
    while len(str(after_key))>=6:  # Legal key has at least 6 char
        file_number = file_number + 1; print "Loop number", file_number
        query = assemble_reddit_query(keyword_input, subreddits_input,
                                    time_input, sort_input, limit_input,
                                    after_input=after_key)
        data = call_reddit(query)
        data = safe_load(data)

        more_post_ids = extract_ids(data); print "Post ID extracted successfully."
        after_key = data['data']['after']; print after_key
        post_ids.append(more_post_ids)
        print  # line break

    return post_ids

# ---------------------------------------------------------------------------- #
# 3. Extract comments and details for each post ID

import praw
from praw.models import MoreComments

import requests
import requests.auth
import pandas as pd
import datetime
import pprint

# Passwords
Username = x
Password = x
Client_ID = x
Client_secret = x

# Auth
reddit = praw.Reddit(user_agent='Testing stuff for school project (by /u/lonely_dingleberry)',
                     client_id=Client_ID, client_secret=Client_secret,
                     username=Username, password=Password)

def get_date(submission):
    time = submission.created
    return datetime.datetime.fromtimestamp(time)
    # Source: https://www.reddit.com/r/learnprogramming/comments/37kr5n/praw_is_it_possible_to_get_post_time_and_date/

def get_comments(post_ids):

    # Extracts these information from a post:
    # >>>>> post title
    # >>>>> post ID
    # >>>>> child comments 
    # >>>>> author of child comment
    # >>>>> date created for each comment
    # Lastly: Bind as csv file 
    
    holder = pd.DataFrame()
    for post_ID in post_ids:

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
        post_title = submission.title

        c_table = pd.DataFrame(c_headers, columns=['Comment', 'Author', 'Date']).set_index('Date')
        c_table['Post_ID'] = post_ID
        c_table['Post_title'] = post_title
        holder = holder.append(c_table)
        
    return holder

# ---------------------------------------------------------------------------- #

