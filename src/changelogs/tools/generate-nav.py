#!/usr/bin/env python

import os
import re
import sys

MODULE = sys.argv[1]
NAME = sys.argv[2]

MODULEDIR = "modules/"+MODULE
PAGESDIR = MODULEDIR+"/pages/"
TITLE = re.compile("^(=+) (.+)$")
ID = re.compile(r"^\[\[(.+),?.*\]\]$")

def remove_duplicate_underscore(string):
    prev = ' '
    res = []
    for char in string:
        if prev == '_' and char == '_':
            pass
        else:
            res.append(char)
        prev = char
    return ''.join(res)

# reproduce asciidoc's behavior
def slugify(s):
    s = "_" + s
    s = s.lower()
    s = s.strip()
    s = re.sub('\W', '_', s)
    s = remove_duplicate_underscore(s)
    s = s.rstrip('_')
    return s

# Get all standalone .adoc pages, sorted alphanumerically
# We exclude files in root (the index of the doc), _partials which are not actual pages

with open(MODULEDIR + "/nav.list") as f:
    files = f.read().splitlines()
#files = sorted([file for root, dirs, files in os.walk('.') for file in files if file.endswith(".adoc") and not "_partials" in root])
#files = sorted([root.split('/', 1)[-1]+"/"+file for root, dirs, files in os.walk('.') for file in files if file.endswith(".adoc") and not "_partials" in root])

result = ["// Automatically generated list of content - do not edit", "* "+NAME]

os.chdir(PAGESDIR)

for file in files:
    with open(file) as f:
        content = f.read().splitlines()

    prev = ""
    first = True
    for line in content:
        search_title = TITLE.search(line)
        if search_title:
            level = search_title.group(1).count("=") + 1
            title = search_title.group(2)
            search_id = ID.search(prev)
            if search_id:
                page_id = search_id.group(1)
            else:
                page_id = slugify(title)
            if level < 4:
                if first:
                    result.append("*" * level + " xref:" + file + "[" + title + "]")
                    first = False
                else:
                    result.append("*" * level + " xref:" + file + "#" + page_id + "[" + title + "]")
        prev = line

print("\n".join(result))
