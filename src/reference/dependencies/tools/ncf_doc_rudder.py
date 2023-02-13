#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Usage: ./ncf_doc_rudder.py
#
# This is a Python module to generate documentation from generic methods in ncf to be embedded in Rudder manual

import ncf
import requests
import sys
import re
from pprint import pprint

def slugify(s):
    s = "_" + s
    s = s.lower()
    s = s.strip()
    s = re.sub('\W', '_', s)
    return s

if __name__ == '__main__':
  # Get all generic methods
  generic_methods = ncf.get_all_generic_methods_metadata()["data"]["generic_methods"]
  
  categories = {}
  for method_name in sorted(generic_methods.keys()):
    category_name = method_name.split('_',1)[0]
    generic_method = generic_methods[method_name]
    if (category_name in categories):
      categories[category_name].append(generic_method)
    else:
      categories[category_name] = [generic_method]

  content = []
  titles = ["** xref:generic_methods.adoc[Generic methods]"]

  for category in sorted(categories.keys()):
    titles.append("*** xref:generic_methods.adoc#"+slugify(category.title())+"["+category.title()+"]")
    content.append('\n## '+category.title())
 
    # Generate markdown for each generic method
    for generic_method in categories[category]:
      bundle_name = generic_method["bundle_name"]
      content.append('\n### '+ bundle_name)
      content.append(generic_method["description"])
      if "deprecated" in generic_method:
        content.append('\n**WARNING**: This generic method is deprecated.')
        content.append(generic_method["deprecated"])
      
      if "documentation" in generic_method:
        content.append('\n#### Usage')
        content.append(generic_method["documentation"])
      content.append('\n#### Parameters')
      for parameter in generic_method["parameter"]:
        content.append("* **" + parameter['name'] + "**: " + parameter['description'])
      content.append('\n#### Classes defined')
      content.append('\n```\n')
      content.append(generic_method["class_prefix"]+"_${"+generic_method["class_parameter"] + "}_{kept, repaired, not_ok, reached}")
      content.append('\n```\n')

  # Write category list
  result = '\n'.join(titles)+"\n"
  outfile = open("generic_methods_categories.txt","w")
  outfile.write(result)
  outfile.close()

  # Write generic_methods.md
  result = '\n'.join(content)+"\n"
  outfile = open("generic_methods.md","w")
  outfile.write(result)
  outfile.close()
