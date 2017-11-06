# Task: Assemble custom API query of relevant posts matching keyword
# Date: 2 November 2017

# ---------------------------------------------------------------------------- #

# Input your stuff here!! 
# Leave everything in ''
# Include everything in the square brackets []

keyword_input = ['jaguar']
subreddits_input = ['Jaguar', 'Jaguars', 'cars', 'jaguarcars', 'carporn', 
                'cars', 'autos', 'spotted', 'formula1', 'classiccars',
                'Shitty_Car_Mods']

# TIME options: //hour, day, week, month, year, all//
# SORT options: //relevance, hot, top, new, comments//
# LIMIT options: must be digits

time_input = "all"
sort_input = "new"
limit_input = "9999999" # default: maximum

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
    print "# ---------------------------------- #" 
    print "Reddit query is", full_link
    print "# ---------------------------------- #"
    return full_link


# Test functions:
# assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input)
# assemble_reddit_query(keyword_input, subreddits_input, time_input, sort_input, limit_input, after_input="abcdefg")

# ---------------------------------------------------------------------------- #
# 2. Call API for json data

import urllib2
import json
import yaml
import fileinput

def call_reddit(query):
    response = urllib2.urlopen(query)
    response.addheaders = [('User-agent 123109821', 'Chrome/2.0')]
    data = json.load(response)
    clean_data = json.dumps(data)
    return clean_data

def save_to_text_file(variable, file_number):
    file_name = 'uglyjson_%s.txt' % (file_number)
    myfile = open(file_name, 'w' )
    myfile.write(variable)
    myfile.close()
    print "File has been saved as", file_name
    return file_name

def loop_through_all_reddit_pages():

    # FIRST PASS
    # Call and store data
    file_number = 1
    reddit_query = assemble_reddit_query(keyword_input, subreddits_input,
                time_input, sort_input, limit_input)
    print "Query submitted"
    
    data = call_reddit(reddit_query)
    print "Data collected"
    
    file_name = save_to_text_file(variable=data, file_number=file_number)
    print "File #", file_number, "saved. File name:", file_name

    # Save file names for later to convert them to json
    file_names = []
    file_names = file_names.append(file_name)
    print "File name appended."
    
    # Extract after key, append to list
    clean_data = yaml.safe_load(data)
    after_key = clean_data['data']['after']
    print "After-key collected. After key is:", after_key
    
    # ALL OTHER PASSES
    print "# ------------------------------------------------ #"
    print "Begin looping."
    while after_key != "null":
        reddit_query = assemble_reddit_query(keyword_input, subreddits_input,
                          time_input, sort_input, limit_input, after_input=after_key)
        print "Query submitted."
        data = call_reddit(reddit_query)
        print "Query loaded."
        file_name = save_to_text_file(variable=data, file_number=file_number)
        print "Query saved."
        file_names = file_names.append(file_name)
        print "File names have been stored:", file_names

        # Extract after key
        clean_data = yaml.safe_load(data)
        after_key = clean_data['data']['after']
        print "After-key collected. The key is:", after_key
        
        file_number = file_number + 1
        print "Done, file number", file_number, "saved as", file_name
        
    print "End looping."
    print "# ------------------------------------------------ #"
    print file_names 
    return file_names


# Problem with RATE LIMITING


