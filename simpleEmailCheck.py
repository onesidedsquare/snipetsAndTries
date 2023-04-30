import re
import requests

url = input("Enter Webpage to check: ")
response = requests.get(url)

email_pattern = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
emails = re.findall(email_pattern, response.text)

for email in set(emails):
    print(email)
