# Title: Reddit API
# Date created: 25 Oct 2017

import praw
import requests
import requests.auth
import pandas as pd
from praw.models import MoreComments

# Passwords
Username = x
Password = x
Client_ID = x
Client_secret = x

# Auth
reddit = praw.Reddit(user_agent='Noob learning stuff, pls help (by /u/lonely_dingleberry)',
                     client_id=Client_ID, client_secret=Client_secret,
                     username=Username, password=Password)

# Date
import datetime
def get_date(submission):
    time = submission.created
    return datetime.datetime.fromtimestamp(time)
    # Source: https://www.reddit.com/r/learnprogramming/comments/37kr5n/praw_is_it_possible_to_get_post_time_and_date/


def get_comments(ID_list):

    # Empty df to hold comments
    holder = pd.DataFrame()

    # Extract comment, author and date for each post
    for post_ID in ID_list:
        submission = reddit.submission(id=post_ID)
        submission.comments.replace_more(limit=0)
        c_comments = []
        c_authors = []
        c_date = []
        for comment in submission.comments.list():
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
ID_list = ['1gsdj9', '70s99c', '358af2']
print get_comments(ID_list)

# -------------------------------------------------------------------- #
# Alt method for auth

# Auth
client_auth = requests.auth.HTTPBasicAuth(Client_ID, Client_secret)
post_data = {"grant_type": "password",
             "username": Username,
             "password": Password}
headers = {"User-Agent": "ChangeMeClient/5.2.0 by YourUsername"}
response = requests.post("https://www.reddit.com/api/v1/access_token",
                         auth=client_auth, data=post_data, headers=headers)

# API Key
a = response.json()
key = a['access_token']

# Info about me
headers = {"Authorization": "bearer %s" % (key),
           "User-Agent": "ChangeMeClient/0.1 by YourUsername"}
response = requests.get("https://oauth.reddit.com/api/v1/me",
                        headers=headers); pp.pprint(response.json())
Get comments from one post from a subreddit
response = requests.get("https://oauth.reddit.com/r/askreddit/coments/id=32rc86/",
                     headers=headers); pp.pprint(response.json())


# -------------------------------------------------------------------- #

# Auth
reddit = praw.Reddit(client_id=Client_ID,
                 client_secret=Client_secret,
                 password=Password,
                 user_agent='DataExtraction by /u/lonely_dingleberry',
                 username='Username')

# Others
submissions = reddit.get_subreddit('opensource').get_hot(limit=5)

[str(x) for x in submissions]

submission = reddit.submission(url='https://www.reddit.com/r/funny/comments/3g1jfi/buttons/')


