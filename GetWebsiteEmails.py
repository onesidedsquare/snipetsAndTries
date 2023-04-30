import requests
import re
from urllib.parse import urljoin, urlparse

def getEmailsOnPage(url):
    response = requests.get(url)
    emailPattern = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
    emails = re.findall(emailPattern, response.text)
    return set(emails)

def getLinksFromPage(url):
    response = requests.get(url)
    linkPattern = r'href=["\']([^"\']+)["\']'
    links = re.findall(linkPattern, response.text)
    links = [urljoin(url, link) for link in links]
    return set(links)

def getEmails(url):
    visitedURLS = set()
    emails = set()
    queue = [url]

    while queue:
        url = queue.pop(0)

        if url in visitedURLS:
            continue

        visitedURLS.add(url)

        try:
            links = getLinksFromPage(url)
            emails |= getEmailsOnPage(url)
        except Exception as e:
            print(f"Error crawling {url}: {e}")
            continue

        for link in links:
            parsedLink = urlparse(link)
            parsedUrl = urlparse(url)

            if parsedLink.netloc == parsedUrl.netloc:
                queue.append(link)
                print(link)

    return emails

# Example usage
url = input("Enter Website to crawl path: ")
emails = getEmails(url)
print(emails)
