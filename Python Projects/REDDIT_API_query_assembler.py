# Task: Assemble custom API query of relevant posts matching keyword
# Date: 2 November 2017

# Search keywords
keyword_input = ['jaguar']
keyword_list = "+".join(keyword_input)
print "Keyword is:", keyword_list

# Subreddit input
subreddits_label = "subreddit:"
subreddits_input = ['Jaguar', 'Jaguars', 'cars', 'jaguarcars', 'carporn', 
                'cars', 'autos', 'spotted', 'formula1', 'classiccars',
                'Shitty_Car_Mods'] # Not case sensitive
subreddits_list = "+".join(subreddits_input)
print "Subreddits are:", subreddits_list

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
