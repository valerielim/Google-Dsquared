# Date: 10 October 2017
# Aim: Set up Facebook API for specific calls

# ---------------------------------------------------------------------------- #
# 0: Authentication

# App = x
app_id = x
app_secret = x

# User ID = x
user_id = x

# Access tokens; expires 09 Dec 2017
user_access_token = x
app_access_token = x


# ---------------------------------------------------------------------------- #
# 1. Get API data

import facebook
import urllib3
import requests
import json
import yaml

import pprint
pp = pprint.PrettyPrinter(indent=2)

import os
path = 'C:\\Users\\valeriehy.lim\\Documents\\PythonDocs'
os.chdir(path)

# Download data: posts_grab
graph = facebook.GraphAPI(user_access_token)
posts_grab = graph.get_object(id="Grab", fields="posts.limit(2){comments}")
data = json.dumps(posts_grab)

# Save 'posts_grab' as file
input_file_name = 'uglyjson.txt'
myfile = open(input_file_name, 'w' )
myfile.write(data)
myfile.close()

# ---------------------------------------------------------------------------- #
# 2. Convert json data to csv file

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait 
from selenium.webdriver.support import expected_conditions as EC

# Load webpage
chrome = webdriver.Chrome()
chrome.get('https://json-csv.com/')

# Upload file
load_data = chrome.find_element_by_id('fileupload')
file_location = "%s\\%s" % (path, input_file_name)
load_data.send_keys(file_location)

# Wait for conversion to be complete
wait = WebDriverWait(chrome, 10)
import sys 
for i in xrange(10,0,-1): # Prints countdown from 10 9 8 ...
    time.sleep(1)
    sys.stdout.write(str(i)+' ')
    sys.stdout.flush()
wait.until(EC.element_to_be_clickable((By.ID, 'convert-another')))

# Download file 
chrome.find_element_by_css_selector("a#download-link.btn-lg.btn-success").click()
time.sleep(10) # To allow time to finish downloading
chrome.quit()
print "Csv file downloaded, location at DOWNLOADS folder."

# ---------------------------------------------------------------------------- #
# SYNTAX FOR OTHER API THINGS

##### Profile info
# profile = graph.get_object("me")
# print profile
# print friend_list

##### Friends list
# friends = graph.get_connections("me", "friends")
# friend_list = [friend['name'] for friend in friends['data']]

##### Events
# events = graph.request('/search?q=Poetry&type=event&limit=10')
# eventsList = events['data'][1]
 
### Other page info: Posts, comments
# posts_grab = graph.get_object(id="Grab", fields="posts{limit=10}")
# posts_comments_grab = graph.get_object(id="Grab", fields="posts.limit(3)")
# posts_comments_replies_grab = graph.get_object(id="Grab", 
# 				fields="posts.limit(3){comments{comments}}")

# ---------------------------------------------------------------------------- #
