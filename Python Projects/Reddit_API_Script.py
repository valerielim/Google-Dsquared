# Title: Reddit API
# Date created: 25 Oct 2017

import praw
import requests
import requests.auth

import pprint
pp = pprint.PrettyPrinter(indent=2)

# Passwords
Username = 'lonely_dingleberry'
Password = 'Passw0rd!1'
Client_ID = 'cOuv_433uGowhg'
Client_secret = 'Lck5D8FGEiDyrngC6_mgODA5yXU'

# Auth
##client_auth = requests.auth.HTTPBasicAuth(Client_ID, Client_secret)
##post_data = {"grant_type": "password",
##             "username": Username,
##             "password": Password}
##headers = {"User-Agent": "ChangeMeClient/5.2.0 by YourUsername"}
##response = requests.post("https://www.reddit.com/api/v1/access_token",
##                         auth=client_auth, data=post_data, headers=headers)
##a = response.json()
##print a


### Get basic profile info
##key = a['access_token']
##print "Info about me:"
##print
##headers = {"Authorization": "bearer %s" % (key),
##           "User-Agent": "ChangeMeClient/0.1 by YourUsername"}
##response = requests.get("https://oauth.reddit.com/api/v1/me",
##                        headers=headers); pp.pprint(response.json())

# Get subreddit info
reddit = praw.Reddit(user_agent='Comment Extraction (by /u/lonely_dingleberry)',
                     client_id=Client_ID, client_secret=Client_secret,
                     username=Username, password=Password)

submission = reddit.submission(url='https://www.reddit.com/r/funny/comments/3g1jfi/buttons/')
from praw.models import MoreComments
for top_level_comment in submission.comments:
    if isinstance(top_level_comment, MoreComments):
        continue
    print(top_level_comment.body)


    
# Get comments from one post from a subreddit
# response = requests.get("https://oauth.reddit.com/r/askreddit/coments/id=32rc86/",
#                         headers=headers); pp.pprint(response.json())

# Second method
# Auth
##reddit = praw.Reddit(client_id=Client_ID,
##                     client_secret=Client_secret,
##                     password=Password,
##                     user_agent='DataExtraction by /u/lonely_dingleberry',
##                     username='Username')

# Others
##submissions = reddit.get_subreddit('opensource').get_hot(limit=5)

##[str(x) for x in submissions]

##
##submission = reddit.submission(url='https://www.reddit.com/r/funny/comments/3g1jfi/buttons/')
##submission = reddit.submission(url='https://www.reddit.com/r/funny/comments/3g1jfi/buttons/')

print "Ok done."
