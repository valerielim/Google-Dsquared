# Date: 10 October 2017
# Aim: Set up Facebook API for specific calls

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
# posts_comments_replies_grab = graph.get_object(id="Grab", fields="posts.limit(3){comments{comments}}")

# ---------------------------------------------------------------------------- #
# Load workspace settings

import facebook
import urllib3
import requests
import json
import csv
import yaml
import fileinput

import pprint
pp = pprint.PrettyPrinter(indent=2)

# Deal with utf-8 problems
import sys
stdin, stdout, stderr = sys.stdin, sys.stdout, sys.stderr
reload(sys)
sys.stdin, sys.stdout, sys.stderr = stdin, stdout, stderr
sys.setdefaultencoding('utf-8')

# ---------------------------------------------------------------------------- #
# Passwords

# App = purpletag
app_id = "x"
app_secret = "x"
user_id = "x"

# Access tokens; expires 09 Dec 2017
user_access_token = "x"
app_access_token = "x|x"

# ---------------------------------------------------------------------------- #
# Get data

# Download data: posts_grab
graph = facebook.GraphAPI(user_access_token)
posts_grab = graph.get_object(id="Grab", fields="posts.limit(2){comments}")

# Save 'posts_grab' as file
input_file_name = 'uglyjson.txt'
output_file_name = 'prettyjson.csv'

myfile = open(input_file_name, 'w' )
myfile.write(repr(posts_grab))
myfile.close()

# Reload txt file as json
clean_data = json.dumps(posts_grab)
clean_data = yaml.safe_load(clean_data) # dict

# ---------------------------------------------------------------------------- #
# Format post data

##with open(output_file_name, 'wb') as csvfile:
##	spamwriter = csv.writer(csvfile, delimiter=',',
##                            quotechar='"', quoting=csv.QUOTE_MINIMAL)
##	titles = (['id', 'created_time', 'message', 'id', 'after', 'before', 'next'])
##	spamwriter.writerow ( titles )
##	spamwriter.writerow([data['id'],
##                        data['posts']['data'][0]['created_time'],
##                        data['posts']['data'][0]['message'],
##                        data['posts']['data'][0]['id'],
##                        data['posts']['paging']['cursors']['after'],
##                        data['posts']['paging']['cursors']['before'],
##                        data['posts']['paging']['next']])
##	spamwriter.writerow([data['id'],
##                        data['posts']['data'][1]['created_time'],
##                        data['posts']['data'][1]['message'],
##                        data['posts']['data'][1]['id'],
##                        data['posts']['paging']['cursors']['after'],
##                        data['posts']['paging']['cursors']['before'],
##                        data['posts']['paging']['next']])
##	spamwriter.writerow([data['id'],
##                        data['posts']['data'][2]['created_time'],
##                        data['posts']['data'][2]['message'],
##                        data['posts']['data'][2]['id'],
##                        data['posts']['paging']['cursors']['after'],
##                        data['posts']['paging']['cursors']['before'],
##                        data['posts']['paging']['next']])
##	csvfile.close()

# ---------------------------------------------------------------------------- #
# Format comments, 1 layer

with open(output_file_name, 'wb') as csvfile:
	spamwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='"', quoting=csv.QUOTE_MINIMAL)
        # header
	titles = ([clean_data.keys()[0], #'id'
                   clean_data['posts']['data'][0]['comments']['data'][1].keys()[0], # created_time,
                   clean_data['posts']['data'][0]['comments']['data'][1].keys()[1], # message,
                   # clean_data['posts']['data'][0]['comments']['data'][1].keys()[2], # from (name)
                   clean_data['posts']['data'][0]['comments']['data'][1].keys()[3], # (message) id,
                   clean_data['posts']['data'][0]['comments']['data'][1]['from'].keys()[0], # name
                   clean_data['posts']['data'][0]['comments']['data'][1]['from'].keys()[1], # id (user id)
                   clean_data['posts']['paging']['cursors'].keys()[0], # after
                   clean_data['posts']['paging']['cursors'].keys()[1], # before
                   clean_data['posts']['paging'].keys()[1]]) # next
	spamwriter.writerow ( titles )

	# body

	comment = clean_data['posts']['data'][0]['comments']['data']
	after = clean_data['posts']['paging']['cursors']['after']
	before = clean_data['posts']['paging']['cursors']['before']
	nextlink = clean_data['posts']['paging']['next'] # next is reserved key

	for i in range(len(comment)):
            spamwriter.writerow([clean_data['id'],
                                comment[i]['created_time'],
                                comment[i]['message'],
                                comment[i]['id'],
                                comment[i]['from']['name'],
                                comment[i]['from']['id'],
                                after,
                                before,
                                nextlink])
	csvfile.close()

# ---------------------------------------------------------------------------- #
# Keep getting posts/comments 

# Get link for second page
# first_page = graph.get_object(id="Grab", fields="posts.limit(2){comments}")

second_page = requests.get(clean_data['posts']['paging']['next']).json()

# Reload txt file as json
clean_data = json.dumps(second_page)
clean_data = yaml.safe_load(clean_data) # dict

# Append second page data to first page csv

with open('prettyjson.csv', 'ab') as csvfile:
	spamwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='"', quoting=csv.QUOTE_MINIMAL)

        # body
	comment = clean_data['data'][0]['comments']['data']
	after = clean_data['paging']['cursors']['after']
	before = clean_data['paging']['cursors']['before']
	nextlink = clean_data['paging']['next'] # next is reserved key

	for i in range(len(comment)):
            spamwriter.writerow(["filler", #[comment['id'], # irrelevant, remove. 
                                comment[i]['created_time'],
                                comment[i]['message'],
                                comment[i]['id'],
                                comment[i]['from']['name'],
                                comment[i]['from']['id'],
                                after, 
                                before, 
                                nextlink])
	csvfile.close()

ad.close()

# Build loop over this
# Teach script to stop at a certain date

# ---------------------------------------------------------------------------- #

friends = graph.get_connections("me","friends")

allcomments = []

# https://stackoverflow.com/questions/28589239/python-facebook-api-cursor-pagination
# Wrap this block in a while loop so we can keep paginating requests until
# finished.
while(True):
    try:
        for comment in posts_grab['data']:
            allcomments.append(comment['name'].encode('utf-8'))
        # Attempt to make a request to the next page of data, if it exists.
        friends=requests.get(friends['paging']['next']).json()
    except KeyError:
        # When there are no more pages (['paging']['next']), break from the
        # loop and end the script.
        break
print allfriends

