#!/usr/bin/env python3

import requests
import json
from bs4 import BeautifulSoup

URL = 'https://jqlang.github.io/jq/manual/'

def main(url):
    response = requests.get(url)
    if response.status_code != 200:
        print(f"Error {response.status_code}: Unable to fetch the webpage.")
        return []

    soup = BeautifulSoup(response.content, 'html.parser')
    for section in soup.find_all('section'):
        h = section.select_one('h2,h3')
        h.find_next('a').decompose()
        # txt = h.get_text().strip()
        # a = h.find_next('a')
        # a.string = txt
        
    doc = soup.find('main')
    sections = soup.find('script', { 'id': 'section-ids' }).text
    return sections, doc


if __name__ == "__main__":
    import sys
    out = sys.argv[1]
    sections, doc = main(URL)
    with open(out, "w") as f:
    	f.write(str(doc))
    with open(sys.argv[2], "w") as f:
    	f.write(json.dumps(json.loads(sections)))
    # print(sections)
