
# Task: Automatically convert ugly json file using json-csv.com
# To convert json to csv file //
# To extract list of IDs 

# pip install selenium first
# install chromedriver.exe too

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait 
from selenium.webdriver.support import expected_conditions as EC

chrome = webdriver.Chrome()
chrome.get('https://json-csv.com/');

# Load data
load_data = chrome.find_element_by_id('fileupload')
load_data.send_keys('C:\\Users\\valeriehy.lim\\Documents\\PythonDocs\\uglyjson.txt')
# load_data.submit()

# Download result
time.sleep(10) 
get_results = chrome.find_element_by_id('download-link')
get_results.click()
chrome.quit()

# -------------------------------------------------------------------- # 
# Shit that doesn't work

# From documentation: 
##wait = WebDriverWait(chrome, 10)
##get_result = wait.until(EC.element_to_be_clickable((By.ID, 'download-link')))
##get_result.click()
##chrome.quit()

#

# From blog:
##old_value = chrome.find_element_by_id('fileupload')
##old_value.click()
##WebDriverWait(chrome, 6).until(
##    EC.text_to_be_present_in_element(
##        (By.ID, 'download-link'),
##        'download-link'
##    )
##)

#

# SO: 
##from selenium.webdriver.support import expected_conditions as EC
##wait.until(ExpectedConditions.presenceOfElementLocated(By.id('download-link')))
##get_results.click()

#

# Source: https://stackoverflow.com/questions/26566799/how-to-wait-until-the-page-is-loaded-with-selenium-for-python
##get_results = chrome.find_element_by_id('download-link')
##delay = 3 # seconds
##try:
##    get_results = WebDriverWait(chrome, delay).until(
##        EC.presence_of_element_located((By.ID, 'download-link'))
##        )
##    print "Page is ready!"
##except TimeoutException:
##    print "Loading took too much time!"
##
## ElementNotVisibleException: Message: element not visible
##get_results.click()
