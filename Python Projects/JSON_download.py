# Date: 31 Oct 2017
# Description: Download JSON from URL, store as txt file 

import urllib2
import json
import yaml
import fileinput

response = urllib2.urlopen('https://www.reddit.com/search.json?q=jaguar')
data = json.load(response)
clean_data = json.dumps(data)
clean_data = yaml.safe_load(clean_data) # a long dict

# Save as file
input_file_name = 'uglyjson.txt'
myfile = open(input_file_name, 'w' )
myfile.write(clean_data)
myfile.close()
