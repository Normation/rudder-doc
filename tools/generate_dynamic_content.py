#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Usage: ./generate_info.py
#
# This is a Python module to generate html code for the manual.
# The parameter is the manual beeing built.

import requests
import sys
import re
from distutils.version import StrictVersion
from pprint import pprint

beginning = """<xsl:stylesheet        
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://docbook.org/ns/docbook"
        xmlns:exsl="http://exslt.org/common"
        xmlns:ng="http://docbook.org/docbook-ng"
        xmlns:db="http://docbook.org/ns/docbook"
        version="1.0" xmlns="http://www.w3.org/1999/xhtml"
	      exclude-result-prefixes="exsl ng db d">"""

end = "</xsl:stylesheet>"

# URL of the rudder_info api
release_info_url = "http://www.rudder-project.org/release-info/rudder/"

def api_bool_to_boolean(api_response):
    return api_response.lower() == "true"

def get_current_version_info(manual_version):

  info = {}
  info["version"] = manual_version

  try:
    info["supported"] = api_bool_to_boolean(requests.get(release_info_url + "versions/" + manual_version + "/supported").content.decode('ascii'))
    info["release-status"] = requests.get(release_info_url + "versions/" + manual_version + "/release-status").content.decode('ascii')
    info["release-date"] = requests.get(release_info_url + "versions/" + manual_version + "/release-date").content.decode('ascii')
    info["eol-date"] = requests.get(release_info_url + "versions/" + manual_version + "/eol-date").content.decode('ascii')
    info["lts"] = api_bool_to_boolean(requests.get(release_info_url + "versions/" + manual_version + "/lts").content.decode('ascii'))
  except requests.exceptions.RequestException as e:
    print(e)
    sys.exit(1)

  return info

def get_versions():
  "Get a list of all versions"
  
  versions = []
  
  try:
    raw_versions = requests.get(release_info_url + "versions").content.decode('ascii').splitlines()
  except requests.exceptions.RequestException as e:
    print(e)
    sys.exit(1)
  
  raw_versions.sort(key=StrictVersion)

  for rudder_version in raw_versions:
    versions.append(get_current_version_info(rudder_version))

  return versions

def format_index(version_info, template):

  return template.format(rudder_version = version_info["version"])

def format_header(versions, manual_version):
  
  output = []
  versions_output = []
  first = True
  found = False

  output.append("""<xsl:template name="otherlinks">
    <div id="otherlinks">
      <span>Resources:
        <strong>User manual</strong> |
        <a href="http://faq.rudder-project.org/">FAQ</a> |
        <a href="http://www.rudder-project.org/changelog-{$rudder.version}">Changelog</a> |
        <a href="http://www.rudder-project.org/rudder-api-doc/">API reference</a>
      </span>
      <span>Version: """)
  
  for version_info in versions:
    current_version = version_info["version"]

    if version_info["lts"]:
      esr_text = " ESR"
    else:
      esr_text = ""

    if version_info["release-status"] not in ["final", "rc"]:
      release_text = "-dev"
    else:
      release_text = ""

    if current_version == manual_version:
      found = True
      versions_output.append("<strong>" + manual_version + release_text + esr_text + "</strong>")
    else:
      if version_info["supported"]:
        versions_output.append("<a href=\"http://www.rudder-project.org/doc-" + current_version + "/\">" + current_version + esr_text + "</a>")
  
  # Unknown version
  if not found:
    versions_output.append("<strong>" + manual_version + "-dev </strong>")

  output.append(" | \n".join(versions_output))

  output.append("""</span>
    <xsl:choose>
      <xsl:when test="$webhelp.embedded != '1'">
        <span>Download as: <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.epub">epub</a> | <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.pdf">pdf</a></span>
      </xsl:when>
      <xsl:otherwise>
        <span>Download as: <a href="http://www.rudder-project.org/rudder-doc-{$rudder.version}/rudder-doc.epub">epub</a> | <a href="rudder-doc.pdf">pdf</a></span>
      </xsl:otherwise>
    </xsl:choose>
    </div>
    </xsl:template>""")

  return "".join(output) + "\n"
  

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("usage: sys.argv rudder_version xsl_path")
    sys.exit(1)

  # Write header file
  versions = get_versions()

  header_file = open(sys.argv[2] + "/links.xsl", "w")
  header_file.write(beginning)
  header_file.write(format_header(versions, sys.argv[1]))
  header_file.write(end)
  header_file.close()

  version_info = get_current_version_info(sys.argv[1])

  # Write index file
  template_file = open(sys.argv[2] + "/index.html.tpl", "r")
  template = template_file.read()
  template_file.close()

  index_file = open(sys.argv[2] + "/index.html", "w")
  index_file.write(format_index(version_info, template))
  index_file.close()


  
